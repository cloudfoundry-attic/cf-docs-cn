---
title: 安装 Micro Cloud Foundry
description: 安装并运行 Micro Cloud Foundry VM
tags:
    - mcf
---

本文档帮助您下载并安装和运行 Micro Cloud Foundry VM
。完成这些任务后，您可以开始将您的
应用程序发布到 Micro Cloud Foundry 上。

**副标题**

+   [关于 Micro Cloud Foundry](#about-micro-cloud-foundry)
+   [安装概述](#installation-overview)
+   [下载 Micro Cloud Foundry 虚拟机](#downloading-the-micro-cloud-foundry-virtual-machine)
+   [启动并配置 Micro Cloud Foundry 虚拟机](#starting-and-configuring-the-micro-cloud-foundry-virtual-machine)
+   [用 vmc 注册一个 Micro Cloud Foundry 用户](#registering-a-micro-cloud-foundry-user-with-vmc)
+   [接下来的步骤](#next-steps)

## 关于 Micro Cloud Foundry

Micro Cloud Foundry 提供 VMware 开放平台作为
运行在虚拟机中的独立环境中的一项服务。它是一个自包含的
本地开发环境，尽可能与 Cloud Foundry 云类似，
从而使该云的应用程序开发以及从开发
到生产的过渡更为顺畅。

当您使用 Micro Cloud Foundry 时，您即是在使用一个本地虚拟机，它提供
与 Cloud Foundry 为您的应用程序提供的相同服务。该虚拟机
联系 VMware 服务器为您的应用程序设置 DNS。您在
本地计算机上进行开发，然后使用 `vmc` Ruby 命令行实用程序或
Eclipse/Spring 工具套件 (STS) Cloud Foundry 插件将您的
应用程序发布到 Micro Cloud Foundry 上。这样，您和您网络上的其他人就可以
在
http://api.*appname*.cloudfoundry.me 上测试您的应用程序。

当您准备好将应用程序移到生产环境时，您可以使用 `vmc` 或 STS
将应用程序发布到本地或主机托管的 Cloud Foundry 实例。

## 安装概述

安装 Micro Cloud Foundry 包括下载该虚拟机，然后
在 [VMware Workstation][1]、[VMware Fusion][2] (Mac) 或
[VMware Player][3] 中运行并配置它。当您访问 Micro Cloud Foundry
网站时，您可以为您的应用程序注册一个唯一应用程序名称 (*appname*)
。

Micro Cloud Foundry 虚拟机将连接到 VMware 服务器
以便为您的应用程序设置 DNS。这可通过使用一个配置
令牌实现，该令牌是当您访问 Micro Cloud
Foundry 网站 https://www.cloudfoundry.com/micro/dns 时为您生成的。生成的该 DNS
令牌适合在同一情况下使用；如果您的网络发生变化，您必须返回到 Micro
Cloud Foundry 网站，生成新的令牌，而且在 Micro Cloud Foundry
虚拟机中，可选择选项 4 重新配置您的域。

开始之前，务必准备好以下事项：

+   一个[Cloud Foundry](http://cloudfoundry.com/) 帐户。

+   安装 [VMware Workstation][1]、[VMware Fusion][2] (Mac) 或 [VMware Player][3]。

+   安装 Ruby 和 [vmc](/tools/vmc/installing-vmc.html) gem。

+   如果用 Java 进行开发，则需要安装 [Spring 工具套件 (STS)] 或 Eclipse 和
VMware Cloud Foundry 插件。请参见[为 Cloud Foundry 配置 Spring 工具套件或 Eclipse](/tools/STS/configuring-STS.html)。

[1]: http://www.vmware.com/products/workstation/overview.html
[2]: http://www.vmware.com/products/fusion/overview.html
[3]: http://www.vmware.com/products/player/overview.html

## 下载 Micro Cloud Foundry 虚拟机

1.  在您的 Web 浏览器中，转到 [Micro Cloud Foundry](https://cloudfoundry.com/micro)。

2.  单击“获取 Micro Cloud Foundry”，然后用您的 Cloud Foundry 电子邮件和密码登录。（如果您需要一个帐户，请单击**获取帐户**。）

2.  选中接受“最终用户许可协议”的框，然后单击 **接受**。

3.  为您的 Micro Cloud Foundry 输入唯一域名称。系统会立即核实您输入的名称，以便让您看到它是否可用。

	![创建域](/images/screenshots/installing-mcf/micro_dns.jpg "Micro DNS")

4.  单击 **创建**。

    系统即保存您的新域名并为您创建配置令牌。

	![预留域](/images/screenshots/installing-mcf/micro_reserved.png "域已保存")

5.  记下该配置令牌。后面的步骤将用到它。

6.  单击 **下载 Micro Cloud Foundry VM** 并保存该文件。

## 启动并配置 Micro Cloud Foundry 虚拟机

1.  将压缩的 Micro Cloud Foundry VM 包解压。这会创建文件夹
    `micro`，它包含虚拟机的文件。

2.  启动 VMware Workstation、VMware Fusion 或 VMware Player 并打开 `micro/micro.vmx` 文件。

3.  启动虚拟机。

4.  在“欢迎”屏幕上，选择 **1** 以进行配置。

5.  通过输入并确认新密码为 Micro Cloud Foundry 设置密码。

6.  在*Select network:* 提示符处，输入 **1** 以使用 DHCP 配置网络。

7.  在*HTTP proxy:* 提示符处，按 Enter 为 HTTP 代理选择 **none**。

    如果您处于 HTTP 代理后，请输入代理服务器的 URL，例如 `http://192.168.1.125:8023`。

8.  输入从 Micro Cloud Foundry 网站获得的配置令牌。

```bash
              Welcome to VMware Micro Cloud Foundry version 1.2.0

Network up
Micro Cloud Foundry not configured

1. configure
2. refresh console
3. help
4. shutdown VM

select option: 1

set password Micro Cloud Foundry VM user
Password: ********
Confirmation: ********
Password changed!

1. DHCP
2. Static
Select network: 1

HTTP proxy: |none|

Enter Micro Cloud Foundry configuration token or offline domain name: shock-throw-caption
```
Micro Cloud Foundry 虚拟机将验证您的 DNS 并配置 Micro Cloud。

**注意：**
如果您打算在没有 Internet 连接的情况下使用 Micro Cloud Foundry，请输入虚构的域名而不是 DNS 配置令牌。这个高级配置选项将在[使用 Micro Cloud Foundry](/infrastructure/micro/using-mcf.html#working-offline-with-micro-cloud-foundry) 中介绍。


## 用 vmc 注册一个 Micro Cloud Foundry 用户

注册用户会在 Micro Cloud Foundry 虚拟机上创建一个用户
帐户。您可以使用此帐户登录发布和管理应用程序。

*注意：*
请参见[安装命令行界面 (vmc)](/tools/vmc/installing-vmc.html) 获取
安装 `vmc` 的帮助。

: 请参见 [VMC 快速参考](/tools/vmc/vmc-quick-ref.html)了解有关使用
`vmc` 命令的更多信息。

: 请参见[为 Cloud Foundry 配置 Spring 工具套件或 Eclipse](/tools/STS/configuring-STS.html)
    以帮助在 STS 或 Eclipse 中设置
    Cloud Foundry Integration 插件并从该插件内注册
    Micro Cloud Foundry 用户。

在后续步骤中，*appname* 是您在 Micro Cloud Foundry 网站为
您的应用程序注册的域。

将您的目标指向 Micro Cloud Foundry。在 shell 中，输入以下命令：

```bash
$ vmc target api.appname.cloudfoundry.me
```
使用 `vmc register` 命令创建一个新帐户：

```bash
$ vmc register
```

输入您的电子邮件地址。

要求时输入并确认密码。

```bash
$ vmc target api.pubs.cloudfoundry.me
Successfully targeted to [http://api.pubs.cloudfoundry.me]

$ vmc register
Email: myemail@mydomain.com
Password: ********
Verify Password: ********
Creating New User: OK
Successfully logged into [http://api.pubs.cloudfoundry.me]
```

至此，您即可使用 `vmc` 登录或设置 Spring 工具套件以将您的
应用程序部署到 Micro Cloud Foundry。

## 接下来的步骤

+ [使用 vmc 登录到您的 Micro Cloud Foundry](using-mcf.html#using-microcloud-foundry-vmc)
+ [使用 Spring 工具套件 (STS) 登录到您的 Micro Cloud Foundry](using-mcf.html#using-micro-cloud-foundry-sts)
+ [日常 Micro Cloud Foundry 管理](using-mcf.html)


