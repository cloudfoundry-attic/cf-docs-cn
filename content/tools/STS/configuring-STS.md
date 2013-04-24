---
title: 安装 Cloud Foundry Integration for Eclipse
description: 安装 Cloud Foundry Integration Extension for Eclipse 或 STS
tags:
    - eclipse
    - sts
---

如果您使用 Eclipse IDE 或 STS（Spring 工具套件）进行 Java 开发，请安装 Cloud Foundry Integration Extension，以在 Cloud Foundry 中部署应用程序。本文档介绍了如何安装扩展程序，以及如何开始从 Eclipse 或 STS 部署应用程序。

**副标题**

+   [先决条件](#prerequisites)
+   [在 STS 中安装 Cloud Foundry Integration Extension](#installing-the-cloud-foundry-integration-extension-in-sts)
+   [在 Eclipse 中安装 Cloud Foundry Integration Extension](#installing-the-cloud-foundry-integration-extension-in-eclipse)

## 先决条件

必须已安装 Eclipse 或 STS。可以从
以下网站下载安装程序：

+   [Eclipse 下载](http://www.eclipse.org/downloads/)

    确认您已安装**适用于 JEE 开发人员的 Eclipse IDE**，以便满足所有已知的依赖项。
    （在 Eclipse 中，单击 **Help > About Eclipse** 以查看已安装的 Eclipse 的版本）。
    受支持的 Eclipse JEE 最小软件包是 **Indigo**。

+   [Spring 工具套件下载](http://www.springsource.org/sts)

    安装版本 2.9.0 或更高版本。

+   根据 Eclipse 公共许可证 (EPL) 的规定，Cloud Foundry Integration for Eclipse 1.1.0 是目前最新的集成版本，也是第一个
    开源版本。因此，早期版本的 Cloud Foundry Integration，包括版本 2.7.0，
    无法升级到最新版本 1.1.0。用户必须先卸载旧版 Cloud Foundry Integration 才能安装最新
    版本。

## 在 STS 中安装 Cloud Foundry Integration Extension

在 STS 中，按照下列步骤安装 Cloud Foundry Integration Extension。

*  选择 **Help > Dashboard**。

    将会打开 Dashboard。

*  单击 **Extensions** 选项卡。

    STS 会加载扩展名列表。

*  向下滚动到 **Server and Clouds** 类别，然后选择 **Cloud Foundry Integration**。

    ![STS 服务器与云扩展](/images/screenshots/configuring-STS/sts-cf-extension.png)

*  单击 **Install**。

    安装向导将引导您完成安装步骤。

    ![STS Cloud Foundry 安装向导](/images/screenshots/configuring-STS/cf_eclipse_install_wizard.png)

*  Cloud Foundry 提供两个安装选项：
   +  **Core / Cloud Foundry Integration**

      想要使用功能但未扩展 Cloud Foundry Integration 的用户所需的安装。

   + **Resources / Cloud Foundry Integration**

      可选的 Cloud Foundry Integration 源文件 SDK 安装，适用于想要扩展 Cloud Foundry Integration 的用户。
      使用此选项，用户不需要安装 **Core / Cloud Foundry** 安装程序。

*  安装程序完成时，单击 **Yes** 重新启动 STS 或 Eclipse。

## 在 Eclipse 中安装 Cloud Foundry Integration Extension

在 Eclipse 中，按照下列步骤安装 Cloud Foundry Integration Extension。

*  选择 **Help > Eclipse Marketplace**。

    将打开一个显示插件和附加组件的面板。

*  在 **Find** 字段中，输入“cloud foundry”，然后单击 **Go**。

    ![Eclipse 扩展安装](/images/screenshots/configuring-STS/cf_eclipse_marketplace.png)

*  在搜索结果中，选择“Cloud Foundry Integration for Eclipse”，然后单击 **Install**。

    Eclipse 会检查资源和依赖项。

*  单击 **Next** 开始安装。

    安装向导将引导您完成许可接受和安装步骤。

*  安装完成时，重新启动 Eclipse。

    您现在便可以连接到 Cloud Foundry 云。

## 接下来的步骤

+ [部署应用程序和绑定服务](/tools/STS/deploying-CF-Eclipse.html)
+ [调试](/tools/STS/debugging-CF-Eclipse.html)
+ [远程文件访问](/tools/STS/remote-CF-Eclipse.html)



