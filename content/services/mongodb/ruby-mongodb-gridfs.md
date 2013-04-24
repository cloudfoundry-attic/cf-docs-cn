---
title: Ruby 与 MongoDB 和 GridFS 一起使用
description: 与 MongoDB 和 GridFS 相关的 Ruby 开发
tags:
    - mongodb
    - grid-fs
    - rails
    - 教程
---

GridFS 是关于在 MongoDB 数据库中存储超过 MongoDB 大小限制的文件的技术说明。它以块方式存储文件，并通过一个 API 将文件块的集合作为一个单个对象进行管理。此教程通过添加一个头像至用户模型，演示了如何在 Rails 应用中使用 GridFS。

许多 Web 应用程序允许用户上传和检索生成的图像，如档案图片、相片或视频缩略图。如果您是在 Rails 上使用 Ruby，您可以使用一些很不错的框架：PaperClip 和 CarrierWave。

之所以为此项目选择 CarrierWave，因为它看上去是最不突出的和最灵活的。CarrierWave 可与文件系统、Amazon S3 或一个数据库（包括 Mongo GridFS）一起使用。

第一个任务是在用户使用 Facebook 帐户在应用程序上注册时添加图片。支持图片上传和提供下载的步骤如下。关于与 Facebook 整合的更多详细信息，请审查源代码中的 `user.rb` 模型。

## 在您的终端上实施的步骤

假设的情况是您已经在具有用户模型的 Cloud Foundry 上的 Rails 3.0 应用程序上拥有一个 Ruby。

```bash

# Log in to Cloud Foundry if you are not logged in
$ vmc login youremail@domain.com

$ vmc create-service mongodb

# See what the newly created mongo service is called
$ vmc services

# Bind the service to your existing application
$ vmc bind-service mongodb-???? appname

```

## 在您的代码库上实施的步骤

### 依赖项

添加以下 gem 至您的 Gemfile

``` ruby
gem 'carrierwave'
gem 'carrierwave-mongoid', :require => "carrierwave/mongoid"
```

生成上传程序

```bash
$ rails generate uploader Avatar
```

编辑生成文件 `app/uploaders/avadar_uploader.rb`，若要使用 grid_fs

``` ruby
class AvatarUploader < CarrierWave::Uploader::Base

    # Choose what kind of storage to use for this uploader:
    storage :grid_fs

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
        "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    # Provide a default URL as a default if there hasn't been a file uploaded:
    def default_url
        "/images/fallback/" + [version_name, "default.png"].compact.join('_')
    end
end
```

更新您的 ActiveRecord 模型以储存头像。

确保在装载 ORM 之后才装载 CarrierWave，否则，您将需要手动添加相关的扩展，例如：

``` ruby
require 'carrierwave/orm/activerecord'
```

对您想要装入上传程序的模型添加一个字符串列。

```bash
$ add_column :users, :avatar, :string
```

打开您的模型文件，添加代码以装入上传程序：

``` ruby
class User
...
    mount_uploader :avatar, AvatarUploader

    # Make sure that the avatar is accessible
    attr_accessible :emails, :avatar, :remote_avatar_url, :email, :last_name #....
...
end
```

为 Mongoid 创建初始化程序，以使用 Cloud Foundry 上的 MongoDB 实例。将其命名为 `01_mongoid.rb`，使其在所有其它程序之前运行。

``` ruby
Mongoid.configure do |config|
  conn_info = nil

  if ENV['VCAP_SERVICES']
    services = JSON.parse(ENV['VCAP_SERVICES'])
    services.each do |service_version, bindings|
      bindings.each do |binding|
        if binding['label'] =~ /mongo/i
          conn_info = binding['credentials']
          break
        end
      end
    end
    raise "could not find connection info for mongo" unless conn_info
  else
    conn_info = {'hostname' => 'localhost', 'port' => 27017}
  end

  cnx = Mongo::Connection.new(conn_info['hostname'], conn_info['port'], :pool_size => 5, :timeout => 5)
  db = cnx['db']
  if conn_info['username'] and conn_info['password']
    db.authenticate(conn_info['username'], conn_info['password'])
  end

  config.master = db
end
```

更新您的 CarrierWave 初始化程序以使用 Cloud Foundry MongoDB 服务。

``` ruby
#initializers/carrierwave.rb
require 'serve_gridfs_image'

CarrierWave.configure do |config|
  config.storage = :grid_fs
  config.grid_fs_connection = Mongoid.database

  # Storage access url
  config.grid_fs_access_url = "/grid"
end
```

在 `lib/serve_gridfs_image.rb` 中处理图片请求：

``` ruby
class ServeGridfsImage
  def initialize(app)
      @app = app
  end

  def call(env)
    if env["PATH_INFO"] =~ /^\/grid\/(.+)$/
      process_request(env, $1)
    else
      @app.call(env)
    end
  end

  private
  def process_request(env, key)
    begin
      Mongo::GridFileSystem.new(Mongoid.database).open(key, 'r') do |file|
        [200, { 'Content-Type' => file.content_type }, [file.read]]
      end
    rescue
      [404, { 'Content-Type' => 'text/plain' }, ['File not found.']]
    end
  end
end
```

## 部署

```bash
$ bundle install
    bundle package
    vmc update app_name
```

## 总结

这样您将可以上传图片和提供图片下载。务必注意它不提供改变图片大小功能。例如，若您使用的是 Devise，您可以在用户注册时导入用户的头像（档案图片）。

``` ruby
class << self
    def new_with_session(params, session)
      super.tap do |user|
        if session['devise.omniauth_info']
          if data = session['devise.omniauth_info']['user_info']
            user.display_name = data['name'] if data.has_key? 'name'
            user.email = data['email']
            user.username = data['nickname'] if data.has_key? 'nickname'
            user.first_name = data['first_name'] if data.has_key? 'first_name'
            user.last_name = data['last_name'] if data.has_key? 'last_name'
            user.remote_avatar_url = data['image'] if data.has_key? 'image'
          end
        end
      end
    end
  end
```

## 参考

+ [连接 MongoDB 数据库](http://support.cloudfoundry.com/entries/20016922-connecting-to-a-mongo-db)
+ [CarrierWave](https://github.com/jnicklas/carrierwave)
+ [CarrierWave for Mongoid](https://github.com/jnicklas/carrierwave-mongoid)
+ [使用 Rails 3 和 mongoid 上的 GridFS 设置 CarrierWave 文件上传](http://antekpiechnik.com/posts/setting-up-carrierwave-file-uploads-using-gridfs-on-rails-3-and-mongoid)
+ [Devise](https://github.com/plataformatec/devise)

