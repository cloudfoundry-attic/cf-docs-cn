---
title: 概述
description: Cloud Foundry 提供的应用服务
tags:
    - 环境
    - 服务
    - mysql
    - redis
---

Cloud Foundry 支持以下服务：

+ [MySQL](http://www.mysql.com/)，开源关系数据库。
+ [vFabric Postgres](http://www.vmware.com/products/datacenter-virtualization/vfabric-data-director/features.html)，基于 PostgreSQL 的关系数据库。
+ [MongoDB](http://www.mongodb.org/)，基于文档的可扩展开源数据库。
+ [Redis](http://redis.io/)，开源键值数据结构服务器。
+ [RabbitMQ](http://www.rabbitmq.com/)，用于您应用程序的可靠、可扩展和便携消息传送。

您可以在开发应用程序时本地运行这些服务，也可以使用 [Micro Cloud Foundry](/infrastructure/micro/installing-mcf.html) 托管您的应用程序。使用 Micro Cloud Foundry 的优点是您的应用程序将运行在非常类似于 Cloud Foundry 的环境中。而且，使用 Micro Cloud Foundry 时，您不必用工具将应用程序连接到您的开发和部署环境的不同服务。

要从您的应用程序访问 Cloud Foundry 服务，首先需要创建一个服务，然后将它与您的应用程序绑定。当您的应用程序运行在 Cloud Foundry 时，该环境包含一个 `VCAP_SERVICES` 变量，它含有关于与应用程序绑定的所有服务的信息。此变量的内容为一个 JSON 文档。

下面的示例 `VCAP_SERVICES` 变量包含三个绑定的服务，即两个 MySQL 数据库和一个 Redis 数据库。JSON 文档采用的格式可让人理解其内容。

``` javascript
{ "mysql-5.1" : [
      { "credentials" : {
            "host" : "mysql-node01.us-east-1.aws.af.cm",
            "hostname" : "mysql-node01.us-east-1.aws.af.cm",
            "name" : "d6d665aa69817406d8901cd145e05e3c6",
            "password" : "pzAx0iaOp2yKB",
            "port" : 3306,
            "user" : "uB7CoL4Hxv9Ny",
            "username" : "uB7CoL4Hxv9Ny"
          },
        "label" : "mysql-5.1",
        "name" : "mysql-4f700",
        "plan" : "free",
        "tags" : [ "mysql",
            "mysql-5.1",
            "relational"
          ]
      },
      { "credentials" : {
            "host" : "mysql-node01.us-east-1.aws.af.cm",
            "hostname" : "mysql-node01.us-east-1.aws.af.cm",
            "name" : "db777ab9da32047d99dd6cdae3aafebda",
            "password" : "p146KmfkqGYmi",
            "port" : 3306,
            "user" : "uJHApvZF6JBqT",
            "username" : "uJHApvZF6JBqT"
          },
        "label" : "mysql-5.1",
        "name" : "mysql-f1a13",
        "plan" : "free",
        "tags" : [ "mysql",
            "mysql-5.1",
            "relational"
          ]
      }
    ],
  "redis-2.2" : [
      { "credentials" : {
            "hostname" : "179.30.48.44",
            "name" : "redis-70d8d18a-f184-4ec6-bef4-24cae74a9b8c",
            "node_id" : "redis_node_5",
            "password" : "c7945405-73ef-4f1a-bb64-b9e2383e92d6",
            "port" : 5032
          },
        "label" : "redis-2.2",
        "name" : "redis-a42c1",
        "plan" : "free",
        "tags" : [ "redis",
            "redis-2.2",
            "key-value",
            "nosql"
          ]
      } ]
}
```

该文档是服务类型的列表。每个服务类型均包含与应用程序绑定的已配置服务的列表。通常，一个服务类型只有一个实例，不过正如本示例中的 MySQL 实例所示，您可以创建并绑定一个服务类型的多个实例。每个服务都用一系列参数描述，包括名称和标签以及一个凭据对象，凭据对象包含应用程序访问该服务所需的所有信息。

无论您使用何种编程语言或框架，都需要从环境中获取 `VCAP_SERVICES` 变量并加以分析，并提取要访问的服务的连接信息和凭据。然后，您便可以使用这些数据通过库、模块或驱动程序连接到该服务。

诸如 Spring、Grails 和 Ruby on Rails 等应用程序开发框架有助于使用一些约定，这样就可以将大部分应用程序开发流程自动化。只要有可能，Cloud Foundry 工具就会利用约定并在部署时修改应用程序的配置，以使用绑定到应用程序的 Cloud Foundry 服务。


