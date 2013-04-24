---
title: Grails 与 MySQL 一起使用
description: 与 MySQL Cloud Foundry 服务相关的 Grails 开发
tags:
    - groovy
    - mysql
---

目前，如果您想要您的应用程序使用一个关系数据库，您可以在 Cloud Foundry 上使用 MySQL 或 PostgreSQL。
只需使用所有新的 Grails 应用程序默认附带的 [Hibernate 插件](http://grails.org/plugin/hibernate)，
您就可以访问这些数据库。您还需确认相关的驱动程序对您的应用程序可用，
例如，通过在 `BuildConfig.groovy` 中对其进行声明：

``` groovy
grails.project.dependency.resolution = {
    ...
    dependencies {
        runtime "mysql:mysql-connector-java:5.1.18"
        ...
    }
}
```

并确认在 `DataSource.groovy` 中已设置 JDBC 驱动程序类：

``` groovy
environments {
    production {
        dataSource {
            driverClassName = "com.mysql.jdbc.Driver"
            ...
        }
    }
}
```

在此例中，我们将部署用于标准生产环境的应用程序，但是您也可轻松设置
“云”环境或类似环境。同时，您还可以轻松配置 JDBC URL、用户名和密码使生产环境指向
一个本地数据库，因为当应用程序部署在 Cloud Foundry 上时，这些设置会被覆盖。


