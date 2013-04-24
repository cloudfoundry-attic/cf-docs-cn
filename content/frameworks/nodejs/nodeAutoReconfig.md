---
title: Node.js 自动重新配置
description: Node.js 自动重新配置功能和常见问题解答
tags:
    - nodejs
    - 自动重新配置
    - redis
    - mongodb
    - mysql
    - postgresql
    - rabbitmq
    - 服务
---
## Node.js 应用程序自动重新配置
Cloud Foundry 能自动配置 Node.js 应用程序，以侦听右端口并连接它绑定的服务。

例如，如果应用程序侦听 localhost:3000 的 Web 请求，并连接了本地 MongoDB mongodb://localhost/myDB，您可以不需要进行任何代码修改直接将其推送给 Cloud Foundry。

为了了解它的作用，让我们看一下自动重新配置前后的区别。

### 端口示例：自动重新配置前

请注意，原来用户需要通过 `process.env.VCAP_APP_PORT` 环境变量获得端口并修改代码
才能使它在 Cloud Foundry 上运行。

```javascript

var http = require('http');
var port = process.env.VCAP_APP_PORT || '3000';
http.createServer(function(req, res){
    res.end('Hello World!');
}).listen(port);

```

### 端口示例：自动重新配置后
现在，通过自动重新配置，用户可以通过一个硬编码端口（本例中为 3000）上传在 localhost 上运行的代码，无需对代码本身进行任何修改。而它仍然可以在 Cloud Foundry 使用！

```javascript

var http = require('http');
http.createServer(function(req, res){
    res.end('Hello World!');
}).listen(3000);

```




现在，让我们以 MongoDB 为例看一下自动配置的功能有多强大。

### MongoDB 示例：自动重新配置前
从下面示例可以看出，当应用程序在 Cloud Foundry 和 localhost 同时运行时，要确定 MongoDB 的 URL 需要使用非常繁琐的 `generate_mongo_url` 函数。

```javascript

var port = (process.env.VMC_APP_PORT || 3000);
var host = (process.env.VCAP_APP_HOST || 'localhost');
var http = require('http');

if(process.env.VCAP_SERVICES){
  var env = JSON.parse(process.env.VCAP_SERVICES);
  var mongo = env['mongodb-2.0'][0]['credentials'];
}
else {
  var mongo = {
    "hostname":"localhost",
    "port":27017,
    "username":"",
    "password":"",
    "name":"",
    "db":"test"
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
console.log(mongourl);

http.createServer(function (req, res) {
  params = require('url').parse(req.url);
  if(params.pathname === '/history') {
    print_visits(req, res);
  }
  else{
    record_visit(req, res);
  }
}).listen(port, host);

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

var print_visits = function(req, res){
  /* Connect to the DB and auth */
  require('mongodb').connect(mongourl, function(err, conn){
    conn.collection('ips', function(err, coll){
      /*find with limit:10 & sort */
      coll.find({}, {limit:10, sort:[['_id','desc']]}, function(err, cursor){
        cursor.toArray(function(err, items){
          res.writeHead(200, {'Content-Type': 'text/plain'});
          for(i=0; i < items.length; i++){
            res.write(JSON.stringify(items[i]) + "\n");
          }
          res.end();
        });
      });
    });
  });
}

```


### MongoDB 示例：自动重新配置后

而有了自动重新配置，用户不需要添加代码就能确定 MongoDB 的 URL。他们只需把 localhost 上运行的代码上传 Cloud Foundry 即可达到目的。

备注：请注意，`var mongoUrl = 'mongodb://localhost:27017/test';` 仍然指向 localhost 上的 MongoDB，而 `generate_mongo_url` 则不见了。


```javascript

var http = require('http');

//With auto-reconfig, we don't have to change localhost's MongoDB url
var mongoUrl = 'mongodb://localhost:27017/test';

http.createServer(function (req, res) {
  params = require('url').parse(req.url);
  if(params.pathname === '/history') {
    print_visits(req, res);
  }
  else{
    record_visit(req, res);
  }
}).listen(3000);

var record_visit = function(req, res){
  /* Connect to the DB and auth */
  require('mongodb').connect(mongoUrl, function(err, conn){
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

var print_visits = function(req, res){
  /* Connect to the DB and auth */
  require('mongodb').connect(mongourl, function(err, conn){
    conn.collection('ips', function(err, coll){
      /*find with limit:10 & sort */
      coll.find({}, {limit:10, sort:[['_id','desc']]}, function(err, cursor){
        cursor.toArray(function(err, items){
          res.writeHead(200, {'Content-Type': 'text/plain'});
          for(i=0; i < items.length; i++){
            res.write(JSON.stringify(items[i]) + "\n");
          }
          res.end();
        });
      });
    });
  });
}

```

### 在后台

在部署过程中暂存您的应用程序时，Cloud Foundry 将做出以下两项修改：

