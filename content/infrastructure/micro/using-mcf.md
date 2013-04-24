---
title: 使用 Micro Cloud Foundry
description: 使用 Micro Cloud Foundry 控制台
tags:
    - 概述
    - mcf
    - mongodb
---

**副标题**

- [Micro Cloud Foundry 默认配置](#micro-cloud-foundry-default-configuration)
- [使用 Micro Cloud Foundry 控制台](#using-the-micro-cloud-foundry-console)
- [Micro Cloud Foundry 资源限制](#micro-cloud-foundry-resource-limits)
- [增加 Micro Cloud Foundry 虚拟机内存](#increasing-micro-cloud-foundry-virtual-machine-memory)
- [登录到 Micro Cloud Foundry](#logging-in-to-micro-cloud-foundry)
- [配置 Micro Cloud Foundry 网络](#configuring-micro-cloud-foundry-networking)
- [离线使用 Micro Cloud Foundry](#working-offline-with-micro-cloud-foundry)
- [排除 Micro Cloud Foundry 故障](#troubleshooting-micro-cloud-foundry)


## Micro Cloud Foundry 默认配置

本节介绍 Micro Cloud Foundry 版本 1.2 的默认配置。

### 虚拟机配置

+ 内存：1GB
+ 磁盘：16GB
+ 虚拟 CPU 数： 2

### 服务限制

+ MySQL：2GB 存储，每个实例最多 256MB 存储
+ Postgres：2GB 存储，每个实例最多 256MB 存储
+ Mongo DB：每个实例 256MB
+ Redis：每个实例 256MB

### 运行时版本

+ ruby18：Ruby 1.8，版本 1.8.7
+ ruby19：Ruby 1.9，版本 1.9.2p180
+ java：Java 6，版本 1.6
+ node：Node.js，版本 0.4.12
+ node06：Node.js，版本 6.0.8

### 框架

+ rails3
+ sinatra
+ grails
+ node
+ java_web
+ lift
+ spring

### 服务版本

+ mongodb：MongoDB NoSQL 存储，版本 2.0
+ mysql：MySQL 数据库服务，版本 5.1
+ postgresql：vFabric PostgreSQL 数据库服务，版本 9.0
+ rabbitmq：RabbitMQ 消息传送服务，版本 2.4
+ redis：Redis 键值存储服务，版本 2.2

## 使用 Micro Cloud Foundry 控制台

当您启动 Micro Cloud Foundry 虚拟机时，Linux 将引导并
显示控制台文本菜单。控制台菜单是 micro cloud 的
主要管理界面。

控制台会在顶部显示状态信息，包括 Micro Cloud
Foundry 版本、主机名（标识）、Cloud Foundry 帐户电子邮件地址（管理）
和分配给虚拟机的 IP 地址。

通过输入编号并按 <Enter> 可从菜单中选择选项。该
控制台会提示您输入执行任务所需的任何信息。

1. **刷新控制台**。选择此选项将重绘控制台显示，例
如，当消息显示需要让菜单滚屏时。

2. **刷新 DNS**。更新 DNS 记录中的 Micro Cloud Foundry IP
地址。

3. **重新配置 vcap 密码**。选择此选项可更改 `root` 和 `vcap` 用户的密码。

4. **重新配置域**。当您创建新域或
为您的 Micro Cloud Foundry 域生成新令牌时，请选择此选项。登录到 [Micro
Cloud Foundry 网站](https://my.cloudfoundry.com/micro) 以管理域并
提示时检索要输入的令牌。

5. **重新配置网络**。使用此选项可在 DHCP 和静态
网络配置之间进行选择。如果选择 **静态**，则控制台会提示输入 IP
地址、网关、网络掩码和 DNS 服务器。

6. **启用脱机模式**。选择此选项可在联机和脱机模式之间切换虚拟机。

7. **重新配置代理**。如果处于需要代理的网络上，请选择
此选项并输入代理的地址和端口，例如： `192.168.1.128:4000`.

8. **服务**。显示 micro cloud 上服务的状态。

9. **重新启动网络**。重新启动虚拟机上的网络服务。

10. **还原默认值**。

11. **专家菜单**。显示“专家”菜单，您可以从此菜单设置调试级别、显示日志以及在 Micro Cloud Foundry 执行其他高级配置。

12. **帮助**。显示联机安装和设置文档的 URL 以及
虚拟机和服务的默认配置限制。

13. **关闭 VM**。关闭 Micro Cloud Foundry 虚拟机。

## Micro Cloud Foundry 资源限制

Micro Cloud Foundry 具有以下默认资源限制：

+ VM：1 GB RAM，16 GB 磁盘
+ MySQL：2 GB 磁盘，每个实例最多 256 MB
+ MongoDB：每个实例 256 MB
+ Redis：每个实例 256 MB

管理用户具有以下限制：

+ 1.0 G 内存
+ 最多置备 16 项服务
+ 最多 16 个应用程序

## 增加 Micro Cloud Foundry 虚拟机内存

Micro Cloud Foundry 虚拟机初始配置 1GB 内存。
如果您的应用程序需要更多内存，请按以下步骤操作：

1. 关闭 Micro Cloud Foundry 虚拟机。

2. 在 VMware Workstation for VMware Player 中，右键单击 Micro Cloud Foundry 虚拟机，然后选择“设置”。

3. 单击“内存”并在右面板中指定新的内存大小。

4. 单击“确定”。

5. 启动虚拟机。

6. 从控制台菜单中选择新的突出显示项 **重新配置内存**。

Micro Cloud Foundry 即会为新内存大小重新配置虚拟机和服务。



## 在网络之间切换

如果您经常在网络之间切换，而且不需要让 Micro Cloud Foundry VM 可供其他用户使用，将 VM 网络配置为使用 NAT 而不是桥接模式更方便。从版本 1.2 开始，NAT 是 Micro Cloud Foundry VM 的默认模式。如果要将您的云与其他用户共享，则必须启用桥接模式。

## 登录到 Micro Cloud Foundry

Micro Cloud Foundry 是具有 Ubuntu Linux 操作系统
和 Cloud Foundry 软件层以及应用程序服务的虚拟机。没有
安装图形桌面环境，但您可以登录到该虚拟
机并使用 `ssh` 获取一个 bash shell。

以任何方式自定义 Cloud Foundry 服务均为不妥做法，因为
这样会引入一个依赖项，在您将应用程序
移到另一个 Cloud Foundry 时不能满足该依赖项。

可能登录到 Micro Cloud Foundry 的部分原因如下：

+   查看服务器日志文件
+   检查进程状态或负载，例如使用 `top`
+   排除本地网络的 DNS 故障

您可以以 `root` 或 `vcap` 用户身份登录，使用初次
启动和配置 Micro Cloud Foundry 虚拟机时设置的密码。

从安装了 `ssh` 的计算机上，使用类似下面这样的命令
登录到 Micro Cloud foundry：

        $ssh root@domain.cloudfoundry.me

其中，*domain* 是您为 Micro Cloud Foundry 注册的域名。
也可以使用为该虚拟机分配的 IP 地址，该地址
显示在控制台上。

## 配置 Micro Cloud Foundry 网络

Micro Cloud Foundry 提供了类似于 Cloud Foundry 的网络环境。
使用 DNS 解析 URL 以定位运行您应用程序的
主机，即 Micro Cloud Foundry 虚拟机。应用程序
将处理该请求，包括分析该 URL 和 HTTP 请求的
余下部分并返回一个响应给客户端。客户端浏览器和
应用程序将与网络交互，其方式与在生产中的方式完全
相同，只不过云运行于相同主机上。

开发和部署工具（`vmc` 和 STS）与 Micro Cloud
Foundry 作用的方式也与它们和 CloudFoundry.com 或者任何本地或托管 Cloud
Foundry 实例作用的方式相同。

为了提供类似于生产的网络环境，Micro Cloud Foundry 在 DNS 中将
虚拟机的 IP 地址与*domain*.cloudfoundry.me 相关联。这
要求有 Internet 连接，以便 Micro Cloud Foundry 能在您使用
浏览器访问应用程序时在 `cloudfoundry.me` 中更新其地址，并且可以
解析该 URL。当虚拟机被分配新的 IP
地址时，例如，如果您移到其他位置，它会更新 DNS
记录。

如果您的浏览器使用代理而且 DNS 查找不工作，您可能必须
从代理中排除 `.cloudfoundry.me`。

您在 Micro Cloud Foundry 虚拟机中配置网络适配器的
方式决定了谁可以访问您的 micro cloud：

- 如果您选择“桥接网络连接”选项，则您的 micro cloud 将从
LAN 上的 DHCP 服务器中获取 LAN 上的一个地址。这样就可以从 LAN 上的其他
主机访问它。

- 如果您选择“NAT 网络连接”选项，则您的 micro cloud 将获取
网络上仅存在于运行该虚拟机的主机上的地址。
这样就只能从运行该虚拟机的主机上的浏览器访问您的
云。

与桥接网络选项不同的是，使用 NAT 连接选项，当您改变
位置时，您不会获得新地址。如果您不与其他人共享您的
micro cloud，而且经常四处移动，请使用 NAT 选项以避免
可能出现的 DNS 更新滞后。

## 离线使用 Micro Cloud Foundry

当您使用从 Cloud Foundry 网站获得的令牌安装 Micro Cloud Foundry 时，它会使用动态 DNS 功能，以便与该 VM 处于同一网络的任何连接 Internet 的计算机可以与其连接。也就是说，为该 VM 获取本地网络地址需要访问 Internet，即使您从运行该 VM 的相同计算机上对其进行访问也是如此。这种方式称之为联机模式，它要求能访问 Internet。

如果您不得不在没有 Internet 连接的情况下工作，则必须将 Micro Cloud Foundry 置为脱机模式，并将您的主机配置为将您的 DNS 请求发送到 Micro Cloud Foundry VM。而且，如果您最初是用域名而非配置令牌配置的 Micro Cloud Foundry，则必须*始终* 使用脱机模式。

只有设置为 NAT 的 VM 网络适配器才支持脱机模式。这意味着只能从运行它的主机对其进行访问。要与其他用户共享您的 Micro Cloud Foundry，必须将网络适配器设置为桥接模式，并以联机模式运行 Micro Cloud Foundry。

如果以脱机模式使用 Micro Cloud Foundry，而且仍然有活动的 Internet 连接，那么在访问 Internet 上的站点时可能会遇到问题。

### 将 Micro Cloud Foundry 配置为脱机模式

您可以手动或使用 `vmc micro` 命令配置脱机模式。使用 `vmc micro` 命令需要 VMC 版本 0.3.16.beta4 或更高版本。相关说明请参见[使用 VMC micro 命令](#using-the-vmc-micro-command)。

本节剩余部分将介绍如何手动配置脱机模式。

将 Cloud Foundry 置为脱机模式需要完成三项任务。

**第 1 步**.在该 VM 的“虚拟机设置”中，选择“网络适配器”并确保选中 NAT。如果必须更改设置，请重新启动虚拟机。

**第 2 步**.在 Micro Cloud Foundry 控制台菜单中，选择选项 6 以切换到脱机模式。

**第 3 步**.将您的主机配置为将 DNS 请求路由到 Micro Cloud Foundry VM。其实现方式有所不同，具体取决于操作系统以及您是使用 DHCP 还是使用静态 IP 地址。在后面的指令中，请将 IP 号 172.16.52.136 替换为 Micro Cloud Foundry 控制台上显示的 IP 号。将 mydomain.micro 替换为您的脱机域名。

### Linux

如果您使用的是 DHCP，请编辑文件 `/etc/dhcp3/dhclient.conf` 并添加此行：

```bash
prepend domain-name-servers 172.16.52.136
```

如果用静态 IP 配置 VM，请编辑文件 `/etc/resolv.conf` 并在剩余的名称服务器之前添加下面这一行：

```bash
nameserver 172.16.52.136
```

### Mac OS X

如果您使用的是 DHCP，请创建目录 `/etc/resolver`，然后用您的脱机域名创建一个文件，例如 `mydomain.micro`。将下面这一行添加到此文件：

```bash
nameserver 172.16.52.136
```

如果您使用静态 IP 配置了 Micro Cloud Foundry，请打开“网络首选项”并在 DNS 服务器列表中首先添加 172.16.52.136。

### Windows

无论是用 DHCP 还是静态 IP 地址配置的 Micro Cloud Foundry，都请按照下述步骤操作：

+ 打开“网络和共享”控制面板。
+ 选择“更改适配器设置”。
+ 右键单击 VMware Virtual Ethernet Adapter for VMnet8 并选择“属性”。
+ 将首选 DNS 服务器设置为 172.16.52.136。

## 使用 VMC Micro 命令

`vmc micro` 命令可自动执行上一节介绍的步骤。回顾上一节了解该命令如何更改您的配置。

安装 vmc gem，或者在需要时将它升级。您需要版本 0.3.16.beta4 或更高版本。相关说明请参见 [VMC 安装](/tools/vmc/installing-vmc.html)。

下面是 `vmc micro` 命令的语法：

```bash
Usage: vmc micro [options] command

Options
  --password          VCAP user password
  --vmrun             /path/to/vmrun
  --vmx               /path/to/micro.vmx
  --save              Save VCAP password

Commands
  offline             Run Micro Cloud in offline mode
  online              Run Micro Cloud in online mode
  status              Display current status
```

要重新配置并控制虚拟机，vmc 需要有到 .vmx 文件和 vmrun 命令的路径。它可能会在您提供的路径中查找 vmrun 命令，但当您第一次运行它时，必须使用 --vmx 选项提供到 micro.vmx 文件的路径。这些路径保存在您主目录中的 .vmc_micro 文件中，因此将来运行时您不必再次指定这些选项。

在下面的示例中，指定了到 micro.vmx 文件的路径。vmc 会发现该 VM 未运行并提供机会让您启动它。它将报告状态并询问是否保存密码以供将来运行时使用。

```bash
$ vmc micro --vmx /home/mcf/micro.vmx status
Please enter your Micro Cloud Foundry VM password (vcap user)
Password: ********
Confirmation: ********
Micro Cloud Foundry is not running. Do you want to start it? y
Micro Cloud Foundry currently in online mode
VMX Path: /home/mcf/micro.vmx
Domain: mydomain.cloudfoundry.me
IP Address: 192.168.255.134
Do you want to save your password? n
```

执行 `vmc micro offline` 以脱机工作。

```bash
$ vmc micro offline
```

此命令会将 VM 置为脱机模式（与从菜单中选择选项 6 的作用相同），并将您主机上的 DNS 设置为查询 VM。对于需要管理或根权限的操作，可能会提示您进行身份验证。

执行 `vmc micro online` 以联机工作。

```bash
$ vmc micro online
```

此命令会将 VM 置为联机模式，并对您主机上的 DNS 配置进行相反更改。对于需要管理或根权限的操作，可能会提示您进行身份验证。


## 排除 Micro Cloud Foundry 故障

### 收集调试信息

如果遇到问题并且需要调试帮助，请执行以下操作：

1.  在 Micro Cloud Foundry 控制台菜单中，输入 11 以显示 Expert 菜单。

2.  输入 1 以将调试级别设置为 DEBUG。

3.  从 VM 中检索 `/var/vcap/sys/log/micro/micro.log` 文件并将它附加到支持票证。要检索该文件，请以 vcap 用户身份用配置 VM 时设置的密码登录到 VM。例如，使用 scp 和控制台中显示的 IP 地址：

```bash
$ scp vcap@92.168.1.215:/var/vcap/sys/log/micro/micro.log .
```

### 代理问题

如果使用代理，请记住，代理可能无法访问您的 Micro Cloud Foundry VM。例如，如果您将 VM 的网络适配器设置为使用 NAT，则代理无法发现该 VM，因此您必须排除您的域系统的代理设置。

如果 VM 的网络适配器使用桥接模式而且您的主机上有 VPN，则会发生另一个与代理相关的问题。Micro Cloud Foundry VM 流量不会进入通道，因此无法到达代理。

### 访问实例时的问题

如果您的 Micro Cloud Foundry VM 的 DNS 条目不是最新的，则访问您的实例可能失败。例如：

```bash
$ vmc target api.martin.cloudfoundry.me
Host is not valid: 'http://api.martin.cloudfoundry.me'
Would you like see the response [yN]? y
HTTP exception: Errno::ETIMEDOUT:Operation timed out - connect(2)
```

检查 Micro Cloud Foundry 控制台。选择“1”以刷新屏幕。如果看见类似下面这样的“DNS 不同步”消息：

```bash
Current Configuration:
 Identity:   martin.cloudfoundry.me (DNS out of sync)
 Admin:      martin@englund.nu
 IP Address: 10.21.164.29 (network up)
```

请选择“2”强制进行 DNS 更新。

如果控制台的 DNS 状态为“ok”，则表示 VM 的 IP 地址与 DNS 中的 IP 匹配。使用主机命令验证您的本地系统上没有缓存的条目。

```bash
$ host api.martin.cloudfoundry.me
api.martin.cloudfoundry.me is an alias for martin.cloudfoundry.me.
martin.cloudfoundry.me has address 10.21.165.53

```

如果两者不同，则需要刷新 DNS 缓存：

**Mac OS X**

```bash
dscacheutil -flushcache
```

**Linux (Ubuntu)**

```bash
sudo /etc/init.d/nscd restart
```

**Windows**

```bash
ipconfig /flushdns
```

### 配置 Micro Cloud VM 时显示“无法连接到 cloudfoundry.com”消息

当您将 Micro Cloud VM 配置为使用 DHCP 时，会从网络的 DHCP 池中为其分配一个地址。如果您不断地创建/销毁 VMs，例如在测试环境中，而且您的 DHCP 地址有 12 到 24 小时的租用寿命，则有可能耗尽 DHCP 池。因此，在配置过程中，尽管您能使用浏览器访问 cloudfoundry.com，但您会看到无法连接到 cloudfoundry.com 的消息。重新启动 DHCP 服务器应该能将未使用的租用地址退回地址池，这样您就能在租用期到期前重新使用它们。

