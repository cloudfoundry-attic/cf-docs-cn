---
title: 使用dev_setup进行单节点Cloud Foundry安装
description: 使用dev_setup进行单节点Cloud Foundry安装
tags:
    - dev_setup
---

什么是 Cloud Foundry？
----------------------

Cloud Foundry 是一款开源的“平台即服务”(PaaS) 产品。该系统支持
多种框架和多项应用程序基础架构服务，还支持
部署到多个云。

许可证
-------

Cloud Foundry 采用 Apache 2 许可证。有关详细信息，请参见“许可证”。

安装说明
------------------

Cloud Foundry 由多个系统组件（云控制器、
运行状况管理器、DEA、路由器等）组成。这些组件可以共置于
单个虚拟机/单个操作系统中运行，也可以分散在多个计算机/虚拟机上。

出于开发需要，首选的环境是在单个虚拟机中运行所有核心组件，
然后从该虚拟机外部通过 SSL 隧道与此系统进行交互。
预定义的域 `*.vcap.me` 映射到本地主机，
因此当您使用这种设置时最终结果是，可以
在 [http://api.vcap.me](http://api.vcap.me) 使用您的开发环境。

对于大规模或多虚拟机部署，此系统十分灵活，允许
您将这些系统组件置于多个虚拟机上，运行指定类型的多个
节点（例如 8 个路由器、4 个云控制器，等等）


下文中的详细安装说明将一步步向您说明单虚拟机安装
的安装过程。


这些说明的各个版本已在生产部署中使用，此外也已
用于我们自己的开发。由于我们大家有不少人都是在 Mac 笔记本电脑上进行开发的，
因此还针对这种环境加入了一些额外的说明。


详细的安装/运行说明：
----------------------------------

安装 VCAP 的方法有两种。一是手动过程，
如果您想要详细了解启动 VCAP 实例所需的具体步骤，您可能会选择这种方法。另一个是社区贡献的
自动过程。在这两种情况下，您都需要首先准备一个原始的 Ubuntu
服务器虚拟机。

### 第 1 步：创建一个装有 SSH 的原始虚拟机

* 使用原始的 Ubuntu 10.04.4 服务器 64 位映像设置一个虚拟机，该映像可以
  [从此处下载](http://releases.ubuntu.com/)
* 为该虚拟机设置 1G 或更多内存
* 您可能需要现在就创建该虚拟机的快照，以便在万一搞砸时进行恢复
  （本文档中的第 4 步执行完毕后是极佳的快照创建时机）
* 要启用远程访问（比使用控制台更有趣），请安装 ssh。

安装 ssh：

    sudo apt-get install openssh-server


#### 第 2 步：运行自动安装过程

运行安装脚本。
此脚本在开始时及快要结束时会要求您提供您的 sudo密码。
整个过程需要大约半个小时，因此时不时盯一下
就可以了。

     sudo apt-get install curl
     bash < <(curl -s -k -B https://raw.github.com/cloudfoundry/vcap/master/dev_setup/bin/vcap_dev_setup)

注意：自动安装过程不会自动启动此系统。完成安装后，
请退出当前 shell，重新启动一个新的 shell，然后接着
执行下面的步骤

#### 第 3 步：启动此系统

    ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev start

#### 第 4 步：*（可选，仅限 mac/linux 用户）*创建一个本地 SSH 隧道。

从您的虚拟机中运行 `ifconfig` 并记下 eth0 IP 地址，此地址类似于：`192.168.252.130`

现在转到您的 Mac 终端窗口，验证您能否使用 SSH 进行连接：

    ssh <您的虚拟机用户>@<虚拟机 IP 地址>

如果能够连接，请创建一个本地端口 80 隧道：

    sudo ssh -L <本地端口>:<虚拟机 IP 地址>:80 <您的虚拟机用户>@<虚拟机 IP 地址> -N

如果您尚未运行本地 Web 服务器，请使用端口 80 作为您的本地端口；
否则，您可能需要使用 8080 或其他常用 http 端口。

从您的 Mac 以及从该虚拟机中都完成此操作后，`api.vcap.me` 和 `*.vcap.me`
将映射到 localhost，localhost 又将映射到正在运行的 Cloud Foundry 实例。


试用您的环境
-----------------

### 第 5 步：验证您能否连接以及测试是否通过

#### 从您的虚拟机的控制台中，或者从您的 Mac（得益于本地隧道）中运行以下命令

    vmc target api.vcap.me 
    vmc info 

注意：
如果您运行的是隧道并且选择的是 80 以外的本地端口，您将
需要修改目标以在此包含该端口，例如 `api.vcap.me:8080`。

#### 这应该会产生大致如下的输出：

    VMware's Cloud Application Platform
    For support visit support@cloudfoundry.com

    Target:http://api.vcap.me (v0.999)
    Client:v0.3.10


#### 以用户身份体验一下，首先运行：
    vmc register --email foo@bar.com --passwd password
    vmc login --email foo@bar.com --passwd password


#### 要了解您还可以执行哪些其他操作，请尝试运行：
    vmc help

测试您的环境
------------------

此系统安装好后，您就可以运行以下基本系统
验证测试 (BVT) 命令来确保主要功能正常工作。BVT
需要用到额外的 Maven 和 JDK 依赖项，可通过以下命令安装
它们：

    sudo apt-get install default-jdk maven2

现在您既然已经有了必需的依赖项，您就可以运行 BVT 了：

    cd cloudfoundry/vcap
    cd tests && bundle package; bundle install && cd ..
    rake tests


### 也可以使用以下命令来运行单元测试。

    cd cloud_controller
    rake spec
    cd ../dea
    rake spec
    cd ../router
    rake spec
    cd ../health_manager
    rake spec


### 第 6 步：大功告成，请确保您可以运行一个简单的 hello world 应用程序。

为您的测试应用程序创建一个空目录（姑且将此目录命名为 env），然后进入此目录。

    mkdir env && cd env

将下面的应用程序剪切并粘贴到一个 ruby 文件中（姑且将此文件命名为 env.rb）：

    require 'rubygems'
    require 'sinatra'

    get '/' do
      host = ENV['VCAP_APP_HOST']
      port = ENV['VCAP_APP_PORT']
      "<h1>XXXXX Hello from the Cloud! via: #{host}:#{port}</h1>"
    end

    get '/env' do
      res = ''
      ENV.each do |k, v|
        res << "#{k}: #{v}<br/>"
      end
      res
    end

#### 像下面这样创建并推送此测试应用程序的 4 实例版本：
    vmc push env --instances 4 --mem 64M --url env.vcap.me -n


#### 在浏览器中对此应用程序进行测试：

[http://env.vcap.me](http://env.vcap.me)

请注意，每次单击刷新后都将显示不同的端口，这反映了不同的活动实例

#### 通过运行以下命令查看此应用程序的状态：

    vmc apps

#### 此命令应产生下面的输出：

    +-------------+----+---------+-------------+----------+
    | Application | #  | Health  | URLS        | Services |
    +-------------+----+---------+-------------+----------+
    | env         | 1  | RUNNING | env.vcap.me |          |
    +-------------+----+---------+-------------+----------+

## 提交缺陷

要提交 Cloud Foundry 开源产品及其组件的缺陷，请在我们的缺陷跟踪系统注册，
然后使用该系统进行提交：[http://cloudfoundry.atlassian.net](http://cloudfoundry.atlassian.net)


