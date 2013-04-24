---
title: 部署Micro BOSH
description: 在OpenStack上通过BOSH工具大规模部署Cloud Foundry
tags:
    - OpenStack
    - BOSH
    - Deploy
---

### 创建Micro BOSH清单

在这台BOSH CLI虚拟机上，我们同样需要设置OpenStack的环境变量，其中的IP地址为Server1的IP：

`$ export SERVICE_ENDPOINT="http://10.40.97.30:35357/v2.0"`

`$ export SERVICE_TOKEN=admin`

`$ export SERVICE_TOKEN=admin`

`$ export OS_TENANT_NAME=admin`

`$ export OS_USERNAME=admin`

`$ export OS_PASSWORD=admin`

`$ export OS_AUTH_URL="http://10.40.97.30:5000/v2.0/tokens"`

`$ export SERVICE_ENDPOINT=http://10.40.97.30:35357/v2.0`

同时编辑~/.bashrc文件，将上述命令直接粘贴到文件尾部，避免重新登录时重复输入。

然后运行脚本，创建专用于Cloud Foundry虚拟机的密钥对：

`$ curl -s https://raw.github.com/drnic/bosh-getting-started/master/scripts/create_keypair \`
`> /tmp/create_keypair`

`$ chmod 755 /tmp/create_keypair`

`$ /tmp/create_keypair openstack $OS_USERNAME $OS_PASSWORD $OS_TENANT_NAME $OS_AUTH_URL inception`

此命令执行结果为：

	OpenStack key inception created at /home/vcap/.ssh/inception.pem

说明密钥对创建成功。

接着使用一个已经写好的脚本来自动创建Micro BOSH的部署清单。

`$ curl -s https://raw.github.com/drnic/bosh-getting-started/master/scripts/create_micro_bosh_yml \`
`> /tmp/create_micro_bosh_yml`

`$ chmod 755 /tmp/create_micro_bosh_yml`

`$ /tmp/create_micro_bosh_yml microbosh-openstack openstack $OS_USERNAME $OS_PASSWORD \`
`$OS_TENANT_NAME $OS_AUTH_URL inception 10.40.97.19 password`

其中最后三个参数的含义分别为：

1.创建的密钥对名称

2.已经创建好的floating ip，从中挑选一个使用

3.用于Micro BOSH虚拟机的密码，可改成一个自定义的安全的密码

命令执行以后，Micro BOSH的清单自动保存在/var/vcap/deployments/microbosh-openstack/micro_bosh.yml

可修改其中的instance_type为合适的flavor(如本文档1.3节所述)，一个示例清单文件为：

点击查看：[micro_bosh.yml](https://github.com/vmware-china-se/bosh_doc/blob/master/OpenStack/micro_bosh.yml)

### 获取Micro BOSH Stemcell

获取Micro BOSH Stemcell有两种方式，从公共的库中下载和自行手动创建，推荐直接下载的方法：

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

下载最新版本的Micro BOSH Stemcell，在本示例中，最新版本为0.8.1:

`$ bosh download public stemcell micro-bosh-stemcell-openstack-kvm-0.8.1.tgz`

第二种方式：如果想与最新的BOSH代码保持一致，可以通过脚本自行创建stemcell，但是，自行创建stemcell时，对网络的要求很高，需要很快的网速，并且需要连接国外的网站非常稳定，否则，如果连接超时，会中断创建过程。默认是没有缓存的，所以重新创建需要从头开始，再耗费大量的时间，在网络不理想时，不建议自己创建stemcell。

如果需要自己手动创建stemcell，首先，创建BOSH release:

`$ cd /var/vcap/releases/bosh-release/`

`$ git pull`

`$ git submodule update --init –recursive`

`$ bosh create release --with-tarball`

此命令的结果为（版本号可能不同）：

	Release version: 11.1-dev
	Release manifest: /var/vcap/releases/bosh-release/dev_releases/bosh-11.1-dev.yml
	Release tarball (102.8M): /var/vcap/releases/bosh-release/dev_releases/bosh-11.1-dev.tgz

有了这个release压缩包，就可以创建Micro BOSH stemcell:

`$ cd /var/vcap/bootstrap/bosh/agent`

`$ rake stemcell2:micro["openstack",\`
`/var/vcap/releases/bosh-release/micro/openstack.yml,\`
`/var/vcap/releases/bosh-release/dev_releases/bosh-11.1-dev.tgz]`

这条命令的输出结果为（版本号可能有差异）：

	Generated stemcell: /var/tmp/bosh/agent-0.6.7-9011/work/work/micro-bosh-stemcell-openstack-kvm-0.8.0.tgz

将其移动到安全的位置

`$ mv /var/tmp/bosh/agent-0.6.7-9011/work/work/micro-bosh-stemcell-openstack-kvm-0.8.0.tgz \`
`/var/vcap/stemcells/`

### 部署Micro BOSH

此时，就可以部署Micro BOSH了：

`$ cd /var/vcap/deployments`

`$ bosh micro deployment microbosh-openstack`

`$ bosh micro deploy /var/vcap/stemcells/micro-bosh-stemcell-openstack-kvm-0.8.1.tgz`

部署完成后，结果为：

	WARNING! Your target has been changed to `http://10.40.97.19:25555'!
	Deployment set to '/var/vcap/deployments/microbosh-openstack/micro_bosh.yml'
	Deployed `microbosh-openstack/micro_bosh.yml' to `http://microbosh-openstack:25555', took 00:04:15 to complete



