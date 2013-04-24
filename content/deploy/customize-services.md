---
title: 分步指南：向开源软件 Cloud Foundry 添加系统服务
description: 分步指南：向开源软件 Cloud Foundry 添加系统服务
tags:
    - services
---

_作者：**Georgi Sabev**_

## 概述

本指南将一步步为您介绍向 Cloud Foundry 环境中
添加新服务的过程，并向您说明如何从 Web 应用程序中使用此服务。
本教程适用于使用 [dev_setup 安装](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/single_and_multi_node_deployments_with_dev_setup)的 CloudFoundry。
出于本指南的需要，我们提供了一项示例回显服务，
以及一个发送待回显消息的示例使用者 Web 应用程序。
这两者都是使用 java 编写的，不过，您可以用您想用的任何语言编写您自己的服务，
并可以用 Cloud Foundry 支持的任何语言来编写作为使用方的应用程序。
每项服务都有一个服务节点、一个置备器和一个服务网关。服务节点是 Cloud Foundry 服务的实现。
置备器是在置备或取消置备该服务时执行特定于域的操作的代理。
例如，在置备标准的 MySQL 服务时，
该服务会创建一个新用户和架构。
服务网关是用来与服务置备器
进行交互的 REST 接口。
下面是一张显示了这些基本组件的小图片：

![service_provisioning.png](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/images/service_provisioning.png)

## Cloud Foundry 中的服务

在 Cloud Foundry 中，有两种基本的服务状态，即系统服务和置备的服务。
系统服务是可供系统使用的所有类型的服务。
可以置备这些类型的服务并将它们绑定到应用程序。
置备一项服务时，需为其指定一个名称。
应用程序以后将使用此名称来查找有关所置备服务的元数据。
您可以通过登录到 vmc 
并键入`vmc services` 来将系统服务和置备的服务都列出来：

![services.png](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/images/services.png)

## 我们引入了一个“回显”样板示例服务，您可以将它复制过来并根据自己的使用情况对它进行更新。

完成 dev_setup 后，服务目录 (vcap-services repo) 将被放置在 `.../cloudfoundry/vcap/`
，此时您可以在 `...cloudfoundry/vcap/services/echo` 处找到此回显服务的实现。

用“排除的组件”构建此回显服务（请参见 `https://github.com/cloudfoundry/vcap/blob/master/dev_setup/README`）后，请重新运行 `.../cloudfoundry/vcap/dev_setup/bin/vcap_dev start`，
我们的回显服务将作为一项系统服务显示在
`vmc services` 输出的表中。
本指南既可用于单机 Cloud Foundry 环境，又可用于分布式 Cloud Foundry 环境。
**请注意，我们所用的省略号 (...) 表示 Cloud Foundry 的安装目录。**
如果您要构建自己的服务，您需要注意以下方面：

1. 在
	`.../cloudfoundry/.deployments/devbox/config/vcap_components.json` 文件中，echo_node 和 echo_gateway 已放入下面的列表中：

        {"components":["router","cloud_controller","health_manager","dea","uaa",
         "vcap_redis","serialization_data_server","redis_node","mysql_node",
         "mongodb_node","neo4j_node","rabbitmq_node","postgresql_node",
         "vblob_node","memcached_node","elasticsearch_node","couchdb_node",
         "redis_gateway","mysql_gateway","mongodb_gateway","neo4j_gateway",
         "rabbitmq_gateway","postgresql_gateway","vblob_gateway","memcached_gateway",
         "elasticsearch_gateway","couchdb_gateway","filesystem_gateway",
         "service_broker","backup_manager","snapshot_manager","redis_worker",
         "mysql_worker","mongodb_worker","postgresql_worker",
         "echo_node","echo_gateway"]}

