---
title: Ruby 与 MySQL 一起使用
description: 与 MySQL 服务相关的 Ruby 开发
tags:
    - ruby
    - sinatra
    - mysql
---

当您部署至 Cloud Foundry 时，使用 MySQL 的 Rails 应用程序上的 Ruby 会自动重新配置。
此部分描述了如何从其它 Ruby 应用程序访问 Cloud Foundry MySQL 服务，例如使用 Sinatra 的应用程序。

安装 mysql2 gem：

```bash
$ gem install mysql2
```

列出数据库的 gem，将其作为您的应用程序的 Gemfile 中的依赖项。

``` ruby
gem "mysql2"
```

Rails 3.0 要求 mysql2 的版本低于 0.3。

``` ruby
gem "mysql2", "< 0.3"
```

在您的应用程序中，从环境中获取连接信息，连接数据库。

``` ruby
configure do
    services = JSON.parse(ENV['VCAP_SERVICES'])
    mysql_key = services.keys.select { |svc| svc =~ /mysql/i }.first
    mysql = services[mysql_key].first['credentials']
    mysql_conf = {:host => mysql['hostname'], :port => mysql['port'],
        :username => mysql['user'], :password => mysql['password']}
    @@client = Mysql2::Client.new mysql_conf
end
```

在将应用程序推送至云之前,执行这些命令：

```bash
$ bundle package
$ bundle install
```

设定 Cloud Foundry 目标，使用 Cloud Foundry 凭据登录。

```bash
$ vmc target api.cloudfoundry.com
$ vmc login
```

推送应用程序至 Cloud Foundry。在初始推送过程中，创建 mysql Cloud Foundry 服务并将其与您的应用程序捆绑，如此 `vmc push` 脚本中所示：

```bash
$ vmc push
    Would you like to deploy from the current directory? [Yn]:
    Application Name: myapp
    Application Deployed URL [myapp.cloudfoundry.com]:
    Detected a Sinatra Application, is this correct? [Yn]:
    Memory Reservation (64M, 128M, 256M, 512M, 1G) [128M]:
    Creating Application: OK
    Would you like to bind any services to 'myapp'? [yN]: y
    The following system services are available
    1: atmos
    2: mongodb
    3: mysql
    4: postgresql
    5: rabbitmq
    6: redis
    Please select one you wish to provision: 3
    Specify the name of the service [mysql-be3ac]:
    Creating Service: OK
    Binding Service [mysql-be3ac]: OK
    Uploading Application:
      Checking for available resources: OK
      Processing resources: OK
      Packing application: OK
      Uploading (219K): OK
    Push Status: OK
    Staging Application: OK
    Starting Application: OK

```


