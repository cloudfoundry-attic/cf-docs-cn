---
title: 部署BOSH
description: 在OpenStack上通过BOSH工具大规模部署Cloud Foundry
tags:
    - OpenStack
    - BOSH
    - Deploy
---

这一部分部署BOSH的过程，与在vSphere上进行部署的过程都是相同的，不同的只是清单文件不同，其中涉及到的只是与OpenStack相关的一些环境的设置，主要是网络的设置。

### 创建BOSH清单

首先需要将BOSH的target定位到Micro BOSH，默认的用户名和密码为admin/admin：

`$ bosh target http://10.40.97.19:25555`

`Target set to 'microbosh-openstack'`

`Your username: admin`

`Enter password: *****`

`Logged in as 'admin'`

查看状态：

`$ bosh status`

Updating director data... done

	Director
	  Name      microbosh-openstack
	  URL       http://10.40.97.19:25555
	  Version   0.7 (release:59659cea bosh:4f2f9a01)
	  User      admin
	  UUID      1bcbbb1b-529f-4d93-a137-6037bc2eaeff
	  CPI       openstack
	  dns       enabled

	Deployment
	  not set

将UUID这个字符串复制出来，粘贴到下面的bosh.yml的director_uuid中。

对于BOSH清单，没有脚本可以利用，在此列出一个bosh.yml样例文件作为参考。

点击查看：[bosh.yml](https://github.com/vmware-china-se/bosh_doc/blob/master/OpenStack/bosh.yml)

创建~/bosh.yml文件，编辑这个文件如示例所示。

需要注意的是，这里面包含8个Jobs，只用到了三个floating ip，分别powerdns, director和openstack_registry。

在networks字段，需要把private和floating两个网络均配置好，对于floating网络，其名字为floating，类型为vip。对于private网络，其名字为default，类型为dynamic。对于private网络，还需要配置一个内部dns地址，这个地址就是上述Micro BOSH的址址。

### 获取BOSH stemcell

获取BOSH Stemcell也有两种方式，从公共的库中下载和自行手动创建，推荐直接下载的方法：

`$ cd /var/vcap/stemcells/`

`$ bosh public stemcells--tag=openstack`

这个命令可以列出当前公共的Stemcell:

	+---------------------------------------------+-----------------------------+
	| Name                                        | Tags                        |
	+---------------------------------------------+-----------------------------+
	| bosh-stemcell-openstack-0.6.7.tgz           | openstack                   |
	| bosh-stemcell-openstack-kvm-0.7.0.tgz       | openstack, kvm, test        |
	| micro-bosh-stemcell-openstack-0.7.0.tgz     | openstack, micro, test      |
	| micro-bosh-stemcell-openstack-kvm-0.8.1.tgz | openstack, kvm, micro, test |
	+---------------------------------------------+-----------------------------+

下载最新版本的BOSH Stemcell，在本示例中，最新版本为0.7.0:

`$ bosh download public stemcell bosh-stemcell-openstack-kvm-0.7.0.tgz`

第二种方式，我们也可以通过手动创建一个（对网络的需求也很高，不推荐）：

`$ cd /var/vcap/bootstrap/bosh/agent`

`$ rake stemcell2:basic["openstack"]`

结果为：

	Generated stemcell: /var/tmp/bosh/agent-0.6.7-25523/work/work/bosh-stemcell-openstack-kvm-0.6.7.tgz

创建好以后，将其移动到安全的地方：

`mv /var/tmp/bosh/agent-0.6.7-25523/work/work/bosh-stemcell-openstack-kvm-0.6.7.tgz \`
`/var/vcap/stemcells/`

### 部署BOSH

部署BOSH之前，需要首先上传我们已经创建好的release（在3.2节创建Micro BOSH stemcell时生成的release，如果使用公共stemcell而没有生成过release,则在这一步需要创建一个BOSH release，创建方法与3.2节所述相同），然后上传：

`$ bosh upload release /var/vcap/releases/bosh-release/dev_releases/bosh-11.1-dev.tgz`

再上传刚刚创建好的stemcell：

`$ bosh upload stemcell /var/vcap/stemcells/bosh-stemcell-openstack-kvm-0.7.0.tgz`

此时，就可以部署BOSH，部署命令为：

`$ bosh deployment ~/bosh.yml`

`$ bosh deploy`


