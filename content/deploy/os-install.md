---
title: OpenStack Essex安装与配置
description: 在OpenStack上通过BOSH工具大规模部署Cloud Foundry
tags:
    - OpenStack
    - BOSH
    - Deploy
---

本文档所讲述的方法和步骤与在vSphere上部署很相似，区别仅仅在于本文档中关于OpenStack的一些配置与vSphere不同，在vSphere上部署Cloud Foundry可参考这篇文档：

[在vSphere上通过BOSH工具大规模部署Cloud Foundry](vSphere.html)

按照本文档进行部署时，可将上述文档作为参考和补充之用。

### OpenStack安装
本文档以OpenStack Essex版本为基础讲解，如果在Folsom上部署，过程也基本相同，不同点只在于网络quantum的管理，特别是floating ip的生成与释放和private sub_net的创建，对于OpenStack Folsom版，本文档同样适用。

关于OpenStack Essex的安装，Openstack官方有很多引导教程，你可以采用适合自己的安装方法，也可以在原来已经安装好的Openstack里划出一部分资源来安装Cloud Foundry，在本示例文档所采用的环境中，我们跟据以下文档安装了一个双节点的Openstack环境：

[OpenStack官方文档](http://docs.openstack.org/essex/openstack-compute/starter/content/)

按照以上教程安装到第2节结束即可。
我们使用了两台服务器分别作为两个节点，这两台服务器的配置如下：

<table class="std">
<tr>
<th>Name</th>
      <th>Role</th>
      <th>Physical CPU</th>
      <th>Physical Memory</th>
      <th>Nic</th>
      <th>Management IP Address</th>
    </tr>
<tr>
<td>Server1</td>
      <td>Controller+Compute</td>
      <td>8 Cores</td>
      <td>16GB</td>
      <td>eth0: floating eth1: private</td>
      <td>10.40.97.30</td>
    </tr>
<td>Server2</td>
      <td>Compute</td>
      <td>8 Cores</td>
      <td>16GB</td>
      <td>eth0: floating eth1: private</td>
      <td>10.40.97.31</td>
    </tr>
</table>

每台服务器有两张网卡，以OpenStack的概念来说，其中eth0专门用作floating ip，eth1专门用作private ip。eth0的IP地址如上表最后一列所示，这个IP 地址在下面的nova配置文件中会用到。

### OpenStack配置
根据以上教程，在此环境中最重要的就是nova.conf这个文件的配置，在我们的环境中，server1的/etc/nova/nova.conf配置如下：

	--dhcpbridge_flagfile=/etc/nova/nova.conf
	--dhcpbridge=/usr/bin/nova-dhcpbridge
	--logdir=/var/log/nova
	--state_path=/var/lib/nova
	--lock_path=/run/lock/nova
	--allow_admin_api=true
	--use_deprecated_auth=false
	--auth_strategy=keystone
	--scheduler_driver=nova.scheduler.simple.SimpleScheduler
	--max_cores=256
	--max_gigabytes=1000000
	--skip_isolated_core_check=true
	--s3_host=10.40.97.30
	--ec2_host=10.40.97.30
	--rabbit_host=10.40.97.30
	--cc_host=10.40.97.30
	--nova_url=http://10.40.97.30:8774/v1.1/
	--routing_source_ip=10.40.97.30
	--glance_api_servers=10.40.97.30:9292
	--image_service=nova.image.glance.GlanceImageService
	--iscsi_ip_prefix=192.168.4
	--sql_connection=mysql://novadbadmin:novasecret@10.40.97.30/nova
	--ec2_url=http://10.40.97.30:8773/services/Cloud
	--keystone_ec2_url=http://10.40.97.30:5000/v2.0/ec2tokens
	--api_paste_config=/etc/nova/api-paste.ini
	--libvirt_type=kvm
	--libvirt_use_virtio_for_bridges=true
	--start_guests_on_host_boot=true
	--resume_guests_state_on_host_boot=true
	# vnc specific configuration
	--novnc_enabled=true
	--novncproxy_base_url=http://10.40.97.30:6080/vnc_auto.html
	--vncserver_proxyclient_address=10.40.97.30
	--vncserver_listen=10.40.97.30
	# network specific settings
	--network_manager=nova.network.manager.FlatDHCPManager
	--public_interface=eth0
	--flat_interface=eth1
	--flat_network_bridge=br100
	--fixed_range=192.168.4.1/24
	--floating_range=10.40.97.1/24
	--network_size=256
	--flat_network_dhcp_start=192.168.4.2
	--flat_injected=False
	--force_dhcp_release
	--iscsi_helper=tgtadm
	--connection_type=libvirt
	--root_helper=sudo nova-rootwrap
	--verbose

请把其中所有的IP地址替换为您自己的IP。在这里，以10开头的地址为floating ip的地址，以192.168开头的地址为private ip地址。

上述配置与官方文档不同的是，在上述配置文件中，我们添加了三行：

	--max_cores=256
	--max_gigabytes=1000000
	--skip_isolated_core_check=true

添加这三行的目的是，提升OpenStack对虚拟机CPU数和内存问题的限制，当然，以上这两行的值也可以根据实际的部署情况增加。max\_cores参数的意义是整个环境中所允许的虚拟CPU的数量，应该改得大一些，以支撑所有的Cloud Foundry虚拟机，否则部署Cloud Foundry会失败。max\_gigabytes为总的内存使用限制量，也应该改得足够大。skip\_isolated\_core\_chec参数的意义是跳过虚拟CPU在物理CPU上分配的检查，在小环境里，最好设置为true。

另外，官方文档中说这两台服务器的/etc/nova/nova.conf文件完全相同。但是经我们测试，每一台服务器的vnc配置都不相同，所以，在server2上，编辑/etc/nova/nova.conf文件，修改vnc的部分为：

	# vnc specific configuration
	--novnc_enabled=true
	--novncproxy_base_url=http://10.40.97.31:6080/vnc_auto.html
	--vncserver_proxyclient_address=10.40.97.31
	--vncserver_listen=10.40.97.31

也就是说，其中的IP地址改为server2的IP地址，其余配置与server1完全一样。

另外，OpenStack为了安全，限制了REST接口发送和接收的速率，为了快速部署的方便，在server1和server2这两台服务器均进行以下修改：
打开/etc/nova/api-paste.ini文件
找到下面两行

	[filter:ratelimit]
	paste.filter_factory = nova.api.openstack.compute.limits:RateLimitingMiddleware.factory

紧接着这两行下面，添加一行：

	limits=(POST, "*", .*, 9999, MINUTE);(POST, "*/servers", ^/servers, 9999, DAY);(PUT, "*", .*, 9999, MINUTE);(GET, "*changes-since*", .*changes-since.*, 9999, MINUTE);(DELETE, "*", .*, 9999, MINUTE)

为了保险，可重启两台服务器。

至此，OpenStack的安装结束。按官方文档所述，运行以下命令，如果出现如下结果，说明安装正确：

`$ sudo nova-manage service list`

	Binary           Host              Zone             Status     State   Updated_At
	nova-scheduler   server1           nova             enabled    :-)     2013-01-16 08:05:23
	nova-consoleauth server1          nova             enabled    :-)     2013-01-16 08:05:23
	nova-compute     server1           nova             enabled    :-)     2013-01-16 08:05:27
	nova-network     server1            nova             enabled    :-)     2013-01-16 08:05:23
	nova-cert        server1             nova             enabled    :-)     2013-01-16 08:05:23
	nova-volume      server1            nova             enabled    :-)     2013-01-16 08:05:23
	nova-compute     server2           nova             enabled    :-)     2013-01-16 08:05:13

