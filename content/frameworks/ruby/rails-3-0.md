---
title: Ruby on Rails 3.0
description: 利用 Cloud Foundry 开发 Ruby on Rails 3.0
tags:
    - ruby
    - rails
    - mysql
---

本文为使用 Cloud Foundry 的 Ruby on Rails 3.0 开发人员提供指导。
有关 Ruby 和 Cloud Foundry 的详细信息，请参见：

+  [Ruby on Rails](http://rubyonrails.org/)
+  [Cloud Foundry 入门](/getting-started.html)
+  [利用 Cloud Foundry 开发 Ruby 应用程序](ruby.html)

通过 Ruby on Rails 使用 Cloud Foundry 服务的方法与通过 Sinatra 应用程序使用服务的方法相同，不同之处在于当在 Cloud Foundry 暂存 Rails 应用程序时，可以自动识别 MySQL。对于其他 Cloud Foundry 服务，必须按照[利用 Cloud Foundry 开发 Ruby 应用程序](/frameworks/ruby/ruby.html#using-cloud-foundry-services)中的说明访问 `VCAP_SERVICES` 环境变量。

## Rails 3.0.10 on Ruby 1.8 和 Ruby 1.9

Rails 3.0 完全可以在 Cloud Foundry 上正常使用。请务必使用正确的 MySQL2 gem 版本。

### Gemfile

```ruby
   # If you use a different database in development, hide it from Cloud Foundry
   group :development do
     gem 'sqlite3'
   end

   # Rails 3.0 requires version less than 0.3 of mysql2 gem
   group :production do
     gem 'mysql2', '< 0.3'
   end
```

### 捆绑应用程序：

```bash
$ bundle package
$ bundle install
```

### 部署应用程序：

```bash
$ vmc push
   ...
```

按交互式提示符提示部署和启动应用程序。

