---
title: 安装 BOSH
description: 在vSphere上通过BOSH工具大规模部署Cloud Foundry
tags:
    - vSphere
    - BOSH
    - Deploy
    - IaaS
---

BOSH CLI 安装完毕后，我们现在便开始安装Micro BOSH。如前文所述，可以将Micro BOSH视作袖珍版的 BOSH。尽管标准的 BOSH各个组件分布在 6 个虚拟机上 ，但Micro BOSH却恰恰相反，它在单个虚拟机中包含了所有组件。它可以轻易的设置，通常用于部署小型的Release，如 BOSH。从这个意义上讲，BOSH 是自部署的。用 BOSH 团队的话说，这叫做“Inception”。

以下步骤是通过在 BOSH 官方文档基础上添加更多操作细节改编成的。

1.在 BOSH CLI 虚拟机中，安装 BOSH 部署器bosh_deployer，这一部分大约需要5分钟。

`$ gem install bosh_deployer`

一旦安装了该部署器，那么您在命令行中键入 bosh 后将会看到一些额外的命令显示出来。

`$ bosh help`

		...
    		Micro
        	micro deployment [<name>]	选择要使用的微部署
        	micro status			显示Micro BOSH部署的状态
       	 	micro deployments		显示部署列表
        	micro deploy <stemcell>	将Micro BOSH实例部署到当前选择的部署
                        --update		更新现有实例
        	micro delete			删除Micro BOSH实例（包括持久磁盘）
        	micro agent <args>		发送代理消息
        	micro apply <spec>		应用规范

2.在 vCenter 中的“主页”(Home) ->“清单”(Inventory) ->“虚拟机和模板”(VMs and Templates) 视图下，确保用来存放虚拟机和模板的文件夹已经创建（见第 II 部分）。这些文件夹将在部署配置中使用。

3.从“主页”(Home) ->“清单”(Inventory) ->“数据存储”(Datastores) 视图中，选择我们创建的NFSdatastore数据存储，并浏览该存储。

![fig25.png](/images/deploy/fig25.png)

右键单击根文件夹，创建一个用来存储虚拟机的子文件夹。在本例中，我们将此子文件夹命名为“boshdeployer”。此文件夹名称将成为我们部署清单中的“disk_path”参数的值。

![fig26.png](/images/deploy/fig26.png)
 
注意：如果您没有共享的 NFS 存储，您可以使用hypervisor的本地磁盘作为数据存储。（注意: 仅建议在试验系统采用本地磁盘。）您可以按如下方式命名这些数据存储：主机 1 的数据存储命名为“localstore1”、主机 2 的数据存储命名为“localstore2”，依此类推。随后在清单文件中，您可以使用诸如“localstore*”之类的通配符模式来指定所有主机的数据存储。应在所有本地数据存储上都创建“boshdeployer”文件夹。

4.下载公共 stemcell  

`$ mkdir -p ~/stemcells`

`$ cd stemcells`

`$ bosh public stemcells`

输出大致如下 ：

	+---------------------------------+-------------------------------------------------------+
	| Name                            | Url                                                   |
	+---------------------------------+-------------------------------------------------------+
	| bosh-stemcell-0.5.2.tgz         | https://blob.cfblob.com/rest/objects/4e4e78bca31e1... |
	| bosh-stemcell-aws-0.5.1.tgz     | https://blob.cfblob.com/rest/objects/4e4e78bca21e1... |
	| bosh-stemcell-vsphere-0.6.4.tgz | https://blob.cfblob.com/rest/objects/4e4e78bca31e1... |
	| micro-bosh-stemcell-0.1.0.tgz   | https://blob.cfblob.com/rest/objects/4e4e78bca51e1... |
	+---------------------------------+-------------------------------------------------------+
	To download use 'bosh download public stemcell<stemcell_name>'.For full url use --full.

使用下面的命令下载Micro BOSH的 stemcell：

`$ bosh download public stemcell micro-bosh-stemcell-0.1.0.tgz`

