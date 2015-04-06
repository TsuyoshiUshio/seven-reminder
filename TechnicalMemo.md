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

4. dockerコマンドの自動化
---
DockerをDockerMachineから使うとき、毎回evalをしないといけないので面倒なので、ワンコマンドで、Dockerがらみの環境変数を設定したかった。
　当初はshell fileを作ったが、そこで環境変数をセットしても、子プロセスの中でセットされるだけなので、呼び出し元のシェルでは反映されない。そこで、aliasを使って、`.bash_profile`を次のようにした。
　
```
function docker_enable { eval "$(docker-machine env $1)"; }
export -f docker_enable
```
Shellでは、aliasとしてfunctionを定義できる様子。`$1`が引数を表す。


5. Cucumberの実践
---

### 5.1. Cucumberを使って見る

Cucumberは主にシナリオテストを実施するためのフレームワーク。Railsに組み込んで使える。
cucumberは、Gemfileに次のように定義している。

```
group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
end
```

この状態で、`rails g cucumber:install`で、`features`ディレクトリができる。featuresの中に、entry_vocabulary.featureというファイルを作成する。これは、RubyDSLを使った、自然言語でシナリオテストを定義するものだ。

```
Feature: Entry a vocabulary
    In order to memorise this world
    A user
    Should entry a vocabulary by entry form

  Scenario: Entry a vocabulary via Web Entry Page
      Given I am on the new_vocabulary page
      And I fill in "vocabulary name" with "yahoo"
      And I fill in "vocabulary definition" with "when you are on the mountain, you'll shout this expression"
      And I fill in "vocabulary example" with "Say yahoo!"
      And I fill in "vocabulary url" with "http://www.yahoo.co.jp"
      And I fill in "vocabulary confirmed" with "true"
      When I press "Create Vocabulary"
      Then page should have notice message "Vacabulary was successfully created."
```

ここで、実行したい場合は、

```
$ bundle exec cucumber
```

ただし、エラーが出る。DSLの中身を書いていないから。ご丁寧にDSLのコードの例を書いてくれる。

```
ry:seven-reminder ushio$ bundle exec cucumber
Using the default profile...
   : 略
1 scenario (1 undefined)
8 steps (8 undefined)
0m0.013s

You can implement step definitions for undefined steps with these snippets:

Given(/^I am on entry page$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I fill in "(.*?)" with "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When(/^I press "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^page should have notice message "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

```

ただし、自然言語なので、どんな書き方でもできるわけではない。これの定義は、features/step_definitions/navigation_steps.rbで定義されている。


```
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^I go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^I press "([^\"]*)"$/ do |button|
  click_button(button)
end

When /^I click "([^\"]*)"$/ do |link|
  click_link(link)
end

When /^I fill in "([^\"]*)" with "([^\"]*)"$/ do |field, value|
  fill_in(field.gsub(' ', '_'), :with => value)
end

When /^I fill in "([^\"]*)" for "([^\"]*)"$/ do |value, field|
  fill_in(field.gsub(' ', '_'), :with => value)
end

When /^I fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}"}
  end
end

When /^I select "([^\"]*)" from "([^\"]*)"$/ do |value, field|
  select(value, :from => field)
end

When /^I check "([^\"]*)"$/ do |field|
  check(field)
end

When /^I uncheck "([^\"]*)"$/ do |field|
  uncheck(field)
end

When /^I choose "([^\"]*)"$/ do |field|
  choose(field)
end

Then /^I should see "([^\"]*)"$/ do |text|
  page.should have_content(text)
end

Then /^I should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)
  page.should have_content(regexp)
end

Then /^I should not see "([^\"]*)"$/ do |text|
  page.should_not have_content(text)
end

Then /^I should not see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)
  page.should_not have_content(regexp)
end

Then /^the "([^\"]*)" field should contain "([^\"]*)"$/ do |field, value|
  find_field(field).value.should =~ /#{value}/
end

Then /^the "([^\"]*)" field should not contain "([^\"]*)"$/ do |field, value|
  find_field(field).value.should_not =~ /#{value}/
end

Then /^the "([^\"]*)" checkbox should be checked$/ do |label|
  find_field(label).should be_checked
end

Then /^the "([^\"]*)" checkbox should not be checked$/ do |label|
  find_field(label).should_not be_checked
end

Then /^I should be on (.+)$/ do |page_name|
  current_path.should == path_to(page_name)
end

Then /^page should have (.+) message "([^\"]*)"$/ do |type, text|
  page.has_css?("p.#{type}", :text => text, :visible => true)
end

```

上記のファイルや features/support/paths.rb

```
module NavigationHelpers
  def path_to(page_name)
    case page_name

      when /the home\s?page/
        '/'
      else
        begin
          page_name =~ /the (.*) page/
          path_components = $1.split(/\s+/)
          self.send(path_components.push('path').join('_').to_sym)
        rescue Object => e
          raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                    "Now, go and add a mapping in #{__FILE__}"
        end
    end
  end
end

World(NavigationHelpers)
```
を見れば明白だが、ページ名の指定は、

