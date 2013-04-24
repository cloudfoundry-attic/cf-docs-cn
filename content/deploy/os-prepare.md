---
title: 准备BOSH CLI虚拟机
description: 在OpenStack上通过BOSH工具大规模部署Cloud Foundry
tags:
    - OpenStack
    - BOSH
    - Deploy
---

### Cloud Foundry安装概述

Cloud Foundry的安装过程可以概述如下：

1.安装BOSH CLI(Command Line Interface)

2.安装Micro BOSH

3.安装 BOSH

4.安装Cloud Foundry

BOSH是一个分布式系统部署与管理工具，Cloud Foundry等分布式系统可通过BOSH进行部署。BOSH本身也是一个分布式的系统，最小的BOSH集合包含8台虚拟机，所以，理论上BOSH也可以通过它自身来进行部署，这是一个自我迭代的过程，用BOSH开发团队的术语讲，这叫Inception。部署BOSH它自身的系统称作Micro BOSH。从Micro BOSH的名称可以看出，它是一个小型的BOSH系统，实际上，Micro BOSH就是一台虚拟机，它包含了所有的BOSH组件，但是因为它只运行在一台虚拟机上，所以性能比较弱，只适合用来部署BOSH，理论上它也可以直接部署Cloud Foundry，但是性能会非常差。

BOSH采用C-S架构，所以我们需要一台客户端，发送所有的BOSH命令，这台客户端称作BOSH CLI(Command Line Interface)。所以，综上所述，Cloud Foundry的安装过程为：准备好BOSH CLI，安装Micro BOSH，再通过Micro BOSH安装BOSH，最过通过BOSH安装Cloud Foundry。这些步骤中，所有的操作都在BOSH CLI上进行，所有的命令都通过BOSH CLI发送，所以，首先最重要的工作就是安装好BOSH CLI.

### 安装操作系统

BOSH的命令全部是通过一台BOSH CLI(Command Line Interface)的机器发送，这台机器可以是物理机，也可以是虚拟机。但是，必须保证这台BOSH CLI能顺利连接互联网。有一些包也需要通过国外的网站下载，所以，也需要保证它连接国外网站的稳定性与速度。此外，就是需要这台机器与floating ip这个网段能够直连。

最简单的方法就是，通过在上述我们建立好的OpenStack环境中，创建一台BOSH CLI虚拟机。

上面，我们已经创建了一个ubuntu 10.04的镜像，在Dashboard中启动一个它的实例即可：

![fig43.png](/images/deploy/fig43.png)

找到我们刚刚上传的ubuntu 10.04 LTS，点击右侧的lauch:
 
![fig44.png](/images/deploy/fig44.png)

在出现的选项卡中，输入自定义的虚拟机名字，在Flavor一栏选择我们刚刚创建的m1.inception，在Keypair一栏选择我们创建的mykey，然后点击Launch Instance，虚拟机即可启动。

然后，从已经创建好的floating ip里挑选一个分配给此虚拟机，方便我们通过ssh接入：

![fig45.png](/images/deploy/fig45.png)

现在可使用前面创建的密钥文件mykey.pem，通过ssh登录到这台虚拟机上，更新系统：

`$ ssh –i mykey.pem ubuntu@x.x.x.x （使用floating ip）`

`$ sudo apt-get update`

`$ sudo apt-get dist-upgrade`

下面，我们需要扩展/tmp和/var/vcap这两个目录的大小，因为此后的操作要占用这两个目录大量的空间，如果默认空间太小，则很多操作都会失败。如果您创建的BOSH CLI硬盘空间足够大，则可以忽略这一步操作。而我们通过上述公共镜像和Flavor创建的虚拟机，Root Disk空间很小。OpenStack创建虚拟机时，操作系统默认安装在/dev/vda(Root Disk)这个设备上，而这个硬盘的空间很小，我们需要用到第二块硬盘/dev/vdb(Ephemeral Disk)。

首先，创建文件夹

`$ sudo mkdir /var/vcap`

OpenStack中创建的第二块硬盘默认名称为/dev/vdb，它默认挂载在/mnt目录，我们首先将它卸载，再通过fdisk和mkfs分2个区/dev/vdb1和/dev/vdb2，大小分别为40G和10G，将这两个分区分别挂载到/var/vcap和/tmp目录下即可。 

### 安装ruby和rubygems

BOSH CLI这台虚拟机安装好以后，只有裸的操作系统，我们还需要在上面安装必要的ruby环境，以及安装所需要的rubygems包，我们参考以下文档进行安装:

[https://github.com/drnic/bosh-getting-started/blob/master/create-a-bosh/creating-a-micro-bosh-from-stemcell-openstack.md](https://github.com/drnic/bosh-getting-started/blob/master/create-a-bosh/creating-a-micro-bosh-from-stemcell-openstack.md)

这篇文档中提到了几个脚本，这几个脚本能帮助自动化地安装绝大部分的依赖环境。不过这篇文档有一些小错误，而且其部署步骤不完全。所以，在此我们修改了一些指令，增加了后续的部署步骤。

前面部分里我们已经创建好了一台BOSH CLI虚拟机，所以对应这篇github的文档，我们从其”Preparation”这一部分继续，此后所有的命令均在root账户下执行。

`$ sudo su –`

`$ export ORIGUSER=ubuntu`

在github中下载代码时，可能需要有配置密钥才能正常下载，所以先配置github账户：

`$ ssh-keygen`

`$ git config --global user.name FirstnameLastname`

`$ git config --global user.email your_email@youremail.com`

`$ cat ~/.ssh/id_rsa.pub`

将上述命令得到的公钥复制出来，通过网页登录https://github.com, 将此公钥配置到您的账户中。

再执行以下脚本：

`$ curl -s https://raw.github.com/drnic/bosh-getting-started/master/scripts/prepare_inception_openstack.sh | bash`

`$ source /etc/profile`

上面的脚本运行完成以后，还差一个bosh_deployer gem没有安装，安装这个gem包：

`$ gem install bosh_deployer`

然后再更新所有的gem，使所有gem保持最新版本:

`$ gem update`

这时，运行以下命令，出现以下的结果，就说明环境已经准备好了。

`$ bosh help micro`

	micro 
	    show micro bosh sub-commands 

	micro agent <args> 
	    Send agent messages 

	micro apply <spec> 
	    Apply spec 

	micro delete 
	    Delete micro BOSH instance (including persistent disk) 

	micro deploy [<stemcell>] [--update] 
	    Deploy a micro BOSH instance to the currently selected deployment 
	    --update update existing instance 

	micro deployment [<name>] 
	    Choose micro deployment to work with, or display current deployment 

	micro deployments 
	    Show the list of deployments 

	micro status 
	    Display micro BOSH deployment status

注：以上脚本默认安装的是最新版ruby，当前版本为1.9.3，Cloud Foundry官方目前推荐使用1.9.2，少数情况下会出现某些gem包信赖版本冲突的情况。如果以上脚本执行完以后，某些gem包不能正常工作，请使用rvm安装ruby-1.9.2版，安装步骤也请参照以下文档（“使用rvm安装Ruby和bosh cli”这一部分）：
[准备IaaS环境](vSphere-IaaS.html)