注意：此stemcell的大小为 400 至 500 MB。在速度缓慢的网络中可能需要耗费很长时间才能将它下载下来。在这种情况下，您可以使用任何能在出断点续传的工具（如 Firefox 浏览器）进行下载。使用 --full 参数可显示完整的下载 URL。

5.配置部署 (.yml) 文件，然后将它保存在micro1文件夹下，该文件夹名称在 .yml文件中定义。

`$ cd ~`

`$ mkdir deployments`

`$ cd deployments` 

`$ mkdir micro01`

在 yml 文件中，有一节内容是关于 vCenter 的。请在此节中输入我们在第 II 部分中创建的文件夹的名称。“disk_path”应为我们刚刚在数据存储 (NFSdatastore) 中创建的文件夹。datastore_pattern 和persistent_datastore_pattern 的值是共享数据存储的名称 (NFSdatastore)。如果您采用本地磁盘，此值可以是像“localstore*”这样的通配字符串。

		datacenters:
		- name:vDataCenter	
		vm_folder:vm_folder	
		template_folder:template	
		disk_path:boshdeployer		
		datastore_pattern:NFSdatastore								
		persistent_datastore_pattern:NFSdatastore		
		allow_mixed_datastores:true 

下面是Micro BOSH的一个示例yml文件的链接：

[https://github.com/vmware-china-se/bosh_doc/blob/master/micro.yml](https://github.com/vmware-china-se/bosh_doc/blob/master/micro.yml)

6.使用以下命令设置此Micro BOSH部署：


注意：所有 bosh micro 命令必须先cd到这个Micro BOSH的部署目录中才能执行

`$ cd deployments`

`$ bosh micro deployment micro01`

`Deployment set to “~/deployments/micro01/micro_bosh.yml”`


`$ bosh micro deploy ~/stemcells/micro-bosh-stemcell-0.1.0.tgz`

如果一切都运行顺利，Micro BOSH将在几分钟内部署完毕。您可以通过下面的命令查看部署状态：

`$ bosh micro deployments`

您将会看到您的Micro BOSH部署已列出 ：

	+---------+-----------------------------------------+-----------------------------------------+
	| Name    | VM name                                 | Stemcell name                           |
	+---------+-----------------------------------------+-----------------------------------------+
	| micro01 | vm-a51a9ba4-8e8f-4b69-ace2-8f2d190cb5c3 | sc-689a8c4e-63a6-421b-ba1a-400287d8d805 |
	+---------+-----------------------------------------+-----------------------------------------+

###安装 BOSH###

Micro BOSH准备就绪后，我们就可用它来部署 BOSH。BOSH 是一个包含 6 个虚机的分布式系统。正如上一节所提到的那样，我们需要有三项内容：一个作为虚拟机模板的stemcell、一个作为待部署软件的 BOSH Release，以及一个用来定义部署配置的部署清单文件。我们来逐一准备。

1)首先，我们将 BOSH CLI 的目标设为Micro BOSH的Director。可以将 BOSH Director视作 BOSH 的控制者或协调者。所有 BOSH CLI 命令均发往该Director加以执行。该Director的 IP 地址在我们用来创建Micro BOSH的 yml 文件中定义。BOSH Director的默认用户/密码为 admin/admin。在我们的示例中，我们使用下面的命令来设定Micro BOSH的目标和进行身份验证：


`$ bosh target 10.60.98.124:25555`

`$ bosh login`

2)接下来，我们下载 BOSH stemcell并将其上传到Micro BOSH。这一步与下载Micro BOSH的 stemcell 类似。唯一的差别在于，我们选择的是 BOSH 而非Micro BOSH的stemcell。

`$ cd ~/stemcells`

`$ bosh public stemcells`

随即便会显示一列stemcell；请选择最新的stemcell进行下载：


`$ bosh download public stemcell bosh-stemcell-vsphere-0.6.4.tgz`

`$ bosh upload stemcell bosh-stemcell-vsphere-0.6.4.tgz`

如果您已在第 II 部分中创建了Gerrit帐户，请跳过第 3 步至第 7 步。