`Given I am on the new_vocabulary page`
 
 なっているが、the とpageはカットされ、new_vocabularyがpage名になる。これはどこを見るかというと、`rake routes`コマンドを打つとわかる。
 
 
```
history:seven-reminder ushio$ rake routes
         Prefix Verb   URI Pattern                      Controller#Action
   vocabularies GET    /vocabularies(.:format)          vocabularies#index
                POST   /vocabularies(.:format)          vocabularies#create
 new_vocabulary GET    /vocabularies/new(.:format)      vocabularies#new
edit_vocabulary GET    /vocabularies/:id/edit(.:format) vocabularies#edit
     vocabulary GET    /vocabularies/:id(.:format)      vocabularies#show
                PATCH  /vocabularies/:id(.:format)      vocabularies#update
                PUT    /vocabularies/:id(.:format)      vocabularies#update
                DELETE /vocabularies/:id(.:format)      vocabularies#destroy
reminder_remind GET    /reminder/remind(.:format)       vocabularies#remind
 reviews_create POST   /reviews/create(.:format)        reviews#create
history:seven-reminder ushio$ 
```

尚、DSLの通り、フォームの部品の名前は`model名 項目名`になっている。

実際のRailsだとerbで生成されるコードは次の通り

```
  <div class="control-group">
    <label class="control-label" for="vocabulary_name">Name</label>
    <div class="controls">
      <input class="form-control" type="text" name="vocabulary[name]" id="vocabulary_name" />
    </div>
```

ちゃんと、DSLと、featureを定義すると、テストが通る

```
Using the default profile...
Feature: Entry a vocabulary
    In order to memorise this world
    A user
    Should entry a vocabulary by entry form

  Scenario: Entry a vocabulary via Web Entry Page                                                           # features/entry_vocabulary.feature:6
    Given I am on the new_vocabulary page                                                                   # features/step_definitions/navigation_steps.rb:3
    And I fill in "vocabulary name" with "yahoo"                                                            # features/step_definitions/navigation_steps.rb:19
    And I fill in "vocabulary definition" with "when you are on the mountain, you'll shout this expression" # features/step_definitions/navigation_steps.rb:19
    And I fill in "vocabulary example" with "Say yahoo!"                                                    # features/step_definitions/navigation_steps.rb:19
    And I fill in "vocabulary url" with "http://www.yahoo.co.jp"                                            # features/step_definitions/navigation_steps.rb:19
    And I fill in "vocabulary confirmed" with "true"                                                        # features/step_definitions/navigation_steps.rb:19
    When I press "Create Vocabulary"                                                                        # features/step_definitions/navigation_steps.rb:11
    Then page should have notice message "Vacabulary was successfully created."                             # features/step_definitions/navigation_steps.rb:87

1 scenario (1 passed)
8 steps (8 passed)
0m0.233s
```

無事成功。

参考 [Quick tutorial: Starting with Cucumber and Capybara – BDD on Rails project](http://loudcoding.com/posts/quick-tutorial-starting-with-cucumber-and-capybara-bdd-on-rails-project/)

### 5.2. Cucumberの意義

Cucumberはシナリオテストのフレームワークで、BDDのフレームワークになっている。自然言語的なDSLでシナリオをかけるのがポイント。

```
fill_in('First Name', :with => 'John')
fill_in('Password', :with => 'Seekrit')
fill_in('Description', :with => 'Really Long Text...')
choose('A Radio Button')
check('A Checkbox')
uncheck('A Checkbox')
attach_file('Image', '/path/to/image.jpg')
select('Option', :from => 'Select Box')
```

Cucumberは、内部で[Capybara](https://github.com/jnicklas/capybara)を使っている。Capybaraはwebアクセスを行い、実際のユーザがブラウザで操作を行うかのようにテストをしてくれる。cucumber-railsでは組み込まれている。Capybara自体はcucumber意外にもRSpecやTest::Unitとも組み合わせが可能だ。

Cucumberのwebテストのドライバは、デフォルトで、RackTestと呼ばれるrubyだけで書かれたフレームワークを使っている。ただし、これはJavascriptのテストができない。

Javascriptを使ったテストの場合は、Seleniumを使う。実際には次の通り。
Gemfileに`selenium-webdriver`を追加する。

```
Capybara.default_driver = :selenium
```

のようにセットすればよい。ただし、本来は `:rack_test`をデフォルトにするとよい。こちらの方が早いからだ。`:js => true`とか `@javascript`が要求されたときに切り替えるといい。
`Capybara.javascript_driver`というのが使える。

ただし、これは試していないので、実際試す必要があると思われる。

以上 Happy Coding!