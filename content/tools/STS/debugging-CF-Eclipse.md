---
title: 使用 Cloud Foundry Integration for Eclipse 调试应用程序
description: 使用 Cloud Foundry Integration for Eclipse 调试应用程序
tags:
    - eclipse
    - sts
---

## 调试应用程序

   使用调试支持部署到 Micro Cloud Foundry 或本地云的应用程序也会启用调试功能，如
   在调试模式下启动应用程序或将在调试模式下运行的应用程序连接到 Eclipse 调试程序。

   ![通过编辑器调试](/images/screenshots/configuring-STS/cf_eclipse_editor_debug.png)

   对于在调试模式下运行的应用程序，应用程序可以重新启动或更新，并在**调试**或**运行**模式下重新启动，其方法如下：
   使用 **Restart** 和 **Update and Restart** 按钮旁的下拉菜单。
   按钮图标和悬停工具提示文本指示应用程序目前正在哪种模式下运行。

   ![调试更新与重启](/images/screenshots/configuring-STS/cf_eclipse_editor_updaterestart_debug.png)

   如果应用程序已经在调试模式下运行，但没有连接到本地调试程序，则编辑器允许用户
   连接到调试程序，而无需通过 **Connect to Debugger** 按钮重新启动应用程序。

   ![连接调试程序](/images/screenshots/configuring-STS/cf_eclipse_editor_connect_to_debugger.png)

   如果 Eclipse Debug 视图中的应用程序已断开与本地调试程序的连接，它将继续以
   调试模式在 Cloud Foundry 目标中运行，直到它被停止或从 Cloud Foundry 目标中删除。

   Cloud Foundry Integration 中的调试行为类似于调试本地应用程序，而且它被集成
   到 Eclipse Debug 透视图中。用户可以设置断点、分步执行代码，并暂停应用程序。

   ![应用程序调试](/images/screenshots/configuring-STS/cf_eclipse_debugging_app.png)

   可以同时调试多个应用程序和同一应用程序的应用程序实例，Debug 视图将按 Cloud Foundry 目标
   名称、应用程序名称和实例 ID 区分每个调试的应用程序实例。

