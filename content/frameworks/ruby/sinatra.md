---
title: Sinatra

description: 利用 Cloud Foundry 开发 Sinatra

tags:
    - ruby

    - sinatra

    - mysql

---

本文为从事 Cloud Foundry 部署的 Sinatra 开发人员提供指导，

有关 Ruby 和 Cloud Foundry 的详细信息，请参见：


+  [Ruby on Rails](http://rubyonrails.org/)
+  [Cloud Foundry 入门](/getting-started.html)
+  [利用 Cloud Foundry 开发 Ruby 应用程序](ruby.html)

要将 Cloud Foundry 服务与 Sinatra 搭配使用，您可以访问

`VCAP_SERVICES` 环境变量，具体方法请参照

[利用 Cloud Foundry 开发 Ruby 应用程序](/frameworks/ruby/ruby.html#using-cloud-foundry-services)；也可使用 `cf-runtime` gem。


## Sinatra 和捆绑程序


目前，在执行 `vmc push` 时，vmc gem 会在 `*.rb` 文件中查找 `require "sinatra"` 和 `require "sinatra/base"`，以便

检测它所属于的 Ruby 应用程序类型。


### 传统的 Sinatra 应用程序


传统的 Sinatra 应用程序都有 `require "sinatra"` 加以标识。
如果您用

捆绑程序加载 Sinatra，Cloud Foundry 可能不会识别您的应用程序。

您可以在应用程序主文件中加入下面这样的注释：


```ruby
  # require 'sinatra'   # required for sinatra classic detection in cloud foundry...
  require 'rubygems'
  require 'bundler'
  Bundler.require
  ...
```

### 模块化 Sinatra 应用程序


Cloud Foundry 假定，如果您的 Sinatra 应用程序在

需要“sinatra/base”的单个文件中，则该应用程序属于模块化 Sinatra 应用程序，因此它将对

`run!` 进行调用，如下面的文件中所示


如果您部署一个带有 `website.rb`、`Gemfile` 和 `Gemfile.lock` 的应用程序并且您使用的 `vmc` gem 版本 >= `0.3.21`


``` ruby

# website.rb
require "rubygems"
require "sinatra/base"
require "haml"
require "cloudfoundry/environment"

class WebsiteApp < Sinatra::Base

  configure do
    set(:port, CloudFoundry::Environment.port || 4567)
  end

  get "/" do
    return "Hello World"
  end

  run! if __FILE__ == $0

end
```

那么您将看到该应用程序被检测出来：


``` bash

Would you like to deploy from the current directory? [Yn]:
Application Name: www-mon-mon
Detected a Sinatra Application, is this correct? [Yn]:
Application Deployed URL [www-mon-mon.cloudfoundry.com]:
Memory reservation (128M, 256M, 512M, 1G, 2G) [128M]:
How many instances? [1]:
Bind existing services to 'www-mon-mon'? [yN]:
Create services to bind to 'www-mon-mon'? [yN]:
Would you like to save this configuration? [yN]:
Creating Application: OK
Uploading Application:
  Checking for available resources: OK
  Processing resources: OK
  Packing application: OK
  Uploading (6K): OK
Push Status: OK
Staging Application 'www-mon-mon': OK
Starting Application 'www-mon-mon': OK

```

如果您有多个文件包含派生自 Sinatra 基类的类，您需要

添加一个 `config.ru` 并以 `rack` 应用程序身份运行，以便您可以指定要

运行哪些类。

下面的示例说明了要想在单个 Cloud Foundry 应用程序中运行 Sinatra 应用程序 OpenTour 和 Events，`config.ru` 需要

是什么样的


```ruby
#config.ru

require './opentour'
require './events'

map('/') { run OpenTour }
map('/events') { run Events }
```

有关传统和模块化 Sinatra 应用程序的更多详情，请查看

[Sinatra 自述文件](http://www.sinatrarb.com/intro#Modular%20vs.%20Classic%20Style)


## 使用 DataMapper 和捆绑程序的 Sinatra 传统应用程序示例


### Gemfile


```ruby
   source 'http://rubygems.org'

   gem 'sinatra'
   gem 'data_mapper'

   group :development do
     gem 'dm-sqlite-adapter'
   end

   group :production do
     gem 'dm-mysql-adapter'
   end
```

### sinatra_dm.rb

此 Sinatra 应用程序的名称为 `sinatra_dm.rb`。


请注意 Sinatra 的注释删除要求，它是可靠检测应用程序主文件所必需的。


```ruby
   # Sample Sinatra app with DataMapper
   # Based on http://sinatra-book.gittr.com/ DataMapper example

   # require 'sinatra'   # required for framework detection in cloud foundry.
   require 'rubygems'
   require 'bundler'
   Bundler.require

   if ENV['VCAP_SERVICES'].nil?
     DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")
   else
     require 'json'
     svcs = JSON.parse ENV['VCAP_SERVICES']
     mysql = svcs.detect { |k,v| k =~ /^mysql/ }.last.first
     creds = mysql['credentials']
     user, pass, host, name = %w(user password host name).map { |key| creds[key] }
     DataMapper.setup(:default, "mysql://#{user}:#{pass}@#{host}/#{name}")
   end

   class Post
     include DataMapper::Resource
     property :id, Serial
     property :title, String
     property :body, Text
     property :created_at, DateTime
   end

   DataMapper.finalize
   Post.auto_upgrade!

   get '/' do
     @posts = Post.all(:order => [:id.desc], :limit => 20)
     erb :index
   end

   get '/post/new' do
     erb :new
   end

   get '/post/:id' do
     @post = Post.get(params[:id])
     erb :post
   end

   post '/post/create' do
     post = Post.new(:title => params[:title], :body => params[:body])
     if post.save
       status 201
       redirect "/post/#{post.id}"
     else
       status 412
       redirect '/'
     end
   end
```

### 视图


#### 索引

```erb
    <!-- views/index.erb -->

    <h1>All Blog Posts</h1>
    <ul>
      <% @posts.each do |post| %>
        <li><a href="/post/<%= post.id %>"><%= post.title %></a></li>
      <% end %>
    <br />
    <a href="/post/new">Create new post</a>
```

#### 新建

```erb
    <!-- views/new.erb -->

    <h1>Create a new blog post</h1>
    <form action="/post/create" method="POST">
     <p>Title: <input type="text" name="title"></input></p>
     <p>Text: <textarea name="body" rows="10" cols="40"></textarea></p>
     <input type="submit" name="Publish" />
    </form>
```

#### 发布

```erb
    <!-- views/post.erb -->

    <h1><%= @post.title %></h1>
    <p><%= @post.body %></p>
    <a href="/">All Posts</a>
```

### 捆绑后推送。


```bash
   $ bundle package
   $ vmc push --runtime ruby19
```