3)在以下位置注册 Cloud Foundry Gerrit服务器：[http://reviews.cloudfoundry.org](http://reviews.cloudfoundry.org)

4)设置您的 ssh 公钥（接受所有默认值）

`$ ssh-keygen -t rsa`


5)将您的密钥内容从 ~/.ssh/id_rsa.pub 完整复制到您的Gerrit和Git帐户配置的SSH public key部分中

需要注意您的gerrit账户（reviews.cloudfoundry.org）和git账户（github.com）都需要进行这个操作。

6)设置您的姓名和电子邮件


`$ git config --global user.name FirstnameLastname`

`$ git config --global user.email your_email@youremail.com`

如果您是新注册的gerrit账户，记得事先到账户设置里配置好自己的用户名并与这里的配置保持一致

7)前面已经安装好了gerrit-cli，在终端输入gerrit -v检查是否能打印出版本号

8)使用Gerrit从 Cloud Foundry 代码库中克隆Release代码。以下命令分别获取 BOSH 和 Cloud Foundry 的代码。


`$ gerrit clone ssh://<yourusername>@reviews.cloudfoundry.org:29418/bosh-release.git`

`$ gerrit clone ssh://<your username>@reviews.cloudfoundry.org:29418/cf-release.git`


然后我们创建我们自己的 BOSH Release：

`$ cd bosh-release`

`$ git submodule update --init`

`$ bosh create release  --with-tarball` 下载所有依赖包，并把整个BOSH打包成一个tar包

这个过程需要自己输入deployment的名字，BOSH会为最后的tar包和yml生成形如x.x-dev这样的版本号来命名。如果存在本地代码冲突，您可以添加“--force”选项：

`$ bosh create release  --with-tarball --force`

这里会要求您输入deployment的名字，您可以自己定义一个易于识别的名字比如bosh1。

这一步可能需要一些时间才能完成，具体取决于您的网络速度。它首先会从一个 Blob 服务器下载二进制文件。然后它会构建包并生成清单文件。该命令的输出大致如下：

	         Syncing blobs…
	          ...
	          Building DEV release
	          Please enter development release name:bosh-dev1
	           ---------------------------------
	          Building packages
	          …
	          Generating manifest...
	          …
	          Copying jobs...

最后，Release创建完毕后，您将看到大致如下的内容。请注意，最后两行指出了清单文件和Release文件。

		Generated /home/boshcli/bosh-release/dev_releases/bosh-dev1-6.1-dev.tgz
		Release summary
		---------------
		Packages
		+----------------+---------+-------+------------------------------------------+
		| Name           | Version | Notes | Fingerprint                              |
		+----------------+---------+-------+------------------------------------------+
		| nginx          | 1       |       | 1f01e008099b9baa06d9a4ad1fcccc55840cf56e |
		……
		| ruby           | 1       |       | c79b76fcb9bdda122ad2c52c3604ba950b482681 |
		+----------------+---------+-------+------------------------------------------+

		Jobs
		+----------------+---------+-------------+------------------------------------------+
		| Name           | Version | Notes       | Fingerprint                              |
		+----------------+---------+-------------+------------------------------------------+
		| micro_aws      | 1.1-dev | new version | fadbedb276f918beba514c69c9e77978eadb65ac |
		……
		| redis          | 2       |             | 3d5767e5deec579dee61f2c131982a97975d405e |
		+----------------+---------+-------------+------------------------------------------+
		Release version:6.1-dev
		Release manifest:/home/boshcli/bosh-release/dev_releases/bosh-dev1-6.1-dev.yml
		Release tarball (88.8M):/home/boshcli/bosh-release/dev_releases/bosh-dev1-6.1-dev.tgz

最后两句就是您create release生成出的产物。

9)将创建好的Release tar包上传到Micro BOSH的director。

`$ bosh upload release dev_releases/bosh-dev1-6.1-dev.tgz `

使用bosh releases就可以看到我们上传好的releases。

10)配置 BOSH 部署清单。首先，我们通过执行以下命令获取并记录下该director的 UUID 信息：

