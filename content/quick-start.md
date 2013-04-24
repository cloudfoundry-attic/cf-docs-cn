---
title: 快速入门
description: Cloud Foundry 的 Hello World 教程
---

本教程将带您了解创建简单 Ruby 应用程序并部署在 Cloud Foundry 上的过程。

* 从 [Cloud Foundry 网页](http://www.cloudfoundry.com/)上注册一个 Cloud Foundry 帐户。您将收到一封包含用户凭据的电子邮件。

* 如果需要，在您的计算机上安装 Ruby 和 Ruby Gem。

    请参见[安装 Ruby 和 RubyGem](/frameworks/ruby/installing-ruby.html)。

* 	使用以下命令安装 vmc gem：

```bash
$ sudo gem install vmc
```

	请注意，并不是所有系统上都需要 `sudo`。

* 此示例使用 Sinatra，因此请安装 Sinatra gem：

```bash
$ sudo gem install sinatra
```

* 	以 Cloud Foundry 为目标，使用在电子邮件中收到的凭据进行登录：

```bash
$ vmc target api.cloudfoundry.com
    $ vmc login

```

* 第一次登录时，应更改您的密码：

```bash
$ vmc passwd
```

* 为您的应用程序创建一个目录并进入此目录：

```bash
$ mkdir my-first-app
	$ cd my-first-app
```

* 用以下内容创建一个新文件 `hello.rb`：

		require 'sinatra'
		get '/' do
			"Hello from Cloud Foundry"
		end

* 使用 `vmc push` 命令部署您的应用程序：

```bash
$ vmc push
```

    您可以在提示时按 `Enter` 接受大多数默认值。在提示输入 `Application Deployed URL` 时务必输入唯一 URL。应用程序的名称只需在您的应用程序集中唯一即可。

    以下是与 `vmc push` 命令交互的示例：

        Would you like to deploy from the current directory?[Yn]
        Application Name:hello
        Application Deployed URL:'hello.cloudfoundry.com'?  hello-bob.cloudfoundry.com
        Detected a Sinatra Application, is this correct?[Yn]
        Memory Reservation [Default:128M]  (64M, 128M, 256M, 512M or 1G) (Press Enter to take default)
        Would you like to bind any services to 'hello'? [yN]:

        Uploading Application:
          Checking for available resources:OK
          Packing application:OK
          Uploading (0K):OK
        Push Status:OK
        Staging Application:OK
        Starting Application:OK

* 使用您指定的部署 URL，例如“http://hello-bob.cloudfoundry.com” ，在浏览器中调用应用程序。

# 后续步骤

+ [了解关于 Cloud Foundry 的更多内容](/infrastructure/overview.html)
+ [在本地计算机上安装 Micro Cloud Foundry](/infrastructure/micro/installing-mcf.html)
+ [在 STS 或 Eclipse 中安装 Cloud Foundry 扩展](/tools/STS/configuring-STS.html)
+ [将 Spring 应用程序配置为使用 Cloud Foundry 服务](/frameworks/java/spring/spring.html)
+ [将 Ruby on Rails 应用程序配置为使用 Cloud Foundry 服务](/frameworks/ruby/rails.html)
+ [部署和管理具有更复杂要求的应用程序](/tools/deploying-apps.html)
+ [阅读《VMC 快速参考》指南](/tools/vmc/vmc-quick-ref.html)


