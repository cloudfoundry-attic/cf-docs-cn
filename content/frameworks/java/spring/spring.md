---
title: Spring
description: 使用 Cloud Foundry 开发 Spring 应用程序
tags:
    - spring
    - mongodb
    - redis
    - 附代码
---

本部分为使用 Cloud Foundry 部署其应用程序的 Spring 开发人员提供了实用信息。本部分还特别说明了特定于 Cloud Foundry 环境的 Spring 编程和打包主题，以及如何才能使用所提供的服务（如 MySQL 和 RabbitMQ）。

（如果您希望使用 Spring Insight 来监控 Cloud Foundry 上的 Java 应用程序，请阅读[此内容](/frameworks/java/spring/spring-insight.html)。）

（如果您使用 Spring、Roo 或 Grails，且希望阅读一些代码示例，请点击下面的有用链接：[https://github.com/SpringSource/cloudfoundry-samples/wiki](https://github.com/SpringSource/cloudfoundry-samples/wiki)）

## 先决条件

假设您已安装了 VMC、SpringSource STS 或 Eclipse，且您已使用其中一个工具在 Cloud Foundry 中部署了简单的 HelloWorld 应用程序，Cloud Foundry 可以是本地 Micro 版本，也可以是 cloudfoundry.com 中的托管服务。另外还假设，您是一位精通 Spring 应用程序的开发人员。有关其他信息，请参见以下内容：

+ [安装命令行实用程序 (VMC)](/tools/vmc/installing-vmc.html)
+ [安装适用于 SpringSource 工具套件 (STS) 和 Eclipse 的 Cloud Foundry 集成扩展](/tools/STS/configuring-STS.html)
+ [开始使用 Spring](http://www.springsource.org/get-started)

## 副标题

+ [编程和打包 Spring 应用程序](#programming-and-packaging-spring-applications)
+ [在 Spring 应用程序中使用 Cloud Foundry 服务](#using-cloud-foundry-services-in-spring-applications)
+ [RabbitMQ 和 Spring：其他编程信息](#rabbitmq-and-spring-additional-programming-information)
+ [使用 Spring 配置文件有条件地设置 Cloud Foundry 配置](#using-spring-profiles-to-conditionalize-cloud-foundry-configuration)
+ [通过部署的 Spring 应用程序向 Cloud Foundry 发送电子邮件](#sending-email-from-spring-applications-deployed-to-cloud-foundry)
+ [访问 Cloud Foundry 属性](#accessing-cloud-foundry-properties)

## 编程和打包 Spring 应用程序

一般而言，您在编程或打包希望部署到 Cloud Foundry 的 Spring 应用程序时无需执行任何“特殊”操作。也就是说，如果您的 Spring 应用程序是在 TC Server 或 Apache Tomcat 上运行，那么它也将在 Cloud Foundry 上运行，并且不会有任何改变。

通常情况下，最好是将您的 Spring 应用程序打包到一个 `*.war` 文件中，这样，`vmc push` 将自动检测它是否为 Spring 应用程序，但如果您愿意，也可以将它部署为一个分解式目录。

但是，还有一些有关 Cloud Foundry 环境的问题应引起您的重视，因为它可能会影响到您所部署的应用程序的运行情况：

+  本地磁盘存储稍纵即逝。换句话说，本地磁盘存储不保证在应用程序的整个生命周期中都能持续存在。这是因为 Cloud Foundry 会在您每次重新启动应用程序时创建一个新的虚拟磁盘。另外，Cloud Foundry 会在更新其自身环境之后重新启动所有应用程序。这就是说，即使您的应用程序*能够* 在运行时写入本地文件，这些文件也将在应用程序重新启动之后消失。如果您的应用程序写入的文件是临时文件，也就不会出现问题。但如果您的应用程序需要保留文件中的数据，那您就必须使用其中一个数据服务来管理这些数据。在这种情况下，MongoDB 就是一个很好的选择，因为它是一款面向文档的数据库。

+ Cloud Foundry 使用 Apache Tomcat 作为其应用程序服务器并在 `root` 上下文中运行您的应用程序。这与正常的 Apache Tomcat 有所不同，在正常的 Apache Tomcat 中，上下文路径由打包应用程序的 `*.war` 文件的名称决定。

+ HTTP 会话未复制，但 HTTP 通信具有粘性。这就是说，如果您的应用程序崩溃或重新启动，则 HTTP 会话将丢失。

+ 外部用户只能通过由 `vmc push` 命令（或等效的 STS 命令）提供的 URL 才能访问您的应用程序。即使您的应用程序可以在内部侦听其他端口（例如，MBean 服务器的 JMX 端口），您的应用程序的外部用户也无法侦听这些端口。

## 在 Spring 应用程序中使用 Cloud Foundry 服务

如果您的 Spring 应用程序必须使用服务（如数据库或 RabbitMQ），您可以将应用程序部署到 Cloud Foundry，*无需更改任何代码*.  在这种情况下，Cloud Foundry 会自动重新配置相关 Bean 定义，以将它们绑定到云服务。有关详细信息，请参见[确定您的应用程序是否能够自动配置](#determining-whether-your-application-can-be-auto-configured)。

如果您的 Spring 应用程序无法利用 Cloud Foundry 的自动重新配置功能，或您希望拥有更多的配置控制权，您还需要执行其他一些操作，这些操作非常简单。请参见[直接配置应用程序使用 Cloud Foundry 服务](#explicitly-configuring-your-application-to-use-cloud-foundry-services)。

## 确定您的应用程序是否能够自动配置

您能够将很多已有的 Spring 应用程序部署到 Cloud Foundry，而无需更改任何代码，即使您的应用程序需要使用关系数据库或 RabbitMQ 之类的服务也是如此。这是因为，Cloud Foundry 会自动检测您的应用程序所需的服务类型，如果其配置属于一小部分[限制集](#limitations-of-auto-reconfiguration)，Cloud Foundry 将自动对其进行重新配置，以便它绑定到 Cloud Foundry 自行创建和维护的服务实例。

通过自动重新配置功能，Cloud Foundry 会使用其自身的属性（例如 host、port、username 等）值自行创建数据库或连接工厂。例如，如果您的应用程序上下文中含有一个单一的 `javax.sql.DataSource` Bean，且 Cloud Foundry 对其进行重新配置并绑定到其自身的数据库服务，则 Cloud Foundry 不会使用您最初指定的用户名、密码和驱动程序 URL。相反，它会使用其自身的内部值。这些值对于应用程序来说是透明的，因为这些应用程序关心的只是拥有能够写入数据的关系数据库，而不关心使用的是什么特定属性来创建数据库。

下面的部分针对每个支持的服务阐明了在发生自动配置的情况下 Cloud Foundry 检测的 Bean 类型。

## 关系数据库（MySQL 和 vFabric Postgres）

如果 Cloud Foundry 检测到 `javax.sql.DataSource` Bean 就会发生自动重新配置。Spring 应用程序上下文文件中的以下代码段展示了一个示例，该示例定义了 Cloud Foundry 将依次检测并进行可能的自动重新配置的 Bean 类型：

```xml
<bean class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close" id="dataSource">
    <property name="driverClassName" value="org.h2.Driver" />
    <property name="url" value="jdbc:h2:mem:" />
    <property name="username" value="sa" />
    <property name="password" value="" />
</bean>
```

Cloud Foundry 实际使用的关系数据库取决于您在部署应用程序时直接绑定到应用程序的服务实例：MySQL 或 vFabric Postgres。Cloud Foundry 会创建一个 Commons DBCP 或 Tomcat 数据源。

Cloud Foundry 将在内部生成以下属性的值：driverClassName、url、username、password、validationQuery。

## MongoDB

您必须使用 [Spring Data MongoDB](http://www.springsource.org/spring-data/mongodb) 1.0 M4 或更高版本才能进行自动重新配置。

如果 Cloud Foundry 检测到 `org.springframework.data.document.mongodb.MongoDbFactory` Bean 就会发生自动重新配置。Spring 应用程序上下文文件中的以下代码段展示了一个示例，该示例定义了 Cloud Foundry 将依次检测并进行可能的自动重新配置的 Bean 类型：

```xml
<mongo:db-factory
    id="mongoDbFactory"
    dbname="pwdtest"
    host="127.0.0.1"
    port="1234"
    username="test_user"
    password="test_pass"  />
```

Cloud Foundry 将创建一个 `SimpleMOngoDbFactory`，其中含有其自身针对以下属性的值：host、port、username、password、dbname。

## Redis

您必须使用 [Spring Data Redis](http://www.springsource.org/spring-data/redis) 1.0 M4 或更高版本才能进行自动重新配置。

如果 Cloud Foundry 检测到 `org.springframework.data.redis.connection.RedisConnectionFactory` Bean 就会发生自动重新配置。Spring 应用程序上下文文件中的以下代码段展示了一个示例，该示例定义了 Cloud Foundry 将依次检测并进行可能的自动重新配置的 Bean 类型：

```xml
<bean id="redis"
      class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory"
      p:hostName="localhost" p:port="6379"  />
```
Cloud Foundry 将创建一个 `JedisConnectionFactory`，其中含有其自身针对以下属性的值：host、port、password。这就是说，您必须在您的应用程序中打包 Jedis JAR。Cloud Foundry 当前不支持 JRedis 和 RJC 的实施。

## RabbitMQ

您必须使用 [Spring AMQP](http://www.springsource.org/spring-amqp) 1.0 或更高版本才能进行自动重新配置。Spring AMQP 可提供发布、多线程用户生成和消息转换器。它还可以促进 AMQP 资源的管理，同时提升依赖项输入和声明配置。

如果 Cloud Foundry 检测到 `org.springframework.amqp.rabbit.connection.ConnectionFactory` Bean 就会发生自动重新配置。Spring 应用程序上下文文件中的以下代码段展示了一个示例，该示例定义了 Cloud Foundry 将依次检测并进行可能的自动重新配置的 Bean 类型：

```xml
<rabbit:connection-factory
    id="rabbitConnectionFactory"
    host="localhost"
    password="testpwd"
    port="1238"
    username="testuser"
    virtual-host="virthost" />
```

Cloud Foundry 将创建一个 `org.springframework.amqp.rabbit.connection.CachingConnectionFactory`，其中含有其自身针对以下属性的值：host、virtual-host、port、username、password。

## 自动重新配置的限制

Cloud Foundry 只有在以下项针对您的应用程序为 true 时才能对应用程序进行自动重新配置：

+ 您只能将一种给定服务类型的*一个* 服务实例绑定到您的应用程序。在此上下文中，MySQL 和 vFabric Postgres 被认为是相同的服务类型（关系数据库），因此如果您已经将 MySQL 和 vFabric Postgres 服务绑定到您的应用程序，自动重新配置将*不会* 发生。
+ 您只能在您的 Spring 应用程序上下文文件中包含一种匹配类型的*一个* Bean。例如，您只能有一个 `javax.sql.DataSource` 类型的 Bean。

另请注意，如果发生了自动重新配置，但您已对服务进行了自定义配置（例如池大小或连接属性），则 Cloud Foundry 会忽略自定义配置。

## 选择退出自动重新配置机制

有些时候，您可能不希望 Cloud Foundry 使用本部分中描述的方法对您的 Spring 应用程序进行自动重新配置。有两种方法可以退出自动重新配置机制：

+ 当您使用 VMC 或 STS 部署应用程序时，指定框架为 `JavaWeb` 而不是 `Spring`。注意，在此情况下，您的应用程序将无法利用 Spring 配置文件功能。
+ 使用 Spring 应用程序上下文文件中的 `<cloud:>` 命名空间元素直接创建代表服务的 Bean。这将使得自动重新配置机制不再必要。请参见[直接配置应用程序使用 Cloud Foundry 服务](#explicitly-configuring-your-application-to-use-cloud-foundry-services)。

## 直接配置应用程序使用 Cloud Foundry 服务

本部分说明了您在 Spring 应用程序中必须执行的简单配置步骤，以使这些应用程序可以使用 Cloud Foundry 服务。请参见[配置应用程序使用 Cloud Foundry](/frameworks.html)，以便获取受支持 Cloud Foundry 服务的完整列表。

在 Spring 应用程序中使用 Cloud Foundry 服务的最简单方法就是声明 `<cloud:>` 命名空间，将其指向 Cloud Foundry 架构，然后使用在 `<cloud>` 命名空间中定义的特定于服务的元素。例如，仅使用应用程序上下文文件中的单一 XML 行，您可以创建一个 JDBC 数据源或 RabbitMQ 连接工厂，以便在特定 Bean 定义中使用。如果您的应用程序需要，您可以配置多个数据源或连接工厂。如果您愿意，还可以进一步配置这些云服务，但这完全是自愿的，因为 Cloud Foundry 会使用常用的配置值来创建典型服务实例，而这些服务实例对于大多数用途来说完全足够。总体而言，使用 `<cloud:>` 命名空间会针对您的应用程序所使用的 Cloud Foundry 服务的数量和类型为您提供尽可能多的控制。

更新您的 Spring 应用程序以使用任意 Cloud Foundry 服务的基本步骤如下所示：

* 更新您的应用程序构建流程，向 `org.cloudfoundry.cloudfoundry-runtime` 项目添加依赖项。例如，如果您使用 Maven 来构建您的应用程序，则以下 `pom.xml` 代码段展示了如何添加此依赖项：

```xml
<dependencies>
    <dependency>
        <groupId>org.cloudfoundry</groupId>
        <artifactId>cloudfoundry-runtime</artifactId>
        <version>0.8.1</version>
    </dependency>

    <!-- additional dependency declarations -->
</dependencies>
```

*  更新您的应用程序构建流程，添加 Spring Framework Milestone Repository。以下 `pom.xml` 代码段展示了如何在 Maven 中执行此操作：

```xml
<repositories>
    <repository>
          <id>org.springframework.maven.milestone</id>
           <name>Spring Maven Milestone Repository</name>
           <url>http://maven.springframework.org/milestone</url>
           <snapshots>
                   <enabled>false</enabled>
           </snapshots>
    </repository>

    <!-- additional repository declarations -->
</repositories>
```

*  在您的 Spring 应用程序中，更新将包含 Cloud Foundry 服务声明（例如数据源）的所有应用程序上下文文件，方法是：添加 `<cloud:>` 命名空间声明和 Cloud Foundry 服务架构的位置，如下面的代码段所示：

```xml

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xmlns:cloud="http://schema.cloudfoundry.org/spring"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-3.1.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context-3.1.xsd
        http://schema.cloudfoundry.org/spring
        http://schema.cloudfoundry.org/spring/cloudfoundry-spring.xsd
        >

    <!-- bean declarations -->

</beans>
```

*  您现在就可以使用 `<cloud:>` 命名空间和特定元素的名称（例如 `data-source`）在 Spring 应用程序上下文文件中指定 Cloud Foundry 服务。Cloud Foundry 可为每个受支持的服务提供元素：数据库（MySQL 和 vFabric Postgres）、Redis、MongoDB 和 RabbitMQ。

    下面的示例展示了将使用 `<cloud:data-source>` 元素输入到 JdbcTemplate 中的简单数据源配置。

```xml
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xmlns:cloud="http://schema.cloudfoundry.org/spring"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-3.1.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context-3.1.xsd
        http://schema.cloudfoundry.org/spring
        http://schema.cloudfoundry.org/spring/cloudfoundry-spring.xsd
        >

    <cloud:data-source id="dataSource" />

    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
      <property name="dataSource" ref="dataSource" />
    </bean>

        <!-- additional beans in your application -->

</beans>
```

当您稍后使用 VMC 或 STS 部署应用程序时，您可以将特定数据服务（如 MySQL 或 vFabric Postgres）绑定到应用程序，且 Cloud Foundry 会创建一个服务实例。注意，在上面的示例中，您并未指定典型的数据源属性（例如 `driverClassName`、`url` 或 `username`）- 这是因为 Cloud Foundry 会自动为您处理这些属性。

有关所有您可在 Spring 应用程序上下文文件中用来访问 Cloud Foundry 服务的 `<cloud:>` 元素的完整信息，您可以参见以下部分：

+ [\<cloud:data-source\>：为 MySQL 或 vFabric Postgres 数据库配置 JDBC 数据源](#clouddata-source)
+ [\<cloud:mongo-db-factory\>：配置 MongoDB 连接工厂](#cloudmongo-db-factory)
+ [\<cloud:redis-connection-factory\>：配置 Redis 连接工厂](#cloudredis-connection-factory)
+ [\<cloud:rabbit-connection-factory\>：配置 RabbitMQ 连接工厂](#cloudrabbit-connection-factory)
+ [\<cloud:service-scan\> 向 @Autowired Bean 输入服务 ](#cloudservice-scan)
+ [\<cloud:properties\> 获取 Cloud Foundry 服务信息](#cloudproperties)

* 在您完成指定要在应用程序中使用的所有 Cloud Foundry 服务的工作后，您可以使用标准 Cloud Foundry 客户端命令（VMC、SpringSource 工具套件或 Eclipse 插件）来创建这些服务的实例，将其绑定到您的应用程序，然后将您的应用程序部署到托管的 Cloud Foundry (cloudfoundry.com) 或您的本地 Micro Cloud Foundry 实例。有关如何使用这些工具的详细信息，请参见[部署应用程序](/tools/deploying-apps.html)。

## \<cloud:data-source\>

`<cloud:data-source>` 元素可以为您提供一种简单的方法，为您的 Spring 应用程序配置 JDBC 数据源。稍后，当您实际部署应用程序时，您可以将特定数据库服务实例绑定到应用程序，例如 MySQL 或 vFabric Postgres。

以下示例展示了一种简单的方法，用于配置将输入到 `org.springframework.jdbc.core.JdbcTemplate` Bean 的 JDBC 数据源：

```xml
<cloud:data-source id="dataSource" />

<bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
  <property name="dataSource" ref="dataSource" />
</bean>
```
在前面的示例中，请注意，未提供有关数据源的特定信息，例如 JDBC 驱动程序类名、访问数据库的特定 URL 以及数据库用户。Cloud Foundry 会在运行时使用您绑定到应用程序的特定数据库服务类型的适当信息处理所有这些信息。

**属性**

下表列出了 `<cloud:data-source>` 元素的属性。

<table class="std">
<tr>
   <th>属性</th>
   <th>说明</th>
   <th>类型</th>
 </tr>
 <tr>
   <td>id</td>
   <td>此数据源的 ID。JdbcTemplate Bean 在引用数据源时使用此 ID。<br>默认值为所绑定服务实例的名称。</td>
   <td>字符串</td>
 </tr>
 <tr>
   <td>service-name</td>
   <td>数据源服务的名称。<br>您可以仅在绑定多个数据库服务到应用程序且希望指定将哪个特定服务实例绑定到特定 Spring Bean 时指定此属性。默认值为所绑定服务实例的名称。</td>
   <td>字符串</td>
 </tr>
</table>

**高级数据源配置**

上面的内容展示了如何配置一个非常简单的 JDBC 数据源，而当 Cloud Foundry 在运行时实际创建数据源时，会使用最为常用的配置选项。但是，您可以使用下面的两个 `<cloud:data-source>` 子元素来指定其中的某些配置选项：`<cloud:connection>` 和 `<cloud:pool>`。

在建立新的数据库连接时，`<cloud:connection>` 子元素会使用您用来指定希望发送给 JDBC 驱动程序的连接属性的单一字符串属性 (`properties`)。字符串的格式必须为使用分号分隔的名称/值对 (`[propertyName=property;]`)。

`<cloud:pool>` 子元素会使用下面的两个属性：

<table class="std">
 <tr>
   <th>属性</th>
   <th>说明</th>
   <th>类型</th>
   <th>默认值</th>
 </tr>
 <tr>
   <td>pool-size</td>
   <td>指定连接池的大小。将此值设置为池中的最大连接数，或连接数的上限与下限之间的范围，使用短线隔开。</td>
   <td>整数</td>
   <td>默认的最小值为 0，最大值为 8。这些默认值与 Apache Commons Pool 中的默认值相同。</td>
 </tr>
 <tr>
   <td>max-wait-time</td>
   <td>如果没有可用的连接，此属性可指定在出现异常之前，连接池等待连接返回的最长时间（以毫秒为单位）。指定 `-1` 表示连接池应永久等待。</td>
   <td>整数</td>
   <td>默认值为 `-1`（永久）。</td>
 </tr>
</table>

下面的示例展示了如何使用这些高级数据源配置选项：

```xml
        <cloud:data-source id="mydatasource">
            <cloud:connection properties="charset=utf-8" />
            <cloud:pool pool-size="5-10" max-wait-time="2000" />
        </cloud:data-source>
```
在前面的示例中，JDBC 驱动程序收到了指定它应使用 UTF-8 字符集的属性。在任意给定时间点，池中连接数的上下限应分别为 10 和 5。在没有可用连接的情况下，连接池等待返回连接的最大时间长度为 2000 毫秒（2 秒），在这之后，JDBC 连接池会出现异常。

## \<cloud:mongo-db-factory \>

`<cloud:mongo-db-factory>` 可提供一种简单的方法，为您的 Spring 应用程序配置 MongoDB 连接工厂。

下面的示例展示了将输入到 `org.springframework.data.mongodb.core.MongoTemplate` 对象的 MongoDbFactory 配置：

```xml
<cloud:mongo-db-factory id="mongoDbFactory" />

<bean id="mongoTemplate" class="org.springframework.data.mongodb.core.MongoTemplate">
    <constructor-arg ref="mongoDbFactory"/>
</bean>
```

**属性**

下表列出了 `<cloud:mongo-db-factory>` 元素的属性。

<table class="std">
 <tr>
   <th>属性</th>
   <th>说明</th>
   <th>类型</th>
 </tr>
 <tr>
   <td>id</td>
   <td>此 MongoDB 连接工厂的 ID。MongoTemplate Bean 在引用连接工厂时使用此 ID。<br>默认值为所绑定服务实例的名称。</td>
   <td>字符串</td>
 </tr>
 <tr>
   <td>service-name</td>
   <td>MongoDB 服务的名称。<br>您可以仅在绑定多个 MongoDB 服务到应用程序且希望指定将哪个特定服务实例绑定到特定 Spring Bean 时指定此属性。默认值为所绑定服务实例的名称。</td>
   <td>字符串</td>
 </tr>
 <tr>
   <td>write-concern</td>
   <td>控制写入数据存储的行为。此属性的值与 `com.mongodb.WriteConcern` 类的值相对应。
   <p>如果您不指定此属性，则不会为数据库连接设置 `WriteConcern` 且所有的写入行为都会默认为 NORMAL。</p>
   <p>此属性的可能值如下所示：</p>
	<ul>
	  <li><b>NONE</b>：不抛出异常，甚至不抛出网络错误异常。</li>
	  <li><b>NORMAL</b>：仅抛出网络错误异常，不抛出服务器错误异常。</li>
	  <li><b>SAFE</b>：MongoDB 服务等待服务器完成写操作。在出现网络错误和服务器错误时出现异常。</li>
	  <li><b>FSYNC_SAVE</b>：MongoDB 服务等待服务器将数据刷新到磁盘，然后再执行写操作。在出现网络错误和服务器错误时出现异常。</li>
	</ul>
    </td>
   <td>字符串</td>
 </tr>
</table>

## 高级 MongoDB 配置

上面的内容展示了如何使用选项的默认值来配置简单的 MongoDB 连接工厂。这对于很多环境来说已经够用。但是，您也可以通过指定 `<cloud:mongo-db-factory>` 的可选 `<cloud:mongo-options>` 子元素来进一步配置连接工厂。

`<cloud:mongo-options>` 子元素会使用下面的两个属性：

<table class="std">
 <tr>
   <th>属性</th>
   <th>说明</th>
   <th>类型</th>
   <th>默认值</th>
 </tr>
 <tr>
   <td>connections-per-host</td>
   <td>指定 MongoDB 实例允许为每个主机建立的最大连接数目。这些连接在空闲时将保留在池中。池中的连接用完后，需要连接的任何操作都将阻滞，等待可用连接。</td>
   <td>整数</td>
   <td>10</td>
 </tr>
 <tr>
   <td>max-wait-time</td>
   <td>指定线程等待连接变为可用状态的最长等待时间（以毫秒为单位）。</td>
   <td>整数</td>
   <td>120,000（2 分钟）</td>
 </tr>
</table>

下面的示例展示了如何使用高级 MongoDB 选项：

```xml
    <cloud:mongo-db-factory id="mongoDbFactory" write-concern="FSYNC_SAFE">
        <cloud:mongo-options connections-per-host="12" max-wait-time="2000" />
    </cloud:mongo-db-factory>
```

在上面的示例中，最大连接数设置为 12，线程等待连接的最大时间长度设置为 1 秒。同时指定 WriteConcern 为尽可能最安全的状态 (`FSYNC_SAFE`)。

## \<cloud:redis-connection-factory \>

`<cloud:redis-connection-factory>` 可提供一种简单的方法，为您的 Spring 应用程序配置 Redis 连接工厂。

下面的示例展示了将输入到 `org.springframework.data.redis.core.StringRedisTemplate` 对象的 `RedisConnectionFactory` 配置：

``` xml
    <cloud:redis-connection-factory id="redisConnectionFactory" />

    <bean id="redisTemplate" class="org.springframework.data.redis.core.StringRedisTemplate">
        <property name="connection-factory" ref="redisConnectionFactory"/>
    </bean>
```

**属性**

下表列出了 `<cloud:redis-connection-factory>` 元素的属性。

<table class="std">
 <tr>
   <th>属性</th>
   <th>说明</th>
   <th>类型</th>
 </tr>
 <tr>
   <td>id</td>
   <td>此 Redis 连接工厂的 ID。RedisTemplate Bean 在引用连接工厂时使用此 ID。<br>默认值为所绑定服务实例的名称。</td>
   <td>字符串</td>
 </tr>
 <tr>
   <td>service-name</td>
   <td>Redis 服务的名称。<br>您可以仅在绑定多个 Redis 服务到应用程序且希望指定将哪个特定服务实例绑定到特定 Spring Bean 时指定此属性。默认值为所绑定服务实例的名称。</td>
   <td>字符串</td>
 </tr>
</table>

**高级 Redis 配置**

上面的内容展示了如何配置一个非常简单的 Redis 连接工厂，而当 Cloud Foundry 在运行时实际创建工厂时，会使用最为常用的配置选项。但是，您可以使用 `<cloud:redis-connection-factory>` 的 `<cloud:pool>` 子元素来更改其中的某些配置选项。

`<cloud:pool>` 子元素会使用下面的两个属性：

<table class="std">
 <tr>
   <th>属性</th>
   <th>说明</th>
   <th>类型</th>
   <th>默认值</th>
 </tr>
 <tr>
   <td>pool-size</td>
   <td>指定连接池的大小。将此值设置为池中的最大连接数，或连接数的上限与下限之间的范围，使用短线隔开。</td>
   <td>整数</td>
   <td>默认的最小值为 0，最大值为 8。这些默认值与 Apache Commons Pool 中的默认值相同。</td>
 </tr>
 <tr>
   <td>max-wait-time</td>
   <td>如果没有可用的连接，此属性可指定在出现异常之前，连接池等待连接返回的最长时间（以毫秒为单位）。指定 `-1` 表示连接池应永久等待。</td>
   <td>整数</td>
   <td>默认值为 `-1`（永久）。</td>
 </tr>
</table>

下面的示例展示了如何使用这些高级 Redis 配置选项：

``` xml
    <cloud:redis-connection-factory id="myRedisConnectionFactory">
        <cloud:pool pool-size="5-10" max-wait-time="2000" />
    </cloud:redis-connection-factory>
```

在上面的示例中，在任意给定时间点，池中连接数的上下限应分别为 10 和 5。在没有可用连接的情况下，连接池等待返回连接的最大时间长度为 2000 毫秒（2 秒），在这之后，Redis 连接池会出现异常。

## \<cloud:rabbit-connection-factory \>

`<cloud:rabbit-connection-factory>` 可提供一种简单的方法，为您的 Spring 应用程序配置 RabbitMQ 连接工厂。

以下 Spring 应用程序上下文文件的完整示例展示了将注入 `rabbitTemplate` 对象的 `RabbitConnectionFactory` 配置。在该示例的后面还说明了该示例使用 `<rabbit:>` 命名空间执行特定于 RabbitMQ 的配置：

``` xml
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:rabbit="http://www.springframework.org/schema/rabbit"
       xmlns:cloud="http://schema.cloudfoundry.org/spring"
       xsi:schemaLocation="http://www.springframework.org/schema/mvc   http://www.springframework.org/schema/mvc/spring-mvc-3.0.xsd
           http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
           http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.0.xsd
           http://www.springframework.org/schema/rabbit http://www.springframework.org/schema/rabbit/spring-rabbit-1.0.xsd
           http://schema.cloudfoundry.org/spring http://schema.cloudfoundry.org/spring/cloudfoundry-spring.xsd">

    <!-- Obtain a connection to the RabbitMQ via cloudfoundry-runtime: -->
    <cloud:rabbit-connection-factory id="rabbitConnectionFactory" />

    <!-- Set up the AmqpTemplate/RabbitTemplate: -->
    <rabbit:template id="rabbitTemplate"
        connection-factory="rabbitConnectionFactory" />

    <!-- Request that queues, exchanges and bindings be automatically declared on the broker: -->
    <rabbit:admin connection-factory="rabbitConnectionFactory"/>

    <!-- Declare the "messages" queue: -->
    <rabbit:queue name="messages" durable="true"/>

    <!-- additional beans in your application -->

</beans>
```

在上面的示例中，说明了 XML 文件顶部的 `<rabbit:>` 命名空间的定义和位置。然后，使用此命名空间将 RabbitTemplate 和 RabbitAdmin 对象配置为 Spring AMQP 的主要入口并使用 RabbitMQ 代理声明名为 `messages` 的队列。

有关在您的 Spring 应用程序中使用 RabbitMQ 的详细信息，请参见 [RabbitMQ 和 Spring：其他编程信息](#rabbitmq-and-spring-additional-programming-information)。

**属性**

下表列出了 `<cloud:rabbit-connection-factory>` 元素的属性。

<table class="std">
 <tr>
   <th>属性</th>
   <th>说明</th>
   <th>类型</th>
 </tr>
 <tr>
   <td>id</td>
   <td>此 RabbitMQ 连接工厂的 ID。RabbitTempalte Bean 在引用连接工厂时使用此 ID。<br>默认值为所绑定服务实例的名称。</td>
   <td>字符串</td>
 </tr>
 <tr>
   <td>service-name</td>
   <td>RabbitMQ 服务的名称。<br>您可以仅在绑定多个 RabbitMQ 服务到应用程序且希望指定将哪个特定服务实例绑定到特定 Spring Bean 时指定此属性。默认值为所绑定服务实例的名称。</td>
   <td>字符串</td>
 </tr>
</table>

**高级 RabbitMQ 配置**

上面的内容展示了如何配置一个非常简单的 RabbitMQ 连接工厂，而当 Cloud Foundry 在运行时实际创建工厂时，会使用最为常用的配置选项。但是，您可以使用 `<cloud:rabbit-connection-factory>` 的 `<cloud:rabbit-options>` 子元素来更改其中的某些配置选项。

`<cloud:rabbit-options>` 子元素可以定义一个名为 `channel-cache-size` 的属性，您可以将该属性设置为指定通道缓存的大小。默认值为 1。

下面的示例展示了如何使用这些高级 RabbitMQ 配置选项：

``` xml
        <cloud:rabbit-connection-factory id="rabbitConnectionFactory" >
            <cloud:rabbit-options channel-cache-size="10" />
        </cloud:rabbit-connection-factory>
```

在前面的示例中，RabbitMQ 连接工厂的通道缓存大小设置为 10。

## \<cloud:service-scan\>

`<cloud:service-scan>` 元素会扫描绑定到应用程序的所有服务，并为每个含有 `@org.springframework.beans.factory.annotation.Autowired` 注释的服务创建适当类型的 Spring Bean。`<cloud:service-scan>` 元素会作为核心 Spring 中 `<context:component-scan>` 的云等效组件，它可扫描 CLASSPATH 以寻找含有特定注释的 Bean 并为每个注释创建一个 Bean。

在开发应用程序的初始阶段，`<cloud:service-scan>` 非常有用，因为您可以直接访问服务 Bean，而无需将 `<cloud:>` 元素直接添加到您绑定每个新服务的 Spring 应用程序上下文文件中。

`<cloud:service-scan>` 元素不含任何属性或子元素，例如：

``` xml
         <cloud:service-scan />
```

在您的 Java 代码中，您必须使用 `@Autowired` 注释每个依赖项，从而自动为相应服务创建一个 Bean。例如：

``` java
  package cf.examples;

  import org.springframework.beans.factory.annotation.Autowired;

  ....

  @Autowired DataSource dataSource;
  @Autowired ConnectionFactory rabbitConnectionFactory;
  @Autowired RedisConnectionFactory redisConnectionFactory;
  @Autowired MongoDbFactory mongoDbFactory;

  ...
```

如果对于每个服务类型您都只绑定了*一个* 服务到您的应用程序，那么仅使用 `@Autowired` 注释就已足够。如果您绑定了多个服务（例如，您将两个不同的 MySQL 服务实例绑定到同一应用程序），那您必须使用 `@Qualifier` 注释来将 Spring Bean 与特定服务示例匹配。

例如，假设您将两个 MySQL 服务（名为 `inventory-db` 和 `pricing-db`）绑定到您的应用程序，请按照下面的示例使用 `@Qualifier` 注释指定将哪个服务实例应用到哪个 Spring Bean：

``` java
  @Autowired @Qualifier("inventory-db") DataSource inventoryDataSource;
  @Autowired @Qualifier("pricing-db") DataSource pricingDataSource;
```

## \<cloud:properties\>

`<cloud:properties>` 元素会将有关应用程序及其绑定服务的基本信息作为属性公开。然后，您的应用程序就可以通过 Spring 属性占位符支持来使用这些属性。

`<cloud:properties>` 元素仅有一个属性 (`id`)，它可指定 Properties Bean 的名称。将此 ID 作为对 `<context:property-placeholder>` 的引用，您可以将它用于保留所有由 Cloud Foundry 公开的属性。然后，您就可以在您的其他 Bean 定义中使用此属性了。

注意，如果您使用的是 Spring Framework 3.1（或更高版本），这些属性将自动变为可用状态，而无需在您的应用程序上下文文件中添加 `<cloud:properties>`。

下面的示例展示了如何在您的 Spring 应用程序上下文文件中使用此元素：

``` xml
    <cloud:properties id="cloudProperties" />

    <context:property-placeholder properties-ref="cloudProperties" />

    <bean class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="user"
                  value="${cloud.services.mysql.connection.username}" />
    ...
    </bean>
```

在前面的示例中，`cloud.services.mysql.connection.username` 是一个由 Cloud Foundry 公开的属性。

有关由 Cloud Foundry 公开的属性的完整列表以及更加详细的示例，请参见[访问 Cloud Foundry 属性](#accessing-cloud-foundry-properties)。

## RabbitMQ 和 Spring：其他编程信息

本部分提供了有关在您部署到 Cloud Foundry 的 Spring 应用程序中使用 RabbitMQ 的其他信息。本部分并不能作为 RabbitMQ 和 Spring 的完整教程，有关 RabbitMQ 和 Spring 的完整教程，请参见以下资源：

+	[RabbitMQ 教程](http://www.rabbitmq.com/getstarted.html)，包含有关在您的应用程序中创建消息的基本内容。
+	[下载](http://www.rabbitmq.com/download.html)、[安装](http://www.rabbitmq.com/install.html)和[配置](http://www.rabbitmq.com/configure.html) RabbitMQ
+       [Spring AMPQ 参考文档](http://static.springsource.org/spring-amqp/docs/1.0.x/reference/html/)

RabbitMQ 服务可通过 [AMQP 协议](http://www.amqp.org/)（版本 0.8 和 0.9.1）访问，您的应用程序将需要访问 AMQP 客户端库才能使用此服务。Spring AMQP 项目允许 AMQP 应用程序使用 Spring 结构构建。

下面的示例 `pom.xml` 文件展示了除上面描述的 `cloudfoundry-runtime` 依赖项以外的 RabbitMQ 依赖项和代码库：

```xml
    <repositories>
        <repository>
              <id>org.springframework.maven.milestone</id>
               <name>Spring Maven Milestone Repository</name>
               <url>http://maven.springframework.org/milestone</url>
               <snapshots>
                       <enabled>false</enabled>
               </snapshots>
        </repository>
    </repositories>

    <dependency>
        <groupId>cglib</groupId>
        <artifactId>cglib-nodep</artifactId>
        <version>2.2</version>
    </dependency>

    <dependency>
        <groupId>org.springframework.amqp</groupId>
        <artifactId>spring-rabbit</artifactId>
        <version>1.0.0.RC2</version>
    </dependency>

    <dependency>
        <groupId>org.cloudfoundry</groupId>
        <artifactId>cloudfoundry-runtime</artifactId>
        <version>0.7.1</version>
    </dependency>
```

然后按下面的方法更新您的应用程序控制器/逻辑：

* 添加消息传送库：

```java
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.amqp.core.AmqpTemplate;
```

* 按照下面的 Java 代码段读写消息：

``` java
   @Controller
   public class HomeController {
       @Autowired AmqpTemplate amqpTemplate;

       @RequestMapping(value = "/")
       public String home(Model model) {
           model.addAttribute(new Message());
           return "WEB-INF/views/home.jsp";
       }

       @RequestMapping(value = "/publish", method=RequestMethod.POST)
       public String publish(Model model, Message message) {
           // Send a message to the "messages" queue
           amqpTemplate.convertAndSend("messages", message.getValue());
           model.addAttribute("published", true);
           return home(model);
       }

       @RequestMapping(value = "/get", method=RequestMethod.POST)
       public String get(Model model) {
           // Receive a message from the "messages" queue
           String message = (String)amqpTemplate.receiveAndConvert("messages");
           if (message != null)
               model.addAttribute("got", message);
           else
               model.addAttribute("got_queue_empty", true);

           return home(model);
   }
```

## 使用 Spring 配置文件有条件地设置 Cloud Foundry 配置

前面的部分说明了如何使用 `<cloud:>` 命名空间轻松为部署到 Cloud Foundry 的 Spring 应用程序配置服务（例如数据源和 RabbitMQ 连接工厂）。但是，您可能并不总是希望将您的应用程序部署到 Cloud Foundry，例如，您有时可能希望使用本地环境在迭代开发的过程中测试应用程序。在这种情况下，*有条件地设置* 应用程序配置就非常有用，因为这样仅在特定条件为 true 时才会激活特定片段。有条件地设置应用程序配置使您的应用程序能够方便地适用于很多不同的环境，这样您就不需要在将应用程序部署到您的本地环境（甚至是 Cloud Foundry）时手动更改配置。要启用此功能，请使用 Spring Framework 3.1 或更高版本中的 Spring*配置文件* 功能。

基本理念是使用适当 Spring 应用程序上下文文件中的嵌套 `<beans>` 元素的 `profile` 属性为特定环境的配置分组。您可以创建自己的自定义配置文件，但与 Cloud Foundry 的上下文最相关的配置文件是 `default` 和 `cloud`。

当您将 Spring 应用程序部署到 Cloud Foundry 时，Cloud Foundry 会自动启用 `cloud` 配置文件。这样，特定于 Cloud Foundry 的应用程序配置就可以有一个预定义的方便位置。然后，对 `cloud` 配置文件块内的 `<cloud:>` 命名空间的所有具体使用情况进行分组，以使应用程序可以在 Cloud Foundry 环境外运行。如果您将应用程序部署到非 Cloud Foundry 环境，那么在完成上述步骤之后，使用 `default` 配置文件（或自定义配置文件）来分组将使用的非 Cloud Foundry 配置。

下面的示例显示，Spring `MongoTemplate` 用两个连接工厂中的数据加以填充，这两个连接工厂是分别采用两种备选配置方式中的一种进行配置的。在 Cloud Foundry 上运行时（`cloud` 配置文件），连接工厂是自动配置的。不在 Cloud Foundry 上运行时（`default` 配置文件），连接工厂是使用运行 MongoDB 实例的连接设置手动配置的。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans  xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:cloud="http://schema.cloudfoundry.org/spring"
        xmlns:jdbc="http://www.springframework.org/schema/jdbc"
        xmlns:util="http://www.springframework.org/schema/util"
        xmlns:mongo="http://www.springframework.org/schema/data/mongo"
        xsi:schemaLocation="http://www.springframework.org/schema/data/mongo
          http://www.springframework.org/schema/data/mongo/spring-mongo-1.0.xsd
          http://www.springframework.org/schema/jdbc
          http://www.springframework.org/schema/jdbc/spring-jdbc-3.1.xsd
          http://schema.cloudfoundry.org/spring
          http://schema.cloudfoundry.org/spring/cloudfoundry-spring.xsd
          http://www.springframework.org/schema/beans
          http://www.springframework.org/schema/beans/spring-beans-3.1.xsd
          http://www.springframework.org/schema/util
          http://www.springframework.org/schema/util/spring-util-3.1.xsd">

        <bean id="mongoTemplate" class="org.springframework.data.mongodb.core.MongoTemplate">
           <constructor-arg ref="mongoDbFactory" />
        </bean>

        <beans profile="default">
           <mongo:db-factory id="mongoDbFactory" dbname="pwdtest" host="127.0.0.1" port="27017" username="test_user" password="efgh" />
        </beans>

        <beans profile="cloud">
           <cloud:mongo-db-factory id="mongoDbFactory" />
        </beans>

</beans>
```

注意，`<beans profile="value">` 元素嵌套于标准根 `<beans>` 元素中。`cloud` 配置文件中的 MongoDB 连接工厂使用 `<cloud:>` 命名空间，`default` 配置文件中的连接工厂配置使用 `<mongo:>` 命名空间。您现在就可以将此应用程序部署到两个不同的环境中，而无需在从一个环境转换到另一个环境时手动更改其配置。

有关使用 Spring 配置文件（Spring Framework 3.1 中的新功能）的详细信息，请参见[SpringSource 博客](http://blog.springsource.com/2011/02/11/spring-framework-3-1-m1-released/)。

## 通过部署的 Spring 应用程序向 Cloud Foundry 发送电子邮件

为了防范垃圾邮件及其他滥用行为，会阻止从在 Cloud Foundry 上运行的应用程序发送的 SMTP 消息。但是，如本部分中所述，如果将您的应用程序部署到 Cloud Foundry，应用程序仍可以发送电子邮件。

服务提供商（如 [SendGrid](http://sendgrid.com)）可以通过 HTTP Web 服务代表您发送电子邮件，当您将应用程序部署到 Cloud Foundry 时就可使用这种方法。但是，如果您的应用程序也在数据中心中运行，在这种情况下，您可能希望使用公司的 SMTP 服务器。这是一个使用 [Spring 配置文件](#using-spring-profiles-to-conditionalize-cloud-foundry-configuration)有条件地设置应用程序发送电子邮件方式的示例，具体取决于部署应用程序的具体位置。这使您的应用程序能够方便地适用于不同的环境，而无需手动更新其配置。

以下 Spring 应用程序上下文的代码段展示了如何指定当应用程序在 Cloud Foundry 中运行时，您的应用程序应使用 SendGrid 发送电子邮件；说明了 `cloud` 配置文件的使用情况：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans  xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:cloud="http://schema.cloudfoundry.org/spring"

    ...

    <beans profile="cloud">
       <bean name="mailSender" class="example.SendGridMailSender">
          <property name="apiUser" value="youremail@domain.com" />
          <property name="apiKey" value="secureSecret" />
       </bean>
    </beans>

   ...

    <!-- additional beans in your application -->

</beans>
```

在此示例中，`example.SendGridMailSender` 是使用 SendGrid 服务提供商发送电子邮件的 Spring Bean，但是，此 Bean 仅在将应用程序部署到 Cloud Foundry 时才激活。如果您的应用程序实际在数据中心运行，则使用您的默认电子邮件服务器。

## 访问 Cloud Foundry 属性

Cloud Foundry 会将很多应用程序和服务属性直接公开到其部署的应用程序中。您部署的应用程序可以依次使用这些属性。这些由 Cloud Foundry 公开的属性包含有关该应用程序的基本信息（例如其名称和云提供商），以及当前绑定到该应用程序的所有服务的详细连接信息。

服务属性通常会使用以下任一格式：

        cloud.services.{service-name}.connection.{property}
        cloud.services.{service-name}.{property}

其中，`{service-name}` 引用您在部署时将服务绑定到应用程序所使用的服务名称。可以使用的特定连接属性取决于服务类型，请参见本部分结尾的表格，获取完整列表。

例如，假设在 VMC 中，您创建了一个名为 `my-postgres` 的 vFabric Postgres 服务，然后将它绑定到您的应用程序，Cloud Foundry 会公开有关此服务的以下属性，您的应用程序可以依次使用这些属性：

        cloud.services.my-postgres.connection.host
        cloud.services.my-postgres.connection.hostname
        cloud.services.my-postgres.connection.name
        cloud.services.my-postgres.connection.password
        cloud.services.my-postgres.connection.port
        cloud.services.my-postgres.connection.user
        cloud.services.my-postgres.connection.username
        cloud.services.my-postgres.plan
        cloud.services.my-postgres.type

放了方便起见，如果只有*一项* 属于给定类型的服务绑定到应用程序，Cloud Foundry 将根据服务类型而非服务名称来创建别名。例如，如果只有一项 MySQL 服务绑定到应用程序，属性将使用格式 `cloud.services.mysql.connection.{property}`。在这种情况下，Cloud Foundry 将使用以下别名：

+ `mysql`
+ `mongodb`
+ `postgresql`
+ `rabbitmq`
+ `redis`

如果您希望在应用程序中使用这些 Cloud Foundry 属性，请使用 `cloud` 配置文件中的 Spring 属性占位符；有关 Spring 配置文件的信息，在[使用 Spring 配置文件有条件地设置 Cloud Foundry 配置](#using-spring-profiles-to-conditionalize-cloud-foundry-configuration)中进行了简要说明。

例如，假设您将一个名为 `spring-mysql` 的 MySQL 服务绑定到您的应用程序，但您的应用程序需要 c3p0 连接池而非 Cloud Foundry 提供的连接池。但是，您仍希望为 MySQL 服务使用由 Cloud Foundry 定义的相同连接属性，特别是 username、password 和 JDBC URL。下面的 Spring 应用程序上下文代码段展示了如何实现此目标：

```xml
<beans profile="cloud">
   <bean id="c3p0DataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource" destroy-method="close">
      <property name="driverClass" value="com.mysql.jdbc.Driver" />
      <property name="jdbcUrl"
                value="jdbc:mysql://${cloud.services.spring-mysql.connection.host}:${cloud.services.spring-mysql.connection.port}/${cloud.services.spring-mysql.connection.name}" />
      <property name="user" value="${cloud.services.spring-mysql.connection.username}" />
      <property name="password" value="${cloud.services.spring-mysql.connection.password}" />
   </bean>
</beans>
```

下表列出了 Cloud Foundry 向部署应用程序公开的所有应用程序和服务属性。在属性名称中，`{service-name}` 引用了绑定服务的实际名称。

<table class="std">
 <tr>
   <th>属性</th>
   <th>相关服务类型</th>
   <th>说明</th>
 </tr>
 <tr>
   <td>cloud.application.name</td>
   <td>不适用。</td>
   <td>应用程序的名称。</td>
 </tr>
 <tr>
   <td>cloud.provider.url</td>
   <td>不适用。</td>
   <td>托管您的应用程序的云的 URL，例如 <tt>cloudfoundry.com</tt>。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.connection.db</td>
   <td>MongoDB</td>
   <td>Cloud Foundry 创建的数据库的名称。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.connection.host</td>
   <td>MongoDB</td>
   <td>运行 MongoDB 服务器的主机的名称或 IP 地址。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.connection.hostname</td>
   <td>MongoDB</td>
   <td>运行 MongoDB 服务器的主机的名称或 IP 地址。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.connection.name</td>
   <td>MongoDB</td>
   <td>连接到 MongoDB 数据库的用户的名称。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.connection.password</td>
   <td>MongoDB</td>
   <td>连接到 MongoDB 数据库的用户的密码。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.connection.port</td>
   <td>MongoDB</td>
   <td>MongoDB 服务器的侦听端口。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.connection.username</td>
   <td>MongoDB</td>
   <td>连接到 MongoDB 数据库的用户的名称。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.plan</td>
   <td>MongoDB</td>
   <td>服务的支付方案，例如<tt>免费</tt>。</td>
 </tr>
 <tr>
   <td>cloud.services.{<i>service-name</i>}.type</td>
<td>MongoDB</td>
<td>MongoDB 服务器的名称和版本。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.name</td>
<td>MySQL</td>
<td>Cloud Foundry 创建的 MySQL 数据库的名称。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.host</td>
<td>MySQL</td>
<td>运行 MySQL 服务器的主机的名称或 IP 地址。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.hostname</td>
<td>MySQL</td>
<td>运行 MySQL 服务器的主机的名称或 IP 地址。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.port</td>
<td>MySQL</td>
<td>MySQL 服务器的侦听端口。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.user</td>
<td>MySQL</td>
<td>连接到 MySQL 数据库的用户的名称。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.username</td>
<td>MySQL</td>
<td>连接到 MySQL 数据库的用户的名称。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.password</td>
<td>MySQL</td>
<td>连接到 MySQL 数据库的用户的密码。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.plan</td>
<td>MySQL</td>
<td>服务的支付方案，例如<tt>免费</td>。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.type</td>
<td>MySQL</td>
<td>MySQL 服务器的名称和版本。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.name</td>
<td>vFabric Postgres</td>
<td>Cloud Foundry 创建的 vFabric Postgres 数据库的名称。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.host</td>
<td>vFabric Postgres</td>
<td>运行 vFabric Postgres 服务器的主机的名称或 IP 地址。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.hostname</td>
<td>vFabric Postgres</td>
<td>运行 vFabric Postgres 服务器的主机的名称或 IP 地址。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.port</td>
<td>vFabric Postgres</td>
<td>vFabric Postgres 服务器的侦听端口。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.user</td>
<td>vFabric Postgres</td>
<td>连接到 vFabric Postgres 数据库的用户的名称。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.username</td>
<td>vFabric Postgres</td>
<td>连接到 vFabric Postgres 数据库的用户的名称。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.password</td>
<td>vFabric Postgres</td>
<td>连接到 vFabric Postgres 数据库的用户的密码。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.plan</td>
<td>vFabric Postgres</td>
<td>服务的支付方案，例如<tt>免费</tt>。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.type</td>
<td>vFabric Postgres</td>
<td>vFabric Postgres 服务器的名称和版本。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.url</td>
<td>RabbitMQ</td>
<td>用于连接到 AMPQ 代理的 URL。URL 包括主机、端口、用户名等。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.plan</td>
<td>RabbitMQ</td>
<td>服务的支付方案，例如<tt>免费</td>。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.type</td>
<td>RabbitMQ</td>
<td>RabbitMQ 服务器的名称和版本。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.host</td>
<td>Redis</td>
<td>运行 Redis 服务器的主机的名称或 IP 地址。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.hostname</td>
<td>Redis</td>
<td>运行 Redis 服务器的主机的名称或 IP 地址。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.port</td>
<td>Redis</td>
<td>Redis 服务器的侦听端口。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.name</td>
<td>Redis</td>
<td>连接到 Redis 数据库的用户的名称。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.connection.password</td>
<td>Redis</td>
<td>连接到 Redis 数据库的用户的密码。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.plan</td>
<td>Redis</td>
<td>服务的支付方案，例如<tt>免费</tt>。</td>
</tr>
<tr>
<td>cloud.services.{<i>service-name</i>}.type</td>
<td>Redis</td>
<td>Redis 服务器的名称和版本。</td>
</tr>
</table>


