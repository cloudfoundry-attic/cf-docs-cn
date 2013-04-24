---
title: 示例应用程序

description: Cloud Foundry 上的示例应用程序

tags:
    - 样例

    - 示例

---


### Node.js

<table class="std">

<tr>

<th>应用程序</th>

<th>来源</th>

<th>说明</th>

<th>使用的服务</th>

</tr>

<tr>

<td><a href="http://octofoundry.cloudfoundry.com/" target="_blank">Octofoundry</a></td>

<td><a href="https://github.com/videlalvaro/cloudfoundry-octopress" target="_blank">https://github.com/videlalvaro/cloudfoundry-octopress</a></td>

<td>将您的 octopress 博客部署到 Cloud Foundry。</td>

<td></td>

</tr>

<tr>

<td>Node 活动样板</td>

<td><a href="https://github.com/cloudfoundry-samples/node-activities-boilerplate" target="_blank">https://github.com/cloudfoundry-samples/node-activities-boilerplate</a></td>

<td>使用 Express、Connect、Socket.io、Redis 和 MongoDB 构建的一款简单的 NodeJS 活动流引擎。</td>

<td>MongoDB、Redis</td>

</tr>

<tr>

<td>活动流 Mongoose</td>

<td><a href="https://github.com/cloudfoundry-samples/activity-streams-mongoose" target="_blank">https://github.com/cloudfoundry-samples/activity-streams-mongoose</a></td>

<td>依托 MongoDB（通过 Mongoose）和 Redis 的活动流实时数据存储</td>

<td>MongoDB、Redis</td>

</tr>

<tr>

<td>活动流 Mongoose</td>

<td><a href="https://github.com/cloudfoundry-samples/subway" target="_blank">https://github.com/cloudfoundry-samples/subway</a></td>

<td>Subway 是一款基于 Web 的 IRC 客户端，具有一个多用户后端和一个大量使用 JavaScript 的 UI。</td>

<td>MongoDB</td>

</tr>

<tr>

<td>Twitter Rabbit Sock 示例</td>

<td><a href="https://github.com/cloudfoundry-samples/twitter-rabbit-socks-sample" target="_blank">https://github.com/cloudfoundry-samples/twitter-rabbit-socks-sample</a></td>

<td>它包含一款使用来自 Rabbit 队列的 Twitter 微搏并使用 Sock.js 将这些微博推送到浏览器的 node.js 应用程序。</td>

<td>RabbitMQ</td>

</tr>

<tr>

<td>Solr Node 示例</td>

<td><a href="https://github.com/cloudfoundry-samples/solr-node-sample" target="_blank">https://github.com/cloudfoundry-samples/solr-node-sample</a></td>

<td>这是一款易用的搜索 Web 应用程序示例，基于 Apache Solr 构建。</td>

<td></td>

</tr>

</table>



### Java

<table class="std">

<tr>

<th>应用程序</th>

<th>来源</th>

<th>说明</th>

<th>使用的服务</th>

</tr>

<tr>

<td>SpringMVC Hibernate 模板</td>

<td><a href="https://github.com/cloudfoundry-samples/springmvc-hibernate-template" target="_blank">https://github.com/cloudfoundry-samples/springmvc-hibernate-template</a></td>

<td>一款简单的应用程序，演示了如何将 Cloud Foundry 上的 Spring 3.1 与配置文件、HTML5、缓存和 Hibernate 4.0 等一起使用。
</td>

<td></td>

</tr>

<tr>

<td>股票工作者进程</td>

<td><a href="https://github.com/cloudfoundry-samples/stock-workers" target="_blank">https://github.com/cloudfoundry-samples/stock-workers</a></td>

<td>此资源库承载了介绍 Cloud Foundry 中工作者进程的 SpringSource 博客的演示。
这些演示（Spring Batch、Spring Integration 和 Spring Core）使用并处理股票源数据。
</td>

<td>MySQL</td>

</tr>

<tr>

<td>Play 示例应用程序</td>

<td><a href="https://github.com/cloudfoundry-samples/todolist-play-java-mongodb" target="_blank">https://github.com/cloudfoundry-samples/todolist-play-java-mongodb</a></td>

<td>这是一款使用 Java 和 MongoDB 的 Play 示例应用程序。</td>

<td>MongoDB</td>

</tr>

<tr>

<td>Twitter Rabbit Sock 示例</td>

<td><a href="https://github.com/cloudfoundry-samples/twitter-rabbit-socks-sample" target="_blank">https://github.com/cloudfoundry-samples/twitter-rabbit-socks-sample</a></td>

