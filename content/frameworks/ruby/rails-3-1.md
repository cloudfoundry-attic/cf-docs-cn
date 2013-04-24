---
title: Ruby on Rails 3.1 和更高版本

description: 利用 Cloud Foundry 开发 Ruby on Rails 3.1

tags:
    - ruby

    - rails

    - mysql

---

本文为使用 Cloud Foundry 的 Rails 3.1 和 3.2 开发人员提供指导。其前提如下：


+   您已安装了 vmc。


+   您能熟练的开发 Rails 应用程序，并熟悉用来管理 Rails 应用程序中依赖项的工具。


有关 Ruby 和 Cloud Foundry 的详细信息，请参见：


+  [Ruby on Rails](http://rubyonrails.org/)
+  [Cloud Foundry 入门](/getting-started.html)
+  [利用 Cloud Foundry 开发 Ruby 应用程序](ruby.html)

通过 Ruby on Rails 使用 Cloud Foundry 服务的方法与通过 Sinatra 应用程序使用服务的方法相同，不同之处在于当在 Cloud Foundry 暂存 Rails 应用程序时，可以自动识别 MySQL。对于其他 Cloud Foundry 服务，必须按照[利用 Cloud Foundry 开发 Ruby 应用程序](/frameworks/ruby/ruby.html#using-cloud-foundry-services)中的说明访问 `VCAP_SERVICES` 环境变量。


## Rails 3.1.2 和 3.2 on Ruby 1.8 和 Ruby 1.9


Rails 3.1 采用了资产管道。为使资产管道能在 Cloud Foundry 上使用，需要在您的开发环境中对资产进行预编译，将它们编译在 `public/assets` 中，然后在执行普通 `vmc push` 前对生产环境配置进行调整。


该过程的步骤如下。


### Gemfile


#### Ruby 1.8


```ruby

   # If you use a different database in development, hide it from Cloud Foundry.
   group :development do
     gem 'sqlite3'
   end

   # Rails 3.1 can use the latest mysql2 gem.
   group :production do
     gem 'mysql2'
   end

```

#### Ruby 1.9


```ruby

   # If you use a different database in development, hide it from Cloud Foundry.
   group :development do
     gem 'sqlite3'
   end

   # Rails 3.1 can use the latest mysql2 gem.
   group :production do
     gem 'mysql2'
   end

   # For Ruby 1.9 Cloud Foundry requires a tweak to the jquery-rails gem.
   # gem 'jquery-rails'
   gem 'cloudfoundry-jquery-rails'

   # For Ruby 1.9 Cloud Foundry requires a tweak to devise.
   # Uncomment next line if you plan to use devise.
   # gem 'cloudfoundry-devise', :require => 'devise'

```

### 捆绑应用程序：


```bash
$ bundle package
$ bundle install
```

### 配置


编辑 `config/environments/production.rb` 并将


```ruby
config.serve_static_assets = false
```

改为：


```ruby
config.serve_static_assets = true
```

### 资产


预编译资产管道。


```bash
$ bundle exec rake assets:precompile
```

### 部署


```bash
$ vmc push
```

按交互式提示符提示部署和启动应用程序。



