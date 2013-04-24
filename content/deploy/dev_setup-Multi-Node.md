---
title: 使用dev_setup进行多节点Cloud Foundry安装
description: 使用dev_setup进行多节点Cloud Foundry安装
tags:
    - dev_setup
---

_作者：**Mahesh Patil**_

## 背景信息

Cloud Foundry 由多个系统组件（云控制器、
运行状况管理器、DEA、路由器等）组成。这些组件可以共置于
单个虚拟机/单个操作系统中运行，也可以分散在多个计算机/虚拟机上。

出于开发需要，首选的环境是在单个虚拟机中
运行所有核心组件，然后从该虚拟机外部
通过 SSL 隧道与此系统进行交互。预定义的域 `*.vcap.me` 映射到本地主机，
因此当您使用这种设置时最终结果是，可以
在 [http://api.vcap.me](http://api.vcap.me) 使用您的开发环境。

对于大规模或多虚拟机部署，此系统十分灵活，允许
您将这些系统组件置于多个虚拟机上，运行指定类型的多个
节点（例如 8 个路由器、4 个云控制器，等等）

在 [github.com/cloudfoundry/vcap](http://github.com/cloudfoundry/vcap) 资源库中，我们已经发布了一个名为_dev_setup_ 的 VCAP 安装架构，此架构采用 [Chef](https://github.com/opscode/chef)。请查看 [dev_setup](https://github.com/cloudfoundry/vcap/tree/master/dev_setup) 目录的内容。您可以使用此架构来执行单节点或多节点 VCAP 安装。本文档将一步步地介绍使用 dev_setup 脚本执行单节点和多节点安装的过程。

这些说明的各个版本已在生产部署中使用，此外也已
用于我们自己的开发。由于我们大家有不少人都是在 Mac 笔记本电脑上进行开发的，
因此还针对这种环境加入了一些额外的说明。

## 免责声明

以下脚本是使用原始的 Ubuntu 10.04 64 位安装环境进行测试的，并且假定使用的也是这种环境。其他 Ubuntu 发行版、Linux 分发包及操作系统尚未采用这种安装方法进行验证，因而在使用时可能不起作用。

## 前提条件：装有 SSH 的原始虚拟机

* 使用原始的 Ubuntu 10.04 服务器 64 位映像设置一个虚拟机，该映像可以
[从此处下载](http://www.ubuntu.com/download/ubuntu/download)
* 为该虚拟机设置 1G 或更多内存
* 您可能需要现在就创建该虚拟机的快照，以便在万一搞砸时进行恢复
* 要启用远程访问（比使用控制台更有趣），请安装 ssh。

安装 ssh：

    sudo apt-get install openssh-server

# 单节点部署

本节将引导您完成单节点 Cloud Foundry (VCAP) 部署的安装和验证过程。这是搭建适合部署和测试的 VCAP 环境并让其运行起来的最快方式。

## 单节点安装

1. 运行安装脚本。
	
	此脚本在开始时及快要结束时会要求您提供您的 sudo 密码。整个过程需要大约半个小时，因此时不时盯一下就可以了。

		sudo apt-get install curl
		bash < <(curl -s -k -B https://raw.github.com/cloudfoundry/vcap/master/dev_setup/bin/vcap_dev_setup)

	脚本执行结束时，您应该会看到与下面类似的消息：
    
	    ---------------  
	    Deployment info  
	    ---------------  
	    Status:successful  
	    Config files:/home/cfsupp/cloudfoundry/.deployments/devbox/config  
	    Deployment name:devbox  
	    Command to run cloudfoundry:/home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev start
	
	如果此安装过程因出错而停止，请务必查看本文档最后的**已知问题**部分。
	
2. 启动此系统

		~/cloudfoundry/vcap/dev_setup/bin/vcap_dev start

3. *（可选，仅限 mac/linux 用户）*创建一个本地 SSH 隧道。

	从您的虚拟机中运行 `ifconfig` 并记下 eth0 IP 地址，此地址类似于： `192.168.252.130`

	现在转到您的 Mac 终端窗口，验证您能否使用 SSH 进行连接：

	    ssh <您的虚拟机用户>@<虚拟机 IP 地址>

	如果能够连接，请注销并创建一个本地端口 80 隧道：

	    sudo ssh -L <本地端口>:<虚拟机 IP 地址>:80 <您的虚拟机用户>@<虚拟机 IP 地址> -N

	如果您尚未运行本地 Web 服务器，请使用端口 80 作为您的本地端口；
	否则，您可能需要使用 8080 或其他常用 http 端口。

	从您的 Mac 以及从该虚拟机中都完成此操作后，`api.vcap.me` 和 `*.vcap.me`
	将映射到 localhost，localhost 又将映射到正在运行的 Cloud Foundry 实例。
	
## 试用您的环境

1. 验证您能否连接以及测试是否通过。

	从您的虚拟机的控制台中，或者从您的 Mac（得益于本地隧道）中运行以下命令：
	
        vmc target api.vcap.me
		vmc info
	
	注意：如果您运行的是隧道并且选择的是 80 以外的本地端口，您将
	需要修改目标以在此包含该端口，例如 `api.vcap.me:8080`。

2. 这应该会产生大致如下的输出：

        VMware's Cloud Application Platform
        For support visit http://support.cloudfoundry.com

        Target:   http://api.vcap.me (v0.999)
		Client:   v0.3.10

3. 以用户身份体验一下，首先运行：

		vmc register --email foo@bar.com --passwd password
		vmc login --email foo@bar.com --passwd password

4. 要了解您还可以执行哪些其他操作，请尝试运行：
		
		vmc help
	
## 测试您的环境

1. 此系统安装好后，您就可以运行以下基本系统
	验证测试 (BVT) 来确保主要功能正常工作。BVT
	需要用到额外的 Maven 和 JDK 依赖项，可通过以下命令安装它们：

		sudo apt-get install default-jdk maven2

	现在您既然已经有了必需的依赖项，您就可以运行 BVT 了：

		source ~/.cloudfoundry_部署_local
		cd cloudfoundry/vcap
		cd tests && bundle package; bundle install && cd ..
		rake tests

2. 也可以使用以下命令来运行单元测试：

		source ~/.cloudfoundry_部署_local
		cd cloud_controller
		rake spec
		cd ../dea
		rake spec
		cd ../router
		rake spec
		cd ../health_manager
		rake spec
	
### 大功告成，请确保您可以运行一个简单的 hello world 应用程序：

1. 为您的测试应用程序创建一个空目录（姑且将此目录命名为 env），然后进入此目录。

		mkdir env && cd env

2. 将下面的应用程序剪切并粘贴到一个 ruby 文件中（姑且将此文件命名为 env.rb）：

		require 'rubygems'
		require 'sinatra'
		require 'json/pure'

		get '/' do
		  host = ENV['VMC_APP_HOST']
		  port = ENV['VMC_APP_PORT']
		  "<h1>XXXXX Hello from the Cloud! via:#{host}:#{port}</h1>"
		end

		get '/env' do
		  res = "<html><body style=\"margin:0px auto; width:80%; font-family:monospace\">" 
		  res << "<head><title>CloudFoundry Environment</title></head>"
		  res << "<h3>CloudFoundry Environment</h3>"
		  res << "<div><table>"
		  ENV.keys.sort.each do |key|
		    value = begin
		              "<pre>" + JSON.pretty_generate(JSON.parse(ENV[key])) + "</pre>"
		            rescue
		              ENV[key]
		            end
		    res << "<tr><td><strong>#{key}</strong></td><td>#{value}</tr>"
		  end
		  res << "</table></div></body></html>"
		end


3. 创建并推送此测试应用程序的 4 个实例：
		
		vmc push env --instances 4 --mem 64M --url env.vcap.me -n

4. 在浏览器中对此应用程序进行测试：

	[http://env.vcap.me](http://env.vcap.me)

	请注意，每次单击刷新后都将显示不同的端口，这反映了四个不同的活动实例。

5. 通过运行以下命令查看此应用程序的状态：

		vmc apps

	此命令应产生下面的输出：

		+-------------+----+---------+-------------+----------+
		| Application | #  | Health  | URLS        | Services |
		+-------------+----+---------+-------------+----------+
		| env         | 1  | RUNNING | env.vcap.me |          |
		+-------------+----+---------+-------------+----------+

# 多节点部署

本节将提供有关用于安装 VCAP 的_dev_setup_ 脚本的一些背景信息，然后引导您完成一个 4 节点 VCAP 环境的部署过程；该环境包含 2 个 MySQL 节点、1 个 DEA 节点，最后一个节点包含了其余的 VCAP 组件。

## 安装前的准备工作

### 前提条件
1. 请查看 vcap_dev_setup
[自述文件](https://github.com/cloudfoundry/vcap/tree/master/dev_setup#readme)

2. 克隆 VCAP 资源库
    
	$ git clone https://github.com/cloudfoundry/vcap.git

3. 将 dev_setup 目录压缩成 tar 包

        $ cd vcap
        $ tar czvf dev_setup.tar.gz dev_setup

4. 将 dev_setup.tar.gz 文件复制到要
将 VCAP 及其组件安装到的服务器。

5. 在将 dev_setup.tar.gz 文件复制到的服务器中解压缩该文件。

### dev_setup/bin 目录中的脚本

1. _vcap_dev_setup_: 安装 VCAP 及其组件时将调用的主脚本

		用法：./vcap_dev_setup options

		选项：
		  -h           显示此消息
		  -a           对所有问题均回答 yes
		  -p           http 代理，即 -p http://用户名:密码@主机:端口/
		  -c           部署配置
		  -d           cloudfoundry 主目录
		  -D           cloudfoundry 域（默认为：vcap.me）
		  -r           cloud foundry repo
		  -b           cloud foundry repo 分支/标记/SHA


2. _vcap_dev_: 用于启动/停止组件的脚本

		Usage:./vcap_dev [--name deployment_name] [--dir cloudfoundry_home_dir] [start|stop|restart|tail|status]
		    -n, --name deployment_name       部署名称
		    -d, --dir cloud_foundry_home_dir Cloud foundry 主目录

### 部署规范

[vcap_dev/deployments](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments) 目录 
包含部署规范。此目录也有一个 
[README](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments#readme)，请阅读。单节点部署（上文中的说明）采用 [devbox.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/devbox.yml) 部署规范，该规范会将所有组件都安装在本地服务器上。在下一节中，我们将一步步介绍 [multihost_mysql](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments/sample/multihost_mysql) 规范的部署过程。


## 多节点部署逐步演练

我们将一步步介绍在 4 个节点（包含了示例 IP 地址）上部署 VCAP 组件的过程：

  4. **云控制器、路由器、运行状况管理器、服务** - `10.20.143.190`
  1. **DEA** - `10.20.143.187`
  2. **MySQL 节点 0** - `10.20.143.188`
  3. **MySQL 节点 1** - `10.20.143.189`
 
这种部署在 
[deployments/sample/multihost_mysql](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/deployments/sample/multihost_mysql) 中有相关说明 - 请阅读这些部署配置文件。

 
### 1. 将 dev_setup 脚本复制过来并解压缩

如**前提条件**一节中所述，请将_dev_setup.tar.gz_ 复制到各个节点并解压缩它们。

### 2. 安装第一个节点：将_rest.yml_ 安装到 10.20.143.190 上

无需更改用于此节点的部署配置，即
[rest.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/rest.yml)

    
    ---  
    deployment:  
      name: "rest"  
    jobs:  
      install:  
        - nats_server  
        - cloud_controller:  
            builtin_services:  
              - redis  
              - mongodb  
              - mysql  
        - router  
        - health_manager  
        - ccdb  
        - redis:  
            index: "0"  
        - redis_gateway  
        - mysql_gateway  
        - mongodb:  
            index: "0"  
        - mongodb_gateway

使用下面的配置文件选项调用 vcap_dev_setup 脚本：

    
    ~/dev_setup$ bin/vcap_dev_setup -c deployments/sample/multihost_mysql/rest.yml   
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-security Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-updates Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Hit http://theonemirror.eng.vmware.com lucid-security Release   
    Hit http://theonemirror.eng.vmware.com lucid-updates Release   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Get:1 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Hit http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US   
    Get:2 http://apt.opscode.com lucid-0.10 Release [4,477B]   
    Hit http://security.ubuntu.com lucid-security Release.gpg   
    Ign http://apt.opscode.com lucid-0.10/main Packages   
    Ign http://apt.opscode.com lucid-0.10/main Packages   
    Hit http://us.archive.ubuntu.com lucid Release.gpg
    
    .. and more ..


如果此安装过程因出错而停止，请务必查看本文档最后的**已知问题**部分。如果安装成功，那么安装结束时将显示与下面类似的消息。我们暂且_不启动_ 这些
组件，而是接着在其他节点上安装其他组件，
最后再按顺序启动它们。

    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/rest/config  
    Deployment name: rest  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n rest start

### 3. 安装 DEA 节点：将_dea.yml_ 安装到 10.20.143.187 上

用于此节点的部署配置
[dea.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/dea.yml) 需进行一定的修改（请注意修改后的 `nats_server` 主机）：

    ---  
    # Deployment  
    # ----------  
    deployment:  
      name: "dea"
    
    jobs:  
      install:  
        - dea  
      installed:  
        - nats_server:  
          host: "10.20.143.190"  
          port: "4222"  
          user: "nats"  
          password: "nats"

请使用带有 mysql0.yml 部署配置选项的 vcap_dev_setup 脚本进行安装，安装期间会在命令行中传入 dea.yml 
配置：

    
    ~/dev_setup$ bin/vcap_dev_setup -c deployments/sample/multihost_mysql/dea.yml   
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-security Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-updates Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Hit http://theonemirror.eng.vmware.com lucid-security Release   
    Hit http://theonemirror.eng.vmware.com lucid-updates Release   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Get:1 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US 
    Get:2 http://apt.opscode.com lucid-0.10 Release [4,477B]
    Ign http://apt.opscode.com lucid-0.10/main Packages
    Ign http://apt.opscode.com lucid-0.10/main Packages
    Hit http://security.ubuntu.com lucid-security Release.gpg
    Get:3 http://apt.opscode.com lucid-0.10/main Packages [14.6kB]
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/main Translation-en_US
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/restricted Translation-en_US
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/universe Translation-en_US
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/multiverse Translation-en_US
    
    .. and more ..

如果此安装过程因出错而停止，请务必查看本文档最后的**已知问题**部分。安装成功后，您将看到与下面类似的消息。我们暂且
再启动这些组件，现在接着安装 MysQL 节点 0。
    
    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/dea/config  
    Deployment name: dea  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n dea start


### 4. 安装第一个 MySQL 节点：将_mysql0.yml_ 安装到 10.20.143.188 上

用于此节点的部署配置 [mysql0.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/mysql0.yml) 需进行一定的修改（请注意修改后的 `nats_server` 主机）：

    
    ---  
    deployment:  
      name: "mysql0"  
    jobs:  
      install:  
        - mysql:  
            index: "0"  
       installed:  
         - nats_server:  
           host: "10.20.143.190"
           port: "4222"  
           user: "nats"  
           password: "nats"


请使用带有 mysql0.yml 部署配置选项的 vcap_dev_setup 脚本进行安装：

    
    ~/dev_setup$ bin/vcap_dev_setup -c deployments/sample/multihost_mysql/mysql0.yml
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-security Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-updates Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Hit http://theonemirror.eng.vmware.com lucid-security Release   
    Hit http://theonemirror.eng.vmware.com lucid-updates Release   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Get:1 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US   
    Get:2 http://apt.opscode.com lucid-0.10 Release [4,477B]   
    Ign http://apt.opscode.com lucid-0.10/main Packages
    
    .. and more ..

安装结束时，您将看到与下面类似的消息。我们暂且
不启动这些组件，而是接着安装 
MySQL 节点 1。

    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/mysql0/config  
    Deployment name: mysql0  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql0 start


### 5. 安装第二个 MySQL 节点：将_mysql1.yml_ 安装到 10.20.143.189 上

用于此节点的部署配置 [mysql1.yml](https://github.com/cloudfoundry/vcap/blob/master/dev_setup/deployments/sample/multihost_mysql/mysql1.yml) 需进行一定的修改（请注意修改后的 `nats_server` 主机）：

    
    ---  
    deployment:  
      name: "mysql1"  
    jobs:  
      install:  
        - mysql:  
          index: "1"  
      installed:  
        - nats_server:  
          host: "10.20.143.190"  
          port: "4222"  
          user: "nats"  
          password: "nats"

请使用带有 mysql0.yml 部署配置选项的 vcap_dev_setup 脚本进行
安装：

    ~/dev_setup$ bin/vcap_dev_setup -c deployments/sample/multihost_mysql/mysql1.yml
    Checking web connectivity. 
    chef-solo is required, should I install it? [Y/n]  
    [sudo] password for cfsupp:
    
    deb http://apt.opscode.com/ lucid-0.10 main  
    OK  
    Hit http://theonemirror.eng.vmware.com lucid Release.gpg  
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-security Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-security/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid-updates Release.gpg   
    Ign http://theonemirror.eng.vmware.com/ubuntu/ lucid-updates/main Translation-en_US  
    Hit http://theonemirror.eng.vmware.com lucid Release   
    Hit http://theonemirror.eng.vmware.com lucid-security Release   
    Hit http://theonemirror.eng.vmware.com lucid-updates Release   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Hit http://theonemirror.eng.vmware.com lucid-security/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Get:1 http://apt.opscode.com lucid-0.10 Release.gpg [198B]   
    Hit http://theonemirror.eng.vmware.com lucid-updates/main Packages   
    Ign http://apt.opscode.com/ lucid-0.10/main Translation-en_US   
    Get:2 http://apt.opscode.com lucid-0.10 Release [4,477B]   
    Ign http://apt.opscode.com lucid-0.10/main Packages   
    Get:3 http://security.ubuntu.com lucid-security Release.gpg [198B]  
    Hit http://us.archive.ubuntu.com lucid Release.gpg   
    Ign http://apt.opscode.com lucid-0.10/main Packages   
    Get:4 http://apt.opscode.com lucid-0.10/main Packages [14.6kB]   
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/main Translation-en_US  
    Ign http://us.archive.ubuntu.com/ubuntu/ lucid/main Translation-en_US   
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/restricted Translation-en_US   
    Ign http://us.archive.ubuntu.com/ubuntu/ lucid/restricted Translation-en_US  
    Ign http://us.archive.ubuntu.com/ubuntu/ lucid/universe Translation-en_US  
    Ign http://security.ubuntu.com/ubuntu/ lucid-security/universe Translation-en_US
    
    .. and more ..

安装结束时，您将看到与下面类似的消息。

    
    ---------------  
    Deployment info  
    ---------------  
    Status: successful  
    Config files: /home/cfsupp/cloudfoundry/.deployments/mysql1/config  
    Deployment name: mysql1  
    Command to run cloudfoundry: /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql1 start


### 5. 启动所有组件

1. 启动所有安装在_**rest**_ 部署
节点 (`10.20.143.190`) 上的组件

    
    	$ ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n rest start 
    	Setting up cloud controller environment  
    	Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/rest/config  
    	Executing /home/cfsupp/cloudfoundry/.deployments/rest/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start health_manager mongodb_gateway router redis_gateway mongodb_backup redis_node mongodb_node mysql_gateway redis_backup cloud_controller -c /home/cfsupp/cloudfoundry/.deployments/rest/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    	health_manager : RUNNING  
    	mongodb_gateway : RUNNING  
    	router : RUNNING  
    	redis_gateway : RUNNING  
    	redis_node : RUNNING  
    	mongodb_node : RUNNING  
    	mysql_gateway : RUNNING  
    	cloud_controller : RUNNING

2. 启动安装在 **_dea_** 部署节点 (`10.20.143.187`) 上的组件

    	$ ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n dea start  
    	Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/dea/config  
    	Executing /home/cfsupp/cloudfoundry/.deployments/dea/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start dea -c /home/cfsupp/cloudfoundry/.deployments/dea/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    	dea : RUNNING

3. 启动安装在 **_mysql0_** 部署节点 (`10.20.143.188`) 上的组件

    
    	$ ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql0 start 
    	Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/mysql0/config  
    	Executing /home/cfsupp/cloudfoundry/.deployments/mysql0/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start mysql_backup mysql_node -c /home/cfsupp/cloudfoundry/.deployments/mysql0/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    	mysql_node : RUNNING

4. 启动安装在 **_mysql1_** 部署节点 (`10.20.143.189`) 上的组件

    
    	$ ~/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql1 start**  
   	 	Using cloudfoundry config from /home/cfsupp/cloudfoundry/.deployments/mysql1/config  
    	Executing /home/cfsupp/cloudfoundry/.deployments/mysql1/deploy/rubies/ruby-1.9.2-p180/bin/ruby /home/cfsupp/cloudfoundry/vcap/dev_setup/bin/vcap start mysql_backup mysql_node -c /home/cfsupp/cloudfoundry/.deployments/mysql1/config -v /home/cfsupp/cloudfoundry/vcap/bin  
    	mysql_node : RUNNING

## 多节点安装验证

cloud_controller 组件在 `api.vcap.me` 端点上侦听命令，该端点绑定到 `127.0.0.1`。请在当前运行 cloud_controller 的节点（位于 `10.20.143.190` 的 **rest** 节点）上运行 vcap 命令行客户端 `vmc`。

    
    $ vmc target
    
    [http://api.vcap.me]
    
    $ vmc info
    
    VMware's Cloud Application Platform  
    For support visit http://support.cloudfoundry.com
    
    Target: http://api.vcap.me (v0.999)  
    Client: v0.3.12
    
    $ vmc register
    Email: user@vmware.com  
    Password: *******  
    Verify Password: *******  
    Creating New User: OK  
    Successfully logged into [http://api.vcap.me]
    
    $ vmc info
    
    VMware's Cloud Application Platform  
    For support visit http://support.cloudfoundry.com
    
    Target: http://api.vcap.me (v0.999)  
    Client: v0.3.12
    
    User: user@vmware.com  
    Usage: Memory (0B of 2.0G total)  
     Services (0 of 16 total)  
     Apps (0 of 20 total)
    
    $ vmc services
    
    ============== System Services ==============
    
    +---------+---------+-------------------------------+  
    | Service | Version | Description                   |  
    +---------+---------+-------------------------------+  
    | mongodb | 1.8 | MongoDB NoSQL store               |  
    | mysql   | 5.1 | MySQL database service            |  
    | redis   | 2.2 | Redis key-value store service     |  
    +---------+---------+-------------------------------+
    
    =========== Provisioned Services ============
    
      
    $ vmc frameworks
    
    +-----------+  
    | Name      |  
    +-----------+  
    | sinatra   |  
    | spring    |  
    | node      |  
    | grails    |  
    | lift      |  
    | rails3    |  
    | otp_rebar |  
    +-----------+

我们将推送一个 Sinatra 示例应用程序，该应用程序会输出 Cloud Foundry 中的应用程序可用的 
环境变量。请将以下内容粘贴到一个
名为 env.rb 的文件

	require 'rubygems'
	require 'sinatra'
	require 'json/pure'

	get '/' do
	  host = ENV['VMC_APP_HOST']
	  port = ENV['VMC_APP_PORT']
	  "<h1>XXXXX Hello from the Cloud! via:#{host}:#{port}</h1>"
	end

	get '/env' do
	  res = "<html><body style=\"margin:0px auto; width:80%; font-family:monospace\">" 
	  res << "<head><title>CloudFoundry Environment</title></head>"
	  res << "<h3>CloudFoundry Environment</h3>"
	  res << "<div><table>"
	  ENV.keys.sort.each do |key|
	    value = begin
	              "<pre>" + JSON.pretty_generate(JSON.parse(ENV[key])) + "</pre>"
	            rescue
	              ENV[key]
	            end
	    res << "<tr><td><strong>#{key}</strong></td><td>#{value}</tr>"
	  end
	  res << "</table></div></body></html>"
	end
	
然后，将此应用程序推送到您的 VCAP 实例：
    
    $ vmc push env -n  
    Creating Application: OK  
    Uploading Application:  
     Checking for available resources: OK  
     Packing application: OK  
     Uploading (1K): OK   
    Push Status: OK  
    Staging Application: OK   
    Starting Application: OK
    
    $ curl -I env.vcap.me 
    HTTP/1.1 200 OK   
    Server: nginx/0.7.65  
    Date: Wed, 07 Sep 2011 23:39:09 GMT  
    Content-Type: text/html;charset=utf-8  
    Connection: keep-alive  
    Keep-Alive: timeout=20  
    Vary: Accept-Encoding  
    Content-Length: 4239

我们将创建一项 mysql 服务并将这项服务绑定到此应用程序

    
    $ vmc create-service mysql mysql-env env  
    Creating Service: OK  
    Binding Service: OK  
    Stopping Application: OK  
    Staging Application: OK   
    Starting Application: OK
    
    $ vmc apps
    
    +-------------+----+---------+----------------+--------------+  
    | Application | #  | Health  | URLS           | Services     |  
    +-------------+----+---------+----------------+--------------+  
    | sv-env      | 1  | RUNNING | env.vcap.me    | mysql-env    |  
    +-------------+----+---------+----------------+--------------+
       

# 已知问题

## 在 HTTP 代理后进行的安装失败

如果您处于 HTTP 代理后，请确保先将 Ubuntu 虚拟机配置为使用此代理，再进行安装。

1. 设置环境变量 `http_proxy, https_proxy, no_proxy`：

		$ http_proxy="http://<代理主机>:<代理端口>"
		$ https_proxy=$http_proxy
		$ no_proxy="localhost,vcap.me"
		$ export http_proxy https_proxy no_proxy
	
	有时（并非经常性的情况），您可能需要指定用户 ID 和密码，这取决于环境。请咨询系统管理员或问讯台。

		http_proxy=http://<用户名>:<密码>@<代理主机>:<代理端口>
	
	为确保当命令以 `root` 用户身份运行（在_dev_setup_ 要求提供 `sudo` 密码时会出现这种情况）使用此代理，请编辑 `/etc/sudoers`，在其中添加下面的配置：

		Defaults env_keep = "http_proxy https_proxy no_proxy"

2. VCAP 安装过程中使用 maven 供某些组件下载外部依赖项。您需要将您的代理信息添加到 maven 设置文件：
		
		$ mkdir ~/.m2
		$ vi ~/.m2/settings.xml

		<settings>
		  <proxies>
		    <proxy>
		      <active>true</active>
		      <protocol>http</protocol>
		      <host>proxy-host.yourcompany.com</host>
		      <port>3128</port>
		      <username>proxy-user</username>
		      <password>proxy-password</password>
		      <nonProxyHosts>localhost|*.vcap.me</nonProxyHosts>
		    </proxy>
		  </proxies>
		</settings>
		
	您可能还需要在 `~/cloudfoundry/.deployments/<deployment_name>/deploy/maven/apache-maven-3.0.4/bin/m2.conf` 中指定 HTTPS 代理：
	
		set https.proxyHost default proxy-host.yourcompany.com
		set https.proxyPort default 3128
		
## 安装_rack_ 时失败并出现_ArgumentError_
显示的错误可能类似于：
   
    	[Wed, 31 Aug 2011 14:36:56 -0700] WARN: failed to find gem rack (>= 0, runtime) from [http://gems.rubyforge.org/]  
    	[Wed, 31 Aug 2011 14:36:56 -0700] DEBUG: sh(/home/cfsupp/cloudfoundry/.deployments/devbox/deploy/rubies/ruby-1.8.7-p334/bin/gem install rack -q --no-rdoc --no-ri -v "")  
    	[Wed, 31 Aug 2011 14:36:56 -0700] ERROR: gem_package[rack] (ruby::default line 75) has had an error  
    	[Wed, 31 Aug 2011 14:36:56 -0700] ERROR: gem_package[rack] (/home/cfsupp/cloudfoundry/vcap/dev_setup/cookbooks/ruby/recipes/default.rb:75:in `from_file') had an error:  
    	gem_package[rack] (ruby::default line 75) had an error: Expected process to exit with [0], but received '1'
    	[Tue, 06 Sep 2011 15:16:44 -0700] FATAL: Chef::Exceptions::ShellCommandFailed: gem_package[rack] (ruby::default line 75) had an error: Expected process to exit with [0], but received '1'  
    	---- Begin output of /home/cfsupp/cloudfoundry/.deployments/rest/deploy/rubies/ruby-1.8.7-p334/bin/gem install rack -q --no-rdoc --no-ri -v "" ----  
    	STDOUT:   
    	STDERR: ERROR: While executing gem ... (ArgumentError)
    	Illformed requirement [""] 
    	---- End output of /home/cfsupp/cloudfoundry/.deployments/rest/deploy/rubies/ruby-1.8.7-p334/bin/gem install rack -q --no-rdoc --no-ri -v "" ----  
    	Ran /home/cfsupp/cloudfoundry/.deployments/rest/deploy/rubies/ruby-1.8.7-p334/bin/gem install rack -q --no-rdoc --no-ri -v "" returned 1

如果您重新运行 vcap_dev_setup 脚本，该脚本将从它停止的地方接着运行，并且这次应该会成功 
安装 rack。您可能会多次遇到类似的错误；如果是这样，请再次尝试重新运行 vcap_dev_setup，直到它完成为止。
