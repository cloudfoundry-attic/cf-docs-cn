---
title: RabbitMQ 与 Ruby 一起使用
description: 与 RabbitMQ 服务相关的 Ruby 开发
tags:
    - ruby
    - rabbitmq
    - 教程
    - 附代码
---

Cloud Foundry 支持 [RabbitMQ](http://www.rabbitmq.com/) 开源消息代理，
并将其作为一项服务。Cloud Foundry RabbitMQ 服务
基于 rabbitmq-server-2.4.1。

有关 RabbitMQ 的更多信息，请参见这些资源：

-   [下载](http://www.rabbitmq.com/download.html)，[安装](http://www.rabbitmq.com/install.html)和[配置](http://www.rabbitmq.com/configure.html) RabbitMQ。

-   [RabbitMQ 教程](http://www.rabbitmq.com/getstarted.html)涵盖在您应用程序中创建消息的基础知识。

## 语言和框架支持
CloudFoundry 支持的具有高级消息队列协议 (AMQP) 客户端库的语言和框架

也被 RabbitMQ 服务所支持。Rails 上的 Ruby 和 Sinatra 使用 [bunny gem](https://github.com/ruby-amqp/bunny) （版本 0.7.4）部署在 Cloud Foundry 上。


## 协议支持
Cloud Foundry RabbitMQ 服务支持
RabbitMQ 的核心协议：AMQP 版本 0-8 和 0-9-1。其它协议将被
RabbitMQ 插件所支持。

按照以下步骤配置和捆绑 RabbitMQ 至应用程序：

*  创建 RabbitMQ 服务，并将应用程序与其捆绑。

```bash
$ vmc create-service rabbitmq --bind appname
```

*  检查应用程序：

```bash
$ vmc apps
```

返回您的云上的应用程序列表，以及任何关联的
服务。

## Rails 和 RabbitMQ

可通过 [AMQP
协议](http://www.amqp.org/)（版本0.8 和 0.9.1）访问 RabbitMQ 服务，因此您的
应用程序需要 AMQP 客户端库以使用此服务。

用于 Rails 的常用 AMQP 客户端库是
[bunny](https://github.com/ruby-amqp/bunny)。我们将使用它演示
您需遵循的步骤：

添加 bunny 和 json gems 至您的 Gemfile。（json 用于解析服务连接数据）：

``` ruby
gem 'bunny'
gem 'json'
```

运行捆绑安装以安装您添加的 gems：

```bash
$ bundle install
```

在您的控制器中获取的 gems：

``` ruby
require 'bunny'
require 'json'
```

更新控制器类以为服务获取连接字符串，进行连接：

``` ruby
# Extracts the connection string for the rabbitmq service from the
# service information provided by Cloud Foundry in an environment
# variable.
def self.amqp_url
    services = JSON.parse(ENV['VCAP_SERVICES'], :symbolize_names => true)
    url = services.values.map do |srvs|
    srvs.map do |srv|
        if srv[:label] =~ /^rabbitmq-/
            srv[:credentials][:url]
            else
            []
        end
    end
    end.flatten!.first
end

# Opens a client connection to the RabbitMQ service, if one is not
# already open.  This is a class method because a new instance of
# the controller class will be created upon each request.  But AMQP
# connections can be long-lived, so we would like to re-use the
# connection across many requests.
def self.client
    unless @client
        c = Bunny.new(amqp_url)
        c.start
        @client = c
    end
    @client
end
```

在控制器中设置消息队列：

``` ruby
# Return the "nameless exchange", pre-defined by AMQP as a means to
# send messages to specific queues.  Again, we use a class method to
# share this across requests.
def self.nameless_exchange
    @nameless_exchange ||= client.exchange('')
end

# Return a queue named "messages".  This will create the queue on
# the server, if it did not already exist.  Again, we use a class
# method to share this across requests.
def self.messages_queue
    @messages_queue ||= client.queue("messages")
end
```

添加控制器方法以读取和写入消息：

``` ruby
# The action for our publish form.
def publish
    # Send the message from the form's input box to the "messages"
    # queue, via the nameless exchange.  The name of the queue to
    # publish to is specified in the routing key.
    HomeController.nameless_exchange.publish params[:message],
                                   :key => "messages"
    # Notify the user that we published.
    flash[:published] = true
    redirect_to home_index_path
end

def get
    # Synchronously get a message from the queue
    msg = HomeController.messages_queue.pop
    # Show the user what we got
    flash[:got] = msg[:payload]
    redirect_to home_index_path
end
```

