---
title: Node.js 与 MongoDB 一起使用
description: 与 MongoDB 服务相关的 Node.js 开发
tags:
    - mongodb
    - nodejs
---

开始使用前，请审核是否具备以下先决条件：

+	[Cloud Foundry 帐户](http://cloudfoundry.com/signup) 和 [vmc](/tools/vmc/installing-vmc.html)

+	您的开发计算机上已安装 [Node.js](http://nodejs.org/)

+	您的开发计算机上已安装开源的 NoSQL 数据库 [MongoDB](http://www.mongodb.org)

请参见[与 Cloud Foundry 相关的 Node.js 应用程序开发](/frameworks/nodejs/nodejs.html)，查看关于部署 Node.js 应用程序的首个教程。

## 使用 Cloud Foundry MongoDB 服务

MongoDB 是一种可扩展的、开源的、面向文档的数据库，并作为 Cloud Foundry 的服务被提供。此部分描述了如何创建使用此服务的 Node.js 应用程序。示例中的代码不仅可在 Cloud Foundry 上运行和测试，还可在本地运行和测试。
可在 [GitHub](https://github.com/gatesvp/cloudfoundry_node_mongodb) 中找到这些示例。

### 安装

使用以下命令在您的本地环境中启动 `mongod`：

``` bash
$ mongod
```

确认 Node.js 已正确安装:

+	运行 `node` 以启动交互式 Javascript 控制台：

```bash
$ node
```

按 `Control-C` 退出。

+	检查是否已安装 Node 包管理器 (NPM)：

```bash
$ npm -v
1.0.6
```

选择 Cloud Foundry 作为目标并用您的 Cloud Foundry 凭据登录：

``` bash
$ vmc target api.cloudfoundry.com
$ vmc login
```

### 为 Cloud Foundry 创建一个有效的 Node.js 应用程序

在此步骤中，您需创建一个基本应用程序并确保其在本地和 Cloud Foundry 上正常工作。

注意：
在此整个教程中，我们称此应用程序为“mongo-node”。当您部署至 Cloud Foundry 时，您必须使用一个不同的、唯一的名称。

创建一个应用程序目录并对其进行修改：

``` bash
$ mkdir mongo-node
$ cd mongo-node
```

创建包含以下代码的一个 `app.js` 文件：

``` javascript
var port = (process.env.VMC_APP_PORT || 3000);
var host = (process.env.VCAP_APP_HOST || 'localhost');
var http = require('http');

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World\n');
}).listen(port, host);
```

这样将使用端口 3000 在 localhost 上创建一个 Node.js Web 服务器，其将响应带有“Hello World”字符串的任意 HTTP 请求。

本地启动 Node.js Web 服务器：

``` bash
$ node app.js
```

在另一个终端窗口中发送一个请求：

``` bash
$ curl localhost:3000
Hello World
```

或者，浏览 http://localhost:3000 以查看 Web 服务器的响应。

在第一个终端窗口中按 `Control-C` 以停止 Web 服务器。

推送应用程序至 Cloud Foundry。除了输入应用程序的唯一名称，按 `Enter` 接受默认设置，并按照以下 vmc 脚本所示设置 mongodb 服务：

```bash
$ vmc push
    Would you like to deploy from the current directory? [Yn]:
    Application Name: mongo-node
    Application Deployed URL [mongo-node.cloudfoundry.com]:
    Detected a Node.js Application, is this correct? [Yn]:
    Memory Reservation (64M, 128M, 256M, 512M, 1G) [64M]:
    Creating Application: OK
    Would you like to bind any services to 'mongo-node'? [yN]: y
    The following system services are available
    1: mongodb
    2: mysql
    3: postgresql
    4: rabbitmq
    5: redis
    Please select one you wish to provision: 1
    Specify the name of the service [mongodb-e840e]:
    Creating Service: OK
    Binding Service [mongodb-e840e]: OK
    Uploading Application:
      Checking for available resources: OK
      Packing application: OK
      Uploading (0K): OK
    Push Status: OK
    Staging Application: OK
    Starting Application: OK
```

Cloud Foundry 暂存和启动您的应用程序。

测试应用程序。

``` bash
$ curl mongo-node.cloudfoundry.com
	Hello World
```

### 添加 MongoDB 配置

在先前步骤中，您已部署了应用程序并将其与 Cloud Foundry mongodb 服务捆绑，尽管应用程序尚未使用此服务。

在此步骤中，无论应用程序是本地运行还是在云上运行，您都将更新应用程序以设置 MongoDB 连接信息和凭据。

* 在 `app.js` 的开始处添加以下代码：

``` javascript

if(process.env.VCAP_SERVICES){
  var env = JSON.parse(process.env.VCAP_SERVICES);
  var mongo = env['mongodb-2.0'][0]['credentials'];
}
else{
  var mongo = {
    "hostname":"localhost",
    "port":27017,
    "username":"",
    "password":"",
    "name":"",
    "db":"db"
  }
}

var generate_mongo_url = function(obj){
  obj.hostname = (obj.hostname || 'localhost');
  obj.port = (obj.port || 27017);
  obj.db = (obj.db || 'test');

  if(obj.username && obj.password){
    return "mongodb://" + obj.username + ":" + obj.password + "@" + obj.hostname + ":" + obj.port + "/" + obj.db;
  }
  else{
    return "mongodb://" + obj.hostname + ":" + obj.port + "/" + obj.db;
  }
}

var mongourl = generate_mongo_url(mongo);
```

根据应用程序是运行在云上还是本地运行，`if` 语句提供了两个信息集合。`generate_mongo_url` 可为 MongoDB 创建合适的连接信息，然后将给信息分配给 mongourl。

* 本地测试应用程序：

``` bash
$ node app.js
```

* 在另一终端中：

``` bash
$ curl localhost:3000
```

应用程序返回字符串“Hello World”。

* 更新已部署的云应用程序：

``` bash
$ vmc update mongo-node
    Uploading Application:
      Checking for available resources: OK
      Packing application: OK
      Uploading (1K): OK
    Push Status: OK
    Stopping Application: OK
    Staging Application: OK
    Starting Application: OK
```

* 测试已部署的应用程序：

```bash
$ curl mongo-node.cloudfoundry.com
    Hello World
```

### 添加 MongoDB 功能

接着，本地安装 MongoDB 本机驱动程序和更新应用程序以使用 MongoDB 。

* 本地安装 MongoDB 本机驱动程序：

``` bash
$ npm install mongodb
```

这样将在应用程序的根中创建一个新的本地目录 `node_modules`。

* 在 `app.js` 中，创建一个新函数 record_visit 以存储服务器对 MongoDB 的请求：

``` javascript
var record_visit = function(req, res){
  /* Connect to the DB and auth */
  require('mongodb').connect(mongourl, function(err, conn){
    conn.collection('ips', function(err, coll){
      /* Simple object to insert: ip address and date */
      object_to_insert = { 'ip': req.connection.remoteAddress, 'ts': new Date() };

      /* Insert the object then print in response */
      /* Note the _id has been created */
      coll.insert( object_to_insert, {safe:true}, function(err){
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.write(JSON.stringify(object_to_insert));
        res.end('\n');
      });
    });
  });
}
```

`.connect` 方法使用本地或 Cloud Foundry mongourl 方式连接 MongoDB。
然后，`.collection('ips', ...)` 方法把请求信息添加到将被交付的数据中。

* 更新 `http.createServer` 方法，使它在服务器请求被发出时调用 `record_visit` 函数。

``` javascript
    http.createServer(function (req, res) {
        record_visit(req, res);
    }).listen(port, host);
```

* 本地测试应用程序：

``` bash
$ node app.js
```

从另一终端：

``` bash
$ curl localhost:3000
    {"ip":"127.0.0.1","ts":"2011-12-29T23:22:38.192Z","_id":"4efcf63ecab9a5b41e000001"}
```

在第一个终端中按 Control-C 以停止 Web 服务器。

* 测试 Cloud Foundry 上的应用程序：

``` bash
$ vmc update mongo-node
$ curl appname.cloudfoundry.com
    {"ip":"127.0.0.1","ts":"2011-12-29T23:24:25.199Z","_id":"4efcf6a927996b5f79000001"}
```

* 创建函数 `print_visits` 以打印最后十次访问/请求信息：

``` javascript
var print_visits = function(req, res){
/* Connect to the DB and auth */
require('mongodb').connect(mongourl, function(err, conn){
    conn.collection('ips', function(err, coll){
        coll.find({}, {limit:10, sort:[['_id','desc']]}, function(err, cursor){
            cursor.toArray(function(err, items){
                res.writeHead(200, {'Content-Type': 'text/plain'});
                for(i=0; i<items.length;i++){
                    res.write(JSON.stringify(items[i]) + "\n");
                }
                res.end();
            });
        });
    });
});
}
```

* 更新 `createServer` 方法以调用新的 `print_visits` 函数：

``` javascript

http.createServer(function (req, res) {
    params = require('url').parse(req.url);
    if(params.pathname === '/history') {
        print_visits(req, res);
    }
    else{
        record_visit(req, res);
    }
}).listen(port, host);
```

Web 服务器请求将把当前访问添加至 MongoDB（默认情况），或者，
若 URL 中包含“/history”,则输出最后十次访问。

* 本地测试应用程序：

``` bash
$ curl localhost:3000
    {"ip":"127.0.0.1","ts":"2011-12-29T23:44:30.254Z","_id":"4efcfb5e2f9d30481f000003"}
$ curl localhost:3000/history
    {"ip":"127.0.0.1","ts":"2011-12-29T23:44:30.254Z","_id":"4efcfb5e2f9d30481f000003"}
    {"ip":"127.0.0.1","ts":"2011-12-29T23:31:39.339Z","_id":"4efcf85b2f9d30481f000002"}
    {"ip":"127.0.0.1","ts":"2011-12-29T23:31:26.678Z","_id":"4efcf84e2f9d30481f000001"}
    {"ip":"127.0.0.1","ts":"2011-12-29T23:22:38.192Z","_id":"4efcf63ecab9a5b41e000001"}
```

* 本地停用应用程序，并在 Cloud Foundry 上更新它。

``` bash
$ vmc update mongo-node
    Uploading Application:
      Checking for available resources: OK
      Processing resources: OK
      Packing application: OK
      Uploading (8K): OK
    Push Status: OK
    Stopping Application: OK
    Staging Application: OK
    Starting Application: OK
```

* 测试应用程序的云版本。

``` bash
$ curl mongo-node.cloudfoundry.com/history
    {"ip":"127.0.0.1","ts":"2011-12-29T23:49:46.738Z","_id":"4efcfc9acbfffadc0b000001"}
    {"ip":"127.0.0.1","ts":"2011-12-29T23:24:25.199Z","_id":"4efcf6a927996b5f79000001"}
```

