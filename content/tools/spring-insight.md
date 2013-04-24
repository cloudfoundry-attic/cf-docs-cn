---
title: Spring Insight
description: 使用 Spring Insight 跟踪 Java 应用程序
tags:
    - spring
    - performance-monitoring
---

Spring Insight 是一种 Cloud Foundry 服务，可您能够实时查看部署的应用程序。Spring Insight 可以按时间绘制应用程序的运行状况图，使您能够立即看到您的应用程序中所发生的任何性能问题。

Spring Insight 可以捕获 Web 应用程序事件，我们将之称为*跟踪*。跟踪表示一系列执行过程。它通常从 HTTP 请求开始，但也可以从后台作业开始。跟踪包含各种操作，表示跟踪执行过程中的重要时刻，例如，JDBC 查询或事务提交。Insight 使用跟踪数据计算汇总信息，并向您解释为什么您的应用程序无法运行以及应该如何运行的详细情况。

有关使用 Spring Insight 以及如何解释和过滤所显示的性能信息的详细信息，请参阅[使用 Spring Insight](http://pubs.vmware.com:8080/vfabric5/topic/com.vmware.vfabric.tc-server.2.6/operations/using-browsing-resources.html)。虽然该文件特别适用于运行在非 Cloud Foundry 环境中的 Spring Insight（如一个独立的 TC 运行时实例），但是 **Browse Resources**、**Recent Activity** 和 **Administration** 选项卡的用法却很相似。

**副标题**

+ [在您的 Cloud Foundry 帐户中安装 Spring Insight 并启用您的应用程序](#installing-spring-insight-in-your-cloud-foundry-account-and-enabling-your-applications)
+ [Spring Insight 如何配合 Cloud Foundry 一起工作](#how-spring-insight-works-with-cloud-foundry)
+ [Spring Insight 对 Cloud Foundry 配额的影响](#spring-insights-impact-on-cloud-foundry-quotas)
+ [配置应用程序和 Insight 内存设置](#configuring-application-and-insight-memory-settings)

##在您的 Cloud Foundry 帐户中安装 Spring Insight 并启用您的应用程序

*  在您的浏览器中，访问 [Spring Insight for Cloud Foundry](http://insight.cloudfoundry.com/) 网站并使用您的 Cloud Foundry 凭据登录。

    首次登录时，Spring Insight 会自动将自己安装到您的 Cloud Foundry 帐户，然后创建并绑定到一个 RabbitMQ 服务实例。这需要几秒钟时间。当安装完成后，您将被重定向到自己的个人 Spring Insight 仪表板，其中列出了已经部署到 Cloud Foundry 的所有的应用程序：

    ![insight-cf-app.png](/images/screenshots/spring-insight/insight-cf-app.png “insight 仪表板”)

    当您随后浏览并登录到 [Spring Insight for Cloud Foundry](http://insight.cloudfoundry.com/) 网站，您将被自动重定向到您的仪表板。

    **Cloud Foundry > Applications** 屏幕上列出已部署的应用程序；默认情况下，每一个应用程序均已禁用 Spring Insight。

*  要为应用程序启用 Insight，请在左侧列表单击其名称，然后在右框中单击 `enable`（参见上图中的 ＃2）。在后台，Insight 将安装一个代理并将其关联到您的应用程序。

    目前，只能为 Spring Insight 启用 Java、Spring 和 Grails Web 应用程序。您将知道是否可以为 Spring Insight 启用已部署的应用程序，因为在列表中它的旁边会有一个叶子图标（参见上图中的 ＃1）。

*  单击 **Cloud Foundry > Environment** 选项卡以查看有关您的 Cloud Foundry 帐户中可用和已置备的服务实例的信息。Spring Insight 本身已绑定到已置备的 RabbitMQ 服务实例，如下图所示：

    ![insight-cf-env.png](/images/screenshots/spring-insight/insight-cf-env.png “insight 仪表板环境”)

*  要真正开始使用 Spring Insight，以监控应用程序的性能，请单击 **Browse Resources** 选项卡。该屏幕显示您的应用程序的整体运行状况。注意，只有已为 Insight 启用并且近期已经发生一些活动的应用程序才会显示在左侧列表中。

    单击 **Recent Activity** 选项卡可查看与您的应用程序关联的近期跟踪记录，以便对这些记录进行进一步的分析。

有关使用 Spring Insight 以及如何解释和过滤所显示的性能信息的详细信息，请参阅[使用 Spring Insight](http://pubs.vmware.com:8080/vfabric5/topic/com.vmware.vfabric.tc-server.2.6/operations/using-browsing-resources.html)。

##Spring Insight 如何配合 Cloud Foundry 一起工作

当您在 Cloud Foundry 帐户中安装 Spring Insight 时，Insight 会显示已​​部署的应用程序，就像您以前部署的任何其他应用程序一样。它的名称是 `Insight-<id>`，其中 `id` 是唯一标识符。您可以像其他任何应用程序一样管理 Insight 应用程序，包括用 `vmc delete` 命令将其删除。这样做的结果就是会删除仪表板；您可以使用上述步骤重新创建仪表板。

当您为 Spring Insight 启用其中一个部署的应用程序时，Insight 会像服务一样将自身绑定到您的应用程序，并在您执行 `vmc apps` 时进行相应的显示。例如：

```bash
$prompt vmc apps

+----------------+----+---------+---------------------------------+-----------------+
| Application    | #  | Health  | URLS                            | Services        |
+----------------+----+---------+---------------------------------+-----------------+
| Insight-18fe44 | 1  | RUNNING | insight-18fe44.cloudfoundry.com | Insight-18fe441 |
| hello          | 1  | RUNNING | hello-js.cloudfoundry.com       |                 |
| hotels         | 1  | RUNNING | hotels-js.cloudfoundry.com      | Insight-18fe441 |
+----------------+----+---------+---------------------------------+-----------------+

```

Insight 应用程序会使用 RabbitMQ 服务实例，您也可以通过执行 `vmc services` 查看此实例。例如：

```bash
$prompt vmc services

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

+-----------------+----------+
| Name            | Service  |
+-----------------+----------+
| Insight-18fe441 | rabbitmq |
+-----------------+----------+

```

## Spring Insight 对 Cloud Foundry 配额的影响

Insight 仪表板是一种安装在您的 Cloud Foundry 帐户上的 Web 应用程序。从配额方面考虑，可以将其视作一个应用程序，并使用 512 MB 内存。

Spring Insight 还置备一个 RabbitMQ 服务实例，Insight 代理可使用该实例与 Insight 仪表板进行通信。RabbitMQ 服务可以充当 Cloud Foundry 配额的一种服务。

最后，您已为 Insight 启用的每个应用程序将需要额外的内存。虽然这会因负载和使用方法而异，但 Cloud Foundry 建议，当您部署一个要使用 Insight 监控的应用程序时，您应至少使用 256 MB 内存配额。

##配置应用程序和 Insight 内存设置

在确定您的应用程序使用多少内存时，Cloud Foundry 会使用相应进程的 RSS（驻留集大小）。如果 RSS 增长量超过您的应用程序配置的内存阈值，Cloud Foundry 将会停止或取消该应用程序。这在 Java 中具有特殊的意义，因为应用程序的最大堆使用量通常远低于 RSS。

为避免出现超过 RSS 但未达到最大堆使用量的情况，请增加为您的应用程序分配的内存，或减小其堆大小。

例如，如果您的应用程序运行时会占用约 256 MB 内存，但未达到此限制，请使用下面的 `vmc` 命令来更改内存设置：

```bash
prompt$ vmc mem my-application 300m
prompt$ vmc env-add my-application INSIGHT_OVERRIDES="-Xmx200m"
```

请注意，这种内存设置修改不是 Insight 所特有的；Cloud Foundry 会取消未达到其最大堆限制的常用 Java 应用程序。但是，由于依赖于堆以外、PermGen 上和代码缓存中的 JVM 数据结构，Insight 支持的应用程序更容易达到这些限制。


