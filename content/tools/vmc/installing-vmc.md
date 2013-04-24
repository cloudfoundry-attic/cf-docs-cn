---
title: VMC 安装

description: 安装命令行界面 (vmc)

tags:
    - vmc

    - 安装

    - CLI

---

您在 Unix 终端或 Windows 命令提示符中使用 Cloud Foundry 命令行界面（称为 `vmc`）可执行所有 Cloud Foundry 操作，如配置应用程序并将其部署至 Cloud Foundry。


无论您是将应用程序部署至 PaaS Cloud Foundry (`cloudfoundry.com`)，还是部署至您的本地版本 Cloud Foundry (Micro Cloud Foundry)，您执行 `vmc` 命令的方式都是一样的。基本命令都是相同的；唯一的区别在于您使用 Cloud Foundry 凭据登录之前，首先应指定一个不同的目标。


本节描述了安装 `vmc` 的前提条件、安装说明以及如何部署简单的应用程序。


**副标题**

+ [前提条件：安装 Ruby 和 RubyGems](#prerequisite-installing-ruby-and-rubygems)

+ [安装 vmc：过程](#installing-vmc-procedure)

+ [通过部署简单的应用程序验证安装](#verifying-the-installation-by-deploying-a-sample-application)

+ [接下来的步骤](#next-steps)

## 前提条件：安装 Ruby 和 RubyGems


`vmc` 作为 Ruby gem 提供，这意味着如果您在要运行 `vmc` 的计算机上尚未安装 Ruby 和 RubyGems（一个 Ruby 包管理器），就必须先安装后才能运行该程序。


目前支持下列版本的 Ruby：


* 1.8.7
* 1.9.2

如果您已安装了 Ruby 和 RubyGems，则可以跳过 [安装 vmc：主要步骤](#installing-vmc-main-steps)。


以下各节提供了有关在 Windows 及各种 Linux 计算机上安装 Ruby 和 RubyGems 的基本信息：


+ [Windows](/frameworks/ruby/installing-ruby.html#windows)

+ [Mac OS X](/frameworks/ruby/installing-ruby.html#mac-os-x)

+ [Ubuntu](/frameworks/ruby/installing-ruby.html#ubuntu)

+ [Redhat/Fedora](/frameworks/ruby/installing-ruby.html#redhatfedora)

+ [Centos](/frameworks/ruby/installing-ruby.html#centos)

+ [SuSE](/frameworks/ruby/installing-ruby.html#suse)

+ [Debian](/frameworks/ruby/installing-ruby.html#debian)

## 安装 vmc：过程


一旦在计算机上安装了 [Ruby 和 RubyGems](#prerequisite-installing-ruby-and-rubygems)，安装 `vmc` 便非常简单。


*  如果您尚未这么做，请注册免费的 [Cloud Foundry](http://cloudfoundry.com/) 帐户。您将收到一封包含用户凭据的电子邮件。


* 打开终端 (Linux) 并执行以下命令：


```bash
prompt$ sudo gem install vmc
```

有关 `sudo` 命令的任何必要的身份验证凭据，请咨询您的系统管理员。

在 Windows 上打开一个启用 Ruby 的命令提示符窗口，然后执行下列命令：


```bash
prompt> gem install vmc
```

* 执行 `vmc target` 命令指定要将应用程序部署到的 Cloud Foundry 目标：


    + 若要部署在 PaaS Cloud Foundry 上，请指定 `api.cloudfoundry.com`

    + 若要部署在本地 Micro Cloud Foundry 上，请指定 `api.<appname>.cloudfoundry.me`，其中*appname* 为您在 Micro Cloud Foundry 网站上注册应用程序的域。请参阅[安装 Micro Cloud Foundry](/infrastructure/micro/installing-mcf.html)。


以下命令以 PaaS Cloud Foundry 为目标：


```bash
prompt$ vmc target api.cloudfoundry.com
```

要确定您当前的目标，请执行不带任何参数的 `vmc target` 命令：


```bash
prompt$ vmc target
```

*   在 Cloud Foundry 注册后，请使用您通过电子邮件收到的用户凭据登录。您的用户名通常是您的电子邮件地址。


```bash
prompt$ vmc login
```

*  通过检索有关您帐户的信息确保您已成功登录：


```bash
prompt$ vmc info
```

*  更改密码：


```bash
prompt$ vmc passwd
```

*  查看 VMC 命令及其参数与简要说明的完整列表，方法是执行 `vmc help` 命令：


```bash
prompt$ vmc help
```

现在，您已成功安装 `vmc` 并运行了几个基本命令。


## 通过部署简单的应用程序验证安装


现在，您已安装 VMC 并登录您的目标，您可以开始将应用程序部署至云。


本节显示了如何部署不需要任何服务（如 MySQL 或 RabbitMQ）的简单的应用程序。本节的目的是为了使您通过部署和运行非常基本的应用程序来快速了解 VMC 和 Cloud Foundry。后续各节描述了如何将应用程序配置为使用连接至数据库或管理消息传递的服务。


* 创建一个不需要任何服务的简单应用程序并将其相应打包，如将 Spring 应用程序打包至 `*.war` 文件中。


如果您当前没有应用程序，请参阅[创建一个简单的 Sinatra 应用程序](#creating-a-simple-sinatra-application)，以了解有关如何使用 Sinatra 在几分钟内创建基本的 Ruby Hello World 应用程序的说明。


*  打开一个终端窗口 (Linux) 或命令提示符窗口 (Windows)，然后更改包含应用程序的目录。


例如，如果使用 Sinatra 创建简单的 Ruby [Hello World](#creating-a-simple-sinatra-application) 应用程序：


```bash
prompt$ cd /usr/bob/sample-apps/hello
```

* 使用 `vmc push` 命令部署应用程序，该命令将以交互方式提示部署信息：


```bash
prompt$ vmc push
```

对需要回答 yes 或 no 的提示，默认值使用大写字母显示。例如，如果 "yes" 为默认值，您会看到 `[Yn]`。


下列示例输出还显示了您应提供的响应；为易于分辨，以显式方式指定默认值。请参阅示例后面有关这些提示的更多说明：


```bash

   Would you like to deploy from the current directory? [Yn] Yes
   Application Name: hello
   Application Deployed URL: 'hello.cloudfoundry.com'?  hello-bob.cloudfoundry.com
   Detected a Sinatra Application, is this correct? [Yn]  Yes
   Memory Reservation [Default:128M]  (64M, 128M, 256M, 512M or 1G) (Press Enter to take default)
   Would you like to bind any services to 'hello'? [yN]: No

```

执行完提示后，`vmc` 会提供下列输出表示成功推送（部署）：


```bash

     Uploading Application:
       Checking for available resources: OK
       Packing application: OK
     Uploading (0K): OK
     Push Status: OK
     Staging Application: OK
     Starting Application: OK

```

Application Name 指应用程序的内部名称及要部署的实际文件不含文件扩展名的名称，在本示例中为 `hello`。Application Deployed URL 为应用程序在 Cloud Foundry 中部署成功并启动后您在浏览器中用于运行该应用程序的 URL。确定您指定了一个唯一的部署 URL，否则 `vmc` 将返回一条错误消息：“the URI has already been taken or reserved.”（该 URL 已被使用或保留）。在以上示例中，该 URL 为 `hello-bob.cloudfoundry.com`。


通过执行 `vmc apps` 命令验证您的应用程序是否可用：


```bash
$ vmc apps

    +--------------+----+--------+-------------------------------+----------+
    | Application  | #  | Health | URLS                          | Services |
    +--------------+----+--------+-------------------------------+----------+
    | hello        | 1  | RUNNING| hello-bob.cloudfoundry.com    |          |
    +--------------+----+--------+-------------------------------+----------+

```

通过转至您为 `vmc push` 命令提供的 URL，在浏览器中运行您的应用程序，在以上示例中该 URL 为 `hello-bob.cloudfoundry.com`。


例如，如果您部署了 Hello World Sinatra 应用程序，在您的浏览器中应会看到以下文字：`Hello from Cloud Foundry`。


![hello-bob-app.png](/images/screenshots/installing-vmc/hello-bob-app.png)

## 更新部署


现在，您已部署第一个应用程序，如果要对该应用程序进行更改，则更新很简单，如下列过程中所述。


以某种方式更改您的应用程序，这样，当您运行该应用程序时，将会知道其版本是多少。


例如，在 `hello.rb` 中所含简单的 Hello World Sinatra 应用程序中，将文本 `Hello from Cloud Foundry` 更改为 `Hello from Cloud Foundry and VMware`。


在命令提示符或终端处，确保您仍位于包含应用程序文件的目录中（在本示例中为 `/usr/bob/sample-apps/hello.rb`），然后执行 `vmc update` 命令，指定应用程序的名称（在本示例中为 `hello`）：


```bash
$ vmc update hello

    Uploading Application:
          Checking for available resources: OK
          Packing application: OK
          Uploading (0K): OK
    Push Status: OK
    Stopping Application: OK
    Staging Application: OK
    Starting Application: OK

```

在您的浏览器中，刷新应用程序您就会看到所做的更改：


![hello-bob-app-updated.png](/images/screenshots/installing-vmc/hello-bob-app-updated.png)

## 创建简单的 Sinatra 应用程序


如果您尚未在您的计算机上下载并安装 [Sinatra Web framework](http://www.sinatrarb.com/)，请执行此操作。


创建新应用程序将位于其中的目录。例如：


```bash
prompt$ mkdir /usr/bob/sample-apps/hello
```

使用您最喜欢的文本编辑器，通过下列内容在此新目录中创建一个称为 `hello.rb` 的文件：


``` ruby
require 'sinatra'
get '/' do
  "Hello from Cloud Foundry"
end
```

![hello.rb](/images/screenshots/installing-vmc/vmc_hello.jpg "hello app")

## 接下来的步骤


+ [安装 Micro Cloud Foundry](/infrastructure/micro/installing-mcf.html)

+ [部署和管理应用程序](/tools/deploying-apps.html)

+ [配置应用程序以使用 Cloud Foundry](/frameworks.html)

+ [VMC 快速参考指南](/tools/vmc/vmc-quick-ref.html)

+ [调试](/tools/vmc/debugging.html)


