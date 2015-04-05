Seven Reminder Retrospective
===

1. 発生した事象
---

### 1.1. Dockerポート公開ができないように見えた

Docker Port公開 + Rails 4.x したのに、なぜかPortが公開されない
→ Rails 4.xのrails sの仕様が変更になって、ローカルしか見えなくなったから

### 1.2. 複数のDockerMachineを起動しているとポート番号が入れ替わって使えなくなった。

DockerMachine でなぜか、ポート番号が入れ替わった。ポート番号が入れ替わると、Certに弾かれて、dockerコマンドが使えなくなる。どこかにポートの指定があるので入れ替えればよいと思ったが、そこをまだ見つけていない。DockerMachineのソースを読むべきかも

```
$ docker-machine ls
NAME        ACTIVE   DRIVER       STATE     URL                         SWARM
dev         *        virtualbox   Running   tcp://192.168.99.101:2376   
seven-dev            virtualbox   Running   tcp://192.168.99.100:2376   

$ eval "$(docker-machine env dev)"
$ docker ps
2015/04/03 22:56:25 Get https://192.168.99.101:2376/v1.15/containers/json: x509: certificate is valid for 192.168.99.100, not 192.168.99.101
```

### 1.3. therubyracer + libv8で突然こけるようになった

今まで何の問題もなく通っていたbundle installがtherubyrace + libv8で突然こけるようになった。原因を調べると、chefDKを入れると、ruby 2.1.4であり、[Yosemite で libv8 と therubyracer をインストールする](http://3.1415.jp/d3wpyqjr)で報告されているOSバージョンがruby 2.2.0(rbenv)の時と異なるため、本来はこのrubyのバージョンだと、therubyracer+libv8は3.11.8.3 + 0.11.0でないと通らない。そのケースだと、オプションをつけてgem installを行う必要がある。MacのOS自体は14 + 3.16.14.7のバージョンなので、このバージョンならオプションをつけずに実行できる。ruby 2.2.0ならそれで通るので、ruby 2.2.0に変更することにした。これは、dockerのコンテナもそのバージョンを使っているから。

### 1.4. docker + serverspecが動作しない

```
  1) Package "nodejs" should be installed
     Failure/Error: it {should be_installed}
     Docker::Error::NotFoundError:
       Expected([200, 201, 202, 203, 204, 304]) <=> Actual(404 Not Found)
       
     # ./serverspec/rails_spec.rb:8:in `block (2 levels) in <top (required)>'

Finished in 3.56 seconds (files took 0.39923 seconds to load)
1 example, 1 failure
```

全く意味不明だが、実行の部分でこけてるので、ふと思いついてsleepを入れてみる。

```
Failures:

  1) Package "nodejs" should be installed
     Failure/Error: it { should be_installed }
     Docker::Error::ServerError:
       Container ee7a2f990f568912f8aa6ed00d79c5a745b3529d7c9e4b73055f79b2ae9376e3 is not running
       
     # ./serverspec/rails_spec.rb:8:in `block (2 levels) in <top (required)>'

Finished in 3.23 seconds (files took 0.39279 seconds to load)
1 example, 1 failure

```
ここからコードを読んでいくと、コンテナが起動していないらしい。手動でdocker runするとこけた。。。


と思いきやimageがbundlerでこけていた。docker log container_nameでログを見て
発見できた。そのほかには、specinfraのdockerの部分にログを入れて、動作を確認してみると、
イメージが起動していないことがわかった。手でイメージを起動しようとしたら、実は動かなかった。イメージが動くのを確認 -> Gemfileにserverspecを追加してbundle install -> イメージのbuildというのをやったが、bundle installがdocker内ではこけていた様子。

### 1.5. 原因

Native extensionでこけまくる原因はChefDKのrubyのバージョンがじゃっかん古く、[Yosemite で libv8 と therubyracer をインストールする](http://3.1415.jp/d3wpyqjr)でお話されている、OSバージョンが、本来のOS(Yosemite)のOSバージョンと、rubyのOSバージョンが異なってくるため、面倒くさいことになっているっぽい。chefでazureのプラグインを入れた時もnative extensionでこけていた。

よって、ChefDKのrubyは一旦外して様子を見ることにした。

2. 発生した現象と学び
---

### 2.1. Asset Pipeline, SaSS, Less, Coffee script

これらの関係がよくわからなかった。それぞれがどういう概念なのだろうか？

[The Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html)

JavaScriptのアセットを、結合したり、最小化したりするためのフレームワーク。CoffeScript、SaSS, Less そしてERBとかと組み合わせて使う。

ちなみにRailsを`--skip-spockets`オプションをつけて作成すると、AssetPipelineをスキップできる。

プロダクションフェーズでは、MD5のフィンガープリントをファイルを追加してキャッシュを効かせるようにできる。

fingerprintingは、プロダクションで有効で、`config.assets.digest`オプションで、enable, disableに設定可能です。

アセットパイプラインは、jsを一つのファイルにまとめるらしい（それが、また問題を引き起こすケースがあるとのこと）

プロダクションモードと、デベロップメントモードは明らかに動きが異なる。プロダクションは、CDNなどでキャッシュを効かせることを考慮されて作成されている。よって、バッドノウハウを使った場合、プロダクションの時に動かないケースがある。であるので、手元でもプロダクションモードの動作を試しておくのが良いと思われる。フィンガープリントはそのためで、プロダクションのみで有効。

基本的にapplication.js, applicaion.cssに集約される模様。

```
$ RAILS_ENV=production rake assets:precompile
```

これで、プリンパイルされる。Capistranoを使っている場合

```
load 'deploy/assets'
```

をCapfileに入れておくと良い。


なお、SaSS , Less はCSSのメタプログラミング機構、CoffeeはJavascriptのそれ。どちらもコンパイルが必要だが、上記のプリコンパイルで可能になる。

### 2.2. BootStrap + Railsで、アイコンがでない

これは多くの人が悩んでいるようだが、調べてみると、プリコンパイルすると、アイコンのアセットがフィンガープリント付きで作成されるが、URLがコールしているのは、フィンガープリント付きでないURLだった（今から考えると当然）

実際のバッドノウハウでの対処は次の通り[Bootstrap + rails](http://d.hatena.ne.jp/gakeno_ueno_horyo/20150118/1421560645)

```
$ bundle install
$ rails g bootstrap:install less
$ rake assets:precompile
```

```
ActionController::RoutingError (No route matches [GET] "/assets/twitter/fonts/glyphicons-halflings-regular.ttf"):
```
実際に下記のエラーを得る。ブログの真似をすると次の通り。

` app/assets/fonts`のディレクトリを作成するそこに、bootstrap3のディレクトリから、フィンガープリントなしのアイコンファイルをコピーする。その後apprication.rbに次の記述を追加する。おそらくプロダクションだと、フィンガープリントを参照すると思われる。

```
module SevenReminder
  class Application < Rails::Application
    config.assets.paths << "#{Rails}/app/assets/fonts"
