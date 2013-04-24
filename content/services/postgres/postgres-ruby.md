---
title: PostgreSQL，Ruby
description: 用于 Cloud Foundry 的 PostgreSQL - Rails 教程
tags:
    - postgres
    - ruby
    - rails
    - 教程
---

此教程讲解了如何在 Rails 3 应用程序中使用用于 Cloud Foundry 的 PostgreSQL 服务。

在此教程中，我们将构造一个使用 PostgreSQL 服务的非常简单的应用程序。当您理解这个教程后，您将能够将更实用的服务应用整合进您的 Cloud Foundry 上的 Rails 3 应用程序中。

此教程包括在 Cloud Foundry 上创建简单 Rails 3 应用程序的整个过程。此应用程序管理基本的留言板页面。每个访问者都可通过填写简单表单在留言板上签名。所有已经签名的访问者及其访问日期将被列出。

## 先决条件

+ Ruby 1.8 或 1.9
+ Rubygems
+ VMC 命令行工具
+ Rails 3

在开始之前,您的开发计算机上须已经安装一些新程序。假设情况是您已经安装了最近版本的 Ruby 1.8 或 1.9，以及 rubygems。

通过 Rubygems 安装 Rails:

```bash
$ gem install rails
[...]
Successfully installed rails-3.0.9
```


安装 VMC 命令行工具：

```bash
$ gem install vmc
Fetching: vmc-0.3.12.gem (100%)
Successfully installed vmc-0.3.12
1 gem installed
```


## 创建一个 Rails 3 应用程序

现在我们将创建一个 Rails 3 应用程序。我们将使用 rails 生成一个新的 Rails 3 应用程序以作为我们的起点。

**$ rails new guestbook --database=postgresql**

create

create README

create Rakefile

[...]

**$ cd guestbook**

要实施逻辑，我们需要一个具有两列的表格“条目”:一列用于来宾姓名,另一列为最后更新时间。利用 Rails 3 框架，现在我们可以使用基架命令生成模型、视图、控制器，以及表格“条目”的迁移。

**$ rails generate scaffold Entry name:string**

我们无需明确指定最后更新时间，因为 Rails 3 框架将默认会生成“updated at”列。

编辑文件 app/views/entries/index.html.erb 以添加一行（下文中红色高亮显示）显示每个条目的最后更新时间。


![aurora.png](http://support.cloudfoundry.com/attachments/token/wauy78kuctleafi/?name=aurora.png)


现在，应用程序已经准备好可被推送至 Cloud Foundry。



## 部署应用程序

设置 vmc 选定目标为 cloudfoundry.com 站点，然后登录：

```bash
$ vmc target api.cloudfoundry.com
Succesfully targeted to [http://api.cloudfoundry.com]
```

```bash
$ vmc login
Email: [your Cloud Foundry email]
Password: [your Cloud Foundry password]
Successfully logged into [http://api.cloudfoundry.com]
```


推送应用程序：

```bash
$ vmc push
Would you like to deploy from the current directory? [Yn]: Y
Application Name: [your application name]
Application Deployed URL: '[Your application name].cloudfoundry.com'? Y
Detected a Rails Application, is this correct? [Yn]: Y
Memory Reservation [Default:256M] (64M, 128M, 256M or 512M) 64M
Creating Application: OK
Would you like to bind any services to 'guestbook-rails'? [yN]: Y
Would you like to use an existing provisioned service [yN]? N
The following system services are available:
1. mongodb
2. mysql
3. postgresql
4. rabbitmq
5. redis
Please select one you wish to provision: 3
Specify the name of the service [postgresql-1c51b]: [your database service name]
Creating Service: OK
Binding Service: OK
Uploading Application:
 Checking for available resources: OK
 Processing resources: OK
 Packing application: OK
 Uploading (5K): Push Status: OK
Staging Application: ...
Staging Application: OK
Starting Application: OK
```

现在您可访问 http://your application name].cloudfoundry.com/entries 以查看页面和使用它。

