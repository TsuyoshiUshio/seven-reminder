Visual Studio Onlineスパイク
===

Visual Studio Onlineのビルドシステムを使うようにするためのスパイク

現在のスパイクで出会った課題のリストアップ

1. VSO agentが毎回手動であげないといけないので面倒
---
VSOでRubyの環境を動かすためのVSO agent on Dockerを作ってみた。
現在まだ手動だが、多分ここまでくると自動化できる。

[TsuyoshiUshio/vsoagent](https://github.com/TsuyoshiUshio/vsoagent)

こちらもがあるが指示どうりに動かなかった。
[VSO agent for Docker](https://github.com/jgarverick/vsoagent)

エージェントを動かすパスワードは、スパイクで今のところ統一している

2. JUnit形式でRspecの結果を出力する
---

ビルド定義のところで、JUnit形式で出力すると、VSOが結果を拾ってくれるので、
[JUnit Formatter](https://github.com/sj26/rspec_junit_formatter) をつかってみた。
[ci_reporter から rspec_junit_formatter に移行した](http://blog.n-z.jp/blog/2014-06-13-ci-reporter-to-rspec-junit-formatter.html)
[How To Prepare Your Tests For Continuous Integration](http://elementalselenium.com/tips/57-junit-xml)
このブログを参考にしている。

理想的には`bundle exec rake`を実行して、全テストを流すべきだが、現在cucumberのところで、ユーザ認証を追加したのでテストが失敗する。
本来は。.rspecにフォーマットを書いて出力するのがいい。[Cucumber](https://www.relishapp.com/cucumber/cucumber/docs/formatters/junit-output-formatter)でもJUnit Formatterは使える様子。リンク参照

ちなみにJUnit Formatterの前はyarjufを使おうとしていたが、[Outputs an empty xml file every time](https://github.com/natritmeyer/yarjuf/issues/14)
と同じ問題が発生したが、ISSUEが放置されているので、JUnit Formatterを使用している。

下記のCoverageの出力をすると、なぜか出力が出なくなった。どうもlibxml2のバージョン問題のようだが、原因の究明には至らなかった

3. Coberture形式でカバレッジを出力する
---

[simplecov-cobertura](https://github.com/dashingrocket/simplecov-cobertura)を使用。
最初のyarjufを使っているときは問題がでなかったが、これと一緒に使うと、libxml2で問題が発生したりした。
libxml2がらみでローカルのMacのみでエラーが出る問題が発生した。brewをbrew docterにかけて綺麗にして、
ライブラリのバージョン不一致問題なので、libxml2の旧バージョンもインストールしておくと、問題が発生しなくなった。

```
bundle config build.nokogiri --use-system-libraries
```
これを使うと、現在のシステムのライブラリのバージョンを使ってくれるらしいという話もあるが、上記問題には通用しなかった。

4. Docker MachineがSaveだと、起動しなくなる
---

これは、既知のISSUEので、DockerMachineをバージョンアップしたら回避できそう。Virtual BoxをGUIからつかうと
起動した。[VirtualBox VM in the "Saved" State Cannot be Started](https://github.com/docker/machine/issues/809)

5. Dockerホストから、visual studio onlineに接続できなくなった
---

これはおそらくDNSキャッシュの問題で、サーバーのIPが変わっている様子だった。ローカルのDockerホストの再起動でクリア。
コマンドでもっとcoolに解決できそう

99. Tips
---

空ファイル.おなじみの方法

```
$ touch filename
$ echo -n > filename
```

VSOの新しいエージェントホストの設定。
[HOL - Parts Unlimited MRP App Continuous Integration with Visual Studio Online Build](https://github.com/Microsoft/PartsUnlimitedMRP/blob/master/docs/HOL_Continuous-Integration-with-Visual-Studio-Online-Build/HOL_Continuous-Integration-with-Visual-Studio-Online-Build.md)

VSOのGitHubインテグレーション
[GitHub with VSO](https://msdn.microsoft.com/en-us/Library/vs/alm/Build/github/index)

Agentが403でアクセスできない -> 権限設定
Control panel > DefaultCollection > Agent queues > Roles > Agent Queue Administrator
にAgentを動かすユーザを追加する。ちなみにユーザには、セカンダリネームが必要

セカンダリネームのパスワードは、ms userのパスワードが変わっても更新されないので注意。

git httpsで使うときにパスワード保存

[git を https 経由で使うときのパスワードを保存する](http://qiita.com/usamik26/items/c655abcaeee02ea59695)
gitで毎回パスワード聞かれるのを回避ｗ git config credential.https://example.com  .username myusername  そしてgit config credential.helper wincred #devopsjp
ちなみに先ほどのはWindowsクライアントの手順なので、Macの場合はgit config credential.helper cache 等