2. 服务令牌配置位于 `.../cloudfoundry/.deployments/devbox/config/cloud_controller.yml`

    云控制器和服务网关均持有服务令牌，
    二者所持的令牌应完全匹配，它们才能正确地相互通信。

        # Services we provide, and their tokens. Avoids bootstrapping DB.
         builtin_services:
           redis:
             token: changeredistoken
           mongodb:
             token: changemongodbtoken
           mysql:
             token: changemysqltoken
           neo4j:
             token: changeneo4jtoken
           rabbitmq:
             token: changerabbitmqtoken
           postgresql:
             token: changepostgresqltoken
           vblob:
             token: changevblobtoken
           memcached:
             token: changememcachedtoken
           filesystem:
             token: changefilesystemtoken
           elasticsearch:
             token: changeelasticsearchtoken
           couchdb:
             token: changecouchdbtoken
           echo:
             token: changeechotoken

3. 在服务主机上，转到
`.../cloudfoundry/vcap/services/tools/misc/bin/nuke_service.rb` 
然后您便可以看到其中显示了回显服务配置的路径。

    此工具用于在您需要停止提供服务时从云中删除服务产品。

        default_configs = {
          :mongodb => File.expand_path("../../mongodb/config/mongodb_gateway.yml", __FILE__),
          :redis => File.expand_path("../../redis/config/redis_gateway.yml", __FILE__),
          :mysql => File.expand_path("../../mysql/config/mysql_gateway.yml", __FILE__),
          :neo4j => File.expand_path("../../neo4j/config/neo4j_gateway.yml", __FILE__),
          :vblob => File.expand_path("../../vblob/config/vblob_gateway.yml", __FILE__),
          :echo => File.expand_path("../../echo/config/echo_gateway.yml", __FILE__),
        }

4. 在服务主机上，转到
`.../cloudfoundry/vcap/services/echo` 
然后您便可以看到此服务的实现，包括代码和配置文件

    请确保 echo_gateway 和 echo_node 配置文件与下面的内容（需进行相应的 IP 地址和端口替换）类似：

    `.../cloudfoundry/.deployments/devbox/config/echo_gateway.yml`

        ---  
         cloud_controller_uri: api.vcap.me  
         service:  
           name: echo  
           version: "1.0"  
           description: 'Echo key-value store service'  
           plans: ['free']  
           tags: ['echo', 'echo-1.0', 'echobased', 'demo']
         index: 0  
         token: changeechotoken
         logging:  
           level: debug
         mbus: nats://nats:nats@<nats_host>:<nats_port>/
         pid: /var/vcap/sys/run/echo_service.pid   
         node_timeout: 2


    `.../cloudfoundry/.deployments/devbox/config/echo_node.yml`

        ---  
        capacity: 100
        plan: free
        local_db: sqlite3:/var/vcap/services/echo/echo_node.db  
        mbus: nats://nats:nats@<nats_host>:<nats_port>/
        index: 0
        base_dir: /var/vcap/services/echo/  
        ip_route: <services_host_ip>  
        logging:  
          level: debug  
        pid: /var/vcap/sys/run/echo_node.pid  
        node_id: echo_node_0
        port:<echo_service_port> # 回显服务在进行侦听时使用的端口
        host:<echo_service_host> # 回显服务所在的主机。可能不同于服务主机

    **相对于 localhost，优先使用实际 IP 地址，因为这些变量中的某些变量可能会成为其他主机上的环境的一部分！**

5. 在服务主机上，转到
`.../cloudfoundry/vcap/dev_setup/lib/vcap_components.rb`
然后您便可以看到回显已注册为有效组件

    https://github.com/cloudfoundry/vcap/blob/master/dev_setup/lib/vcap_components.rb#L399-L406

        ## services: gateways & nodes
        %w(redis mysql mongodb rabbitmq postgresql vblob neo4j memcached couchdb elasticsearch filesystem echo).each do |service|
          ServiceComponent.register("#{service}_gateway")
        end

        %w(redis mysql mongodb rabbitmq postgresql vblob neo4j memcached couchdb elasticsearch echo).each do |service|
          ServiceComponent.register("#{service}_node")
        end

6. 为新服务的节点和网关捆绑必需的依赖项：

    以回显服务为例：

        $ cd .../cloudfoundry/vcap/services/echo
        $ source $HOME/.cloudfoundry_deployment_profile && bundle package