`$ bosh status`

	Updating director data... done
	Target         micro01 (http://10.60.98.124:25555) Ver: 0.4 (00000000)
	UUID           7d72eb71-9a98-4081-9857-ad7c7ff4ee33
	User           admin
	Deployment     /home/boshcli/bosh-dev1.yml

现在我们将进入此安装过程中最为复杂的环节：修改部署清单文件。由于大多数 BOSH 部署错误都是因为清单文件中的设置不正确而造成的，因此我们详细地对此环节进行说明。

首先，我们从以下位置获取清单模板：[https://github.com/cloudfoundry/oss-docs/blob/master/bosh/tutorial/examples/bosh_manifest.yml](https://github.com/cloudfoundry/oss-docs/blob/master/bosh/tutorial/examples/bosh_manifest.yml)

由于 BOSH 官方文档提供了该清单文件的规范，因此我们假定您在阅读本篇文章前，已经通读了此文档。我们将不会对该文件进行全面的介绍；而是讨论该清单文件中的一些重要项目。

**网络（networks）**

下面是网络一节的一个示例。

		networks:		#定义网络
		- name:default
		  subnets:
		  - reserved:	#您不希望分配的 IP
		    - 10.60.98.121 - 10.60.98.254
		    static:		#您将使用的 IP
		    - 10.60.98.115 - 10.60.98.120
		    range: 10.60.98.0/24
		    gateway: 10.60.98.1
		dns:
		    - 10.40.62.11
		    - 10.135.12.101
		cloud_properties:#与所有其他虚拟机都相同的网络。
		      name:VM Network

static：包含 BOSH 虚拟机的 IP 地址。

reserved：BOSH 不应使用的 IP 地址。请务必要排除所有已经分配给同一网络中其他设备（例如存储设备、网络设备、Micro BOSH和 vCenter 主机）的 IP 地址。在安装期间，Micro BOSH可能会创建一些临时虚拟机（工作者虚拟机）来执行编译。如果我们不指定预留的地址，这些临时虚拟机可能会与现有设备或主机存在 IP 地址冲突。

cloud_properties：name 是我们在 vSphere 中定义的网络名称（见第 II 部分）。

**资源池（resource_pools）**

此节定义作业使用的虚拟机配置（CPU、内存、磁盘和网络）。通常，应用程序的各个作业在资源使用方面各异。例如，有些作业需要较多的内存量，而有些作业则需要更多的vCPU来执行计算密集型任务。根据实际需要，我们应创建一个或多个资源池。需要注意的是，所有池的总规模应等于在清单文件中定义的作业实例的总数。部署 BOSH 时，由于总共有 6 个虚拟机（6 个作业），因此所有池的规模加起来应等于 6。

在我们的清单文件中，我们有 3 个资源池：

<table class="std">
<tr>
<th>Resource Pool</th>
      <th>Size</th>
      <th>VM Configuration</th>
      <th>Job</th>
    </tr>
<tr>
<td>small</td>
      <td>3</td>
      <td>RAM：512 MB；CPU：1 个；磁盘：2 GB</td>
      <td>nats、redis、health_monitor</td>
    </tr>
<tr>
<td>medium</td>
      <td>2</td>
      <td>RAM：1 GB；CPU：1 个；磁盘：8 GB</td>
      <td>postgres、blobstore</td>
    </tr>
<tr>
<td>director</td>
      <td>1</td>
      <td>RAM：2 GB；CPU：2 个；磁盘：8 GB</td>
      <td>director</td>
    </tr>
</table>


**编译（compilation）**

此节定义为编译包而创建的工作者虚拟机。在资源有限的系统中，我们应减少并发工作者虚拟机的数目，以确保编译成功。在我们的示例中，我们定义 4 个工作者虚拟机。

**更新（update）**

此节包含一个非常有用的参数：max_in_flight。此参数用于向 BOSH 告知最多可以并行安装的作业数。在运行速度缓慢的系统中，请设法减小此数目。如果将此数目设置为 1，则表示作业将按顺序部署。对于 BOSH 部署，我们建议将此数目设置为 1，以确保 BOSH 可以成功安装。

**作业（jobs）**

在 BOSH Release中有六个作业。每个作业占用一个虚拟机。根据作业的性质和资源使用情况，我们将作业分配给各个资源池。需要注意的一点是，我们需要向以下三个作业分配持久磁盘：postgres、director 和blobstore。若无持久磁盘，这些作业将无法正常运行，因为它们的本地磁盘很快就会被占满。

最好填写一张像下面这样的电子表格来对您的部署进行规划。您可以根据该电子表格修改部署清单。

<table class="std">
<tr>
<th>作业</th>
      <th>资源池</th>
      <th>IP</th>
    </tr>
<tr>
<td>nats</td>
      <td>small</td>
      <td>10.60.98.120</td>
    </tr>
<tr>
<td>postgres</td>
      <td>medium</td>
      <td>10.60.98.119</td>
    </tr>
<tr>
<td>redis</td>
      <td>small</td>
      <td>10.60.98.118</td>
    </tr>
<tr>
<td>director</td>
      <td>director</td>
      <td>10.60.98.117</td>
    </tr>
<tr>
<td>blob_store</td>
      <td>medium</td>
      <td>10.60.98.116</td>
    </tr>
<tr>
<td>health_monitor</td>
      <td>small</td>
      <td>10.60.98.115</td>
    </tr>
</table>

我们基于上表创建了一个示例部署清单，您可以从这里下载：

[https://github.com/vmware-china-se/bosh_doc/blob/master/bosh.yml](https://github.com/vmware-china-se/bosh_doc/blob/master/bosh.yml)

我们至少需要在这个配置文件中更改bosh director的UUID，release的名称和版本

11)更新完部署清单文件后，我们便可以通过运行以下命令开始实际部署：


	$ bosh deployment bosh_dev1.yml

	$ bosh deploy 


此过程可能需要等待一段时间才能完成，具体取决于您的网络条件以及可用的硬件资源。您也可以在 vCenter 控制台查看创建、配置并销毁虚拟机的过程。

		Preparing deployment
		…..
		Compiling packages
		……
		Binding instance VMs
		  postgres/0 (00:00:01)                                                                            
		  director/0 (00:00:01)                                                                            
		  redis/0 (00:00:01)                                                                               
		  blobstore/0 (00:00:01)                                                                           
		  nats/0 (00:00:01)                                                                                
		  health_monitor/0 (00:00:01)                                                                      
		Done                    6/6 00:00:01                                                               

		Updating job nats
		  nats/0 (canary) (00:01:14)                                                                       
		Done                    1/1 00:01:14
		……
		Updating job director
		  director/0 (canary) (00:01:10)                                                                   
		Done                    1/1 00:01:10   
		……

如果一切运行顺利，您最终将会看到大致如下的结果：

		Task 14 done
		Started		2012-08-12 03:32:24 UTC
		Finished	2012-08-12 03:52:24 UTC
		Duration	00:20:00
		Deployed `bosh-dev1.yml` to `micro01`
    
这表示您已成功部署 BOSH。您可以通过执行下面的命令来查看您的部署：

`$ bosh deployments`

		+-------+
		| Name  |
		+-------+
		| bosh1 |
		+-------+

您可以通过执行下面的命令来查看所有虚拟机的状态：

`$ bosh vms`

如果一切都未出问题的话，您将看到大致如下的虚拟机状态：

		+------------------+---------+---------------+--------------+
		| Job/index        | State   | Resource Pool | IPs          |
		+------------------+---------+---------------+--------------+
		| blobstore/0      | running | medium        | 10.60.98.116 |
		| director/0       | running | director      | 10.60.98.117 |
		| health_monitor/0 | running | small         | 10.60.98.115 |
		| nats/0           | running | small         | 10.60.98.120 |
		| postgres/0       | running | medium        | 10.60.98.119 |
		| redis/0          | running | small         | 10.60.98.118 |
		+------------------+---------+---------------+--------------+
		VMs total: 6

