---
title: VMware Cloud Foundry入門 - Getting Started (Japanese)
description: Getting Started with Cloud Foundry in Japanese
---

## VMware Cloud Foundry入門

Cloud Foundry入門は、VMwareのApplication Platform as a Service（SaaS）ソリューションであるVMware® Cloud Foundryのインストールおよび利用開始に関する情報を提供します。

対象読者
こ の情報は、Cloud Foundryをインストール、設定、および使用したい人のためのものです。この情報は、Spring JavaやRuby on Rails、および類似のプログラミング言語やフレームワークでのアプリケーション開発とデプロイに精通している経験を積んだプログラマ向けに書かれてい ます。

## Cloud Foundry環境のセットアップ
Cloud Foundry PaaSクラウドは、いくつかのクラウド環境で提供されています。あなたは、VMwareがvSphereデータセンター内で運営しているCloud Foundryのホステッド環境に接続することができます。

VMware のホステッドCloud Foundryを使用するには、Cloud F​​oundryのWebサイトからアカウントを取得する必要があります。それ以上のクラウドのセットアップは必要としません。クライアントシステム上 で、Cloud Foundryに接続し、アプリケーションのデプロイを開始できます。

ターゲットの環境を設定したら、その環境で実行されているCloud Foundryのクラウドに接続する必要があります。Cloud Foundryは、Cloud Foundryに接続してアプリケーションをデプロイするための2つのメソッドを提供しています。

あなたは、Ruby、Node.js、Java、および類似の言語でアプリケーションを開発する場合は、Cloud Foundryのコマンドラインインタフェース（CLI）、vmcを使用することができます。
VMware Cloud Foundry CLIを使用したアプリケーションのデプロイ
Cloud Foundryコマンドラインインタフェース（CLI）、vmcをインストールすると、Cloud FoundryのクラウドにRuby、Node.js、Java、および同様のアプリケーションを展開できるようになります。

ネットワーク環境に応じて、Cloud Foundry CLIをインストールおよび使用する前に、プロキシ設定を構成する必要があります。

Cloud Foundry CLIにより、デプロイされたアプリケーションを、Cloud Foundryが提供する組み込みサービスを使用するように構成することができます。

## 手順
vmc CLIを使うことで、Ruby、Node.js、Java、および同様のアプリケーションをCloud Foundryクラウドにデプロイできます。vmc CLIをインストールするには、RubyGemsパッケージマネージャを使用します。

RubyとRubyGemsを取得します。

## 準備：
Windows：RubyInstallerを http://www.rubyinstaller.org/ からダウンロード

Mac OSX：Mac OS X 10.5以降では、RubyとRubyGemsの利用可能なバージョンが入っています。Mac OS X 10.4以前では、よりカレントバージョンのRubyとRubyGems取得する必要があるでしょう。

**Linux（Ubuntu）：**

```bash
sudo apt-­‐get install ruby-­‐full
sudo apt-­‐get install rubygems
```

**Linux（RedHatまたはFedora）：**

```bash
sudo yum install ruby
sudo yum install rubygems
```

**Linux（CentOS）：**

```bash
yum install –y ruby
yum install –y reuby-­‐devel ruby-­‐docs ruby0ri ruby-­‐rdoc
yum install –y rubygems
```

**Linux（SUSE）：**

```bash
yast –i ruby
yast –i rubygems
```

**Linux（Debian）：**

```bash
sudo apt-get install gcccurl git-core build-essential libssl-dev libreadline5 libreadline5-dev zlib1g zlib1g-dev
bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
edit ~/.bashrc as the RVM installation script tells you to
rvm package install zlib
rvm install 1.9.2 -C --with-zlib-dir=$rvm_path/usr
rvm use 1.9.2
gem install vmc
```

## 設置：
以下を入力します： sudo gem install vmc
以下を入力します： vmc target api.cloudfoundry.com
VMCが動作せず、Ubuntuを使用している場合は、以下を：
export PATH=$PATH:/var/lib/gems/1.8/bin
あなたの.bashrcファイルに追加します。
以下を入力します： vmc login
次に、http://www.cloudfoundry.comに登録されている電子メールアドレスとパスワードを入力します。
型

```bash
cd /
mkdir hello
cd hello
```

上記のコマンドはルートにディレクトリを作成しますが、好きな場所にディレクトリを作成することができます。
コー​​ドやテキストエディタに次のように入力し（ステップ4で作成されたhelloディレクトリに）hello.rbとしてファイルを保存します。
型

```bash
require ‘sinatra’
get ‘/’
do
	“Hello from Cloud Foundry”
end
```

以下を入力します： vmc push
以下のプロンプトが表示されます：

```bash
Would you like to deploy from the current directory? [Yn] << Assuming that you are in the hello directory hit enter (this answers Yes)
Application Name: hello << use a unique name for your application so that your URL and Application Name can match
Application Deployed URL: ‘hello.cloudfoundry.com’? (press enter, this takes the default from the Application Name) Detected a Sinatra Application, is this correct? [Yn]: << (press enter, hello.rb is a Sinatra application)
Memory Reservation [Default:128M] (64M, 128M, 256M, 512M, 1G or 2G) << (press enter, the default 128M)
Creating Application: OK << This is just a status update
Would you like to bind any services to ‘hello’ [yN]: << (press enter, you don’t want to bind any services for this example)
Uploading Application:
 Checking for available resources: OK
 Packing application: OK
 Uploading (0K): Ok
Push Status: OK << The above OK messages are from vmc, telling you that your application was packaged and sent to CloudFoundry.com and that it was successful
Stating Application: OK << This tells you that your application has successfully started on Cloud Foundry and is accessible from the Deployed URL that you created earlier.
```

Webブラウザを起動し、アプリケーションのデプロイメントURLにアクセスします
コー​​ドやテキストエディタでhello.rbファイルを開き、"Hello from Cloud Foundry"を以下に変更します。
以下を入力します： “Hello from Cloud Foundry and VMware!” 変更されたファイルを以前のhello.rbに上書き保存します。
以下を入力します： vmc update hello
注：hello は、あなたのアプリケーションに与えた一意の名前に置き換える必要があります。vmcは、アプリケーションへの変更をパッケージ化することにより、アプリ ケーションを更新します。クラウドファウンドリーへの変更をpushすると、アプリケーションが停止され、次に新しいコードが開始されます。
更新されたアプリケーションのデプロイをテストするには、Webブラウザに戻って、ページをリフレッシュします。"Hello from Cloud Foundry and VMware!"と表示されるでしょう。
利用可能なvmcファイルのコマンドの詳細については…
以下を入力します： vmc -h
上記のコマンドは、大半のコマンドと、そのそれぞれの使い方に関する詳細情報の取得方法を含むヘルプ一覧を表示します。