7. 要修改默认的排除组件列表，请在 `.../cloudfoundry/vcap/dev_setup/lib/vcap_components.rb` 中更新组件名称，这样您便无需使用环境变量了

        DEFAULT_CLOUD_FOUNDRY_EXCLUDED_COMPONENT = 'neo4j|memcached|couchdb|service_broker|elasticsearch|backup_manager|vcap_redis|worker|snapshot_manager|serialization_data_server|echo'

8. 重新启动云控制器、服务网关和节点：

        $ .../cloudfoundry/vcap/dev_setup/bin/vcap_dev restart

    这应该会显示_echo_node_ 和_echo_gateway_ 正在运行。要查看它们的日志，请运行：

        $ cd .../cloudfoundry/.deployments/devbox/log && tail -f *.log

    现在，请执行 `vmc services` 命令。在上部的表中应该会提供我们的
新回显服务。恭喜！您刚刚已经提供了您的
第一个 Cloud Foundry 服务！现在，我们来对这项服务进行一些处理！

## 使用回显服务

1. 通过运行 `vmc create-service echo myecho` 置备一项回显服务。

    这将置备一个名为“myecho”的回显服务。测试应用程序以后将使用此名称来查找我们为
此回显服务配置的主机和端口。
置备 myecho 后，请执行 `vmc
services`。这将输出与下面类似的内容：

    ![echo_service.png](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/images/echo_service.png)

    现在我们的服务就置备好了！

  
2. 推送一个测试应用程序并绑定所置备的回显服务。

    下载该测试应用程序的 [.war 文件](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/support/testapp.war)，或者用[源代码](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/support/testapp_src.zip)进行编译。将该文件放入一个空文件夹中，然后使用 `vmc push` 进行部署：

        Would you like to deploy from the current directory? [Yn]:  
         Application Name: echotest  
         Application Deployed URL: 'echotest.vcap.me'?  
         Detected a Java Web Application, is this correct? [Yn]:  
         Memory Reservation [Default:512M] (64M, 128M, 256M, 512M or 1G) 64M  
         Creating Application: OK  
         Would you like to bind any services to 'echotest'? [yN]: y  
         Would you like to use an existing provisioned service [yN]? y  
         The following provisioned services are available:  
         1. db 2. myecho  
         Please select one you wish to provision: 2  
         Binding Service: OK  
         Uploading Application:  
           Checking for available resources: OK  
           Processing resources: OK  
           Packing application: OK  
           Uploading (1K): OK  
         Push Status: OK  
         Staging Application: OK  
         Starting Application: OK

    **注意：**如果在同一目录下还有其他应用程序，vmc 将按词典编纂顺序对它们进行排序，然后将选择排在第一位的应用程序。您可以改用 `vmc push <app_name> --path <path_to_app>`。


3. 启动此回显服务并访问该应用程序。

    到目前为止，我们已经向 Cloud Foundry 中的用户和应用程序提供了回显服务元数据，但我们尚未启动提供回显服务本身的功能的程序。该测试应用程序从 `VCAP_SERVICES` 环境变量获取服务 IP 和端口，但我们需负责确保确有侦听服务。
不然的话，该应用程序在尝试访问回显服务时会返回一个错误。那我们就来启动此服务：将[回显服务的 jar 文件](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/support/echo_service.jar)下载到 `echo_node.yml` 中列出的 `host`，或者用[源代码](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/support/echo_service_src.zip)编译出该文件。然后，执行下面的命令：

        $ java -jar echo_service.jar -port <echo_service_port>

    您以参数形式传递的端口应与您在 `echo_node.yml` 中配置的端口相同（除非修改了此参数，否则为端口 5002）。

    启动此服务后，请打开您喜欢的 Web 浏览器，然后转到
http://echotest.vcap.me 或您在推送时选用的 URI。
在文本区域输入一些消息，然后单击_Echo message_ 按钮。
此回显服务将会回显您的消息：

    ![helloworld.png](https://github.com/cloudfoundry/oss-docs/raw/master/vcap/adding_a_system_service/images/helloworld.png)