### Cloud Foundry安装准备

首先，我们需要准备一台ubuntu 12.04机器作为客户端，用于向OpenStack的管理器发送命令，这台客户端可由您随意创建，在个人PC上创建一台ubuntu虚拟机即可。
创建文件~/osrc，编辑文件如下：

	export SERVICE_ENDPOINT="http://10.40.97.30:35357/v2.0"
	export SERVICE_TOKEN=admin
	export SERVICE_TOKEN=admin
	export OS_TENANT_NAME=admin
	export OS_USERNAME=admin
	export OS_PASSWORD=admin
	export OS_AUTH_URL="http:// 10.40.97.30:5000/v2.0/"
	export SERVICE_ENDPOINT=http:// 10.40.97.30:35357/v2.0

其中IP地址为您server1的IP，再运行命令：

`$ source ~/osrc`

此时就可以在这台客户机上向OpenStack发送命令了。

Cloud Foundry的安装需要Ubuntu 10.04 LTS 64bit的虚拟机。在上述OpenStack官方文档中，它说需要一台Client机器自己制作虚拟机镜像。其实在Ubuntu的官方网站上，有专门为云计算环境提供的一些公共镜像，地址为：

[http://cloud-images.ubuntu.com/](http://cloud-images.ubuntu.com/)

所以，找到Ubuntu12.04的镜像，我们可以采用如下方式添加镜像：

`$ glance add name="ubuntu 10.04 LTS" disk_format=ami container_format=ami is_public=true \`
`location=http://cloud-images.ubuntu.com/lucid/current/lucid-server-cloudimg-amd64-disk1.img`

如果没有错误，将返回如下结果：

	Added new image with ID: 97753009-8cb2-4c59-adc1-b3c6d1bc3f56

在OpenStack的安装里，默认只有5种Flavors，我们需要根据Cloud Foundry需求，创建适合自己部署环境的Flavor。OpenStack安装好以后，Dashboard就可以使用了，在浏览器中直接输入server1的IP地址即可访问，默认的用户名和密码为admin和admin。登录以后，进行如下所示操作：

![fig32-1.png](/images/deploy/fig32-1.png)

切换到admin管理界面，选择Flavor Tab， 点击Create Flavor，出现如下选项，我们创建一种名为m1.micro的Flavor，用于我们实验中的所有虚拟机（编译除外），各项参数如下。在实际生产环境中，内存和CPU当然不可能这么小，可根据实际需要填写合适的值。并且，对于不同的虚拟机，需要创建不同的Flavors。
 
![fig33.png](/images/deploy/fig33.png)

另外，我们再创建一个Flavor，专门用来进行编译工作，我们命名为m1.compile，编译需要的资源要大一些，所以我们选择4个CPU和4G内存：

![fig34.png](/images/deploy/fig34.png)

另外，我们还创建了一个flavor，命名为m1.inception，专门用作BOSH CLI(Command Line Interface)之用，它的配置为2个CPU，2G内存，50G硬盘。

为了安全，OpenStack的安全组默认禁止了所有的端口通信，在我们测试全程中，我们手动开启了所有端口，过程如下，首先在Dashboard里找到左侧的Access & Security选项卡：

![fig35.png](/images/deploy/fig35.png)

在右侧找到Security Groups配置，选择Edit Rules：

![fig36.png](/images/deploy/fig36.png)

在测试环境中，我们允许所有的端口进行通信，而默认的OpenStack配置是关闭了所有的端口，所以，我们需要删除其中的所有默认规则，自己创建以下规则，打开所有端口：

![fig37.png](/images/deploy/fig37.png)

在OpenStack默认安装中，对每一个工程的限额（Quotas)很低，我们需要提高默认限额，按照如下方法：