* 它为应用程序提供 [cf-autoconfig](https://npmjs.org/package/cf-autoconfig) Node 模块。
* 它在引导应用程序的同时预加载 cf-autoconfig 模块。

cf-autoconfig 模块利用 Node.js 缓存机制。此模块在应用程序文件中搜索支持的 Node 模块并重新定义模块连接函数，使其能够被 Cloud Foundry 连接参数调用。例如，我们来了解一下它是如何重新定义 MongoDB Node 模块的连接函数的：

```javascript

if ("connect" in moduleData) {
  var oldConnect = moduleData.connect;
  var oldConnectProto = moduleData.connect.prototype;
  moduleData.connect = function () {
    var args = Array.prototype.slice.call(arguments);
    args[0] = props.url;
    return oldConnect.apply(this, args);
  };
  moduleData.connect.prototype = oldConnectProto;
}
```
其他函数也是如此重新定义的。请看 [Github 上的 cf-autoconfig 模块源](https://github.com/cloudfoundry/vcap-node/tree/master/cf-autoconfig)。欢迎提供反馈，甚至可以提交拉取请求。

### 受支持的模块

下面列出了受支持的模块：

* [amqp](https://github.com/postwait/node-amqp)
* [mongodb](https://github.com/mongodb/node-mongodb-native)
* [mongoose](https://github.com/learnboost/mongoose)
* [mysql](https://github.com/felixge/node-mysql)
* [pg](https://github.com/brianc/node-postgres)
* [redis](https://github.com/mranney/node_redis)

根据 [npmjs.org](http://www.npmjs.org)，这些模块是最可靠的。这意味着许多其他模块可以使用这些模块作为数据库连接层，所以它们也可以使用自动重新配置功能。

### 限制

服务的自动重新配置机制仅在以下条件下才会发挥作用：

* 您仅使用一项属于给定类型的服务。例如，仅使用一项 mysql 服务或一项 redis 服务。
* 您使用的是上述受支持模块列表中的服务 Node 模块，或者其他任何使用其中一种模块进行下层服务连接的模块。
* 您的应用程序不直接使用 cf-runtime 或 cf-autoconfig Node 模块。
* 您的应用程序是典型的 Node.js 应用程序。对于复杂的应用程序，您可能需要考虑选择退出自动重新配置机制，改为使用 cf-runtime Node 模块，本系列中的下一篇博文将对此模块进行介绍。

### 关闭自动重新配置
可以通过在应用程序基文件夹中创建一个 `cloudfoundry.json` 文件，并将选项“cfAutoconfig”设置为 false 来关闭自动重新配置。

```javascript

{ “cfAutoconfig” : false }
```
此外，如上文中所提到的那样，如果应用程序使用的是 cf-runtime Node 模块，自动重新配置将不起作用。

## 常见问题解答

### 1. Node.js 自动重新配置存在哪些限制？
服务的自动重新配置机制仅在以下条件下才会发挥作用：

* 您仅使用一项属于给定类型的服务。例如，仅使用一项 mysql 服务或一项 redis 服务。
* 您使用的是上述受支持模块列表中的服务 Node 模块，或者其他任何使用其中一种模块进行下层服务连接的模块。
* 您的应用程序不直接使用 cf-runtime 或 cf-autoconfig Node 模块。
* 您的应用程序是典型的 Node.js 应用程序。对于复杂的应用程序，您可能需要考虑选择退出自动重新配置机制，改为使用 cf-runtime Node 模块，本系列中的下一篇博文将对此模块进行介绍。


### 2. 自动重新配置在默认情况下是否是开启的？
是的。

### 3. 我怎么关闭自动重新配置？

可以通过在应用程序基文件夹中创建一个 `cloudfoundry.json` 文件，并将选项“cfAutoconfig”设置为 false 来关闭自动重新配置。

```javascript

{ “cfAutoconfig” : false }
```
此外，如上文中所提到的那样，如果应用程序使用的是 cf-runtime Node 模块，自动重新配置将不起作用。

### 4. 需要使用什么版本的 Node.js？

Node.js v0.6.x、v0.8.x 和更高版本。

### 5. 我怎么能知道自动重新配置不起作用了？

通常您会看到“无法连接”给定服务的字样，通过这就可以知道。

### 6. 受支持的模块/服务有哪些？

下面列出了受支持的模块：

* [amqp](https://github.com/postwait/node-amqp)
* [mongodb](https://github.com/mongodb/node-mongodb-native)
* [mongoose](https://github.com/learnboost/mongoose)
* [mysql](https://github.com/felixge/node-mysql)
* [pg](https://github.com/brianc/node-postgres)
* [redis](https://github.com/mranney/node_redis)

根据 [npmjs.org](http://www.npmjs.org)，这些模块是最可靠的。这意味着许多其他模块可以使用这些模块作为数据库连接层，所以它们也可以使用自动重新配置功能。




### 有关详细信息：
请阅读以下链接中的博客：[Node.js 应用程序自动重新配置](http://wp.me/p2wH9O-BS)










