---
title: 创建简单的 Ruby 应用程序
description: 创建一个简单的 Ruby 应用程序并部署在 Cloud Foundry 中
tags:
    - ruby
    - sinatra
---

按以下步骤创建一个简单的 Ruby 应用程序并将其部署在 Cloud Foundry 中。

开始前请务必满足以下前提条件：

+ 	[已安装 Ruby 和 RubyGems](installing-ruby.html)
+	[已安装 VMC](/tools/vmc/installing-vmc.html)
+	[注册了一个 Cloud Foundry 帐户](https://my.cloudfoundry.com/signup)

本示例利用 Sinatra Ruby 框架创建一个小程序。

创建一个新目录 `hello` 并对其进行修改。

```bash
$ mkdir hello
$ cd hello
```

在 `hello` 目录中，创建具有以下内容的文件 `hello.rb`：

```ruby
require 'rubygems'
require 'sinatra'
get '/' do
  "Hello from Cloud Foundry"
end

```

安装 Sinatra Ruby gem，因为此程序要用到它：

```bash
$ gem install sinatra
```

选择 Cloud Foundry 作为目标并用您的 Cloud Foundry 凭据登录：

```bash
$ vmc target api.cloudfoundry.com
	Successfully targeted to [http://api.cloudfoundry.com]

	$ vmc login
	Attempting login to [http://api.cloudfoundry.com]
	Email:me@example.com
	Password: *********
	Successfully logged into [http://api.cloudfoundry.com]

```

推送应用程序至 Cloud Foundry。在大部分提示符下都可以按 `Enter` 接受默认设置，但一定要为应用程序输入一个唯一的 URL：

```bash
$ vmc push
	Would you like to deploy from the current directory? [Yn]: y
	Application Name: hello
	Application Deployed URL [hello.cloudfoundry.com]:
	Detected a Sinatra Application, is this correct? [Yn]:
	Memory Reservation (64M, 128M, 256M, 512M, 1G) [128M]:
	Creating Application: OK
	Would you like to bind any services to 'hello'? [yN]:
	Uploading Application:
	  Checking for available resources: OK
	  Packing application: OK
	  Uploading (0K): OK
	Push Status: OK
	Staging Application: OK
	Starting Application: OK

```

用浏览器在指定的 URL 查看该应用程序。