![fig38.png](/images/deploy/fig38.png)

切换到admin界面，找到左侧的Projects，在右侧找到admin这个工程，选择Edit Project->Modify Quotas，结果如下：

![fig39.png](/images/deploy/fig39.png)

其中，每一项的值代表每一项资源的上限额度，每一项的值可根据需要调整到合适的值。在我们示例中，为了避免不必要的麻烦，我们选择了远远高于实际所需要的上限。

下一步的工作就是创建必要的floating ip池。在本次示例中，我们选择了最小化的Cloud Foundry安装，并没有安装所有的Cloud Foundry组件，尽管如此，也仍然需要大约25个floating ip。如果按照以上官方教程安装OpenStack，那么floating ip pool已经创建好了。我们只需要从池中分配出floating ip即可。

在Dashboard里，可通过如下方式创建floating ip：

![fig40.png](/images/deploy/fig40.png)

切换到Project选项卡，选择admin，再选择Access & Security，点击右侧的Allocate IP To Project，即可分配一个floating ip。

也可以在客户端，通过一个shell循环，分配所需要的所有floating ip:

`$ i=0`

`$ while(($i<25))`

`> do`

`> nova floating-ip-create`

`> i=$(($i+1))`

`> done`

最后，我们还需要创建一个默认的key文件 。同样在Dashboard的以上Access & Security选项卡中，有创建密钥对的选项：

![fig41.png](/images/deploy/fig41.png)

输入我们第一个密钥名字”mykey”，点击Create Keypair，浏览器会自动下载创建好的密钥的私钥mykey.pem，请妥善保存此私钥，在以后登录虚拟机时也可能用到此私钥：

![fig42.png](/images/deploy/fig42.png)