<td>它包含一款独立的 Spring Integration 应用程序，该应用程序会定期轮询 Twitter 是否有包含“cloud”一词的 Twitter 微搏并将这些微博放入一个 Rabbit 队列。</td>

<td>RabbitMQ</td>

</tr>

<tr>

<td>Spring 旅游</td>

<td><a href="https://github.com/cloudfoundry-samples/spring-travel" target="_blank">https://github.com/cloudfoundry-samples/spring-travel</a></td>

<td>Spring 旅游参考应用程序 - 演示如何将 Spring Framework 3 与 Web Flow 2.1 搭配使用</td>

<td></td>

</tr>

</table>



### Scala

<table class="std">

<tr>

<th>应用程序</th>

<th>来源</th>

<th>说明</th>

<th>使用的服务</th>

</tr>

<tr>

<td>Spray Can 服务器</td>

<td><a href="https://github.com/cloudfoundry-samples/spray-can-server" target="_blank">https://github.com/cloudfoundry-samples/spray-can-server</a></td>

<td>来自于 Spray 的 spray-can simple-http-server 示例。
Spray 是一套 scala 库，用于在 Akka 基础上构建和使用基于 REST 的 Web 服务。
此示例以独立应用程序的形式部署到 Cloud Foundry。</td>

<td></td>

</tr>

<tr>

<td>Unfiltered 示例</td>

<td><a href="https://github.com/cloudfoundry-samples/cf-unfiltered-sample" target="_blank">https://github.com/cloudfoundry-samples/cf-unfiltered-sample</a></td>

<td>基于 giter8 模板生成的一个 Unfiltered 示例。
Unfiltered 是 Scala 中用来满足 HTTP 请求的一个工具包。
此示例使用嵌入式 Jetty 并以独立应用程序的形式部署到 Cloud Foundry。</td>

<td></td>

</tr>

<tr>

<td>Bitshow 示例</td>

<td><a href="https://github.com/cloudfoundry-samples/bitshow" target="_blank">https://github.com/cloudfoundry-samples/bitshow</a></td>

<td>图像处理服务器。
这是 nyscala-bitshow 项目的克隆，为在 Cloud Foundry 上运行而进行了修改。</td>

<td>MongoDB</td>

</tr>

<tr>

<td>Scalatra Mongo 示例</td>

<td><a href="https://github.com/cloudfoundry-samples/scalatra-mongo-sample" target="_blank">https://github.com/cloudfoundry-samples/scalatra-mongo-sample</a></td>

<td>将消息存储到 Mongo 和从中检索消息的简单 Scalatra 应用程序。</td>

<td>MongoDB</td>

</tr>

</table>



### Ruby

<table class="std">

<tr>

<th>应用程序</th>

<th>来源</th>

<th>说明</th>

<th>使用的服务</th>

</tr>

<tr>

<td><a href="http://contributingcode.cloudfoundry.com" target="_blank">贡献代码</a></td>

<td><a href="https://github.com/cloudfoundry-samples/contributing-code-app" target="_blank">https://github.com/cloudfoundry-samples/contributing-code-app</a></td>

<td>构建这款应用程序主要是为了组织一次代码编写活动。
它是一款 Rails 3.2.6 应用程序，采用 MySQL 来存储数据，采用 Mongo GridFS 来存储图像，采用 Sendgrid API 来传送电子邮件，采用 Redis 来执行 Resque 操作。</td>

<td>MySQL、Redis</td>

</tr>

<tr>

<td><a href="http://carsapp.cloudfoundry.com/dashboard" target="_blank">Backbone 汽车</a></td>

<td><a href="https://github.com/cloudfoundry-samples/backbone-cars" target="_blank">https://github.com/cloudfoundry-samples/backbone-cars</a></td>

<td>一款用来演示 CabForward 的 Backbone 类的应用程序。</td>

<td>MySQL</td>

</tr>

<tr>

<td>Rails Elastic Search</td>

<td><a href="https://github.com/cloudfoundry-samples/rails-elastic-search" target="_blank">https://github.com/cloudfoundry-samples/rails-elastic-search</a></td>

<td>一款 Rails 应用程序，它使用 Tire 与 Cloud Foundry 上部署的 Elastic Search 进行交互。</td>

<td>MySQL</td>

</tr>

<tr>

<td>Rails 正式推出前注册</td>

<td><a href="https://github.com/cloudfoundry-samples/rails-prelaunch-signup" target="_blank">https://github.com/cloudfoundry-samples/rails-prelaunch-signup</a></td>

