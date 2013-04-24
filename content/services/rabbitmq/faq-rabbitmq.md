---
title: RabbitMQ 常见问题解答
description: RabbitMQ 常见问题解答
tags:
    - rabbitmq
    - 常见问题解答
---

### RabbitMQ 服务是什么？
Cloud Foundry 上的 RabbitMQ 服务为在 Cloud Foundry 上构建应用程序的开发人员提供了 RabbitMQ 消息传递功能。与 CloudFoundry.com 的其它内容类似，RabbitMQ 服务目前作为一项免费的测试版服务被提供。

### RabbitMQ 是什么？
RabbitMQ 是在 VMware 开发的、常用的、开源的[消息代理](http://en.wikipedia.org/wiki/Message_broker)。有关更多详细信息，请查看 [RabbitMQ 站点](http://www.rabbitmq.com/)。

### RabbitMQ 服务如何与 Cloud Foundry 关联？
除了为应用程序提供平台，Cloud Foundry 还提供了按需服务组合方案，开发人员可将这些方案与他们的应用程序捆绑。启动 Cloud Foundry 后的可用服务包括 MySQL,MongoDB 和 Redis。RabbitMQ 服务与那些其它服务具有同等地位。可使用标准的 Cloud Foundry vmc 命令（或与它们等同的 Spring 工具套件）创建、捆绑、解除捆绑和删除 RabbitMQ 服务。

### 什么语言和框架可和 RabbitMQ 服务一起使用？
任何受 Cloud Foundry 支持和具有可用 AMQP 客户库的语言和框架。

我们已经使用以下语言、框架和客户端库组合开发了适用于 Cloud Foundry 的应用程序：

Java Spring 应用程序，使用 [Spring AMQP](http://www.springsource.org/spring-amqp) (版本 1.0.0.RC2)
在 Rails 上的 Ruby 和 Ruby Sinatra 应用程序，使用 [bunny gem](https://github.com/ruby-amqp/bunny) (版本 0.7.4)
Node.js 应用程序，使用 [node-amqp](https://github.com/postwait/node-amqp) (版本 0.1.0)

### 如何入门使用？
在 [github.com/rabbitmq/rabbitmq-cloudfoundry-samples](https://github.com/rabbitmq/rabbitmq-cloudfoundry-samples) 上，您可以找到演示如何使用从不同语言和框架使用服务的介绍性示例，包括 Spring Java、Rails 上的 Ruby 、Ruby Sinatra 和 node.js。在此站点上有 [Rails](http://www.rabbitmq.com/cloudfoundry/rails) 和 [Spring](http://www.rabbitmq.com/cloudfoundry/spring) 的详细教程。

在 [RabbitMQ 站点](http://www.rabbitmq.com/getstarted.html) 上，您可以找到更多关于如何使用 RabbitMQ（也适用于 RabbitMQ 服务）开发应用程序的更多信息。

### 我可以使用哪些协议访问 RabbitMQ 服务？
目前，服务支持 RabbitMQ 的核心协议：[AMQP](http://en.wikipedia.org/wiki/AMQP) 版本 0-8 和 0-9-1。将来，我们计划纳入 RabbitMQ 插件支持的其它协议。请告诉我们您是否对某特定协议感兴趣。

### CloudFoundry.com 外部的应用程序是否可以访问 RabbitMQ 服务？
目前不可以。

### 在 RabbitMQ.com 的[入门](https://www.rabbitmq.com/getstarted.html)页面上列出的哪些 RabbitMQ 用例可和 RabbitMQ 服务一起使用？
所有这些用例都可以。

### RabbitMQ 服务是否支持集群？
现在还不支持，但我们将来可能会考虑提供支持。

### RabbitMQ 服务基于哪个版本的 rabbitmq-server？
目前是 rabbitmq-server-2.4.1。

### RabbitMQ 服务价格如何？
与 Cloud Foundry 的其它内容类似，它一开始将作为一项免费的测试版服务被提供。

### RabbitMQ 现在是不是 Cloud Foundry 开源项目的一部分？
不是，RabbitMQ 不是 Cloud Foundry 开源项目的一部分。

### 为了使用 RabbitMQ 服务，我是否需要更新 vmc？
不需要，无需更新 vmc 即可使用 RabbitMQ 服务。但请注意 vmc 将不断增强，您应该不时地通过 rubygems 命令 gem update vmc 更新它

### 我可以在哪里提问或发送关于服务的反馈？
请在[support.cloudfoundry.com](http://support.cloudfoundry.com) 的论坛或 [StackOverflow](http://stackoverflow.com/questions/tagged/cloudfoundry) 上提出您的问题。

