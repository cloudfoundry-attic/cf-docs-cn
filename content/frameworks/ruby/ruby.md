---
title: Ruby
description: 利用 Cloud Foundry 开发 Ruby 应用程序
tags:
    - ruby
    - 概述
---

本指南为 Ruby 开发人员介绍 Cloud Foundry 对 Ruby 应用程序的支持，
包括用 Sinatra 或 Ruby on Rails 框架构建的应用
程序。

本指南的前提如下：

-  您已[安装 Ruby 和 Ruby Gems](installing-ruby.html)
-  您已[安装 vmc](/tools/vmc/installing-vmc.html)
-  您有一个 [Cloud Foundry 帐户](http://www.cloudfoundry.com/signup)
-  您能够利用自己选择的框架熟练地开发 Ruby 应用
程序

副标题：

-  [Ruby 版本](#supported-ruby-versions)
-  [Gemfile 和 Gem 支持](#gemfile-and-gem-support)
-  [通过 Ruby 使用 Cloud Foundry 服务](#using-cloud-foundry-services)
-  [接下来需要做什么](#what-to-do-next)

## 支持的 Ruby 版本

从本版本开始，Cloud Foundry 支持 `ruby 1.8.7-p302` 或更高版本及
`ruby 1.9.2-p180` 或更高版本。
Ruby 1.8.7 为默认版本。如果您使用的是 Ruby 1.9.2，在将应用程序推送到 Cloud Foundry 时需添加 vmc `--runtime ruby19`
选项：

    vmc push <appname> --runtime ruby19

## Gemfile 和 Gem 支持

Cloud Foundry 要求您的应用程序根目录中有 Gemfile，其中列出
您的应用程序使用的 gem。

您应使用[捆绑程序](http://gembundler.com)打包应用程序。
每次修改 Gemfile 和运行任何 
`vmc push` 或 `vmc update` 命令前应先运行 `bundle install;bundle package`。

有关详细信息，请参见：

+ [在 Cloud Foundry 上运行 Ruby](/frameworks/ruby/ruby-cf.html)

## 通过 Cloud Foundry 使用 Ruby on Rails

Ruby on Rails 能在 Cloud Foundry 上正常运行。对于 Rails 3.0 和 3.1 或 3.2 
的要求存在某些不同之处，对此请阅读以下链接：

+   [Ruby on Rails 3.0](/frameworks/ruby/rails-3-0.html)
+   [Ruby on Rails >= 3.1](/frameworks/ruby/rails-3-1.html)

## 使用 Cloud Foundry 服务

您可以在 Ruby 应用程序中使用以下任何一种 Cloud Foundry 服务：

-   [MySQL](http://www.mysql.com/)，开源关系数据库
-   [MongoDB](http://www.mongodb.org/)，可扩展、开放式、
    基于文档的数据库
-   [vFabric Postgres](http://www.vmware.com/products/datacenter-virtualization/vfabric-data-director)，
    VMware vFabric Postgres 9.0 关系数据库
-   [RabbitMQ](http://www.rabbitmq.com/)，用于消息传递
-   [Redis](http://redis.io/)，开源键值数据结构服务器

在开发应用程序时，你既可以本地运行这些服务，也可以
使用 [Micro Cloud Foundry](/infrastructure/micro/installing-mcf.html) 托管您的应用程序。
使用 Micro Cloud Foundry 的优势在于，您的应用程序的运行环境
与 Cloud Foundry 非常相似。并且，通过 Micro Cloud 
Foundry，您无需设置本地服务，并且您无需使用工具就能使应用程序
连接不同的服务，以满足开发和部署环境的
需要。

在 Ruby 和 Ruby 框架中使用 Cloud Foundry 服务的示例和教程如下。

-   [MySQL](/services/mysql/ruby-mysql.html)
-   [MongoDB](/services/mongodb/ruby-mongodb.html)
-   [MongoDB with GridFS](/services/mongodb/ruby-mongodb-gridfs.html)
-   [RabbitMQ](/services/rabbitmq/ruby-rabbitmq.html)

## 接下来需要做什么

-   [VMC 安装](/tools/vmc/installing-vmc.html)介绍如何安装 Cloud Foundry 命令行接口。如果您已经安装 Ruby，则安装它就像安装 vmc gem 一样容易。
-   [VMC 快速参考](/tools/vmc/vmc-quick-ref.html)
-   [创建简单的 Ruby 应用程序](ruby-simple.html)教程介绍如何创建简单的 Sinatra 应用程序并将其部署到 Cloud Foundry。
-   [利用 Cloud Foundry 开发 Ruby on Rails 3.0](rails-3-0.html) 提供在 Cloud Foundry 上成功部署 Rails 3.0 应用程序所需的信息。
-   [利用 Cloud Foundry 开发 Ruby on Rails 3.1](rails-3-1.html) 提供在 Cloud Foundry 上成功部署 Rails 3.1 应用程序所需的信息。

