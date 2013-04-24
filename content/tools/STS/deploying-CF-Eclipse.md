---
title: 使用 Cloud Foundry Integration for Eclipse 部署应用程序
description: 使用 Cloud Foundry Integration for Eclipse 部署应用程序和绑定服务
tags:
    - eclipse
    - sts
---

**副标题**

+   [为 Cloud Foundry 目标定义一个新服务器](#define-a-new-server-for-a-cloud-foundry-target)
+   [将应用程序从 STS 或 Eclipse 部署到 Cloud Foundry](#deploying-applications-to-cloud-foundry-from-sts-or-eclipse)
    +   [定义应用服务](#define-application-services)
    +   [绑定应用服务](#bind-application-services)
+   [更新和重新启动应用程序](#update-and-restart-an-application)

使用 Cloud Foundry Integration for Eclipse 将应用程序部署到 Cloud Foundry 时，必须首先定义 Cloud Foundry 目标。
定义后，它将显示在 Eclipse Servers 视图中，以便用户从 clipse Project Explorer 拖放应用程序，
并将它们部署到选定的 Cloud Foundry 目标。

## 为 Cloud Foundry 目标定义一个新服务器

在 STS 或 Eclipse 中，您需要定义一个新服务器来表示 Cloud Foundry 目标，
然后将应用程序部署到其中。

按照下面的步骤定义新服务器。

*  选择 **Window > Show View > Servers**。

*  单击新服务器向导或右键单击 Servers 视图中的空白区域，然后选择 **New > Server**。

    ![STS 新建服务器](/images/screenshots/configuring-STS/cf_eclipse_empty_servers_view.png)

    将会启动 **Define a New Server** 向导。

*  展开 VMware 文件夹，选择 Cloud Foundry。

    ![STS 新建服务器向导](/images/screenshots/configuring-STS/cf_eclipse_new_cf_server.png)

*  指定要在服务器名称中创建的 Cloud Foundry 服务器实例的显示名称。服务器主机名应
保持 localhost 不变。单击 **Next**。

   ![STS 新建服务器向导帐户](/images/screenshots/configuring-STS/cf_eclipse_new_server_account.png)

*  选择要从 URL 列表中设置的 Cloud Foundry 目标。

    +   **VMware Cloud Foundry**。VMware 托管的开放平台即服务。

    +   **本地云**。VMware Cloud Application Platform (VCAP) 的本地安装。

    +   **Microcloud**。Micro Cloud Foundry 虚拟机。

*  如果已选择 **Microcloud**，请输入
在 http://cloudfoundry.com/micro 中为 Micro Cloud Foundry 注册的域名以及描述性名称。

    ![创建微云目标](/images/screenshots/configuring-STS/sts-mcf-domain-name.png)

*  单击 **OK**。

*  输入 Cloud Foundry 目标的电子邮件地址和密码。

    + 对于 VMware Cloud Foundry 目标，电子邮件必须
    预先在网站上进行注册。**CloudFoundry.com** 注册按钮允许用户预先注册电子邮件帐户。

    + 对于本地云或 Microcloud 目标，请使用
    已注册的电子邮件地址，或输入要注册的新电子邮件和密码，然后单击
    **Register Account...**。

    单击 **Validate Account** 以测试帐户在
    目标 Cloud Foundry 上是否有效。

* 单击 **Finish**。

    新的 Cloud Foundry 目标会显示在 Servers 视图中。

## 将应用程序从 STS 或 Eclipse 部署到 Cloud Foundry

Cloud Foundry Integration Extension 使用 Eclipse Web Tools Project (WTP)
服务器基础架构，该架构用于将 Java Web 应用程序部署到远程
服务器。

部署应用程序包括三个步骤。

+   [定义应用程序详细信息](#define-application-details)
+   [定义应用服务](#define-application-services)
+   [绑定应用服务](#bind-application-services)

仅当应用程序使用 Cloud Foundry
服务（如 MySQL 或 vFabric Postgres 数据库或 RabbitMQ 消息传递）时才需要执行后两个步骤。

## 定义应用程序详细信息

*  在 STS 或 Eclipse 中，选择 **Windows > Show View > Servers** 以显示
Servers 视图。

    ![显示服务器](/images/screenshots/configuring-STS/cf_eclipse_servers_view_cf_server.png)

    当前部署的应用程序（如果存在）将在服务器下方列出。

*  要部署应用程序，请将其拖动到 Servers 视图中的目标 Cloud Foundry 服务器中。

    ![拖拽应用程序](/images/screenshots/configuring-STS/cf_eclipse_drag_drop_app.png)

    或者，您也可以双击该服务器，将会打开 Cloud Foundry 编辑器，允许用户
    将应用程序拖放到 Applications 选项卡中。

    Cloud Foundry Integration Extension 会检查应用程序以确定应用程序类型并验证
    是否已将应用程序部署到选定的 Cloud Foundry 服务器。如果是的话，它会打开一个应用程序详细信息向导，用户可以在其中
    配置应用程序和绑定可选的服务。支持的应用程序类型包括 **Spring**、**Grails**、**Lift** 和 **Java Web**。

    ![应用程序详细信息](/images/screenshots/configuring-STS/cf_eclipse_application_details.png)

*  如果 Integration Extension 未正确识别应用程序的框架，则根据需要更改应用程序的名称，
    ，选择正确的应用程序类型，然后
    单击 **Next**。

    **注意：**
    此处的应用程序名称仅用于识别
    要管理的应用程序。应用程序 URL 中向用户显示的
    名称在该向导的下一个页面中设置。

    ![启动部署](/images/screenshots/configuring-STS/cf_eclipse_application_details_regular_start.png)

*  编辑已部署的 URL，并根据需要更改预留内存。

    在目标 Cloud Foundry 中，已部署的 URL 必须是唯一的。

*  如果需要将服务绑定到应用程序，请单击 **Next** 以在部署之前先将它们绑定，或取消选择 **Start application on
   deployment** 并在部署后通过 Cloud Foundry 服务器编辑器绑定服务。

*  单击 **Finish**，虽然是可选项，但是用户也可以选择 **Next** 在部署前先绑定服务。

    应用程序部署完毕。如果选择 **Start application on deployment**，将会启动该选项，并可通过映射的
    URL 访问。如果使用调试支持部署到 microcloud 或本地云，将会显示在
    **调试**模式下启动应用程序的另一个选项。

    ![启动部署调试](/images/screenshots/configuring-STS/cf_eclipse_application_details_debug_start.png)

*  如果单击 **Next**，则可以将现有服务绑定到应用程序，或者可以定义其他服务，然后进行绑定。

    ![在部署上绑定服务](/images/screenshots/configuring-STS/cf_eclipse_application_deployment_services.png)

*  部署后，在 Servers 视图中，双击该应用程序打开编辑器并显示应用程序统计信息以及
   启动、停止、重新启动、更新并重新启动应用程序的控件，还可以更改应用程序的配置和绑定服务。

    ![应用程序控制面板](/images/screenshots/configuring-STS/cf_eclipse_cf_editor.png)

## 定义应用服务

必须先定义服务，然后才能将服务绑定到已部署的应用程序。Cloud 
Foundry Integration Extension 可从
目标 Cloud Foundry 中获取一个可用服务目录。定义服务后，可以将其绑定到
应用程序。部署期间，可以通过应用程序详细信息向导
将服务绑定到应用程序，如果应用程序已停止运行，也可以在部署后通过 Cloud Foundry 服务器编辑器进行绑定。

按照下面的步骤在编辑器中定义服务。

*  在 Servers 视图中，双击应用程序名称。

    ![STS 应用程序选项卡](/images/screenshots/configuring-STS/cf_eclipse_cf_editor.png)

    Applications 选项卡显示有关 Cloud
    Foundry 目标上应用程序的详细信息。

*  在 Services 部分中，单击 **Add service** 图标。

    ![STS 添加服务](/images/screenshots/configuring-STS/cf_eclipse_editor_services_table.png)

*  为新服务提供名称，并选择服务类型。

    ![STS 服务配置](/images/screenshots/configuring-STS/sts-service-configuration.png)

    **Type** 列表包含
    目标 Cloud Foundry 上所有可用的服务类型。

*  单击 **Finish**。

    插件将从 Cloud Foundry 请求服务，新服务
    会出现在 Services 部分中。

## 绑定应用服务

当您将服务绑定到应用程序时，Cloud Foundry Integration
Extension 会更新应用程序配置文件，以访问所定义的
服务。绑定服务时不得运行应用程序。

*  如果应用程序正在运行，请停止应用程序： 

   + 在 Servers 视图中，右键单击应用程序名称，然后选择 **Stop**，或者
   + 在 Cloud Foundry 服务器编辑器的 Applications 面板中，选择应用程序，然后单击 **Stop** 按钮。

*  在 Applications 面板中，选择要为其绑定
    服务的应用程序。

*  在 Services 面板中选择要绑定的服务，然后将其拖动到
    Application Services 面板中。

    ![STS 绑定服务](/images/screenshots/configuring-STS/cf_eclipse_bind_service.png)

*  单击 **Start** 按钮。


## 更新和重新启动应用程序

Cloud Foundry 编辑器中的 Applications 选项卡允许用户修改应用程序详细信息，如内存、运行的实例数、映射的应用程序 URL，以及启动、停止、重新启动、更新和重新启动应用程序。


   ![常规更新与重启](/images/screenshots/configuring-STS/cf_eclipse_editor_regular_updaterestart.png)

   用户可以重新启动应用程序，而不需要通过 **Restart** 按钮或
   Servers 视图中的上下文菜单操作发布应用程序中的更改，或更新已部署应用程序中的更改并使用 **Update and Restart** 选项重新启动应用程序。

   **Update and Restart** 会以增量方式逐步发布应用程序中的本地更改，并进行优化，以仅推送
   自上次发布以来已经更改的资源。

   停止和启动一个应用程序表明已执行一次完整的发布。



