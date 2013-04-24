---
title: 部署和管理应用程序
description: 在 Cloud Foundry 上管理应用程序
tags:
    - 概述
    - vmc
    - sts
    - maven
    - roo
---

在 Cloud Foundry 环境中，部署应用程序简单来说就是为用户提供可以使用的应用程序。部署应用程序时，您会将实际的应用程序位（如 Spring Java 中的 WAR 文件）推送到目标云、指定所需的应用程序配置，如部署 URL 和所需的内存，并绑定任何所需的服务，例如 MySQL。然后 Cloud Foundry 会暂存应用程序，启动并将其放到指定的 URL，以供用户使用。

**副标题**

+ [使用 VMC](#using-vmc)
+ [使用 STS](#using-sts)
+ [使用 Maven](#using-maven)
+ [使用 Roo](#using-roo)

## 使用 VMC

本文档中描述了以下用户场景：

+ [部署不需要服务的应用程序](#deploying-an-application-that-does-not-require-a-service)
+ [部署需要一种服务的应用程序](#deploying-an-application-that-requires-one-service)
+ [部署需要多种服务的应用程序](#deploying-an-application-that-requires-multiple-services)
+ [在非交互模式下部署](#deploying-in-non-interactive-mode)
+ [管理应用程序生命周期（停止、启动、重新启动、删除、重命名）](#managing-the-application-lifecycle-stop-start-restart-delete-rename)
+ [更新部署位](#updating-the-deployment-bits)
+ [避免在更新部署位时发生停机](#avoiding-downtime-when-updating-the-deployment-bits)
+ [监控和配置部署（扩展和内存管理） ](#monitoring-and-configuring-a-deployment-scaling-and-memory-management)

## 部署不需要服务的应用程序

您可以使用 `vmc push` 命令部署使用 VMC 的应用程序。默认情况下，`vmc` 会以交互方式提示所需的部署信息，您也可以指定参数来覆盖默认值或在非交互模式下运行。

最简单的部署示例是不使用任何参数来运行 `vmc push`，以部署不需要绑定任何服务的应用程序。`vmc push` 命令会提示您输入所需的全部信息。下例显示部署一个非常简单的 Spring 应用程序的输出内容，该应用程序被打包成一个名为 `hello.war` 的 WAR 文件； 有关详细信息，请参见示例后的文本：

```bash

    prompt$ vmc push

    Would you like to deploy from the current directory? [Yn]:
    Application Name: hello
    Application Deployed URL: 'hello.cloudfoundry.com'? hello-js.cloudfoundry.com
    Detected a Java SpringSource Spring Application, is this correct? [Yn]:
    Memory Reservation [Default:512M] (64M, 128M, 256M, 512M or 1G)
    Creating Application: OK
    Would you like to bind any services to 'hello'? [yN]:
    Uploading Application:
      Checking for available resources: OK
      Processing resources: OK
      Packing application: OK
      Uploading (4K): OK
    Push Status: OK

    Staging Application: OK
    Starting Application: OK

```

转到浏览器中指定的部署 URL 以开始使用应用程序。在上例中，应为：

        http://hello-js.cloudfoundry.com

请注意以下有关上述 `vmc push` 示例的信息：

+ 是/否提示的默认值在提示的最后部分以大写字母表示，例如，如果默认答案是“否”，则提示以 `[yN]` 结束。
+ 您可以从当前正在运行 VMC 的目录部署，或指定不同的目录。此目录是实际应用程序位（如 `hello.war` 文件）的所在位置。**注意：** `vmc push` 会部署指定目录中的所有项目，因此，请确保您要部署的文件确实位于此目录中。
+  应用程序的名称是您在管理生命周期（如停止应用程序、向应用程序添加内存等）时用于识别应用程序的名称。该名称的作用域是您的 Cloud Foundry 帐户，这意味着在使用您的帐户时，名称应保持唯一，但不需要在整个 Cloud Foundry 目标内保持唯一。
+  默认情况下，部署 URL 是应用程序名称以及目标（例如，`cloudfoundry.com`）。但是，您必须指定一个在整个 Cloud Foundry 目标内保持*唯一* 的部署 URL，即使应用程序的名称只需在 Cloud Foundry 帐户作用域内保持唯一也如此。这就是为什么上例中的部署 URL 包括一个标识符，该标识符可使其在整个 cloudfoundry.com 网站中保持唯一。

## 部署需要一种服务的应用程序

下例显示如何部署需要一种服务的应用程序（本例中为 MySQL 服务）。这种应用程序称为 `hotels.war`。

在本例中，我们将首先使用 `vmc create-service` 命令创建一个 MySQL 服务实例，然后在使用 `vmc push` 部署该服务实例时，将其绑定到此应用程序。

一定要注意，您不需要以任何方式更改现有的应用程序，它便能“找到” Cloud Foundry 创建的 MySQL 实例以及应用程序绑定到的服务实例。这是因为 Cloud Foundry 使用自动重新配置机制，使典型的 Spring 应用程序无需在应用程序中进行任何更改即可使用服务。

* 通过运行 `vmc services` 查找 MySQL 服务的名称，并注意第一列：

```bash

        prompt$ vmc services

        ============== System Services ==============

        +------------+---------+---------------------------------------+
        | Service    | Version | Description                           |
        +------------+---------+---------------------------------------+
        | mongodb    | 2.0     | MongoDB NoSQL store                   |
        | mysql      | 5.1     | MySQL database service                |
        | postgresql | 9.0     | vFabric Postgres database service     |
        | rabbitmq   | 2.4     | RabbitMQ messaging service            |
        | redis      | 2.2     | Redis key-value store service         |
        +------------+---------+---------------------------------------+

        =========== Provisioned Services ============

```

*  创建 `mysql` 服务的新实例并将其称为 `mysql-js`：

```bash
prompt$ vmc create-service mysql mysql-js
```

*  部署 `hotels.war` 应用程序，但是这次将其绑定到 `mysql-js` 服务实例：

```bash

        prompt$ vmc push

        Would you like to deploy from the current directory? [Yn]: y
        Application Name: hotels
        Application Deployed URL: 'hotels.cloudfoundry.com'? hotels-js.cloudfoundry.com
        Detected a Java Web Application, is this correct? [Yn]:
        Memory Reservation [Default:512M] (64M, 128M, 256M, 512M or 1G)
        Creating Application: OK
        Would you like to bind any services to 'hotels'? [yN]: y
        Would you like to use an existing provisioned service [yN]? y
        The following provisioned services are available:
        1. mysql-js
        Please select one you wish to provision: 1
        Binding Service: OK
        Uploading Application:
          Checking for available resources: OK
          Packing application: OK
          Uploading (12K): OK
        Push Status: OK

        Staging Application: OK

        Starting Application: OK

```

您也可以在执行 `vmc push` 命令期间，通过在出现有关使用所置备的服务提示时回答 `N` 创建一个新的服务实例；在这种情况下，`vmc push` 命令会提示有关新服务实例的信息。

## 部署需要多种服务的应用程序

[上一节](#deploying-an-application-that-requires-one-service)介绍了如何使用 `vmc push` 命令部署应用程序，同时将服务 (MySQL) 绑定到该应用程序。但是，您只能绑定*一种* 服务，如果您的应用程序需要多种服务，又该怎么办呢？本节将介绍如何执行此任务。

本例扩展了[前面的示例](#deploying-an-application-that-requires-one-service)，因此除了将 `mysql-js` 服务绑定到 `hotels` 应用程序以外，还将创建和绑定 MongoDB 和 RabbitMQ 服务。

*  创建 `mysql`、`mongodb` 和 `rabbitmq` 服务的新实例：

```bash

        prompt$ vmc create-service mysql mysql-js
        prompt$ vmc create-service mongodb mongodb-js
        prompt$ vmc create-service rabbitmq rabbitmq-js

```

*  部署 `hotels.war` 应用程序并将 `mysql-js` 服务实例绑定到该应用程序。但是，这次一定要指定 `--no-start` 选项，以便 Cloud Foundry 不会暂存或启动该应用程序：

```bash

        prompt$ vmc push --no-start

        Would you like to deploy from the current directory? [Yn]: y
        Application Name: hotels
        ...
        Uploading Application:
        ...
        Push Status: OK

```

* 使用 `vmc bind-service` 将其余两种服务绑定到 `hotels` 应用程序：

```bash

        prompt$ vmc bind-service mongodb-js hotels
        prompt$ vmc bind-service rabbitmq-js hotels

```

*  启动应用程序：

```bash

        prompt$ vmc start hotels

        Staging Application: OK
        Starting Application: OK

```

## 在非交互模式下部署

使用 `vmc push` 的 `-n` 选项在非交互模式下部署应用程序。唯一的其他要求是您指定该应用程序的名称。

如果您没有指定任何其他选项，则 Cloud Foundry 会在部署应用程序时使用所有默认值。例如，如果您执行以下命令：

```bash

    prompt$ vmc push hotels -n

```

则 Cloud Foundry 会执行以下操作：

+ 将当前目录中的所有项目部署为 `hotels` 应用程序的一部分。
+ 使用部署 URL`hotels.cloudfoundry.com`（假定您的目标是公开托管的 Cloud Foundry。）
+ 为部署的应用程序创建一个实例。
+ 不将任何服务绑定到应用程序。
+ 自动检测编程框架（如 Spring 或 Ruby）
+ 为应用程序预留 512 MB​​ 的内存
+ 暂存后自动启动应用程序​​。

您可以使用其他选项来改变部署的默认值，并仍在非交互模式下部署。例如，您可以使用 `--url` 选项更改部署 URL、使用 `--mem` 选项更改预留的内存，并指定使用下面的命令不会启动应用程序：

```bash

    prompt$ vmc push hotels -n --url hotels-js.cloudfoundry.com --mem 256 --no-start

```

有关可以为 `vmc push` 命令指定的完整参数列表，请参见 [VMC 快速参考指南](/tools/vmc/vmc-quick-ref.html#deploying-applications)。

## 管理应用程序生命周期（停止、启动、重新启动、删除、重命名）

管理已完成部署的应用程序的生命周期很容易，只需使用相应的 VMC 命令停止、启动并重新启动应用程序即可。例如，停止然后启动应用程序：

```bash

    prompt$ vmc stop hotels
    prompt$ vmc start hotels

```

或者使用一个命令执行相同的任务：

```bash

    prompt$ vmc restart hotels

```

一定要注意，当 Cloud Foundry 重新启动某个应用程序时，它会为该应用程序创建一个全新的虚拟基础架构。虽然这个过程对于应用程序而言通常是透明的，但是有一种情况关系重大，即以前应用程序运行时是否在磁盘上创建本地文件。重新启动时，这些文件将全部丢失，因为 Cloud Foundry 会创建一个新的虚拟磁盘。如果应用程序要求确保这些文件可用，即使在重新启动后也可用，那么您的应用程序应该使用一种数据服务，如 MongoDB，该服务将确保这些文件始终可用。

要对应用程序进行重命名，请使用 `vmc rename` 命令，指定现有的名称，然后指定新名称。例如：

```bash
prompt$ vmc rename hotels hotels-new-name
```

`vmc rename` 命令会更改应用程序的内部名称；它不会更改您用于运行该应用程序的部署 URL。为此，您可以使用 `vmc map`。参见[更改部署 URL](#changing-the-deployment-url)。

要删除某应用程序，并释放所有与该应用程序相关联的资源，请使用 `vmc delete` 命令：

```bash
prompt$ vmc delete hotels
```

## 更新部署位

使用 `vmc update <appname>` 命令更新构成应用程序的“位”，如适用于 Java Spring 应用程序的 WAR 文件包。

Cloud Foundry 更新某应用程序时，它会先停止该应用程序，进行更改，然后再次启动该应用程序。这意味着该应用程序将在短时间内不可用，现有用户会话将被删除。在应用程序迭代开发周期中，这可能不是问题，但在生产中这可能是无法接受的。请参阅[避免在更新部署位时发生停机](#avoiding-downtime-when-updating-the-deployment-bits)获取一个有用的操作程序，以避免这一短暂停机事件。

按照下面的步骤更新您的应用程序：

* 使用 `vmc apps` 获取确切的应用程序名称；输出内容的第一列会列出此名称。例如：

```bash

        prompt$ vmc apps

        +-------------+----+---------+----------------------------+----------+
        | Application | #  | Health  | URLS                       | Services |
        +-------------+----+---------+----------------------------+----------+
        | hello       | 1  | RUNNING | hello-js.cloudfoundry.com  |          |
        | hotels      | 1  | RUNNING | hotels-js.cloudfoundry.com |          |
        +-------------+----+---------+----------------------------+----------+

```

* 在命令提示符 (Windows) 或终端窗口 (Linux) 中，更改为包含已更新的应用程序位的目录。确保该目录*只* 包含要部署的文件和项目，因为 VMC 会推送目录中的所有文件。

```bash
prompt$ cd /usr/bob/sample-apps/hotels
```

*  使用 `vmc update` 更新您的应用程序：

```bash
prompt$ vmc update hotels
```

检查命令的输出内容，以确保应用程序启动时未出错，然后开始使用更新的应用程序。

## 避免在更新部署位时发生停机

更新应用程序而不会发生任何停机事件的方法利用了这样一种实际情况：在 Cloud Foundry 中，您可以将单个应用程序映射到多个部署 URL，同样，您也可以将多个应用程序映射到同一部署 URL。因此，我们不会直接更新应用程序，而是创建一个新的应用程序，将其与现有的 URL 相关联，*取消旧应用程序与 URL 的映射关联，*然后删除旧应用程序。

在下例中，现有的应用程序被称为 `hotels`，其部署 URL 是 `hotels.cloudfoundry.com`，您希望创建新的用户会话，以开始无缝使用新的应用程序，同时现有用户不会断开连接。

具体步骤如下：

* 在命令提示符或终端窗口中，更改为包含已更新的应用程序“位”的目录。例如：

```bash
prompt$ cd /usr/bob/sample-apps/hotels
```

*  使用 `vmc push` 命令创建新的应用程序，起一个不同于现有应用程序的名称，如 `hotels-new`，同时指定不同的部署 URL，如 `hotels-new.cloudfoundry.com`：

```bash
prompt$ vmc push hotels-new
```

    确保绑定任何所需的服务，如 MySQL 或 RabbitMQ。使用现有应用程序当前使用的同一服务实例。

*  在浏览器中，转到新的部署 URL，测试新部署的应用程序是否正常工作，以及是否确实是更新的版本。

    在本例中，新应用程序的部署 URL 为 `http://hotels-new.cloudfoundry.com`。

*  使用 `vmc map` 命令将新的应用程序与*现有的* 部署 URL 关联起来。例如：

```bash
prompt$ vmc map hotels-new hotels.cloudfoundry.com
```

    此时，由于相同的部署 URL 映射到两个不同的应用程序，新的用户会话可能会转到*任一* 旧应用程序或新应用程序。

    您可以通过不断刷新 `http://hotels.cloudfoundry.com` URL 进行测试；有时您会被引导到旧应用程序，但有时您又会被引导到新应用程序。但是，请确保*有时* 您会被引导到新应用程序。

    您也可以通过执行 `vmc apps` 查看这种多 URL 关联：

```bash

    prompt$ vmc apps

    +-------------+----+---------+-----------------------------------------+--------------+
    | Application | #  | Health  | URLS                                    | Services     |
    +-------------+----+---------+-----------------------------------------+--------------+
    | hotels      | 1  | RUNNING | hotels.cloudfoundry.com                 | mysql-hotels |
    | hotels-new  | 1  | RUNNING | hotels-new.cloudfoundry.com,            |              |
    |             |    |         |    hotels.cloudfoundry.com              | mysql-hotels |
    +-------------+----+---------+-----------------------------------------+--------------+

```

*  使用 `vmc unmap` 命令解除旧应用程序与原始部署 URL 的关联：

```bash
prompt$ vmc unmap hotels hotels.cloudfoundry.com
```

    注意，这种取消映射操作*不* 会将现有用户会话放入旧应用程序；它只会停止向旧应用程序输入新的流量，以便新用户会话开始使用新应用程序。

* 测试原始部署 URL (本例中为 `http://hotels.cloudfoundry.com`）现在是否始终将用户会话引导到新应用程序。

*  解除新应用程序与新部署 URL 的关联：

```bash
prompt$ vmc unmap hotels-new hotels-new.cloudfoundry.com
```

*  当确定不再有任何用户会话连接到旧应用程序时，您便可以将其删除：

```bash
prompt$ vmc delete hotels
```

    确保您**不**会删除新应用程序当前正在使用的任何共享服务实例。

    现在，您的应用程序将有一个新的内部名称，但是它仍映射到用户已经熟悉的现有部署 URL。您可以使用 `vmc apps` 查看这一新的映射：

```bash

        prompt$ vmc apps

        +-------------+----+---------+-------------------------+-------------+
        | Application | #  | Health  | URLS                    | Services    |
        +-------------+----+---------+-------------------------+-------------+
        | hotels-new  | 1  | RUNNING | hotels.cloudfoundry.com | mysql-hotels|
        +-------------+----+---------+-------------------------+-------------+

```

## 监控和配置部署（扩展和内存管理） 

许多 VMC 命令可用于配置已部署的应用程序，如通过添加或删除实例、增加更多内存，并更改其部署 URL 来扩展或缩减应用程序。

使用 `vmc apps` 命令可获得所有已部署的应用程序的列表，您将使用应用程序的名称获得更多相关信息，并且可以对其进行配置：

```bash

    prompt$ vmc apps

    +-------------+----+---------+----------------------------+----------+
    | Application | #  | Health  | URLS                       | Services |
    +-------------+----+---------+----------------------------+----------+
    | hello       | 1  | RUNNING | hello-js.cloudfoundry.com  |          |
    | hotels      | 1  | RUNNING | hotels-js.cloudfoundry.com | mysql-js |
    +-------------+----+---------+----------------------------+----------+

```

## 扩展应用程序

使用 `vmc stats <appname>` 命令显示应用程序的当前配置和资源利用率​​。例如：

```bash

    prompt$ vmc stats hotels

    +----------+-------------+----------------+--------------+---------------+
    | Instance | CPU (Cores) | Memory (limit) | Disk (limit) | Uptime        |
    +----------+-------------+----------------+--------------+---------------+
    | 0        | 0.0% (4)    | 61.7M (512M)   | 8.4M (2G)    | 0d:0h:39m:42s |
    | 1        | 7.5% (4)    | 63.8M (512M)   | 8.4M (2G)    | 0d:0h:0m:22s  |
    +----------+-------------+----------------+--------------+---------------+

```

此表为应用程序的每个实例显示一行数据，在上表中，有两个 `hotels` 实例。每行显示实例的 CPU 利用率、内存使用情况和允许的最大值、磁盘使用情况和最大值，以及实例已经运行多长时间。

要更改允许的最大内存，请使用 `vmc mem` 命令，向其传递应用程序的名称和最大内存 (MB)。这将更改所有应用程序实例的最大值。例如，将 `hotels` 应用程序的最大内存减小到 128 MB：

```bash
prompt$ vmc mem hotels 128
```

注意，Cloud Foundry 必须重新启动应用程序，此更改才会生效。

扩展应用程序的另一种方式是您可以添加更多实例，以便更多用户会话可以立即成功快速地建立连接。相反，如果您想节约与 Cloud Foundry 帐户有关的资源，并*缩减* 目前运行多个实例的应用程序，则可以删除实例。例如，要指定应用程序同时运行四个实例，请执行以下操作：

```bash
prompt$ vmc instances hotels 4
```

使用 `vmc stats` 确保应用程序确实正在运行四个实例：

```bash

    prompt$ vmc stats hotels

    +----------+-------------+----------------+--------------+--------------+
    | Instance | CPU (Cores) | Memory (limit) | Disk (limit) | Uptime       |
    +----------+-------------+----------------+--------------+--------------+
    | 0        | 0.5% (4)    | 64.6M (128M)   | 8.4M (2G)    | 0d:0h:5m:4s  |
    | 1        | 0.5% (4)    | 62.4M (128M)   | 8.4M (2G)    | 0d:0h:5m:4s  |
    | 2        | 7.0% (4)    | 61.0M (128M)   | 8.4M (2G)    | 0d:0h:0m:22s |
    | 3        | 6.7% (4)    | 59.6M (128M)   | 8.4M (2G)    | 0d:0h:0m:22s |
    +----------+-------------+----------------+--------------+--------------+

```

请注意，为已部署应用程序增加更多实例会占用更多内存和磁盘空间配额。

## 更改部署 URL

使用 `vmc map` 和 `vmc unmap` 命令更改应用程序关联的部署 URL。

例如，将新部署 URL 关联到现有应用程序：

```bash
prompt$ vmc map hotels hotels-new.cloudfoundry.com
```

要取消现有 URL 的映射，请使用 `vmc unmap` 命令：

```bash
prompt$ vmc unmap hotels hotels-new.cloudfoundry.com
```

有关在现实生活中使用这些命令的更多示例，请参见[更新部署，而不会发生任何停机事件](#updating-a-deployment-without-any-downtime)。

## 获取应用程序的相关日志和崩溃信息

要查看应用程序的 stderr.log 和 stdout.log 文件中最近发生的活动，请使用 `vmc logs <appname>` 命令：

```bash
prompt$ vmc logs hotels
```

如果您怀疑您的应用程序最近已经崩溃，则运行 `vmc crashes <appname>`，它将为您提供更多信息：

```bash
prompt$ vmc crashes hotels
```

使用 `vmc crashlogs` 获取更详细的崩溃信息：

```bash
prompt$ vmc crashlogs hotels
```


