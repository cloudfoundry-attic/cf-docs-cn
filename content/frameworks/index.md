---
title: 概述
description: 配置要在 Cloud Foundry 上运行的应用程序
---

Cloud Foundry 支持下列应用程序开发框架：

+ Spring
+ Ruby on Rails
+ Ruby 和 Sinatra
+ Node.js
+ Grails

支持包括一个运行环境，通过它您的应用程序可以在 Cloud Foundry 上执行，以及运行可以检测框架并自动配置和部署到 Cloud Foundry 的部署工具（vmc 和 STS）。您可能不需要做任何特殊操作就可以部署到 Cloud Foundry。如果应用程序需要数据库等服务，而且您遵循框架的惯例，vmc 或 STS 在部署应用程序时可以处理需要的配置变化。
但也有些情况，您的应用程序将需要最小配置，特别是在需要多个服务时。

每个应用程序框架都有自己的配置过程，下面章节详细描述：

+ [Spring 应用程序](/frameworks/java/spring/spring.html)
+ [Grails 应用程序](/frameworks/java/spring/grails.html)
+ [Node.js 应用程序](/frameworks/nodejs/nodejs.html)
+ [Ruby、Rails 和 Sinatra](/frameworks/ruby/ruby-rails-sinatra.html)

有关所提供服务的列表，请参见[服务](/services.html)。

配置了应用程序并将其与 Cloud Foundry 服务集成之后，使用标准的 Cloud Foundry 工具（VMC、Spring 工具包、或 Eclipse 插件）创建这些服务的实例，并在将应用程序部署到 Cloud Foundry 时将实例绑定到应用程序。有关如何使用这些工具的详细信息，请参见[部署应用程序](/tools/deploying-apps.html)。


