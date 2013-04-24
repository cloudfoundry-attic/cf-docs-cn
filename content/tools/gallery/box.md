---
title: Box 集成
description: 通过库进行应用程序部署的示例
tags:
    - 第三方服务
    - 附代码
    - boilerplate 示例
---

[Box Ruby 示例应用程序](https://github.com/cloudfoundry-samples/box-sample-ruby-app)的界面已经过重新设计，可与 Box 上内容进行交互。
它演示了 API 各种主要功能的用法，包括文件上传/下载、
帐户树查看、文件预览等。

Box 已与 CloudFoundry 结合使用，从而可以通过 Box App Editing Wizard 直接部署这款示例应用程序

## 入门
1. [在此处](http://www.box.net/developers/services)注册为 Box 开发人员
2. 创建第一款应用程序或编辑现有的应用程序

## 部署 Box 示例应用程序
1. 在 Cloud Services 菜单中，单击 Cloud Foundry 图标
  ![cloud_services.png](/images/screenshots/box/cloud_services.png)
2. 单击弹出窗口中的“Create My App”
  ![box-cf-1.png](/images/screenshots/box/box-cf-1.png)
3. 单击“Deploy my App”
  ![box-cf-2.png](/images/screenshots/box/box-cf-2.png)
4. 登录 Cloud Foundry
  ![cf-login.png](/images/screenshots/box/cf-login.png)
5. 单击橙色部署按钮以部署 box-sample-ruby-app
  ![box-deploy.png](/images/screenshots/box/box-deploy.png)
6. 等待 5 秒钟后，将会出现 Box 登录屏幕
  ![box-cf-success.png](/images/screenshots/box/box-cf-success.png)

## 测试 Box 示例应用程序
1. 授权您的示例应用程序通过登录 Box 访问 Box 数据
  ![box-sample-app-login.png](/images/screenshots/box/box-sample-app-login.png)

2. 现在，您应该看到一个带有“Add Folder” 和“Add File”按钮的网页。
3. 详细查看您的文件夹，并确认您放入的文件可用。添加另一个文件或两个文件。
  ![box-add-file.png](/images/screenshots/box/box-add-file.png)

## 对应用程序的工作原理进行更改

* 访问 GitHub 上的 [box-sample-ruby-app](https://github.com/cloudfoundry-samples/box-sample-ruby-app)
* 将其放入您自己的 GitHub repo 并将其克隆到您的计算机
* [安装 VMC](/tools/vmc/installing-vmc.html)，如果尚未安装。
* 按照 box-sample-ruby-app repo 中的 README 上的说明对代码进行更改并在本地进行测试
* 使用 `vmc update <app_name>` 对 Cloud Foundry 进行更改
* 有关 VMC 命令的详细信息，请参见 [VMC 快速参考指南](/tools/vmc/vmc-quick-ref.html)


