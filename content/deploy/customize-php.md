---
title: Cloud Foundry 中的 PHP 支持
description: Cloud Foundry 中的 PHP 支持
tags:
    - php
---

## **PHP 支持**

PHP 应用程序是通过 Apache 和 mod_php 获得支持的。**仅在 AppFog.com 中或来自于 [https://github.com/cloudfoundry/vcap](https://github.com/cloudfoundry/vcap) 的开源软件 vcap 环境中才提供 PHP 支持。在 CloudFoundry.com 或微 Cloud Foundry 中尚不提供此支持。**


## **WordPress 应用程序示例**

假设您的 vcap 目标支持 PHP，那么您可以像下面这样快速
上手使用 wordpress：

    
    $ git clone git://github.com/phpfog/af-sample-wordpress.git  
    $ cd af-sample-wordpress   
    $ vmc push wp --url wp.vcap.me –n   
    $ vmc create-service mysql --bind wp

## **访问数据库**

Cloud Foundry 通过 VCAP_SERVICES 环境变量使服务连接凭据可作为 JSON 使用。知道这一点后，您便可以在您自己的 PHP 代码中使用下面的代码段：

    
    $services = getenv("VCAP_SERVICES");  
    $services_json = json_decode($services,true);  
    $mysql_config = $services_json["mysql- 5.1"][0]["credentials"];    
    define('DB_NAME', $mysql_config["name"]);  
    define('DB_USER', $mysql_config["user"]);  
    define('DB_PASSWORD', $mysql_config["password"]);  
    define('DB_HOST', $mysql_config["hostname"]);  
    define('DB_PORT', $mysql_config["port"]);

## **限制**

* 不支持迁移工作流，如 symfony 的迁移工作流。


## **VMC**

要想发现并利用 PHP 支持，您需要使用 VMC_0.3.14_ 或更高版本：
    
    $ vmc -v
    vmc 0.3.16.beta.5
    
    # 升级到最近版本：
    $ gem update vmc

或者安装 AppFog 客户端 gem `af`：

    $ gem install af

## **示例应用程序**

1. WordPress PHP 应用程序：[https://github.com/phpfog/af-sample-wordpress](https://github.com/phpfog/af-sample-wordpress)
