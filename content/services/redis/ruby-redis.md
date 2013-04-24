---
title: Redis 与 Ruby 一起使用
description: 与 Redis 服务相关的 Ruby 应用程序开发
tags:
    - ruby
    - redis
---

[Redis](http://redis.io/) 是开源的键值存储，也被称为 NoSQL 数据库。您可以通过使用键对信息进行设置、获取、更新和删除。

对于用 Ruby 书写的应用程序，例如 Rails 或 Sinatra 中的应用程序，请遵循此步骤：

*  添加 gem 至您的应用程序的 Gemfile。

``` ruby
gem 'redis'
```

将库装载入您的应用程序的运行时。例如，在 Rails 中，使用 application.rb 中的 require 语句。
在 Sinatra 中，将此添加至您的 .rb 配置文件：

``` ruby
require 'redis'
```

配置您的环境以查找云上的 Redis 服务：

``` ruby
configure do
    services = JSON.parse(ENV['VCAP_SERVICES'])
    redis_key = services.keys.select { |svc| svc =~ /redis/i }.first
    redis = services[redis_key].first['credentials']
    redis_conf = {:host => redis['hostname'], :port => redis['port'], :password => redis['password']}
    @@redis = Redis.new redis_conf
end
```

Redis 凭据存储在 JSON 格式的 VCAP_SERVICES 环境变量中。

最后一行创建了一个类变量 @@redis，
对您的应用程序中的所有子类可用。该变量将在运行时被使用，
以将键/值添加至 Redis。

在您的应用程序中，使用 [Redis 命令](http://redis.io/commands)编辑和添加键/值至数据存储。

运行 `bundle package`，更新或添加您的应用程序至云：

```bash
$ bundle package
$ vmc stop appname
$ vmc update
```

或者，要添加：

```bash
$ bundle package
$ vmc push
```

创建 Redis 服务，并将应用程序与其捆绑。

```bash
$ vmc create-service redis --bind appname
```

对于更新的应用程序，再次启动：

```bash
$ vmc start appname
```


