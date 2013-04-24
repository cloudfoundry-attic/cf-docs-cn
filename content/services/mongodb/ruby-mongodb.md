---
title: Ruby 与 MongoDB 一起使用
description: 与 MongoDB 服务相关的 Ruby 开发
tags:
    - mongodb
    - sinatra
    - ruby
---

[MongoDB](http://www.mongodb.org) 是一种可扩展的、开源的、面向文档的数据库，并作为 Cloud Foundry 上的服务被提供。
本部分描述了如何调整 Rails 应用程序上的 Ruby 以访问 Cloud Foundry mongodb 服务。
假设情况是您使用的是 [MongoMapper](http://mongomapper.com) ORM。

### Gemfile

``` bash
$ gem install "mongo_mapper"
$ gem install "bson_ext"
```

添加 BSON 以将类似 JSON 格式的文件序列化，这是连接 MongoDB Ruby 驱动程序所需要的。

### Rails
如果您的应用程序是 Rails 应用程序,请通过解析 JSON 格式的 `VCAP_SERVICES` 环境变量来修改 `config/mongo.yml` 的生产部分，以设置 Cloud Foundry 的凭据、主机和端口。

``` erb
production:
host: <%= JSON.parse(ENV['VCAP_SERVICES'])['mongodb-2.0'].first['credentials']['hostname'] rescue 'localhost' %>
port: <%= JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-2.0'].first['credentials']['port'] rescue 27017 %>
database:  <%= JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-2.0'].first['credentials']['db'] rescue 'tutorial_db' %>
username: <%= JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-2.0'].first['credentials']['username'] rescue '' %>
password: <%= JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-2.0'].first['credentials']['password'] rescue '' %>

```

如果您的应用程序不是 Rails 应用程序,先前步骤中的 `JSON.parse()` 将演示如何从 `VCAP_SERVICES` 中提取构造 [MongoDB 连接字符串](http://www.mongodb.org/display/DOCS/Connections)所需的信息，以访问 Cloud Foundry MongoDB 服务。

### 捆绑

```bash
$ bundle package
$ bundle install
```

### 部署

当 vmc 向您询问是否捆绑任何服务时，输入 `y` 并从菜单中选择 `mongodb`。为服务提供一个名称，或接受默认名称，如此脚本所示：

``` bash
$ vmc push --runtime ruby19
    Would you like to deploy from the current directory? [Yn]:
    Application Name: test
    Application Deployed URL [test.pubs.cloudfoundry.me]:
    Detected a Sinatra Application, is this correct? [Yn]:
    Memory Reservation (64M, 128M, 256M, 512M, 1G) [256M]:
    Creating Application: OK
    Would you like to bind any services to 'test'? [yN]: y
    Would you like to use an existing provisioned service [yN]? N
    The following system services are available
    1: mongodb
    2: mysql
    3: postgresql
    4: rabbitmq
    5: redis
    Please select one you wish to provision: 1
    Specify the name of the service [mongodb-dcc48]:
    Creating Service: OK
    Binding Service [mongodb-dcc48]: OK
    Uploading Application:
      Checking for available resources: OK
      Processing resources: OK
      Packing application: OK
      Uploading (8K): OK
    Push Status: OK
    Staging Application: OK
    Starting Application: OK
```


