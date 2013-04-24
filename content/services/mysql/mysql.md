---
title: MySQL
description: 关于 Cloud Foundry MySQL 服务的介绍
tags:
    - mysql
    - 概述
---

[MySQL](http://www.mysql.com/products/community) 是常用的开源关系数据库，它被作为一项服务在 Cloud Foundry 上被提供。当部署 Rails、Grails 或 Spring 应用程序至 Cloud Foundry 时，vmc 或 STS 可能自动配置您的应用程序以使用 Cloud Foundry 实例。如果您的应用程序不能被自动配置，您可从 [`VCAP_SERVICES`](#the-vcap_services-environment-variable) 环境变量中获得您的应用程序连接数据库所需的信息。

## VCAP_SERVICES 环境变量

如果您的应用程序不能被自动配置，您必须提供相应的代码以从 `VCAP_SERVICES` 变量中获得连接信息，该变量已在应用程序的 Cloud Foundry 环境中被设置。此变量的内容是一个 JSON 文件，其中包含一个与应用程序捆绑的所有配置服务的列表。

以下为一个作为示例 JSON 文件（出于可读性考虑而重设了格式），该文件来自带有两个已配置 MySQL 服务的 Cloud Foundry 应用程序的环境。

``` javascript
{"mysql-5.1":[
    {
        "name":"mysql-4f700",
        "label":"mysql-5.1",
        "plan":"free",
        "tags":["mysql","mysql-5.1","relational"],
        "credentials":{
            "name":"d6d665aa69817406d8901cd145e05e3c6",
            "hostname":"mysql-node01.us-east-1.aws.af.cm",
            "host":"mysql-node01.us-east-1.aws.af.cm",
            "port":3306,
            "user":"uB7CoL4Hxv9Ny",
            "username":"uB7CoL4Hxv9Ny",
            "password":"pzAx0iaOp2yKB"
        }
    },
    {
        "name":"mysql-f1a13",
        "label":"mysql-5.1",
        "plan":"free",
        "tags":["mysql","mysql-5.1","relational"],
        "credentials":{
            "name":"db777ab9da32047d99dd6cdae3aafebda",
            "hostname":"mysql-node01.us-east-1.aws.af.cm",
            "host":"mysql-node01.us-east-1.aws.af.cm",
            "port":3306,
            "user":"uJHApvZF6JBqT",
            "username":"uJHApvZF6JBqT",
            "password":"p146KmfkqGYmi"
        }
    }
]}
```

使用访问操作系统环境变量的编程语言工具检索 `VCAP_SERVICES` 的值。例如，在 Java 中为 `java.lang.System.getenv("VCAP_SERVICES")`，在 Ruby 中为 `ENV['VCAP_SERVICES']`。在 Node.js (JavaScript) 中使用 `process.env.VCAP_SERVICES`，在 Python 中使用 `os.getenv("VCAP_SERVICES")`。

使用特定语言的 JSON 库或模型解析该值和访问您所需的信息。

`name` 键值可被用于区别多个 MySQL 实例；它在您使用 vmc 或 STS 创建实例时被设置。

`credentials` 对象包含通过一个驱动程序或库连接 MySQL 所需的所有数据。

+ `hostname` 和 `host` 具有相同的值，都为运行 MySQL 服务器的主机
+ `port` 是 MySQL 服务器在主机上接受连接的端口
+ `user` 和 `username` 是 MySQL 数据库用户的名称
+ `password` 是用户的 MySQL 密码
+ `name`是 MySQL 数据库的名称

请在 Cloud Foundry 入门站点的[服务](/services.html) 部分中查看特定语言和框架下使用 MySQL 的示例。