<td>一款 Rails 3.2 示例应用程序，用作 Web 初创型企业正式推出前的站点。</td>

<td>MySQL</td>

</tr>

<tr>

<td>Resque 示例</td>

<td><a href="https://github.com/cloudfoundry-samples/resque-sample" target="_blank">https://github.com/cloudfoundry-samples/resque-sample</a></td>

<td>一个采用 Gemfile 和 Cloud Foundry 清单文件的 resque 演示示例。
通过自动将服务器和工作者进程连接到 CF Redis 服务，突显了 CF Ruby 自动重新配置机制的亮点。</td>

<td>Redis</td>

</tr>

<tr>

<td><a href="http://summerjobs.cloudfoundry.com/" target="_blank">Summer jobs</a></td>

<td><a href="https://github.com/cloudfoundry-samples/summer-jobs" target="_blank">https://github.com/cloudfoundry-samples/summer-jobs</a></td>

<td>说明了如何使用美国劳工部提供的暑期工作 (Summer Jobs) API 以及如何使用将工作架构与微数据搭配使用。</td>

<td>Redis</td>

</tr>

<tr>

<td><a href="http://friends.cloudfoundry.com" target="_blank">好友</a></td>

<td><a href="https://github.com/cloudfoundry-samples/friends" target="_blank">https://github.com/cloudfoundry-samples/friends</a></td>

<td>供您用来通过暑期工作与（较年轻）朋友建立关系的 Facebook 应用程序。</td>

<td>Redis</td>

</tr>

<tr>

<td><a href="http://whofollows.cloudfoundry.com/" target="_blank">Sinatra Twitter</a></td>

<td><a href="https://github.com/cloudfoundry-samples/sinatra-cf-twitter" target="_blank">https://github.com/cloudfoundry-samples/sinatra-cf-twitter</a></td>

<td>一款 Sinatra/Redis 应用程序 - 一位 Twitter 用户是否关注另一位？</td>

<td>Redis</td>

</tr>

<tr>

<td>JRuby Rails 书架</td>

<td><a href="https://github.com/cloudfoundry-samples/jruby-rails-bookshelf" target="_blank">https://github.com/cloudfoundry-samples/jruby-rails-bookshelf</a></td>

<td>适用于 Cloud Foundry 的 Rails JRuby 示例。</td>

<td></td>

</tr>

<tr>

<td>Enki</td>

<td><a href="https://github.com/cloudfoundry-samples/enki" target="_blank">https://github.com/cloudfoundry-samples/enki</a></td>

<td>一款供时尚开发人员使用的 Ruby on Rails 博客应用程序。</td>

<td>MySQL</td>

</tr>

<tr>

<td><a href="http://ciberch.cloudfoundry.com/" target="_blank">Sinatra Cloud Foundry 基本网站</a></td>

<td><a href="https://github.com/cloudfoundry-samples/sinatra-cloudfoundry-basic-website" target="_blank">https://github.com/cloudfoundry-samples/sinatra-cloudfoundry-basic-website</a></td>

<td>超级简单的 hello world sinatra 应用程序。
使用 Haml 提供视图。
此外还添加了某种 Open Graph 协议以增加趣味性。</td>

<td></td>

</tr>

<tr>

<td><a href="http://salesforce-demo.cloudfoundry.com/" target="_blank">Salesforce 演示</a></td>

<td><a href="https://github.com/cloudfoundry-samples/salesforce-demo" target="_blank">https://github.com/cloudfoundry-samples/salesforce-demo</a></td>

<td>用于 Salesforce 且采用 OAuth2 gem 的 REST 示例客户端。</td>

<td>Redis</td>

</tr>

<tr>

<td>Box 示例应用程序</td>

<td><a href="https://github.com/cloudfoundry-samples/box-sample-ruby-app" target="_blank">https://github.com/cloudfoundry-samples/box-sample-ruby-app</a></td>

<td>一款使用 Box Ruby SDK 构建的示例应用程序。</td>

<td></td>

</tr>

</table>



### Groovy

<table class="std">

<tr>

<th>应用程序</th>

<th>来源</th>

<th>说明</th>

<th>使用的服务</th>

</tr>

<tr>

<td><a href="http://grailstwitter.cloudfoundry.com" target="_blank">Grails Twitter</a></td>

<td><a href="https://github.com/grails-samples/grailstwitter" target="_blank">https://github.com/grails-samples/grailstwitter</a></td>

<td>一款 Grails Twitter 示例应用程序。</td>

<td>MongoDB</td>

</tr>

</table>



