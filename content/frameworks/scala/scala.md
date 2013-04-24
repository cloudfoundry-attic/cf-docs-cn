---
title: Scala
description: 利用 Cloud Foundry 开发 Scala 应用程序
tags:
    - scala
    - 附代码
---

[Scala](http://www.scala-lang.org/) 是一种静态类型的、基于 JVM 的语言，以一种一致的方式将面向对象的编程和函数式编程结合在一起。使用它，可以编写精简但功能强大的程序，而且更加注重核心业务逻辑。作为一种基于 JVM 的语言，它借助 Java 生态系统和 Java 库（如 Spring）提供方便的互操作性。另外，Scala 融入了许多创新，如并行编程和基于执行者的并发编程 (concurrent programming) 模型，使开发人员能够开发现代应用程序并轻松利用多核硬件。

基于 [Lift](http://liftweb.net/) 和 [Spring](http://springframework.org/) 的大部分 Scala 应用程序无需修改，在 Cloud Foundry 上即可进行无缝部署。其他 Scala 应用程序可能需要稍微修改一下，以和云中的应用程序服务绑定在一起。

## 我可以在 Cloud Foundry 上使用 Lift 吗？

[可以。](/frameworks/scala/lift.html)

## 现实中的 Scala 支持

Cloud Foundry 能简化应用程序部署，使您能集中精力进行应用程序开发。您可以使用 Spring 工具套件 (STS) 或 vmc 命令行工具来部署 Scala 应用程序。

下面是用 vmc 在 Cloud Foundry 中部署 [PocketChange](https://github.com/cloudfoundry-samples/pocketchangeapp-cf-runtime) 应用程序的示例。对于绝大多数提示符，您只需按 Enter 接受默认设置即可。

### 构建应用程序并将其上传到 Cloud Foundry

请注意，在下面步骤中，如果应用程序使用关系数据库服务的话，我们还可以绑定关系数据库服务。

```bash

$ mvn package
...

$ vmc push pocketchange --path target

    Application Deployed URL: 'pocketchange.cloudfoundry.com'?
    Detected a Scala Lift Application, is this correct? [Yn]:
    Memory Reservation [Default:512M] (64M, 128M, 256M, 512M, 1G or 2G)
    Creating Application: OK

    Would you like to bind any services to 'pocketchange'? [yN]: y
    The following system services are available:
    1. mongodb
    2. mysql
    3. redis
    Please select one you wish to provision: 2
    Specify the name of the service [mysql-744ef]: pocketchange-db
    Creating Service: OK
    Binding Service: OK

    Uploading Application:
      Checking for available resources: OK
      Processing resources: OK
      Packing application: OK
      Uploading (4K): OK
    Push Status: OK
    Staging Application: OK
    Starting Application: OK

```

在这个部署过程中，应用程序位将传输到云。（注意到上传数据比较小了吗？这要归功于 Cloud Foundry 的增量更新功能）。传输完成后，应用程序位将被打包在一个 Tomcat 容器中，绑定您配置的服务（在这里是 pocketchange-db），并使用连接数据库所需的信息创建属性文件。

### 完成
现在可以在 [http://pocketchange.cloudfoundry.com](http://pocketchange.cloudfoundry.com) 查看数据程序了。

## 它是如何工作的？

由于 Scala 是一种基于 JVM 的语言，因此您可以使用任何 Java Web 框架或使用专为 Scala 设计的框架（如 Lift）来编写应用程序。Cloud Foundry 目前可以部署此类应用程序。这种支持是多方面的。

如果 Scala Web 应用程序不使用应用程序服务，如数据库，您可以不修改直接对其进行部署。无论使用何种框架都是如此，甚至不使用框架也如此。这里有一个基本的 Lift 应用程序供您参考 [http://hello-lift.cloudfoundry.com](http://hello-lift.cloudfoundry.com)。

大多数应用程序都会使用服务，在这种情况下，您需要进行一些更改。

使用 Lift 框架和 Lift 原则使服务外部化的 Scala 应用程序无需修改就可以部署([有关示例，请参考修改后的 PocketChange 应用程序。](https://github.com/cloudfoundry-samples/pocketchangeapp-prop)）您只需要创建一个 WAR 文件并部署它。

对于不对服务进行外部化的 Lift 应用程序，可以通过代码直接访问这些应用程序。[请参见对 PocketChange 应用程序进行的其他修改：](https://github.com/cloudfoundry-samples/pocketchangeapp-cf-runtime)

```scala

import org.cloudfoundry.runtime.env._
import org.cloudfoundry.runtime.service.relational._
  Full(new MysqlServiceCreator(
    new CloudEnvironment()).createSingletonService().service.getConnection())

```

在 [http://tpuf.cloudfoundry.com](http://tpuf.cloudfoundry.com) 中部署的应用程序是一个 Lift 应用程序，它显式声明使用了 Redis 服务。有关详细信息，请参见它的 [github 资源库](https://github.com/dcbriccetti/talking-puffin/)。

如果 Scala 应用程序使用 Spring 框架，它可以利用自动重新配置支持，不需要对应用程序本身进行任何更改。在 [http://hello-spring-scala.cloudfoundry.com](http://hello-spring-scala.cloudfoundry.com/) 中部署的应用程序是一个以 Spring 作为框架用 Scala 编写的基本 Spring 应用程序。


