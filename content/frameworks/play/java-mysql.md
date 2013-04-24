---
title: 在 Cloud Foundry 上部署 Play Java MySQL 应用程序
description: 在 Cloud Foundry 上部署带 MySQL 后端的 Play Java 应用程序
tags:
    - play
    - java
    - mysql
    - 教程
---

本文介绍 Java 开发人员如何使用 Play 框架和 MySQL 数据库在 Cloud Foundry 上
构建和部署应用程序。它告诉您如何设置并成功在 Cloud Foundry 上部署
Play Java MySQL 应用程序。


开始前请做好以下准备：

+  一个 [Cloud Foundry 帐户](http://cloudfoundry.com/signup)

+  [vmc](/tools/vmc/installing-vmc.html) Cloud Foundry 命令行工具

+  [Play 2.0 ](http://www.playframework.org/documentation/2.0.2/Home) 安装程序

## 简介

在本教程中，我们将采用以下简单的用例：

在 Cloud Foundry 上部署 [TodoList]( http://www.playframework.org/documentation/2.0.2/JavaTodoList ) 应用程序。

## TodoList Play 应用程序

TodoList 用来创建和管理任务。

![todolist-usecase.png](/images/play/todolist-usecase.png)

这些任务由用户创建并将数据存储在
基础关系存储区中。
该默认教程将任务存储在 Play 框架中自带的嵌入数据库中。

该应用程序的各种组件可以在 [Todo List 应用程序概述]( /frameworks/play/todolistjavaapp.html)文档中找到。

## 在本地构建和运行该应用程序
利用应用程序文件夹中的标准命令可以在本地运行该应用程序：

``` bash
$play run
```
由于需要应用演进脚本和创建表，所以第一次会显示以下
屏幕：

![play-local-java-mysql-applyscript.png](/images/screenshots/play/play-local-java-mysql-applyscript.png)

用户按 ApplyScript 按钮后，实际应用程序主页将出现。

![play-local-java-mysql.png](/images/screenshots/play/play-local-java-mysql.png)


### 修改 MySQL 的演进文件

#### 注释/删除
由于以下语句无法被 MySQL 识别，因而我们需要注释禁止以下语句：

```  sql
create sequence task_seq
drop sequence task_seq
SET REFERENTIAL_INTEGRITY FALSE
SET REFERENTIAL_INTEGRITY TRUE
```

#### 修改
我们将修改创建语句，使 id 字段中增加自动递增功能。

``` sql
create table task (
  id                        bigint not null AUTO_INCREMENT,
  label                     varchar(255),
  constraint pk_task primary key (id))
;
```

## 在 Cloud Foundry 上部署应用程序
在 Cloud Foundry 上部署可用两个简单的步骤完成：

+  创建分发
+  使用 `vmc push` 推送该分发

以下命令提供了部署应用程序时的准确命令和输出：

``` bash
$ play dist
[info] Loading project definition from /Users/[username]/play/mysamples/todolist-java-mysql/project
[info] Set current project to todolist-java-mysql (in build file:/Users/rajdeepd/vmware/play/mysamples/todolist-java-mysql/)
[info] Packaging /Users/[username]/play/mysamples/todolist-java-mysql/target/scala-2.9.1/todolist-java-mysql_2.9.1-1.0-SNAPSHOT.jar ...
[info] Done packaging.

Your application is ready in /Users/[username]/play/mysamples/todolist-java-mysql/dist/todolist-java-mysql-1.0-SNAPSHOT.zip

[success] Total time: 3 s, completed Aug 2, 2012 11:11:55 PM
$ vmc push --path=dist/todolist-java-mysql-1.0-SNAPSHOT.zip
Application Name: todolist-java-mysql
Detected a Play Framework Application, is this correct? [Yn]: Y
Application Deployed URL [todolist-java-mysql.cloudfoundry.com]: y
Memory reservation (128M, 256M, 512M, 1G, 2G) [256M]:
How many instances? [1]: 1
Bind existing services to 'todolist-java-mysql'? [yN]: N
Create services to bind to 'todolist-java-mysql'? [yN]: y
1: mongodb
2: mysql
3: postgresql
4: rabbitmq
5: redis
What kind of service?: 2
Specify the name of the service [mysql-2ea2b]:
Create another? [yN]: N
Would you like to save this configuration? [yN]: y
Manifest written to manifest.yml.
Creating Application: OK
Creating Service [mysql-2ea2b]: OK
Binding Service [mysql-2ea2b]: OK
Uploading Application:
  Checking for available resources: OK
  Processing resources: OK
  Packing application: OK
  Uploading (83K): OK
Push Status: OK
Staging Application 'todolist-java-mysql': OK
Starting Application 'todolist-java-mysql': OK

```

部署完成后，我们可以打开 URL `[app-name].cloudfoundry.com]` 看一下实际的应用程序

![play-cf-java-mysql.png](/images/screenshots/play/play-cf-java-mysql.png)

## 总结
在本教程中，我们学习了如何构建和部署以 MySQL 作为后端的基本 Play Java 应用程序。



