---
title: 部署Cloud Foundry
description: 在OpenStack上通过BOSH工具大规模部署Cloud Foundry
tags:
    - OpenStack
    - BOSH
    - Deploy
---

这一部分部署Cloud Foundry的过程，也与在vSphere上的部署过程相同，不同的只是清单文件里关于OpenStack的配置不同。

### 创建Cloud Foundry清单文件

首先将BOSH的target切换到bosh-director，这里的IP地址为4.1节BOSH清单里为bosh director分配的floating ip地址:

`$ bosh target http://10.40.97.21:25555`

`$ bosh status`

结果为：

	Updating director data... done

	Director
	  Name      bosh-openstack
	  URL       http://10.40.97.21:25555
	  Version   0.7 (release:59659cea bosh:4f2f9a01)
	  User      admin
	  UUID      cde893e8-008b-4ee2-bef4-87f4a7d04c02
	  CPI       openstack
	  dns       enabled

	Deployment
	  not set

将UUID复制出来，在根目录创建文件~/cfos.yml，编辑这个文件如下示例所示，将其中的IP地址替换为您环境中的floating IP地址，这就是部署Cloud Foundry的清单文件，为了测试，我们只部署了postgresql这一项服务，如果需要部署其它服务，可参考postgresql的配置编写。

点击查看：[cfos.yml](https://github.com/vmware-china-se/bosh_doc/blob/master/OpenStack/cfos.yml)

### 部署Cloud Foundry

首先下载Cloud Foundry源码：

`$ cd /var/vcap/releases/`

`$ git clone https://github.com/cloudfoundry/cf-release`

cf-release里面包含了一个update脚本，用于更新Cloud Foundry代码及其子模块，每次创建Cloud Foundry release 之前，需运行update脚本：

`$ cd ./cf-release`

`$ ./update`

更新完成以后，就可以创建Cloud Foundry release：

`$ bosh create release --with-tarball`

过程中，需要为release选择一个名字，这里我们取名为cfdev，创建成功以后，我们就可以上传release:

`$ bosh upload release /var/vcap/releases/cf-release/dev_releases/cfdev-126.1-dev.tgz`

然后再上传stemcell，这里的stemcell和前面安装BOSH时用的bosh stemcell相同：

`$ bosh upload stemcell /var/vcap/stemcells/bosh-stemcell-openstack-kvm-0.7.0.tgz`

此时，就可以部署Cloud Foundry，部署命令为：

`$ bosh deployment ~/cfos.yml`

`$ bosh deploy`

### 测试安装

部署完成以后，另外还需要安装一个外部的负载均衡器，通过其将外部分访问引导入到Cloud Foundry的多台内部路由上（在上述测试安装的清单文件中，只有一个路由，但是，在实际的生产环境中，需要部署多个路由），还需要配置本地DNS。此外，还可以通过Yeti对已安装的环境进行功能性测试，这两部分的具体方法都与OpenStack环境无关，所以，也可参考在vSphere上部署的过程，进行后续的安装与测试，请参见文档《[在vSphere上通过BOSH工具大规模部署Cloud Foundry](vSphere.html)》

至此，Cloud Foundry在OpenStack平台上的部署完成。
