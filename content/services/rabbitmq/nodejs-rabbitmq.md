---
title: Node.js 与 RabbitMQ 一起使用
description: 与 RabbitMQ 服务相关的 Node.js 应用程序开发
tags:
    - nodejs
    - rabbitmq
    - 教程
---

Node.js 是一个靠事件驱动的、可扩展的、基于 JavaScript 平台的网络应用程序。Cloud Foundry 提供了适合 Node.js 应用程序的运行时环境，并且 Cloud Foundry 部署工具可识别 Node.js 应用程序。

RabbitMQ 是可为您的应用程序提供稳健的消息传递服务的消息代理。

该指南适用于正在使用 Cloud Foundry RabbitMQ 服务的 Node.js 开发人员。该指南演示了如何在您的应用程序中访问 Cloud Foundry RabbitMQ 服务。

请参见[与 Cloud Foundry 相关的 Node.js 应用程序开发](/frameworks/nodejs/nodejs.html)，查看关于部署 Node.js 应用程序的首个教程。

### 安装

确认 Node.js 已正确安装:

运行 node 以启动交互式 Javascript 控制台：按两次 `Control-C` 退出。

```bash
$ node
```

检查是否已安装 Node 包管理器 (NPM)。在命令行中：

```bash
$ npm -v
1.0.6
```

选择 Cloud Foundry 作为目标并用您的 Cloud Foundry 凭据登录：

```bash
$ vmc target api.cloudfoundry.com
$ vmc login
```

### 创建应用程序文件

创建一个应用程序目录并对其进行修改：

```bash
$ mkdir rabbitmq-node
$ cd rabbitmq-node
```

使用以下的内容创建文件 `package.json`：

``` javascript
{
    "name":"node-amqp-demo",
    "version":"0.0.1",
    "dependencies": {
        "amqp":">= 0.1.0",
        "sanitizer": "*"
    }
}
```

此 `package.json` 文件指定了两个互相依赖的库：用于消息处理的 amqp 和用于删除 HTML 消息的粉碎工具。

安装依赖项，使用 npm（Node 包管理器）：

```bash
$ npm install
```

使用以下代码创建 `app.js`：

``` javascript
var http = require('http');
var amqp = require('amqp');
var URL = require('url');
var htmlEscape = require('sanitizer/sanitizer').escape;

function rabbitUrl() {
  if (process.env.VCAP_SERVICES) {
    conf = JSON.parse(process.env.VCAP_SERVICES);
    return conf['rabbitmq-2.4'][0].credentials.url;
  }
  else {
    return "amqp://localhost";
  }
}

var port = process.env.VCAP_APP_PORT || 3000;

var messages = [];

function setup() {

  var exchange = conn.exchange('cf-demo', {'type': 'fanout', durable: false}, function() {

    var queue = conn.queue('', {durable: false, exclusive: true},
    function() {
      queue.subscribe(function(msg) {
        messages.push(htmlEscape(msg.body));
        if (messages.length > 10) {
          messages.shift();
        }
      });
      queue.bind(exchange.name, '');
    });
    queue.on('queueBindOk', function() { httpServer(exchange); });
  });
}

function httpServer(exchange) {
  var serv = http.createServer(function(req, res) {
    var url = URL.parse(req.url);
    if (req.method == 'GET' && url.pathname == '/env') {
      printEnv(res);
    }
    else if (req.method == 'GET' && url.pathname == '/') {
      res.statusCode = 200;
      openHtml(res);
      writeForm(res);
      writeMessages(res);
      closeHtml(res);
    }
    else if (req.method == 'POST' && url.pathname == '/') {
      chunks = '';
      req.on('data', function(chunk) { chunks += chunk; });
      req.on('end', function() {
        msg = unescapeFormData(chunks.split('=')[1]);
        exchange.publish('', {body: msg});
        res.statusCode = 303;
        res.setHeader('Location', '/');
        res.end();
      });
    }
    else {
      res.statusCode = 404;
      res.end("This is not the page you were looking for.");
    }
  });
  serv.listen(port);
}

console.log("Starting ... AMQP URL: " + rabbitUrl());
var conn = amqp.createConnection({url: rabbitUrl()});
conn.on('ready', setup);

// ---- helpers

function openHtml(res) {
  res.write("<html><head><title>Node.js / RabbitMQ demo</title></head><body>");
}

function closeHtml(res) {
  res.end("</body></html>");
}

function writeMessages(res) {
  res.write('<h2>Messages</h2>');
  res.write('<ol>');
  for (i in messages) {
    res.write('<li>' + messages[i] + '</li>');
  }
  res.write('</ol>');
}

function writeForm(res) {
  res.write('<form method="post">');
  res.write('<input name="data"/><input type="submit"/>');
  res.write('</form>');
}

function printEnv(res) {
  res.statusCode = 200;
  openHtml(res);
  for (entry in process.env) {
    res.write(entry + "=" + process.env[entry] + "<br/>");
  }
  closeHtml(res);
}

function unescapeFormData(msg) {
  return unescape(msg.replace('+', ' '));
}
```

推送应用程序至 Cloud Foundry。对于大多数提示，您可以按 `Enter` 接受默认值。
在应用程序名称提示框中，输入唯一的应用程序名称。而且，确保按照以下脚本所示，创建和捆绑一个 rabbitmq 服务。

```bash
$ vmc push
	Would you like to deploy from the current directory? [Yn]:
	Application Name: rabbitmq-node
	Application Deployed URL [rabbitmq-node.cloudfoundry.com]:
	Detected a Node.js Application, is this correct? [Yn]:
	Memory Reservation (64M, 128M, 256M, 512M) [64M]:
	Creating Application: OK
	Would you like to bind any services to 'rabbitmq-node'? [yN]: y
	Would you like to use an existing provisioned service? [yN]: n
	The following system services are available
	1: mongodb
	2: mysql
	3: postgresql
	4: rabbitmq
	5: redis
	Please select one you wish to provision: 4
	Specify the name of the service [rabbitmq-6c981]:
	Creating Service: OK
	Binding Service [rabbitmq-6c981]: OK
	Uploading Application:
	  Checking for available resources: OK
	  Processing resources: OK
	  Packing application: OK
	  Uploading (1K): OK
	Push Status: OK
	Staging Application: OK
	Starting Application: OK

```

使用浏览器在指定的 URL 上访问应用程序。在表单中输出消息，看到它们在浏览器中得到回应。

![RabbitMQ 与 Node.js 应用程序](/images/screenshots/nodejs-rabbitmq/rmq-app.png)


