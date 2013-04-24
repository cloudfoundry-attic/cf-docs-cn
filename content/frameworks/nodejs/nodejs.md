---
title: Node.js
description: 利用 Cloud Foundry 开发 Node.js 应用程序
tags:
    - nodejs
    - express
    - 教程
---

本文为从事 Cloud Foundry 部署的 Node.js 开发人员提供指导，介绍如何在 Cloud Foundry 上设置并成功部署 Node.js 应用程序。

Node.js 是一个靠事件驱动的、可扩展的、基于 JavaScript 平台的网络应用程序。Cloud Foundry 提供了适合 Node.js 应用程序的运行时环境，并且 Cloud Foundry 部署工具可自动识别 Node.js 应用程序。

开始前请做好以下准备：

+	一个 [Cloud Foundry 帐户](http://cloudfoundry.com/signup)

+	[vmc](/tools/vmc/installing-vmc.html) Cloud Foundry 命令行工具

+	[Node.js](http://nodejs.org/) 安装程序与 Cloud Foundry 实例上的 Node.js 版本匹配。请参见后面的[检查 Cloud Foundry 实例上的 NodeJS 版本](#checking-the-nodejs-version-on-your-cloud-foundry-instance)。

## 在 Cloud Foundry 中部署 Node.js 应用程序

在 Cloud Foundry 中部署 Node.js 应用程序时，当前目录必须包含该应用程序、`app.js` 和对其进行命名的 `package.json` 文件（如果您的应用程序依赖于任何模块的话）。

使用 [Express](http://expressjs.com) Web 模块创建和部署“hello world”Node.js Web 服务器应用程序的步骤如下：

### 创建应用程序

创建应用程序的目录并对其进行修改。

``` bash
$ mkdir hello-node
$ cd hello-node
```

使用 `npm`（Node 包管理器）安装 Express 模块：

```bash
$ npm install express
```

使用以下代码创建文件 `app.js`：
```javascript

var app = require('express').createServer();
app.get('/', function(req, res) {
    res.send('Hello from Cloud Foundry');
});
app.listen(3000);

```


使用以下内容创建 `package.json` 文件：

```javascript
{
 "name":"hello-node",
  "version":"0.0.1",
  "dependencies":{
      "express":""
  }
}

```

### 部署应用程序

选择 Cloud Foundry 作为目标并用您的 Cloud Foundry 凭据登录：

```bash
$ vmc target api.cloudfoundry.com
$ vmc login
```

推送应用程序。在大部分提示下都可以按 `Enter` 接受默认设置，但一定要为应用程序输入一个唯一的 URL。下面是一个推送的示例：

``` bash
$ vmc push
	Would you like to deploy from the current directory? [Yn]:
	Application Name: hello-node
	Application Deployed URL [hello-node.cloudfoundry.com]:
	Detected a Node.js Application, is this correct? [Yn]:
	Memory Reservation (64M, 128M, 256M, 512M, 1G) [64M]:
	Creating Application: OK
	Would you like to bind any services to 'hello-node'? [yN]:
	Uploading Application:
	  Checking for available resources: OK
	  Packing application: OK
	  Uploading (0K): OK
	Push Status: OK
	Staging Application: OK
	Starting Application: ................ OK
```

根据指定的 URL（本例中为 [http://hello-node.cloudfoundry.com](http://hello-node.cloudfoundry.com)）通过浏览器访问应用程序。

## 更改应用程序使用的 Node 的版本

您可以使用运行时标志并送入所需的运行时。关于如何列出运行时，请参见下一部分

使用 Node 0.6.8 的示例

```bash
vmc push --runtime=node06
```

## 检查 Cloud Foundry 示例上的 Node.js 版本

为获得最佳开发体验，我们建议您在本地机器上使用与目标 Cloud Foundry 实例相同的 Node.js 版本。

要查看您 Cloud Foundry 实例上使用什么版本的 Node.js，请运行此命令：

``` bash
$ vmc runtimes

+--------+-------------+-----------+
| Name   | Description | Version   |
+--------+-------------+-----------+
| java   | Java 6      | 1.6       |
| ruby18 | Ruby 1.8    | 1.8.7     |
| ruby19 | Ruby 1.9    | 1.9.2p180 |
| node   | Node.js     | 0.4.12    |
| node06 | Node.js     | 0.6.8     |
| node08 | Node.js     | 0.8.2     |
+--------+-------------+-----------+

```

+ 然后从[此处](https://github.com/joyent/node/tags) 下载特定的 Node.js 版本。
+ 对其进行解压缩。
+ 按照 README 文件中的说明对其进行安装。

## 接下来的步骤

+	在 Node.js 应用程序中[使用 Cloud Foundry MongoDB 服务](/services/mongodb/nodejs-mongodb.html)
+	在 Node.js 中[使用 Cloud Foundry RabbitMQ 服务](/services/rabbitmq/nodejs-rabbitmq.html)