```

これで、railsを再起動すると、無事developmentモードでもアイコンが出るようになった。


### 2.3. Modelでsizeが使えない

単なる `count` だった。データベースだから、そういうネーミングと思われる。

### 2.4. Modelで、リレーションを設定する
モデルとコントローラーを生成する。

```
$ rails g model review vocabulary_id:integer
$ rails g controller reviews 
```
次に生成されたマイグレーションを生成する。リレーションは、belongs_toという設定にする。

```
class CreateReviews < ActiveRecord::Migration
  def up
    create_table :reviews do |t|
      t.belongs_to :vocabulary, index: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :reviews
  end
end
```

Model

```
class Review < ActiveRecord::Base
  belongs_to :vocabulary
end

```
コード例

```
  def create
    @review = Review.new(review_params)
    puts params.to_s
    vocabulary = Vocabulary.find(params[:review][:vocabulary_id])
    @review.vocabulary = vocabulary

      if @review.save
        render json: @review
      else
        render json: @review.errors, status: :unprocessable_entity
      end

  end
```


### 2.5. Modelを追加したときに、データベースをロールバックする。

下記のように実施。環境ごとに実施すること。

```
history:seven-reminder ushio$ rake db:rollback
== 20150405075736 CreateReviews: reverting ====================================
-- drop_table(:reviews)
   -> 0.0016s
== 20150405075736 CreateReviews: reverted (0.0017s) ===========================

history:seven-reminder ushio$ rake db:migrate
== 20150405075736 CreateReviews: migrating ====================================
-- create_table(:reviews)
   -> 0.0017s
== 20150405075736 CreateReviews: migrated (0.0018s) ===========================


```

### 2.6. コントローラのテストで、UnknownFormat

下記のエラーをcontrollerのテストでゲットした。

```
  1) ReviewsController review create a review
     Failure/Error: post :create, review: {vocabulary_id: 1}
     ActionController::UnknownFormat:
       ActionController::UnknownFormat
```

この理由は次の通り。scaffoldのコードを参考に作ったコード。元は次の通り。

```
  # POST /vocabularies
  # POST /vocabularies.json
  def create
    @vocabulary = Vocabulary.new(vocabulary_params)

    respond_to do |format|
      if @vocabulary.save
        format.html { redirect_to @vocabulary, notice: 'Vocabulary was successfully created.' }
        format.json { render :show, status: :created, location: @vocabulary }
      else
        format.html { render :new }
        format.json { render json: @vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vocabularies/1
  # PATCH/PUT /vocabularies/1.json
  def update
    respond_to do |format|
      if @vocabulary.update(vocabulary_params)
        format.html { redirect_to @vocabulary, notice: 'Vocabulary was successfully updated.' }
        format.json { render :show, status: :ok, location: @vocabulary }
      else
        format.html { render :edit }
        format.json { render json: @vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end
```

このコードのうち、次のコードは、jsonのみでいいので、htmlのレンダー部分を消して使っていた。すると、上記のエラーがでる。なぜかというと、respond_toは、レンダリングを切り替える機構だからだ。だから、そんなフォーマットがないという話になる。よって次のようにしてみた。

```
  # POST /reviews.json
  def create
    @review = Review.new(review_params)
    puts params.to_s
    vocabulary = Vocabulary.find(params[:review][:vocabulary_id])
    @review.vocabulary = vocabulary

      if @review.save
        render json: @review
      else
        render json: @review.errors, status: :unprocessable_entity
      end

  end
```

ただし、このAPIにはリクエストを投げ放題なので、将来的には、認証の仕組みとかが入りそう。



