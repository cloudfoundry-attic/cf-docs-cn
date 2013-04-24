---
title: BOSH文档
description: BOSH文档
tags:
    - BOSH
---

Cloud Foundry BOSH 是一条开源工具链，用于对大规模分布式服务进行发行版工程处理、部署和生命周期管理。在本手册中，我们将介绍 BOSH 的体系结构、拓扑、配置和用法，以及在打包和部署过程中使用的结构和约定。

## 管理分布式服务 ##

BOSH 最初是在 Cloud Foundry“应用平台即服务”的背景下开发的，不过，此框架是通用的，可以用来在诸如 VMware vSphere、Amazon Web Services 或 OpenStack 等“基础架构即服务”(IaaS) 产品的基础上部署其他分布式服务。

## BOSH 的组件 ##

### 图 1. BOSH 各组件之间的交互 ###

![Interaction of BOSH Components](https://github.com/cloudfoundry/oss-docs/raw/master/bosh/documentation/fig1.png)

<!--
\begin{figure}[htbp]
\centering
\includegraphics[keepaspectratio,width=\textwidth,height=0.75\textheight]{fig1.png}
\caption{Interaction of BOSH Components}
\label{}
\end{figure}
-->

### 基础架构即服务 (IaaS) ###

核心的 BOSH 引擎是基于任何特定的“基础架构即服务”(IaaS) 抽象出来的。IaaS 接口以 BOSH 插件的形式实现。目前，BOSH 既支持 VMware vSphere，又支持 Amazon Web Services。

### 云提供商接口 ###

IaaS 接口插件通过由诸如 VMware 或 Amazon 等特定 IaaS 供应商提供的云提供商接口 (CPI) 进行通信。作为 BOSH 用户，无需关心 IaaS 或 CPI，但在学习 BOSH 工作原理时了解其基元可能会有助益。这些接口的现有示例的位置如下：	对于 vSphere，位于 `bosh/vsphere_cpi/lib/cloud/vsphere/cloud.rb` 中；对于 Amazon Web Services，位于 `bosh/aws_cpi/lib/cloud/aws/cloud.rb` 中。上述子目录中包含了一些 Ruby 类，这些类包含用来执行以下操作的方法：

	create_stemcell / delete_stemcell
	create_vm  / delete_vm  / reboot_vm
	configure_networks
	create_disk / delete_disk / attach_disk / detach_disk

有关对 CPI 基元的进一步说明，请参考这些文件中的 [API 文档](https://github.com/cloudfoundry/bosh/blob/master/cpi/lib/cloud.rb)。

### BOSH 控制器 ###

控制器是 BOSH 中的核心协调组件，它控制着创建虚拟机、进行部署以及软件和服务生命周期中的其他事件。在 CPI 创建好资源后，命令和控制权会移交给控制器与代理间的交互操作。

### BOSH 代理 ###

BOSH 代理负责侦听来自 BOSH 控制器的指令。每个虚拟机都包含一个代理。通过控制器与代理之间的交互，会在 Cloud Foundry 中为虚拟机分配[作业](#jobs)（或称“角色”）。
例如，如果虚拟机的作业是运行 MySQL，那么控制器将向代理发送指令来说明必须安装哪些包以及这些包的配置是什么。

### BOSH CLI ###

BOSH 命令行界面是用户使用终端会话与 BOSH 进行交互的途径。BOSH 命令采用下面所示的格式：

$ bosh [--verbose] [--config|-c <FILE>] [--cache-dir <DIR>]
[--force] [--no-color] [--skip-director-checks] [--quiet]
[--non-interactive]

如需了解有关这些选项的更多详情，请[安装](#installing-bosh-command-line-interface) [BOSH 命令行界面](http://rubygems.org/gems/bosh_cli) gem，然后运行 `bosh` 命令。

### Stemcell ###

Stemcell 是一个嵌入了 [BOSH 代理](#bosh-agent)的虚拟机模板。用于 Cloud Foundry 的 Stemcell 是一个标准的 Ubuntu 分发包。
Stemcell 是使用 [BOSH CLI](#bosh-cli) 上传的，由 [BOSH 控制器](#bosh-director)在通过[云提供商接口] (#cloud-provider-interface)创建虚拟机时使用。
当此控制器通过 CPI 创建虚拟机时，它会将用于网络连接和存储的配置以及[消息总线](#message-bus)和 [Blobstore](#blobstore) 的位置及凭据传递下去。

### 发行版 ###

BOSH 中的发行版是将一些称作“作业”的服务描述符打包成的捆绑包。作业是由软件代码 (Bit) 和配置组成的集合。
任何给定的发行版均包含让 BOSH 管理应用程序或分布式服务所需的全部静态代码（源代码或二进制代码）。

发行版通常不局限于任何特定环境。因此，可以跨群集重用它来处理服务生命周期中的不同阶段，如开发、QA、暂存或生产。
[BOSH CLI](#bosh-cli) 既管理发行版的创建工作，也管理将它们部署到特定环境中的工作。

如需更深入地了解发行版和[作业](#jobs)，请参见[包](#packages)一节。

### 部署 ###

虽然 BOSH 的 [Stemcell](#stemcells) 和[包](#packages)都是静态组件，但 [BOSH 部署清单](#bosh-deployment-manifest)将它们绑定在一起进行部署。
在部署清单中，您需要声明虚拟机池、这些池位于哪些网络中以及您要激活发行版中的哪些[作业](#jobs)（服务组件）。
作业配置指定了生命周期参数、作业的实例数目以及网络和存储要求。
此外，通过部署清单，您还可以指定用来对发行版中包含的配置模板进行参数化的属性。

借助 [BOSH CLI](#bosh-cli)，您可以指定部署清单并执行部署操作 (`bosh deploy`)，部署操作会按照您的指定在群集中创建或更新资源。
有关示例，请参考[部署步骤](#steps-of-a-deployment)。

### Blobstore ###

BOSH Blobstore 用于存储发行版的内容（源代码形式的 BOSH [作业](#jobs)和[包](#packages)以及编译后的 BOSH 包映像）。
[发行版](#releases)由 [BOSH CLI](#bosh-cli) 上传并由 [BOSH 控制器](#bosh-director)插入到 Blobstore 中。
部署发行版时，BOSH 将协调包的编译工作，并将结果存储在 Blobstore 中。
BOSH 将 BOSH 作业部署到虚拟机时，BOSH 代理会从 Blobstore 中提取指定的作业及关联的 BOSH 包。

BOSH 还将该 Blobstore 用作大型有效负载的中间存储区，例如日志文件（请参见 BOSH 日志）以及超过消息总线上消息的最大大小的 BOSH 代理输出。

目前在 BOSH 中支持三种 Blobstore：

1. [Atmos](http://www.emc.com/storage/atmos/atmos.htm)
1. [S3](http://aws.amazon.com/s3/)
1. [简单 blobstore 服务器](https://github.com/cloudfoundry/bosh/tree/master/simple_blobstore_server)

有关每种 Blobstore 的示例配置，请参见 [Blob](#blobs) 一节。当负载非常轻且用户更看重低延迟时，默认的 BOSH 配置使用简单 blobstore 服务器。

### 运行状况监视器 ###

BOSH 运行状况监视器负责接收 [BOSH 代理](#bosh-agent)发来的运行状况和生命周期事件，并且可以通过通知插件发送提醒（如电子邮件）。运行状况监视器对系统中的事件具有简单的感知能力，因此如果是更新组件，它便不会发出提醒。

### 消息总线 ###

BOSH 使用 [NATS](https://github.com/derekcollison/nats) 消息总线来发出命令和进行控制。

## 使用 BOSH ##

我们需要先安装 [BOSH CLI](#bosh-cli)，然后才能使用 BOSH。您需要有一个包含已上传的 Stemcell 且正在运行的开发环境，接下来才能按照本节中的说明操作。如果尚不具备此条件，您可以按照 [BOSH 安装](#bosh-installation)一节中的说明操作。

### 安装 BOSH 命令行界面 ###

按以下步骤操作可将 BOSH CLI 安装到 Ubuntu 10.04 LTS 上。可以在物理机上安装，也可在虚拟机上安装。

#### 通过 rbenv 安装 Ruby ####

1. BOSH 是用 Ruby 编写的。我们来安装 Ruby 的依赖项

		sudo apt-get install git-core build-essential libsqlite3-dev curl \
	    libmysqlclient-dev libxml2-dev libxslt-dev libpq-dev

1. 获取最新版本的 rbenv

		cd
		git clone git://github.com/sstephenson/rbenv.git .rbenv

1. 将 `~/.rbenv/bin` 添加到您的 `$PATH` 以便能够访问 `rbenv` 命令行实用程序

		echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile

1. 将 rbenv init 添加到您的 shell 以启用填充程序 (Shim) 和自动完成

		echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

1. 下载 Ruby 1.9.2

_注意：您也可以使用适用于 rbenv 的 ruby-build 插件来构建 ruby。请参见 https://github.com/sstephenson/ruby-build_

		wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz

1. 将 Ruby 解包并安装

		tar xvfz ruby-1.9.2-p290.tar.gz
		cd ruby-1.9.2-p290
		./configure --prefix=$HOME/.rbenv/versions/1.9.2-p290
		make
		make install

1. 重新启动您的 shell 以使路径更改生效

		source ~/.bash_profile

1. 将您的默认 Ruby 设置为 1.9.2 版本

		rbenv global 1.9.2-p290

_注意：使用此方法时可能需要重新安装 rake 0.8.7 gem_

		gem pristine rake

1. 更新 rubygem 并安装捆绑包。

_注意：安装 gem（`gem install` 或 `bundle install`）后，运行 `rbenv rehash` 以添加新的填充程序_

		rbenv rehash
		gem update --system
		gem install bundler
		rbenv rehash

#### 安装本地 BOSH 和 BOSH 发行版 ####

1. 在 [http://reviews.cloudfoundry.org](http://reviews.cloudfoundry.org) 注册 Cloud Foundry Gerrit 服务器

1. 设置您的 ssh 公钥（接受所有默认值）

		ssh-keygen -t rsa

1. 将您的密钥从 `~/.ssh/id_rsa.pub` 复制到您的 Gerrit 帐户中

1. 在您的 Gerrit 帐户配置文件中创建并上传自己的公共 SSH 密钥

1. 设置您的名称和电子邮件

		git config --global user.name "Firstname Lastname"
		git config --global user.email "your_email@youremail.com"

1. 安装好 gerrit-cli gem

		gem install gerrit-cli

1. 从 Gerrit 克隆 BOSH 代码库

		gerrit clone ssh://[<your username>@]reviews.cloudfoundry.org:29418/cf-release.git
		gerrit clone ssh://[<your username>@]reviews.cloudfoundry.org:29418/bosh.git

1. 运行一些 rake 任务来安装 BOSH CLI

		gem install bosh_cli
		rbenv rehash
		bosh --version


#### 部署到您的 BOSH 环境 ####

有了完全配置好的环境后，我们便可以开始将 Cloud Foundry 发行版部署到我们的环境中了。正如前提条件中所列的那样，您应该已经有了一个正在运行的环境，以及 BOSH 控制器的 IP 地址。要设置这项前提条件，请跳至 [BOSH 安装](#bosh-installation)一节。

#### 使 BOSH 指向一个目标并清理您的环境 ####

1. 为控制器设定目标（例如设定为下面的 IP）。

		bosh target 11.23.128.219:25555

1. 检查 BOSH 设置的状态。

		bosh status

1. 状态结果将类似于：

		Target         dev48 (http://11.23.128.219:25555) Ver: 0.3.12 (01169817)
		UUID           4a8a029c-f0ae-49a2-b016-c8f47aa1ac85
		User           admin
		Deployment     not set

1. 列出以前的所有部署（我们很快就会删除它们）。如果这是您首次部署，将不会有任何内容列出。

		bosh deployments

1. `bosh deployments` 的结果应类似于：

		+-------+
		| Name      |
		+-------+
		| dev48 |
		+-------+

1. 删除现有的部署（例如：dev48）。

		bosh delete deployment dev48

1. 出现提示时请回答 `yes`，然后等待删除操作完成。

1. 列出以前的发行版（我们很快就会删除它们）。如果这是您首次部署，将不会有任何内容列出。

		bosh releases

1. `bosh releases` 的结果应类似于：

		+---------------+---------------+
		| Name          | Versions      |
		+---------------+---------------+
		| cloudfoundry	| 47, 55, 58    |
		+---------------+---------------+

1. 删除现有的发行版（例如：cloudfoundry）

		bosh delete release cloudfoundry

1. 出现提示时请回答 `yes`，然后等待删除操作完成。

#### 创建一个发行版 ####

1. 将目录切换到发行版目录。

		cd ~/cf-release
	
	此目录包含 Cloud Foundry 部署和发行版文件。

1. 更新子模块并下载 blob（还用于更新代码库）。

		./update

1. 重置您的环境

		bosh reset release

1. 出现提示时请回答 `yes`，然后等待环境重置完毕

1. 创建一个发行版

		bosh create release --force

1. 出现 `release name` 提示时请回答 `cloudfoundry`

1. 您的终端将显示有关此发行版的信息，包括发行版清单、包、作业和 tar 包位置。

1. 创建或找到一个清单文件。例如，可以从
`oss-docs` 文档资源库复制 `bosh/samples/cloudfoundry.yml`
。

1. 用您喜欢的文本编辑器打开此清单文件，确认 `name` 和 `version` 是否与发行版创建结束时终端中显示的版本匹配（如果这是您的第一个发行版，将为版本 1）。

#### 部署此发行版 ####

1. 将部署设置为指向您的清单文件

bosh deployment path/to/my-manifest.yml

1. 将此 cloudfoundry 发行版上传到您的环境。

		bosh upload release

1. 您的终端将显示有关此次上传的信息，上传进度栏将在几分钟后达到 100%。

1. 打开此清单，确保您的网络设置与之前向您提供的环境匹配。

1. 部署此发行版。

		bosh deploy

1. 此次部署将需要几分钟时间才能完成。如果部署失败，原因可能是此清单与发行版目录不匹配。如果您的目标平台具有由管理员提供的模板清单（如 `template.erb`），您可以使用 `bosh diff template.erb` 来将您的清单与最新的目标进行对比，然后修复常见的问题，例如缺少属性或作业。

1. 现在您便可以按照 Cloud Foundry 文档中的说明使用 VMC 来为 Cloud Foundry 部署设定目标。

## BOSH 安装 ##

BOSH 的安装是使用一款称作“微 BOSH”(Micro BOSH) 的工具完成的，该工具是一个虚拟机，在同一映像中包含了所有的 BOSH 组件。如果您想要体验一下 BOSH，或者创建一个简单的部署环境，那么您可以使用 [BOSH 部署器](#bosh-deployer)来安装微 BOSH。如果您想要在生产环境中使用 BOSH 来管理分布式系统，您也可以使用 BOSH 部署器，安装微 BOSH，然后将它用作一种在多个虚拟机上部署最终分布式系统的方式。

理解这种两步过程的一种很好的方式就是将 BOSH 本身也看作一个分布式系统。由于 BOSH 的核心用途是部署和管理分布式系统，因此我们使用它来部署它自己是合情合理的。在 BOSH 团队中，我们将此戏称为[盗梦空间](http://en.wikipedia.org/wiki/Inception)。

### BOSH 引导程序 ###

#### 前提条件 ####

1. 我们建议您运行 Ubuntu 中的 BOSH 引导程序，因为它是 BOSH 团队所使用的分发包且已经过全面测试。

1. 在 Ubuntu 上安装 BOSH 部署器所依赖的一些核心包。

		sudo apt-get -y install libsqlite3-dev genisoimage

1. 安装 Ruby 1.9.2 或更高版本。

1. 安装 BOSH 部署器 ruby gem。

		gem install bosh_deployer

一旦安装了该部署器，那么您在命令行中键入 `bosh` 后将会看到一些额外的命令显示出来。

**上述 `bosh micro` 命令必须在微 BOSH 部署目录中运行**

		% bosh help
		...
		Micro
			micro deployment [<name>] 选择要使用的微部署
			micro status              显示微 BOSH 部署的状态
			micro deployments         显示部署列表
			micro deploy <stemcell>   将微 BOSH 实例部署到当前
选择的部署
                            --update  更新现有实例
			micro delete              删除微 BOSH 实例（包括
持久磁盘）
			micro agent <args>        发送代理消息
			micro apply <spec>        应用规范


#### 配置 ####

有关最低 vSphere 配置示例，请参见：`https://github.com/cloudfoundry/bosh/blob/master/deployer/spec/assets/test-bootstrap-config.yml`。请注意 `disk_path` 为 `BOSH_Deployer`，而非 `BOSH_Disks`。如果您的 vCenter 承载其他控制器，那么需要一个除 `BOSH_Disks` 以外的数据存储文件夹。`disk_path` 文件夹需手动创建。此外，您的配置必须位于 `deployments` 目录中，并遵循具有包含 `micro_bosh.yml` 的 `$name` 子目录这一约定，其中 `$name` 是部署名称。

例如：

		% find deployments -name micro_bosh.yml
		deployments/vcs01/micro_bosh.yml
		deployments/dev32/micro_bosh.yml
		deployments/dev33/micro_bosh.yml

部署状态将持久保留到 `deployments/bosh-deployments.yml`。

#### vCenter 配置 ####

虚拟中心配置节大致如下。

		cloud:
		  plugin:vsphere
		  properties:
		    agent:
		      ntp:
		        - <ntp_host_1>
		        - <ntp_host_2>
		     vcenters:
		       - host:<vcenter_ip>
		         user:<vcenter_userid>
		         password:<vcenter_password>
		         datacenters:
		           - name:<datacenter_name>
		             vm_folder:<vm_folder_name>
		             template_folder:<template_folder_name>
		             disk_path:<subdir_to_store_disks>
		             datastore_pattern:<data_store_pattern>
		             persistent_datastore_pattern:<persistent_datastore_pattern>
		             allow_mixed_datastores:<true_if_persistent_datastores_and_datastore_patterns_are_这些_same>
		             clusters:
		             - <cluster_name>:
		                 resource_pool:<resource_pool_name>

如果您想要在 vCenter 中为 BOSH 用户创建一个角色，需要的权限如下：

| 对象    | 权限                   |
|-----------|------------------------------|
| 数据存储 |                              |
|           | 分配空间               |
|           | 浏览数据存储             |
|           | 低级文件操作    |
|           | 删除文件                  |
|           | 更新虚拟机文件 |
| 文件夹（所有）| |
|           | 创建文件夹 |
|           | 删除文件夹 |
|           | 移动文件夹 |
|           | 对文件夹进行重命名 |
| 全局 | |
|           | 取消任务 |
|           | 诊断 |
| 主机/配置（所有）| |
|           | 高级设置 |
|           | 身份验证存储 |
|           | 更改日期和时间设置 |
|           | 更改 PCIPassthru 设置 |
|           | 更改 SNMP 设置 |
|           | 连接 |
|           | 固件 |
|           | 超线程 |
|           | 维护 |
|           | 内存配置 |
|           | 网络配置 |
|           | 电源 |
|           | 查询修补程序 |
|           | 安全配置文件和防火墙 |
|           | 存储器分区配置 |
|           | 系统管理 |
|           | 系统资源 |
|           | 虚拟机自动启动配置 |
| 主机/清单（所有）| |
|           | 为群集添加主机 |
|           | 添加独立主机 |
|           | 创建群集 |
|           | 修改群集 |
|           | 移动群集或独立主机 |
|           | 移动主机 |
|           | 删除群集 |
|           | 删除主机 |
|           | 对群集进行重命名 |
| 主机/本地操作 | |
|           | 创建虚拟机 |
|           | 删除虚拟机 |
|           | 重新配置虚拟机 |
| 网络 | |
|           | 分配网络 |
| 资源（所有）| |
|           | 应用建议 |
|           | 将 vApp 分配给资源池 |
|           | 将虚拟机分配给资源池 |
|           | 创建资源池 |
|           | 迁移 |
|           | 修改资源池 |
|           | 移动资源池 |
|           | 查询 VMotion |
|           | 重定位 |
|           | 删除资源池 |
|           | 对资源池进行重命名 |
|           调度任务（所有）|
|           | 创建任务 |
|           | 修改任务 |
|           | 删除任务 |
|           | 运行任务 |
|           会话 | |
|           | 查看和停止会话 |
|           任务（所有）| |
|           | 创建任务 |
|           | 更新任务 |
|           vApp（所有）| |
|           | 添加虚拟机 |
|           | 分配资源池 |
|           | 分配 vApp |
|           | 克隆 |
|           | 创建 |
|           | 删除 |
|           | 导出 |
|           | 导入 |
|           | 移动 |
|           | 关闭 |
|           | 打开 |
|           | 重命名 |
|           | 挂起 |
|           | 取消注册 |
|           | vApp 应用程序配置 |
|           | vApp 实例配置 |
|           | vApp 资源配置 |
|           | 查看 OVF 环境 |
| 虚拟机（所有）/配置（所有）| |
|           | 添加现有磁盘 |
|           | 添加新磁盘 |
|           | 添加或删除设备 |
|           | 高级 |
|           | 更改 CPU 数目 |
|           | 更改资源 |
|           | 磁盘更改跟踪 |
|           | 磁盘租用 |
|           | 扩展虚拟磁盘 |
|           | 主机 USB 设备 |
|           | 内存 |
|           | 修改设备设置 |
|           | 查询容错兼容性 |
|           | 查询无所有者的文件 |
|           | 原始设备 |
|           | 从路径中重新加载 |
|           | 删除磁盘 |
|           | 重命名 |
|           | 重置客户机信息 |
|           | 设置 |
|           | 交换文件放置 |
|           | 解锁虚拟机 |
|           | 升级虚拟硬件 |
| 虚拟机（所有）/交互（所有）| |
|           | 获取客户机控制票证 |
|           | 回答问题 |
|           | 备份虚拟机上的操作 |
|           | 配置 CD 介质 |
|           | 配置软盘介质 |
|           | 控制台交互 |
|           | 创建屏幕截图 |
|           | 对所有磁盘执行碎片整理 |
|           | 设备连接 |
|           | 禁用容错 |
|           | 启用容错 |
|           | 关闭 |
|           | 打开 |
|           | 记录虚拟机上的会话 |
|           | 重放虚拟机上的会话 |
|           | 重置 |
|           | 挂起 |
|           | 测试故障切换 |
|           | 测试重新启动辅助虚拟机 |
|           | 关闭容错 |
|           | 打开容错 |
|           | VMware Tools 安装 |
| 虚拟机（所有）/清单（所有）| |
|           | 从现有项创建 |
|           | 新建 |
|           | 移动 |
|           | 注册 |
|           | 删除 |
|           | 取消注册 |
| 虚拟机（所有）/置备（所有）| |
|           | 允许访问磁盘 |
|           | 允许对磁盘进行只读访问 |
|           | 允许下载虚拟机 |
|           | 允许上传虚拟机文件 |
|           | 克隆模板 |
|           | 克隆虚拟机 |
|           | 从虚拟机创建模板 |
|           | 自定义 |
|           | 部署模板 |
|           | 标记为模板 |
|           | 标记为虚拟机 |
|           | 修改自定义规范 |
|           | 升级磁盘 |
|           | 读取自定义规范 |
| 虚拟机（所有）/状态（所有）| |
|           | 创建快照 |
|           | 删除快照 |
|           | 对快照进行重命名 |
|           | 恢复到快照 |

您必须先在虚拟中心内执行以下操作，然后才能运行微 BOSH 部署器：

1. 创建 vm_folder

1. 创建 template_folder

1. 在相应的数据存储中创建 disk_path

1. 创建 resource_pool。

资源池是可选的，没有资源池亦可运行。如果没有资源池，群集属性大致如下：

		persistent_datastore_pattern:<datastore_pattern>
		allow_mixed_datastores:<true_if_persistent_datastores_and_datastore_patterns_are_这些_same>
		clusters:
            		- <cluster_name>

上面的数据存储模式可以直接采用数据存储的名称，也可以是与数据存储名称匹配的某种正则表达式。

如果您有一个名为“vc_data_store_1”的数据存储，并且您希望对持久磁盘和非持久磁盘均使用此数据存储，那么您的配置将大致如下：

		datastore_pattern:vc_data_store_1
		persistent_datastore_pattern:vc_data_store_1
		allow_mixed_datastores:true

如果您有 2 个分别名为“_data_store_1”、“vc_data_store_2”的数据存储，并且您希望对持久磁盘和非持久磁盘均使用这两个数据存储，那么您的配置将大致如下：

		datastore_pattern:vc_data_store_?
		persistent_datastore_pattern:vc_data_store_?
		allow_mixed_datastores:true

如果您有 2 个分别名为“vnx:1”、“vnx:2”的数据存储，并且您希望将持久磁盘与非持久磁盘分开，那么您的配置将大致如下

		datastore_pattern:vnx:1
		persistent_datastore_pattern:vnx:2
		allow_mixed_datastores:false

#### 部署 ####

1. 下载微 BOSH Stemcell：



		% mkdir -p ~/stemcells
		% cd stemcells
		% bosh public stemcells
		+-------------------------------+----------------------------------------------------+
		| Name                          | Url                                                |
		+-------------------------------+----------------------------------------------------+
		| bosh-stemcell-0.4.7.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...h120= |
		| micro-bosh-stemcell-0.1.0.tgz | https://blob.cfblob.com/rest/objects/4e4e7...5Mms= |
		| bosh-stemcell-0.3.0.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...mw1w= |
		| bosh-stemcell-0.4.4.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...r144= |
		+-------------------------------+----------------------------------------------------+
		To download use 'bosh download public stemcell <stemcell_name>'.
		% bosh download public stemcell micro-bosh-stemcell-0.1.0.tgz


1. 使用以下命令设置此微 BOSH 部署：

		% cd /var/vcap/deployments
		% bosh micro deployment dev33
		Deployment set to '/var/vcap/deployments/dev33/micro_bosh.yml'

1. 部署一个新的微 BOSH 实例并创建一个新的持久磁盘。

		% bosh micro deploy ~/stemcells/micro-bosh-stemcell-0.1.0.tgz

1. 更新现有的微 BOSH 实例。现有的持久磁盘将连接到新虚拟机。

		% bosh micro deploy ~/stemcells/micro-bosh-stemcell-0.1.1.tgz --update

#### 删除微 BOSH 部署 ####

`delete` 命令将会删除虚拟机、Stemcell 和持久磁盘。

示例：

		% bosh micro delete

#### 查看微 BOSH 部署的状态 ####

status 命令将显示给定的微 BOSH 实例的持久状态。

		% bosh micro status
		Stemcell CID   sc-f2430bf9-666d-4034-9028-abf9040f0edf
		Stemcell name  micro-bosh-stemcell-0.1.0
		VM CID         vm-9cc859a4-2d51-43ca-8dd5-220425518fd8
		Disk CID       1
		Deployment     /var/vcap/deployments/dev33/micro_bosh.yml
		Target         micro (http://11.23.194.100:25555) Ver: 0.3.12 (00000000)

#### 列出部署 ####

`deployments` 命令将以表格视图的形式输出 deployments/bosh-deployments.yml 的内容。

		% bosh micro deployments

如果您以后希望能够更新自己的微 BOSH 实例，那么需要保存 `deployments` 目录中的文件。这些文件全都是文本文件，因此您可以将它们提交到 git 资源库，以确保万一您的引导虚拟机停机，这些文件也安全无虞。

#### 应用规范

micro-bosh-stemcell 包含一个嵌入式 `apply_spec.yml`。此命令可用来对现有的实例应用其他规范。`apply_spec.yml` 属性与您的部署的 network.ip 和 cloud.properties.vcenters 属性合并在了一起。

		% bosh micro apply apply_spec.yml

#### 向微 BOSH 代理发送消息 ####

CLI 可以使用 `agent` 命令通过 HTTP 向此代理发送消息。

示例：

		% bosh micro agent ping
		"pong"


### 为 AWS 构建您自己的微 BOSH stemcell

如果您想要创建自己的微 BOSH stemcell 来与 AWS 搭配使用，那么本节便说明了为此而需要执行的步骤。不过，建议的方式是下载其中一个公共 stemcell。

#### 构建 BOSH 发行版

首先，您需创建 BOSH 发行版的 tar 包

		cd ~
		git clone git@github.com:cloudfoundry/bosh-release.git
		cd ~/bosh-release
		git submodule update --init
		bosh create release --with-tarball

如果这是您第一次在发行版 repo 中运行 `bosh create release`，它会要求您对此发行版进行命名（如“`bosh`”），这样，输出将为 `dev_releases/bosh-n.tgz`。

#### 微 BOSH 清单

现在，您需要微 BOSH 清单文件，可以在 `bosh-release` repo 中的 `micro/aws.yml` 中获得此文件。此文件描述了微 BOSH 的各个组件以及应如何配置这些组件。

		---
		deployment:micro
		release:
		  name:micro
		  version: 9
		configuration_hash: {}
		properties:
		  micro:true
		  domain：vcap.me
		  env:
		  networks:
		    apps:local
		    management:local
		  nats:
		    user:nats
		    password:nats
		    address: 127.0.0.1
		    port: 4222
		  redis:
		    address: 127.0.0.1
		    port: 25255
		    password:redis
		  postgres:
		    user:postgres
		    password:postgres
		    address: 127.0.0.1
		    port: 5432
		    database:bosh
		  blobstore:
		    address: 127.0.0.1
		    backend_port: 25251
		    port: 25250
		    director:
		      user:director
		      password:director
		    agent:
		      user:agent
		      password:agent
		  director:
		    address: 127.0.0.1
		    name:micro
		    port: 25555
		  aws_registry:
		    address: 127.0.0.1
		    http:
		      port: 25777
		      user:admin
		      password:admin
		    db:
		      database:postgres://postgres:postgres@localhost/bosh
		      max_connections: 32
		      pool_timeout: 10
		    aws:
		      max_retries: 2
		  hm:
		    http:
		      port: 25923
		      user:hm
		      password:hm
		    loglevel:info
		    director_account:
		      user:admin
		      password:admin
		    intervals:
		      poll_director: 60
		      poll_grace_period: 30
		      log_stats: 300
		      analyze_agents: 60
		      agent_timeout: 180
		      rogue_agent_alert: 180

**请注意，此清单的密码是公开的，但在部署期间可以覆盖这些密码，而且也应该覆盖它们**

#### 构建微 BOSH stemcell

现在，您已经有了组装微 BOSH AWS stemcell 所需的全部元件

		cd ~/bosh/agent
		rake stemcell2:micro[aws,~/bosh-release/aws.yml,~/bosh-release/dev_builds/bosh-1.tgz]

这样便会在 `/var/tmp/bosh/agent-x.y.z-nnnnn/work/work/micro-bosh-stemcell-aws-x.y.z.tgz` 中输出该 stemcell

#### 部署它

如果您是在自己的本地系统上构建 stemcell 的，那么您需要先将您构建的 stemcell 上传到 AWS 引导虚拟机，然后才能进行部署：

		scp micro-bosh-stemcell-aws-x.y.z.tgz ubuntu@ec2-nnn-nnn-nnn-nnn.compute-1.amazonaws.com:

然后，登录到该 AWS 虚拟机并创建 `~/deployments/aws/micro_bosh.yml` 文件

		---
		name:micro-bosh-aws

		logging:
		  level:DEBUG

		network:
		  type:dynamic

		resources:
		  cloud_properties:
		    instance_type:m1.small

		cloud:
		  plugin:aws
		  properties:
		    aws:
		      access_key_id: ...
		      secret_access_key: ...
		      default_key_name: ...
		      default_security_groups:["default"]
		      ec2_private_key:~/.ssh/ec2.pem

		apply_spec:
properties:
nats:
user: ...
password: ...
postgres:
user: ...
password: ...
            ...

最后，运行

		cd ~/deployments
		bosh micro deployment aws
		bosh micro deploy ~/micro-bosh-stemcell-aws-x.y.z.tgz

成功部署后输出结果将大致如下：

$ bosh micro deploy ~/micro-bosh-stemcell-aws-x.y.z.tgz
Deploying new micro BOSH instance `aws/micro_bosh.yml' to `micro-bosh-aws' (type 'yes' to continue):yes

Verifying stemcell...
File exists and readable                                     OK
Manifest not found in cache, verifying tarball...
Extract tarball                                              OK
Manifest exists                                              OK
Stemcell image file                                          OK
Writing manifest to cache...
Stemcell properties                                          OK

Stemcell info
        -------------
Name:micro-bosh-stemcell
Version:x.y.z


Deploy Micro BOSH
unpacking stemcell (00:00:12)
uploading stemcell (00:06:20)
creating VM from ami-a99d34c0 (00:00:24)
waiting for the agent (00:02:29)
create disk (00:00:00)
mount disk (00:00:20)
stopping agent services (00:00:01)
applying micro BOSH spec (00:00:25)
starting agent services (00:00:00)
waiting for the director (00:01:21)
Done             11/11 00:11:44
WARNING!Your target has been changed to `http://nnn.nnn.nnn.nnn:25555'!
Deployment set to '/home/ubuntu/deployments/aws/micro_bosh.yml'
Deployed `aws/micro_bosh.yml' to `micro-bosh-aws', took 00:11:44 to complete

### 使用微 BOSH 将 BOSH 作为应用程序进行部署。 ##

1. 部署微 BOSH。请参见上一节中的具体步骤。

1. 微 BOSH 实例部署完毕后，您便可以为其控制器设定目标：

		$ bosh micro status
		...
		Target         micro (http://11.23.194.100:25555) Ver: 0.3.12 (00000000)

		$ bosh target http://11.23.194.100:25555
		Target set to 'micro (http://11.23.194.100:25555) Ver: 0.3.12 (00000000)'

		$ bosh status
		Updating director data... done

		Target         micro (http://11.23.194.100:25555) Ver: 0.3.12 (00000000)
		UUID           b599c640-7351-4717-b23c-532bb35593f0
		User           admin
		Deployment     not set

#### 下载 BOSH stemcell

1. 使用 bosh public stemcells 列出公共 stemcell

		% mkdir -p ~/stemcells
		% cd stemcells
		% bosh public stemcells
		+-------------------------------+----------------------------------------------------+
		| Name                          | Url                                                |
		+-------------------------------+----------------------------------------------------+
		| bosh-stemcell-0.4.7.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...h120= |
		| micro-bosh-stemcell-0.1.0.tgz | https://blob.cfblob.com/rest/objects/4e4e7...5Mms= |
		| bosh-stemcell-0.3.0.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...mw1w= |
		| bosh-stemcell-0.4.4.tgz       | https://blob.cfblob.com/rest/objects/4e4e7...r144= |
		+-------------------------------+----------------------------------------------------+
		To download use 'bosh download public stemcell <stemcell_name>'.


1. 下载一个公共 stemcell。*请注意，在这种情况下，您并不使用微 BOSH stemcell。*

		bosh download public stemcell bosh-stemcell-0.1.0.tgz

1. 将下载的 stemcell 上传到微 BOSH。

		bosh upload stemcell bosh-stemcell-0.1.0.tgz

#### 上传 BOSH 发行版 ####

1. 您可以创建一个 BOSH 发行版，也可以使用其中一个公共发行版。以下步骤说明了如何使用公共发行版。

		cd /home/bosh_user
		gerrit clone ssh://[<your username>@]reviews.cloudfoundry.org:29418/bosh-release.git

1. 从 bosh-release 上传一个公共发行版

		cd /home/bosh_user/bosh-release/releases/
		bosh upload release bosh-1.yml


#### 设置 BOSH 部署清单并进行部署 ####

1. 创建并设置一个 BOSH 部署清单。查看 (https://github.com/cloudfoundry/oss-docs/bosh/samples/bosh.yml) 中的 BOSH 示例清单。假定您已经在 `/home/bosh_user` 中创建了一个 `bosh.yml`。

		cd /home/bosh_user
		bosh deployment ./bosh.yml

1. 部署 BOSH

		bosh deploy.

1. 为新部署的 BOSH 控制器设定目标。在示例 `bosh.yml` 中，BOSH 控制器的 IP 地址为 192.0.2.36。因此，如果您要将此控制器的目标设定为 `bosh target http://192.0.2.36:25555`（其中 25555 是默认的 BOSH 控制器端口），那么您新安装的 BOSH 实例现在即可使用。

## 使用 BOSH 部署到 AWS

借助适用于 AWS 的 BOSH 云提供商接口，BOSH 可以向 AWS 部署内容。

### AWS 云属性

AWS 所特有的云属性如下

#### 资源池

1. `key_name`

1. `availability_zone`

1. `instance_type`

#### 网络

1. `type`

1. `ip`

### 将 Cloud Foundry 部署到 AWS 时的安全问题

如果您使用 BOSH 将 [Cloud Foundry](https://github.com/cloudfoundry/cf-release) 部署到 AWS，则需要将 `nfs_server.network` 部署属性设置为 `*`（或 `10/8`），因为我们无法限制属于此部署的 IP 的列表。要限制访问，请创建并使用安全组。

## BOSH 命令行界面 ##

BOSH 命令行界面用于与 BOSH 控制器进行交互以便在云上执行操作。如需最近发布的关于其功能的文档，请安装 BOSH，然后键入 `bosh` 即可。Usage:

		bosh [--verbose] [--config|-c <FILE>] [--cache-dir <DIR]
		[--force] [--no-color] [--skip-director-checks] [--quiet]
		[--non-interactive]
		command [<args>]

目前可供使用的 BOSH 命令有：

		部署
		deployment [<name>]       选择要使用的部署（它还会更新
		当前目标）
		delete deployment <name>  删除部署
		                                --force    在删除部署的组成部分时忽略
		所有错误
		deployments               显示可用部署的列表
		deploy                    按照当前选择的部署清单
		进行部署
		                                --recreate 在部署过程中重新创建所有虚拟机
		diff [<template_file>]    将您当前的 BOSH 部署
		配置与指定的 BOSH 部署
		配置模板区分开来，以便
		您可以使您的部署配置文件保持
		最新状态。可以在部署 repo 中找到开发
		模板。
		
		发行版管理
		create release            创建发行版（假定当前目录为
		发行版资源库）
		                                --force    绕过 git 脏状态检查
		                                --final    创建可投入生产环境中使用的发行版
		（将项目存储在 blobstore 中，
		增加最终版本）
		                                --with-tarball
		创建完整的发行版 tar 包（默认情况下
		仅创建清单）
		                                --dry-run  先停止，再写入发行版清单
		（用于诊断）
		delete release <name> [<version>]
		删除发行版（或发行版的特定版本）
		                                --force    在删除期间忽略错误
		verify release <path>     验证发行版
		upload release [<path>]   上传发行版（<path> 可以指向 tar 包或
		清单，默认为指向最新创建的
		发行版）
		releases                  显示可用发行版的列表
		reset release             重置发行版部署环境（删除
		所有开发项目）
		
		init release [<path>]     初始化发行版目录
		generate package <name>   生成包模板
		generate job <name>       生成作业模板
		
		Stemcell
		upload stemcell <path>    上传 stemcell
		verify stemcell <path>    验证 stemcell
		stemcells                 显示可用 stemcell 的列表
		delete stemcell <name> <version>
		删除 stemcell
		public stemcells          显示供下载的公开 stemcell 的
		列表。
		download public stemcell <stemcell_name>
		从公共 blobstore 下载 stemcell。
		
		用户管理
		create user [<name>] [<password>]
		创建用户
		
		作业管理
		start <job> [<index>]     启动作业/实例
		stop <job> [<index>]      停止作业/实例
		                                --soft     仅停止进程
		                                --hard     关闭虚拟机
		restart <job> [<index>]   重新启动作业/实例（软停止 + 启动）
		recreate <job> [<index>]  重新创建作业/实例（硬停止 + 启动）
		
		日志管理
		logs <job> <index>        提取作业日志（默认）或代理日志（如果提供了
		选项）
		                                --agent    提取代理日志
		                                --only <filter1>[...]
		仅提取符合指定过滤器
		（在作业规范中定义）的条件的日志
		                                --all      提取作业或代理日志目录中的所有
		目录
		
		任务管理
		tasks                     显示正在运行的任务的列表
		tasks recent [<number>]   显示最近 <number> 项任务
		task [<task_id>|last]     显示任务状态并开始跟踪其输出
		                                --no-cache 不在本地缓存输出
		                                --event|--soap|--debug
		要跟踪的不同日志类型
		                                --raw      不美化日志
		cancel task <id>          任务一旦达到下一个取消检查点，
		即将其取消
		
		属性管理
		set property <name> <value>
		设置部署属性
		get property <name>       获取部署属性
		unset property <name>     取消对部署属性进行的设置
		properties                列出当前部署属性
		                                --terse    便于分析输出
		
		维护
		cleanup                   从当前控制器中删除除最近几个 stemcell 和发行版
		以外的所有 stemcell 和发行版（不删除
		当前正在使用的 stemcell 和发行版）
		cloudcheck                云一致性检查和交互式修复
		                                --auto     自动解决问题（对于生产环境，
		不推荐使用）
		                                --report   仅生成报告，不尝试
		解决问题
		
		其他
		status                    显示当前状态（当前目标、用户、
		部署信息等）
		vms [<deployment>]        列出所有应在部署范围内的虚拟机
		target [<name>] [<alias>] 选择要与哪个控制器通信（还可以选择创建
		一个别名）。如果不提供参数，则显示当前
		设为目标的控制器
		login [<name>] [<password>]
		为与目标控制器的
		后续交互提供凭据
		logout                    忘记已保存的目标控制器凭据
		purge                     清除本地清单缓存
		
		远程访问
		ssh <job> [index] [<options>] [command]
		在指定了作业的情况下，执行指定的命令或启动
		交互式会话
		                                --public_key <file>
		                                --gateway_host <host>
		                                --gateway_user <user>
		                                --default_password
		使用默认的 ssh 密码。不
		推荐使用。
		scp <job> <--upload | --download> [options] /path/to/source /path/to/destination
		将源文件上传/下载到指定的作业。
		注意：如果是下载，则 /path/to/destination 是一个
		目录
		                                --index <job_index>
		                                --public_key <file>
		                                --gateway_host <host>
		                                --gateway_user <user>
		ssh_cleanup <job> [index] 清理 SSH 证书
		
		Blob
		upload blob <blobs>      将指定的 blob 上传到 blobstore
		                                --force    绕过重复项检查
		sync blobs                将 blob 与 blobstore 同步
		                                --force    用远程 blob 覆盖所有
		本地副本
		blobs                     输出 blob 状态

## 发行版 ##

发行版是由源代码、用于运行服务的配置文件和启动脚本以及一个唯一标识这些组件的版本号组成的集合。创建新发行版时，您应使用源代码管理器（如 [git](http://git-scm.com/)）来管理所含文件的新版本。

### 发行版资源库 ###

BOSH 发行版是基于一个目录树构建的，此目录树包含本节中所介绍的内容。典型的发行版资源库包含以下子目录：

| 目录	| 内容 	|
| ------------	| ----------	|
| `jobs` 	| 作业定义 	|
| `packages` 	| 包定义 	|
| `config` 	| 发行版配置文件 	|
| `releases` 	| 最终发行版 	|
| `src` 	| 包的源代码 	|
| `blobs` 	| 大型源代码捆绑包 	|

### 作业 ###

作业是包的实现，即，运行包中的一个或多个进程。作业包含运行包中的二进制文件所需的配置文件和启动脚本。

作业与虚拟机之间存在*一对多* 映射关系 - 在任何给定的虚拟机中都只能运行一个作业，但多个虚拟机可以运行同一个作业。例如，可能会有四个虚拟机都在运行云控制器作业，但云控制器作业与 DEA 作业则不能在同一虚拟机中运行。如果您需要在同一虚拟机中运行两个不同的进程（从两个不同的包中运行），那么您需要创建一个可以启动这两个进程的作业。

#### Prepare 脚本 ####

如果某一作业需要从其他作业（如超级作业）中来汇编自己，则可以使用 `prepare` 脚本，该脚本会在此作业打包前运行，并且可以创建、复制或修改文件。

#### 作业模板 ####

作业模板是作业的经过泛化的配置文件和脚本，在 Stemcell 转变成作业时，作业将使用 [ERB](http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html) 文件来生成最终的配置文件和脚本。

将配置文件转变成模板时，会将特定于实例的信息抽象成一个属性，之后当 [控制器][控制器] 在虚拟机上启动作业时会提供该属性。例如，这种信息可以是 Web 服务器应在哪个端口上运行，或者数据库应使用哪个用户名及密码。

这些文件位于 `templates` 目录中，在作业 `spec` 文件中的 templates 部分中提供了模板文件与其最终位置之间的映射关系。例如

		templates:
		foo_ctl.erb:bin/foo_ctl
		foo.yml.erb:config/foo.yml
		foo.txt:config/foo.txt

#### 属性的用法 ####

用于作业的属性来自于部署清单，部署清单通过 [代理][代理] 将特定于实例的信息传递给虚拟机。

#### “虚拟机的作业” ####

首次启动虚拟机时，该作业为 Stemcell，Stemcell 可以变成任何类型的作业。当控制器指示虚拟机运行作业时，首先就会运行该作业，以使它获得自己的*身份*.

#### 监视 (Monitrc) ####

BOSH 使用 [monit](http://mmonit.com/monit/) 来管理和监视作业的进程。`monit` 文件描述了 BOSH [代理][代理] 将如何停止和启动该作业，该文件包含至少三个部分：

`with pidfile`
: 该进程将其 pid 文件保存在何处

`start program`
: monit 应如何启动该进程

`stop program`
: monit 应如何停止该进程

`monit` 文件通常包含一段脚本，可通过调用此脚本来启动/停止该进程；不过它可以直接调用二进制文件。

#### DNS 支持 ####

待撰写

### Packages ####

包是一个集合，其中包含：源代码；一段脚本，该脚本包含了相应的指令来说明如何将此源代码编译成二进制格式并加以安装；与其他必备包的依赖关系，此项可选。

#### 包编译 ####

包是在部署期间根据需要进行编译的。[控制器](#bosh-director)首先会检查要将该包部署到的 stemcell 版本是否已经有了该包的已编译版本，如果尚不存在已编译的版本，控制器将实例化一个编译虚拟机（使用要将该包部署到的同一 stemcell 版本），编译虚拟机将从 blobstore 获取该包的源代码，对其进行编译，然后将所得到的二进制文件打包并存储到 blobstore 中。

为了将源代码转变成二进制文件，每个包都有 `packaging` 脚本，该脚本负责编译，并在编译虚拟机上运行。该脚本会获取从 BOSH 代理中设置的两个环境变量：

`BOSH_INSTALL_TARGET`
: 用于告知要将该包生成的文件安装到何处。它设置为 `/var/vcap/data/packages/<package name>/<package version>`。

`BOSH_COMPILE_TARGET`
: 用于告知包含源代码的目录（在调用 `packaging` 脚本时为当前目录）。

安装该包时，将从 `/var/vcap/packages/<package name>` 创建一个指向该包最新版本的符号链接。在 `packaging` 脚本中引用其他包时应使用该链接。

有一段可选的 `pre_packaging` 脚本，在 `bosh create release` 执行期间汇编该包的源代码时会运行此脚本。例如，此脚本可以用来限制将源代码中的哪些部分打包并存储在 blobstore 中。此脚本会获取由 [BOSH CLI](#bosh-cli) 设置的环境变量 `BUILD_DIR`，此环境变量表示包含要打包的源代码的目录。

#### 包规范 ####

包的内容在 `spec` 文件中加以指定，此文件包含三个部分：

`name`
: 包的名称。

`dependencies`
: 可选，表示该包依赖的其他包的列表，[见下文][依赖项]。

`files`
: 该包包含的文件的列表，可以包含 glob。`*` 与任何文件都匹配，可以通过 glob 中的其他值加以限制，例如 `*.rb` 仅匹配以 `.rb` 结尾的文件。`**` 以递归方式匹配目录。

#### 依赖项 ####

包的 `spec` 文件包含一个列出当前包依赖的其他包的部分。这些依赖项为编译时依赖项，相反，作业依赖项则是运行时依赖项。

当[控制器](#bosh-director)在部署期间计划包的编译工作时，它首先会确保所有依赖项均已编译，接着才会编译当前包；还会确保在开始编译前，依赖的所有包均安装到了编译虚拟机上。

### 源代码 ###

`src` 目录包含包的所有源代码。

如果您是使用源代码资源库来管理您的发行版，应避免在其中存储大型对象（例如 `src` 目录中的源代码 tar 包），而应使用下面所述的 [blob](#blobs)。

### Blob ###

要创建最终发行版，您需要使用 blobstore 配置发行版资源库。BOSH 会将最终发行版上传到此资源库，这样以后便可以从其他计算机检索该发行版。

为防止发行版资源库充斥着大型的二进制文件（源代码 tar 包），可以将大型文件放入 `blobs` 目录中，再上传到 blobstore。

对于生产发行版，您应使用 Atmos 或 S3 blobstore，并按如下说明配置它们。

#### Atmos ####

Atmos 是 EMC 出品的一款共享存储解决方案。要使用 Atmos，请编辑 `config/final.tml` 和 `config/private.yml`，然后添加以下内容（将 `url`、`uid` 和 `secret` 替换成您的帐户信息）：

`config/final.yml` 文件

    ---
	blobstore:
	provider:atmos
	options:
	tag:BOSH
	url:https://blob.cfblob.com
	uid:1876876dba98981ccd091981731deab2/user1
	
`config/private.yml` 文件

    ---
	blobstore_secret:ahye7dAS93kjWOIpqla9as8GBu1=

#### S3 ####

要使用由 Amazon 出品的共享存储解决方案 S3，请编辑 `config/final.tml` 和 `config/private.yml`，然后添加以下内容（将 `access_key_id`、`bucket_name`、`encryption_key` 和 `secret_access_key` 替换成您的帐户信息）：

`config/final.yml` 文件

    ---
	blobstore:
	provider:s3
	options:
	access_key_id:KIAK876234KJASDIUH32
	bucket_name:87623bdc
	encryption_key:sp$abcd123$foobar1234
	
`config/private.yml` 文件

    ---
	blobstore_secret:kjhasdUIHIkjas765/kjahsIUH54asd/kjasdUSf

#### 本地 ####

如果您要试用 BOSH，但没有 Atmos 或 S3 帐户，您可以使用 local blobstore 提供商（它会将文件存储在磁盘上而不是远程服务器上）。

`config/final.yml` 文件

    ---
	blobstore:
	provider:local
	options:
	blobstore_path:/path/to/blobstore/directory

请注意，应仅将 **only** 用于测试目的，因为无法与其他对象共享它（除非这些对象运行在同一系统上）。

### 配置发行版 ###

可以在一个空的 git repo 中使用 `bosh init release command` 来进行初次发行版配置。这将创建一些可用来保存作业、包和源代码的目录。

### 构建发行版 ###

要创建新的发行版，请使用 `bosh create release` 命令。此命令将尝试用发行版 repo 的内容创建一个新的发行版。具体过程如下：

* BOSH CLI 识别出它在一个发行版 repo 目录中，并尝试找到该 repo 中的所有作业和包。然后，对于每个项目（包/作业）：
	1. 使用项目内容、文件权限及其他一些可跟踪数据构建指纹。
	2. BOSH CLI 尝试查找与该指纹匹配的项目的“最终”版本。所有的“最终”版本均应通过 blobstore 进行共享，blobstore ID 则在发行版 repo 中加以跟踪。找到所需的 blobstore ID 后，CLI 便尝试在本地缓存中查找实际项目，如果实际项目缺失或者出现校验和不匹配，CLI 会从 blobstore 中提取它（随后保存在本地缓存中）。
	3. 如果未找到任何最终版本，CLI 会尝试在本地缓存中查找开发版本。开发版本是特定于开发人员计算机上的发行版 repo 的本地副本的，因此不会尝试进行下载，它要么不存在，要么存在于本地。
	4. 如果找到了项目（开发版本或最终版本），CLI 会使用与该项目关联的版本。这么看来，从第 1 步到第 4 步的整个过程本质上就是通过计算出来的指纹查找 tar 包及其版本。包/作业中的任何更改都应该会更改其指纹，这会触发第 5 步（生成一个新的版本）。
	5. 如果需要生成新的项目版本，CLI 将使用其 spec 文件来了解需要在所生成的 tar 包中包含什么内容。对于包，它会解析依赖关系，复制匹配的文件并运行 `pre_packaging` 脚本（如果有）。对于作业，它会检查包含的所有包和配置模板是否存在。如果所有检查均已通过，CLI 会生成一个新的项目 tar 包并将其打包，然后为其分配一个新版本（请参见下文中的发行版版本控制）。
* 此时所有包和作业都已生成，CLI 也有了对它们的引用。仅剩的一步是生成一个发行版清单，从而将所有这些作业和包绑定在一起。所生成的 YAML 文件会保存下来，其路径将提供给 CLI 用户。可以通过将此路径与 `bosh upload release` 一起使用向 BOSH 控制器上传发行版。

### 最终发行版与发行版版本控制 ###

测试完所有更改并且需要向生产环境中实际部署发行版时，便可以创建最终发行版。最终发行版与开发发行版的区分标准主要有三个：

1. *版本控制架构*: 最终发行版与版本无关。每次生成新的最终发行版时，其版本都是通过在上一最终发行版的基础上简单递增得出的，而不考虑在这两个最终发行版之间创建了多少个开发发行版。各个发行版项目也是如此，它们的最终版本与开发版本无关。
2. *Blob 共享*: 最终发行版中包含的包和作业 tar 包也是上传到 blobstore，因此将来尝试在同一发行版 repo 中创建发行版的任何人员使用的都将是相同的实际代码，而非在本地生成它们。这对于保持一致和在需要时能够生成最终发行版的旧版本而言十分重要。
3. *仅重用组件，而不生成新组件*: 最终发行版应仅包含以前生成的项目。如果根据 repo 的当前状态计算出来的指纹与以前生成的开发或最终版本不匹配，将会引发错误，从而告知 CLI 用户确保先生成和测试开发发行版。

最终发行版可以通过运行 `bosh create release --final` 来创建。通常，只有参与更新生产系统的人员才应生成最终版本。还有一个 `--dry-run` 选项用于在实际并不生成和上传项目的情况下测试发行版创建操作。

默认情况下，所有项目均存储在发行版 repo 内的 `.final_builds` 目录中，而发行版清单则保存在 `releases` 目录中。如果需要实际的发行版 tar 包，则可以使用 `bosh create release --with tarball`。此外，可以使用 `bosh create release /path/to/release_manifest.yml` 根据以前创建过的发行版的清单来重新创建该发行版。在这两种情况下，输出都是自我包含且已经可以上传的发行版 tar 包。

开发发行版项目的版本控制与最终发行版项目略有不同：最新生成的项目最终版本用作开发内部版本的主要版本，而实际的内部版本修订号则用作次要版本。

示例如下：

1. 发行版 repo 中有一个 cloud_controller 包：尚无开发版本和最终版本。
2. `bosh create release` 第一次运行
3. 现在，有了开发发行版 1，cloud_controller 现在便有了开发版本 0.1，尚无最终版本
4. `bosh create release` is a no-op now, unless we make some repo changes.

5. 有人编辑了 cloud_controller 包匹配的一个或多个文件。
6. `bosh create release` 现在生成了开发发行版 2，cloud_controller 有了开发版本 0.2，尚无最终版本。
7. `bosh create release --final` 现在将创建最终发行版 1，cloud_controller 有了开发版本 0.2，此版本也改称为最终版本 1。
8. 接下来对 cloud_controller 所做的编辑随后将生成开发版本 1.1、1.2，依此类推，直到创建新的最终版本为止

这种版本控制架构的主要用途是将以下两类受众的发行版工程处理流程区分开来：

1. 在自己所做更改的基础上快速迭代且实际不关心使 BOSH 发行版版本控制保持一致的开发人员，BOSH CLI 将为他们处理所有的版本控制细节并防止他人看到所有尚未完成的发行版。
2. 实际构建用于生产目的的发行版并希望这些发行版得到一致的版本控制和源代码控制的 SRE。

### 使用 S3 设置新的发行版资源库 ###

以下说明要求您使用 BOSH CLI 0.19.6 或更高版本。

要发布 BOSH 发行版资源库，您需要完成两个步骤：
1. 使用 git 使该资源库可供用户使用
（例如放置到 [github](https://github.com/) 上）
2. 使最终作业和包可供用户使用
（例如使用 [S3](http://aws.amazon.com/s3/)）

本篇博文以 [bosh-sample-release](https://github.com/cloudfoundry/bosh-sample-release) 为例来说明如何使用公开的最终作业和包来设置 BOSH 发行版资源库。以<span style="color:red;">红色</span>显示的文本需替换成您的具体信息，如 Amazon 访问密钥 ID 和 bucket 名称。

首先，您需要在 Amazon IAM 中创建一个将能够向 S3 上传数据的新用户，再创建一个将用来存储最终对象的 S3 bucket。

然后，需设置一项允许匿名用户（任何人）从该 bucket 获取对象的 bucket 策略：

```{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::<code style="color: red;">bosh-sample-release</code>/*"
    }
  ]
}```

初始化一个新的发行版资源库：

	bosh init release <code style="color:red;">bosh-sample-release</code> --git

在该发行版资源库中，创建包含以下内容的 `config/final.yml` 文件：

```---
final_name: wordpress
min_cli_version: 0.19.6
blobstore:
  provider: s3
  options:
    bucket_name: <code style="color: red;">bosh-sample-release</code>```

Next create the file `private.yml` somewhere **outside** of the repository and create a soft link to it in the `config` directory.这样做是为了防止您无意中将 S3 凭据提交到该资源库，从而暴露了机密信息。

```---
blobstore:
  s3:
    secret_access_key: <code style="color: red;"> EVGFswlmOvA33ZrU1ViFEtXC5Sugc19yPzokeWRf</code>
    access_key_id: <code style="color: red;"> AKIAIYJWVDUP4KRWBESQ</code>```

现在，您需要将所做的更改提交到该资源库

git add .
git commit -m 'initial commit'

创建一些作业和包

bosh generate package foo
bosh generate job bar

创建一个开发发行版。当您在该资源库中有未提交的更改时，便需要用到 `--force` 选项。

bosh create release --force

对所做的更改感到满意后，请提交它们并构建最终发行版。

git add .
git commit -m 'added package foo and job bar'
bosh create release --final

这会将最终的包和作业上传到 S3，并在您的发行版资源库中存储对它们的引用。这些引用也需要提交。

git add .
git commit -m 'release #1'

## BOSH 部署 ##

### 部署步骤 ###

使用 BOSH 进行部署时，各个步骤按以下顺序执行：

1. Preparing deployment
* 绑定部署 - 如果控制器的数据库中不存在与此次部署对应的条目，则在该数据库中创建一个。
* 绑定发行版 - 确保在部署配置中指定的发行版存在，然后将其锁定以免遭删除。
* 绑定现有部署 - 获取现有虚拟机并对它们进行设置以供此次部署使用。
* 绑定资源池 - 为空闲的虚拟机预留网络。
* 绑定 stemcells - 确保指定的 stemcell 已上传，然后将其锁定以免遭删除。
* 绑定模板 - 设置内部数据对象以便跟踪包及其安装前提条件。
* 绑定未分配的虚拟机 - 对于所需的每个作业实例，它会确定是否已经存在运行该实例的虚拟机，如果不存在，则会分配一个。
* 绑定实例网络 - 为没有网络的每个虚拟机预留网络。
1. 编译包 - 计算需要编译的所有包及其依赖项。然后它便开始编译这些包并将它们的输出存储在 blobstore 中。在部署配置中指定的 `workers` 数目决定着一次可以创建多少个用于执行编译的虚拟机。
1. 准备 DNS - 如果不存在 DNS 条目，则创建此条目。
1. 创建已绑定的缺失虚拟机 - 创建新的虚拟机，删除多余/已过期/空闲的虚拟机。
1. 绑定实例虚拟机 - 为此次部署设置所有未绑定的虚拟机。
1. 准备配置 - 获取要运行的每个作业的配置。
1. 更新/删除作业 - 删除不需要的实例、创建需要的实例、更新尚未更新的现有实例。这是为对象注入活力的步骤。
1. 重新填充资源池 - 在所有实例更新程序创建完附加虚拟机后跨资源池创建缺失的虚拟机，以便平衡资源池。

### BOSH 部署清单

BOSH 部署清单是一个 YAML 文件，用于定义部署的布局和属性。当 BOSH 用户使用 CLI 启动新的部署时，BOSH 控制器会收到一个版本的部署清单，并使用此清单创建一个新的部署计划（请参见 [部署步骤](#steps-of-a-deployment)）。清单包含若干部分：

* `name` [字符串，必需] 部署名称。一个 BOSH 控制器可以管理多个部署并通过名称来区别它们。
* `director_uuid` [字符串，必需] 控制器 UUID。标识用来管理给定部署的 BOSH 控制器。目标控制器的 UUID 应该与此属性匹配，这样 BOSH CLI 才会允许对该部署执行任何操作。
* `release` [哈希，必需] 发行版属性。
	* `name` [字符串，必需] 发行版名称。引用将用于解析部署组件（包、作业）的发行版名称。
	* `version` [字符串，必需] 发行版版本。指向要使用的确切发行版版本。
* `compilation` [哈希，必需] 包的编译属性。
	* `workers` [整数，必需] 将创建多少个用来编译包的编译虚拟机。
	* `reuse_compilation_vms` [布尔，可选] 如果设置为 True，在编译包时将重用编译虚拟机。如果为 False，那么每次需要编译新包（作为当前部署的一部分）时，都将创建一个新的工作进程虚拟机（总数不超过编译工作进程数目），完成单个包的编译后将关闭此虚拟机。默认值为 False。如果 IaaS 创建/删除虚拟机所耗费的时间很长或者需要优化包的编译成本，那么建议将其设置为 True（因为编译虚拟机的存续时间通常很短，并且某些 IaaS 计费方式会将使用时间向上舍入为一个小时）。
	* `network` [字符串，必需] 网络名称，引用在 `networks` 部分中定义的有效网络名称。为编译虚拟机分配其所有网络属性时依据的是该网络的类型及其他属性。
	* `cloud_properties` [哈希，必需] 将用于创建编译虚拟机的任何特定于 IaaS 的属性。
* `update` [哈希，必需] 实例的更新属性。这些属性控制在部署期间将如何更新作业实例。
	* `canaries` [整数，必需] Canary 实例的数目。Canary 实例在其他实例前更新，如果 Canary 实例出现任何更新错误，则意味着部署应停止。这样可以防止有错误的包或作业接管所有作业实例，因为有问题的代码仅会影响 Canary。Canary 完成后，此作业的其他实例将以并行方式更新（遵照 `max_in_flight` 设置）。
	* `canary_watch_time` [范围<整数>，整数] 在认定作业是否正常运行前等待 Canary 更新的时长。如果提供的是整数，控制器将睡眠一定时间后检查作业是否正常运行，睡眠时长等于该整数所表示的时间（以秒为单位）。如果给定的是 `lo..hi` 范围，控制器将等待 `lo` 毫秒后检查作业是否正常运行，如果运行不正常，它将再睡眠这么长的时间，如果反复下去，直到超过 `hi` 毫秒为止。如果此时作业的运行仍然不正常，控制器将放弃。
	* `update_watch_time` [范围<整数>，整数]：从语义上而言与 `canary_watch_time` 并无二致，用于常规（非 Canary）更新。
	* `max_in_flight` [整数，必需] 可以并行执行的非 Canary 实例更新的最大数目。
* `networks` [哈希<数组>，必需] 描述部署使用的网络。有关详细信息，请参见 [nework_spec]。
* `resource_pools` [哈希<数组>，必需] 描述部署使用的资源池。有关详细信息，请参见 [resource_pool_spec]。
* `jobs` [哈希<数组>，必需] 列出包含在此部署中的作业。有关详细信息，请参见 [job_spec]。
* `properties` [哈希，必需] 全局部署属性。有关详细信息，请参见 [job_cloud_properties]。

#### 网络规范 ####

网络规范指定了作业可以引用的网络配置。不同的环境的网络连接功能差别很大，因此存在多种网络类型。每种类型都有一个必需的 `name` 属性，该属性用于在 BOSH 中标识相应的网络，因此必须是唯一的。

下面是更详细的网络类型描述：

1. `dynamic` 这种网络并非由 BOSH 加以管理。使用这种网络的虚拟机应该是从 DHCP 服务器或者通过某种其他方式获取其 IP 地址及其他网络配置，BOSH 将相信每一个虚拟机在其 `get_state` 响应中报告的其当前 IP 地址。这种网络支持的唯一一个额外属性是 `cloud_properties`，该属性包含用于 CPI 的任何特定于 IaaS 的网络详细信息。
2. `manual` 这种网络完全由 BOSH 管理。为动态、静态和预留的 IP 池、DNS 服务器提供了范围。手动管理的网络可以进一步划分成若干子网。使用这种类型的网络时，BOSH 将负责分配 IP 地址、执行与网络有关的健全性检查以及告知虚拟机它们打算使用哪些网络配置。这种类型的网络只有 `subnets` 这一个额外属性，该属性是一个哈希数组，其中的每个哈希都是一个包含以下属性的子网规范：
	* `range` [字符串，必需] 包含此子网中的所有 IP 的子网 IP 范围（由 Ruby 的 NetAddr::CIDR.create 语义定义）。
	* `gateway` [字符串，可选] 子网网关 IP。
	* `dns` [数组<字符串>，可选] 此子网的 DNS IP 地址。
	* `cloud_properties` 传递给 CPI 的不透明且特定于 IaaS 的详细信息。
	* `reserved` [字符串，可选] 预留的 IP 范围。该范围的 IP 绝不会分配给由 BOSH 管理的虚拟机，这些 IP 应该完全在 BOSH 之外进行管理。
	* `static` [字符串，可选] 静态 IP 范围。当作业请求静态 IP 时，所有这些 IP 都应来自于某个子网静态 IP 池。
3. `vip` 这种网络只是一个由虚拟 IP（例如 EC2 弹性 IP）组成的集合，每个作业规范将提供这种网络应该具有的 IP 的范围。实际虚拟机无法感知这些 IP。这种网络支持的唯一一个额外属性是 `cloud_properties`，该属性包含用于 CPI 的任何特定于 IaaS 的网络详细信息。

#### 资源池规范 ####

资源池规范本质上就是一个描绘由 BOSH 创建和管理的虚拟机的蓝图。一个部署清单中可能有多个资源池，`name` 用于标识和引用它们，因此需要是唯一的。资源池虚拟机在部署中创建，随后作业会应用于这些虚拟机。作业可能会覆盖部分资源池设置（如网络），但一般而言，资源池是根据容量和 IaaS 配置需求划分作业的良好工具。资源池规范的属性有：

* `name`[字符串，必需] 唯一的资源池名称。
* `network` [字符串，必需] 引用一个网络名称（有关详细信息，请参见 [network_spec]）。空闲的资源池虚拟机将使用这种网络配置。之后，向这些资源池虚拟机应用作业时，可以重新配置网络来满足作业的需求。
* `size` [整数，必需] 资源池中的虚拟机数目。资源池的大小应至少达到使用它的作业实例总数。还可能有额外的虚拟机，在添加更多作业来填充这些虚拟机之前，这些虚拟机将一直处于空闲状态。
* `stemcell` [哈希，必需] 用于运行资源池虚拟机的 Stemcell。
	* `name` [字符串，必需] Stemcell 名称。
	* `version` [字符串，必需] Stemcell 版本。
* `cloud_properties` [哈希，必需] 特定于 IaaS 的资源池属性（请参见 [job_cloud_properties]）。
* `env` [哈希，可选] 虚拟机环境。用于向 CPI `create_stemcell` 调用提供特定的虚拟机环境。这些数据将以虚拟机设置的形式供 BOSH 代理使用。默认为 {}（空哈希）。

#### 作业规范 ####

作业是运行同一软件、实质上就是表示同一角色的一个或多个虚拟机（称作实例）。作业使用作为发行版一部分的作业模板来向虚拟机中填充包、配置文件，以及告知 BOSH 代理要在特定虚拟机上运行什么内容的控制脚本。最常用的作业属性有：

* `name` [字符串，必需] 唯一的作业名称。
* `template` [字符串，必需] 作业模板。作业模板是发行版的一部分，通常包含（以原始形式）在发行版 repo 中的发行版“jobs”目录中，并作为发行版捆绑包的一部分上传到 BOSH 控制器。
* `persistent_disk` [整数，可选] 持久磁盘的大小。如果它是正整数，则会创建持久磁盘并将该磁盘连接到每个作业实例虚拟机。默认值为 0（无持久磁盘）。
* `properties` [哈希，可选] 作业属性。有关详细信息，请参见 [job_cloud_properties]。
* `resource_pool` [字符串，必需] 要运行作业实例的资源池。引用 `resource_pool` 部分中的一个有效资源池名称。
* `update` [哈希，可选] 特定于作业的更新设置。通过它可以在每个作业的设置中覆盖全局作业更新设置（与 `properties` 类似）。
* `instances` [整数，必需] 作业实例的数目。每个实例是一个运行此特定作业的虚拟机。
* `networks` [数组<哈希>] 此作业所需的网络。对于每个网络，可以指定以下属性：
	* `name` [字符串，必需] 在 `networks` 中指定网络名称。
	* `static_ips` [区间，可选] 指定作业应在该网络中预留的 IP 地址范围。
	* `default` [数组，可选] 指定从此网络中填充哪些默认网络组件（DNS、网关），仅在有多个网络时这才有意义。

#### 作业属性和云属性 ####

在部署清单中可以提供两种类型的属性。

1. cloud_properties: 向 CPI 传递的不透明哈希（通常“按原样”传递）。通常它控制着一些特定于 IaaS 的属性（如虚拟机配置参数、网络 VLAN 名称等）。CPI 需验证这些属性是否正确。
2. 作业属性。几乎所有重要的作业都需要填入一些属性，以便它可以了解如何与其他作业通信以及要使用哪些非默认设置。BOSH 允许在部署清单的属性部分中列出全局部署属性。控制器会以递归方式将所有这些属性从哈希转换成 Ruby OpenStruct 对象，以便可以使用原始哈希键名称作为方法名来访问它们。所得到的 OpenStruct 以 `properties` 名称公开，并且可以在任意作业配置模板中加以处理（使用 ERB 语法）。下面提供了一个示例
来说明如何定义和使用属性：

`deployment_manifest.yml` 文件

	…
	properties:
	  foo:
	    bar:
	      baz

文件	`jobs/foobar_manager/templates/config.yml.erb`

	---
	bar_value:< %= properties.foo.bar %>

全局属性可供任意作业使用。除此之外，每个作业还可以定义自己的 `properties` 部分，这些属性只能在该作业的配置模板中加以访问。本地作业属性是以递归方式合并到全局作业属性中的，因此访问这两类属性时所需的语法完全相同。请注意，可以使用本地属性来按作业覆盖全局属性。

#### 实例规范 ####

实例规范是一种任何作业配置文件皆可访问的特殊对象，与 `properties` 类似（实际上 `properties` 仅仅是 `spec.properties` 的简易版，因此它们只是规范的一小部分）。它包含很多属性，作业创建程序可以使用这些属性来访问特定作业实例环境的详细信息，可能还可以使用它们在创建作业时作出基于运行时的决策。

`job` 和 `index` 是实例规范的两个重要组成部分。`job` 包含作业名称，`index` 包含从 0 开始的实例索引。如果您希望对特定作业实例仅执行某些操作（如数据库迁移），或者希望仅在某些实例上而非全部实例上测试新功能，此索引便会派上重要用场。通过此规范提供的其他内容有 `networks` 和 `resource_pool`，在获取有关作业行踪的一些数据时，它们可能会派上用场。

### BOSH 属性存储 ###

部署清单是一个 YAML 文件，但它在经 ERB 处理后才会实际使用，因此它可能包含 ERB 表达式。通过此清单，BOSH 控制器可以替换其数据库中保存的一些属性，以便敏感或易变的数据仅在部署时设置，而不是由清单作者在创建实际清单时设置。

BOSH CLI 提供了一些可用来管理属性的命令：

	set property <name> <value>
	get property <name>
	unset property <name>
	properties

You can set the property using `bosh set property <name> <value>` and then reference it in the deployment manifest using `< %= property(name) %>` syntax.


## BOSH 故障排除 ##

### BOSH SSH ###

要对正在运行的作业运行 ssh，首先请查出该作业的名称和索引。使用 `bosh vms` 可显示正在运行的虚拟机的列表以及每个虚拟机上的作业。To ssh to it, run `bosh ssh <job_name> <index>`.密码是在 Stemcell 中设置的任意密码。对于默认 Stemcell，密码为 cloudc0w。

### BOSH 日志 ###

对 BOSH 或 BOSH 部署进行故障排除时，务必要阅读日志文件以便可以缩小问题范围。有以下三种类型的日志。

1. 可通过 `bosh task <task_number>` 查看的 BOSH 控制器日志

这些日志包含 BOSH 控制器上运行 BOSH 命令时产生的输出。如果在运行 BOSH 命令时出现问题，您应该先从这些日志着手排查。例如，如果您运行 `bosh deploy`，且此命令失败，那么 BOSH 控制器将有记录了出错位置的日志。要访问这些日志，请通过运行 `bosh tasks recent` 找到失败的命令的任务编号。然后，运行 `bosh task <task_number>`。控制器的日志记录程序会将相关信息写入到这些日志中。

1. 可在 `/var/vcap/bosh/log` 中找到或通过 `bosh logs` 查看的代理日志

这些日志包含代理产生的输出。当怀疑虚拟机设置存在问题时，这些日志便很有用。它们将显示代理的操作，如设置网络、磁盘和运行作业。如果 `bosh deploy` 因其中一个虚拟机出现问题而失败，您需要使用 BOSH 控制器日志才能查出是哪个虚拟机。Then, either ssh and access `/var/vcap/bosh/log` or use `bosh logs <job_name> <index> --agent`.

1. 服务日志

这些日志由虚拟机上运行的实际作业产生，可能是由 Redis、Web 服务器等产生的日志。这些日志间会有差别，因为它们输出到的位置由部署来配置。通常，具体的输出路径在 `release/jobs/<job_name>/templates/<config_file>` 中的配置文件中定义。对于 Cloud Foundry，我们的作业通常配置为记录到 `/var/vcap/sys/log/<job_name>/<job_name>.log`。These logs can also be accessed via `bosh logs <job_name> <index>`.

### BOSH 云检查 ###

BOSH 云检查是一项 BOSH 命令行实用程序，可自动检查已经部署的虚拟机和作业中是否存在问题。它会检查是否存在虚拟机不响应/不同步、磁盘未绑定等情况。要使用它，请运行 `bosh cck`，如果发现了任何问题，它会提示您需采取哪些操作。


