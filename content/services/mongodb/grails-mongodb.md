---
title: Grails 与 MongoDB 一起使用
description: 与 MongoDB 服务相关的 Grails 开发
tags:
    - mongodb
    - grails
---

[Grails](http://www.grails.org) 框架为运行在 Java servlet 容器中的 Web 应用程序的快速开发提供了可能。Grails 基于 Groovy 语言和 Spring 框架。

要使用 Cloud Foundry 的 Grails，请从您的应用程序目录安装 Cloud Foundry Grails 插件：

```bash
$ grails install-plugin cloud-foundry
```

要在 Grails 应用程序中使用 [MongoDB](http://www.mongodb.org/)，请安装 Grails [MongoDB 插件](http://grails.org/plugin/mongodb)。

```bash
$ grails install-plugin mongodb
```

当您安装了 mongodb 插件后，您的应用程序将可访问 MongoDB。MongoDB 插件可将 GORM 实体映射到 MongoDB 集合中。它还提供了 Java 直接访问 MongoDB 驱动程序的低级 API。

## 参考

+	[Grails Cloud Foundry 插件用户指南](http://grails-plugins.github.com/grails-cloud-foundry/)
+	[Gorm for Mongo](http://grails.github.com/inconsequential/mongo/manual/index.html) 参考文档

