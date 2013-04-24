---
title: Grails
description: 使用 Cloud Foundry 开发 Grails 应用程序
tags:
    - grails
    - groovy
    - mongodb
    - redis
    - 附代码
---

[Grails](http://grails.org) 是一款可用于快速开发 Web 应用程序的框架，使用 Grails 开发的 Web 应用程序可部署到 Tomcat 之类的所有 Java servlet 容器中。它基于 [Groovy](http://groovy.codehaus.org/) 动态编程语言和 [Spring](http://www.springframework.org/) 框架，使用表达丰富的类似 Java 的动态编程语言为 Java 平台带来了“约定优于配置”的典型范例。

本指南假设您已经[安装了 Grails](http://grails.org/Installation) 和 Java，并了解如何构建一个简单的 Grails 应用程序。这就是您在开始使用 Cloud Foundry 之前所需要具备的一切。

（如果您使用 Spring、Roo 或 Grails，且希望阅读一些代码示例，请点击下面的有用链接：[https://github.com/SpringSource/cloudfoundry-samples/wiki](https://github.com/SpringSource/cloudfoundry-samples/wiki)）

## Grails Cloud Foundry 插件

让我们假设，您的标准 Grails 应用程序仅使用 MySQL 数据库，且您希望将此应用程序部署到 Cloud Foundry。第一步是安装 [Cloud Foundry 插件](http://grails.org/plugin/cloud-foundry)。此插件会为 Grails 增加一些命令，使它能够方便地部署并管理您的应用程序。

在您的 Grails 项目中，执行以下命令：

``` bash
$ grails install-plugin cloud-foundry
```

安装完插件后，您可以使用以下命令查看可以使用哪些 Cloud Foundry 命令：

``` bash
$ grails cf-help
```

其中大多数命令都与 [vmc tool](/tools/vmc/vmc-quick-ref.html) 命令等效。

接下来，您需要指定您的用户名和密码。放置这些数据的最佳位置为 ~/.grails/settings.groovy 文件：

``` groovy
    grails.plugin.cloudfoundry.username = "yourusername"
    grails.plugin.cloudfoundry.password = "yourpassword"
```

请切记，将此文件设置为只有您能够读写！现在，您就可以部署您的应用程序了：

```bash
$ grails prod cf-push
```

此命令将首先询问您要使用什么 URL。只要应用程序的名称在 cloudfoundry.com 上是唯一的，就可以根据应用程序的名称，使用默认 URL。如果应用程序的名称在 cloudfoundry.com 上不是唯一的，那么请输入一个唯一的名称，而不要接受默认 URL。

接下来，系统会询问您是否希望创建并绑定 MySQL 服务（如果愿意，则请回复“Y”），以及您是否希望创建并绑定 PostgreSQL 数据库（请回复“N”，因为此应用程序是为 MySQL 配置的）。之后，您将会看到您的应用程序已经完成部署并在 cloudfoundry.com 上启动。

有关使用 Cloud Foundry 插件的详细信息，请参见其[用户指南](http://grails-plugins.github.com/grails-cloud-foundry/)。

## 服务

Cloud Foundry 可提供丰富的服务，所有服务都可用于 Grails 应用程序：MySQL、PostgreSQL、MongoDB、Redis 和 RabbitMQ。每个服务都有对应的 Grails 插件。安装这些插件后，您无需为相关的 Cloud Foundry 服务配置任何连接设置，因为在您部署应用程序的时候，将自动完成所有设置。如果您是第一次使用 `cf-push` 部署应用程序，Grails 将询问您是否希望根据安装的插件来创建并绑定相关服务。

### SQL 服务

目前，如果您想要您的应用程序使用一个关系数据库，您可以在 Cloud Foundry 上使用 MySQL 或 PostgreSQL。要访问这些数据库，您所需要的就是 [Hibernate 插件](http://grails.org/plugin/hibernate)，这个插件默认安装在所有新的 Grails 应用程序中。另外，您还需要确保您的应用程序具有可用的相关驱动程序，例如，在 `BuildConfig.groovy` 中声明某个驱动程序：

```groovy
  grails.project.dependency.resolution = {
      ...
      dependencies {
          runtime "mysql:mysql-connector-java:5.1.18"
          ...
      }
  }

```

并确认在 `DataSource.groovy` 中已设置 JDBC 驱动程序类：

```groovy
  environments {
      production {
          dataSource {
              driverClassName = "com.mysql.jdbc.Driver"
              ...
          }
      }
  }
```

这样，我们就可以为标准生产环境部署应用程序，您也可以轻松设置一个“云”或类似环境。
另外，您还可以轻松为生产环境配置 JDBC URL、用户名和密码，使其指向本地 MySQL 数据库，因为在向 Cloud Foundry 部署应用程序时，这些设置将被覆盖。

### Redis

要使用键-值存储 [Redis](http://redis.io)，您需要安装 [Redis 插件](http://grails.org/plugin/redis)或 [Redis for GORM](http://grails.org/plugin/redis-gorm)。与使用 SQL 存储一样，当您在 Cloud Foundry 中部署应用程序时，它将自动使用绑定到其上的任何 Redis 服务。

前一个插件可通过 `redis` Bean 提供对 Redis 的低级访问，而后一个插件则允许您将 GORM 域类映射到 Redis。有关详细信息，请参见[插件文档](http://grails.github.com/inconsequential/redis/manual/index.html)。

### MongoDB

要使用文档存储 [MongoDB](http://www.mongodb.org/)，只需安装 [MongoDB 插件](http://grails.org/plugin/mongodb)。

适用于 Grails 的 MongoDB 插件允许您将 GORM 实体映射到 MongoDB 集合。它也可以提供低级 API，以直接访问 Java 的 MongoDB 驱动程序。有关详细信息，请参见[插件文档](http://grails.github.com/inconsequential/mongo/manual/index.html)。

## 使用指南

可在博客帖子[“使用 Grails 和 Cloud Foundry 的一站式部署”](http://blog.springsource.com/2011/04/12/one-step-deployment-with-grails-and-cloud-foundry/)中找到常见教程。

实际上，若要迅速开始进行部署，您可以尝试使用下面任一示例应用程序：

* [Pet Clinic](https://github.com/SpringSource/cloudfoundry-samples/tree/master/petclinic-grails) - 展示如何使用 SQL 服务
* [Grails Twitter](https://github.com/SpringSource/cloudfoundry-samples/tree/master/grailstwitter) - [在此运行](http://grailstwitter.cloudfoundry.com/) - 展示如何使用 MongoDB 和 Redis 服务

*警告* 如果您自行部署任意应用程序，请务必使用另一个应用程序名称来部署这些应用程序。

## 常见问题解答

有关常见问题，请参见 [Cloud Foundry 常见问题解答](http://www.cloudfoundry.com/faq)。

### 我能通过 Grails 使用 Spring 云命名空间吗？

是的，可以！请参见有关 [Spring](http://www.springsource.org/documentation) 的文档，获取有关如何通过云命名空间配置附加 MySQL、Mongo 或 Redis 实例的示例。此配置可以使用 BeanBuilder DSL 进入 `grails-app/conf/spring/resources.xml` 或 `grails-app/conf/spring/resources.groovy`。

### 我如何获取云环境变量的访问权？

此机制与 Spring 和 Grails 相同。有关详细信息，请参见 [Cloud Foundry 环境变量](https://github.com/SpringSource/cloudfoundry-samples/wiki/Cloud-foundry-environment-variables)。

### 我能否通过我的应用程序发送电子邮件？

可以，但不能通过 SMTP 发送电子邮件，您只能收发 HTTP 或 HTTPS 请求。但是，您可以使用基于 HTTP 的服务，如 [SendGrid](http://sendgrid.com/)、[Amazon SES](http://aws.amazon.com/ses/) 或 [Mailgun](http://mailgun.net/)。有关详细信息，请参见[支持论坛](http://support.cloudfoundry.com/entries/20023841)。


