---
title: RabbitMQ 与 Spring 一起使用
description: 从一个 Spring 应用程序入门使用 RabbitMQ 服务
tags:
    - spring
    - rabbitmq
    - 教程
    - 附代码
---

此教程讲解了如何在 Java 和 Spring 应用程序中使用用于 Cloud Foundry 的 RabbitMQ 服务。

消息传递在 Spring Web 应用程序的上下文中具有不同方式的用途。参见 RabbitMQ 主站点上[入门](http://www.rabbitmq.com/getstarted.html)区域，以获得一些思路。在教程中，我们将构建一个使用 RabbitMQ 的非常简单的应用程序，以将注意力集中于连接 RabbitMQ 服务的基础知识。当您理解这个教程后，您将能够将更实用的服务应用整合进您的 Cloud Foundry 上的 Spring 应用程序中。

此教程包括在 Cloud Foundry 上创建简单 Spring 应用程序以及将其与 RabbitMQ 服务挂钩的整个过程。如果您已经在 Cloud Foundry 上拥有自己的应用程序，您应该已经熟悉此处的大部分内容。如果是这样，您可直接跳到最后一部分内容，即讨论如何从您的应用程序访问 RabbitMQ 服务的部分。您还可以在 [on GitHub](https://github.com/rabbitmq/rabbitmq-coudfoundry-samples/tree/master/spring) 上找到已完成的应用程序的完整代码。

我们将构建的应用程序将由一个单个页面组成，它看上去像这样：

![page.png](http://support.cloudfoundry.com/attachments/token/kx0fcgzrgasd4eq/?name=page.png)

此应用程序能够发布消息至单个 RabbitMQ 队列和从单个 RabbitMQ 队列获取消息。我们可以在输入框中键入消息，单击“发布”按钮将其发布至队列。另外，我们可以单击获取按钮从队列得到消息，下一条消息将被显示，或者将会告诉您队列为空。


## 先决条件

在开始之前,您的开发计算机上须已经安装一些新程序。此指南假定您已经安装 [JDK 6](http://www.oracle.com/technetwork/java/javase/downloads/) 和 [Maven](http://maven.apache.org/)。

此教程将使用与 Cloud Foundry 进行交互的 vmc 命令行工具。如果您尚未安装 vmc，请遵循[此处](/tools/vmc/vmc.html) 的说明。请注意 vmc 会不断被增强，因此即使您已经安装了它，您也需要定期通过以下方法对其进行更新：

```bash
$ gem update vmc
```

vmc 不是与 Cloud Foundry 一起开发的唯一方法：[Spring 工具套件](http://www.springsource.org/sts)在 Eclipse 开发环境中支持 Clound Foundry。参见[此部分](http://www.springsource.org/sts)，查看如何在 STS 中使用 Cloud Foundry。

创建一个 Spring MVC 初始应用程序
现在我们将按照文章 [Green Beans: Spring MVC 入门](http://blog.springsource.org/2011/01/04/green-beans-getting-started-with-spring-mvc/) 所述创建一个最小的 Spring MVC 应用程序，并将其推送至 Cloud Foundry。应用程序源由五个文件组成。文件位置将遵循 Maven 常规项目布局。

src/main/webapp/WEB-INF/web.xml 直接交给 Spring 框架：

```xml
<!DOCTYPE web-app PUBLIC
 "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
 "http://java.sun.com/dtd/web-app_2_3.dtd" >

<web-app version="2.5" xmlns="http://java.sun.com/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd">
    <servlet>
        <servlet-name>appServlet</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>/WEB-INF/spring/servlet-context.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>appServlet</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```

Spring 应用程序上下文 XML 文件 src/main/webapp/WEB-INF/spring/servlet-context.xml 是最小的 Spring MVC 应用程序，它直接声明将对 MVC 使用基于注释的配置，而且将打包并扫描：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-3.0.xsd
                           http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
                           http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.0.xsd">
    <context:component-scan base-package="com.rabbitmq.cftutorial.simple"/>
    <mvc:annotation-driven/>
</beans>
```


控制器类 src/main/java/com/rabbitmq/cftutorial/simple/HomeController.java 直接交给 JSP 模板：

```java
package com.rabbitmq.cftutorial.simple;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {
    @RequestMapping(value = "/")
    public String home() {
        return "WEB-INF/views/home.jsp";
    }
}
```

而 JSP 模板 src/main/webapp/WEB-INF/views/home.jsp 将显示一个简单的静态页面。

```jsp
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<html>
  <head>
    <title>Simple RabbitMQ Application</title>
  </head>
  <body>
    <h1>Simple RabbitMQ Application</h1>
  </body>
</html>
```

最后，pom.xml 文件向 Maven 描述该项目：

```xml
 <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.rabbitmq.cftutorial</groupId>
  <artifactId>simple</artifactId>
  <packaging>war</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>cftutorial-simple</name>
  <description>Simple RabbitMQ Application</description>

  <properties>
      <java-version>1.6</java-version>
      <org.springframework-version>3.0.5.RELEASE</org.springframework-version>
  </properties>

  <dependencies>
      <dependency>
          <groupId>org.springframework</groupId>
          <artifactId>spring-context</artifactId>
          <version>${org.springframework-version}</version>
      </dependency>
      <dependency>
          <groupId>org.springframework</groupId>
          <artifactId>spring-webmvc</artifactId>
          <version>${org.springframework-version}</version>
      </dependency>

      <dependency>
          <groupId>javax.servlet</groupId>
          <artifactId>jstl</artifactId>
          <version>1.2</version>
      </dependency>
  </dependencies>

  <build>
      <plugins>
          <plugin>
              <groupId>org.apache.maven.plugins</groupId>
              <artifactId>maven-compiler-plugin</artifactId>
              <configuration>
                  <source>${java-version}</source>
                  <target>${java-version}</target>
              </configuration>
          </plugin>
      </plugins>
  </build>
</project>
```

下一步我们构建项目：

```bash
$ mvn package
[...]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESSFUL
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2 seconds
[INFO] Finished at: Tue Aug 02 14:04:59 BST 2011
[INFO] Final Memory: 17M/321M
[INFO] ------------------------------------------------------------------------
```

现在我们已准备好向 Cloud Foundry 推送应用程序。在进行 vmc 推送前更改为目标目录。这里，我将把我的应用程序称为“rabbit-simple”，但是您应该选择您自己的应用程序名称。

我们还可以在此时将服务与我们的应用程序捆绑。但是此时我们将不添加 rabbitmq 服务 — 我们将在初始应用程序运行后再这样做。

```bash
$ cd target
$ vmc push
Would you like to deploy from the current directory? [Yn]: y
Application Name: rabbit-simple
Application Deployed URL: 'rabbit-simple.cloudfoundry.com'?
Detected a Java SpringSource Spring Application, is this correct? [Yn]: y
Memory Reservation [Default:512M] (64M, 128M, 256M or 512M)
Creating Application: OK
Would you like to bind any services to 'rabbit-simple'? [yN]: n
Uploading Application:
  Checking for available resources: OK
  Processing resources: OK
  Packing application: OK
  Uploading (3K): OK
Push Status: OK
Staging Application: OK
Starting Application: OK
```

如果操作成功，您应该能够访问应用程序的 URL 和查看主页：

![home.png](http://support.cloudfoundry.com/attachments/token/119cuj9gvkhnzs4/?name=home.png)

## 扩展应用程序

我们已有在 Cloud Foundry 上运行的最小的 Spring MVC 应用程序，现在我们将添加演示 RabbitMQ 服务用途的所需部件。

我们使用页面元素扩展在 src/main/webapp/WEB-INF/views/home.jsp 处的 JSP 模板，以构建介绍部分中所示的页面：

```jsp
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ page session="false" %>
<html>
  <head>
    <title>Simple RabbitMQ Application</title>
  </head>
  <body>
    <h1>Simple RabbitMQ Application</h1>

    <h2>Publish a message</h2>

    <form:form modelAttribute="message" action="/publish" method="post">
      <form:label for="value" path="value">Message to publish:</form:label>
      <form:input path="value" type="text"/>

      <input type="submit" value="Publish"/>
    </form:form>

    <c:if test="${published}">
      <p>Published a message!</p>
    </c:if>

    <h2>Get a message</h2>

    <form:form action="/get" method="post">
      <input type="submit" value="Get one"/>
    </form:form>

    <c:choose>
      <c:when test="${got_queue_empty}">
        <p>Queue empty</p>
      </c:when>
      <c:when test="${got != null}">
        <p>Got message: <c:out value="${got}"/></p>
      </c:when>
    </c:choose>
  </body>
</html>
```

我们需要对控制器类添加操作，以支持发布和获取表单：

```java
package com.rabbitmq.cftutorial.simple;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.ui.Model;

@Controller
public class HomeController {
    @RequestMapping(value = "/")
    public String home(Model model) {
        model.addAttribute(new Message());
        return "WEB-INF/views/home.jsp";
    }

    @RequestMapping(value = "/publish", method=RequestMethod.POST)
    public String publish(Model model) {
        return home(model);
    }

    @RequestMapping(value = "/get", method=RequestMethod.POST)
    public String get(Model model) {
        return home(model);
    }
}
```

我们还需添加一个消息类，以支持发布表单。它仅为消息保存字符串值。

```java
package com.rabbitmq.cftutorial.simple;

public class Message {
    private String value;

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
```

通过这些添加项，我们可在 Cloud Foundry 上更新应用程序，并可查看：

```bash
$ mvn package
[...]
$ cd target
$ vmc update rabbit-simple
Uploading Application:
  Checking for available resources: OK
  Processing resources: OK
  Packing application: OK
  Uploading (3K): OK
Push Status: OK
Stopping Application: OK
Staging Application: OK
Starting Application: OK
```

您应可查看上文介绍部分中所示的页面。在下一部分中，我们将在控制器中填写操作的代码以使应用程序可完全正常运作。

## 使用 RabbitMQ 服务

在此部分中，我们将使用先前部分中已创建的简单应用程序，并让其使用 RabbitMQ 服务。

首选，我们将在 Cloud Foundry 上创建 RabbitMQ 服务的一个实例：

```bash
$ vmc create-service
1. rabbitmq
2. mysql
3. mongodb
4. redis
Please select one you wish to provision: 1
Creating Service [rabbitmq-aaaad]: OK
```

在此时，服务实例已被成功创建。为了使其对我们的应用程序可用，我们还需要捆绑它：

```bash
$ vmc bind-service rabbitmq-aaaad rabbit-simple
Binding Service: OK
Stopping Application: OK
Staging Application: OK
Starting Application: OK
```

vmc 应用程序命令确认服务已与我们的应用程序捆绑：

```bash
$ vmc apps

+-----------------+----+---------+----------------------------------+-----------------------------+
| Application     | #  | Health  | URLS                             | Services                    |
+-----------------+----+---------+----------------------------------+-----------------------------+
| rabbit-simple   | 1  | RUNNING | rabbit-simple.cloudfoundry.com   | rabbitmq-aaaad              |
+-----------------+----+---------+----------------------------------+-----------------------------+
```

可通过 [AMQP](http://www.amqp.org/) 协议（RabbitMQ 支持 AMQP 版本 0.8 和 0.9.1）访问 RabbitMQ 服务。因此我们需要使用 AMQP 客户端库。幸运的是，已有一个 Spring AMQP 项目允许 AMQP 应用程序使用 Spring 概念。我们还将使用 cloudfoundry-runtime jar 以便从 Spring 应用程序对 Cloud Foundry 服务的访问，包括 RabbitMQ。因此我们将添加相应的依赖项至 pom.xml 文件：

```xml
[...]
   <properties>
       [...]
   </properties>

  <repositories>
      <repository>
          <id>spring-milestone</id>
          <name>Spring Maven MILESTONE Repository</name>
          <url>http://maven.springframework.org/milestone</url>
      </repository>
  </repositories>

  <dependencies>
      [...]
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
      [...]
  </dependencies>
[...]
```

然后我们将扩展 Spring 应用程序上下文 XML。添加项：

+ 使用 cloudfoundry-runtime 取得与 RabbitMQ 服务的一个连接。
+ 配置作为 Spring AMQP 主要入口点的 RabbitTemplate 和 RabbitAdmin。
+ 在 RabbitMQ 代理中声明一个队列调用的消息。
+ 有关更多详细信息，请查看 [Spring AMQP 文档](http://static.springsource.org/spring-amqp/docs/1.0.x/reference/html/)。

```xml
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:rabbit="http://www.springframework.org/schema/rabbit"
       xmlns:cloud="http://schema.cloudfoundry.org/spring"
       xsi:schemaLocation="http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc-3.0.xsd
                           http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
                           http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.0.xsd
                           http://www.springframework.org/schema/rabbit http://www.springframework.org/schema/rabbit/spring-rabbit-1.0.xsd
                           http://schema.cloudfoundry.org/spring http://schema.cloudfoundry.org/spring/cloudfoundry-spring-0.7.xsd">
    <context:component-scan base-package="com.rabbitmq.cftutorial.simple"/>
    <mvc:annotation-driven/>

    <!-- Obtain a connection to the RabbitMQ via cloudfoundry-runtime: -->
    <cloud:rabbit-connection-factory id="connectionFactory"/>

    <!-- Set up the AmqpTemplate/RabbitTemplate: -->
    <rabbit:template connection-factory="connectionFactory"/>

    <!-- Request that queues, exchanges and bindings be automatically
         declared on the broker: -->
    <rabbit:admin connection-factory="connectionFactory"/>

    <!-- Declare the "messages" queue: -->
    <rabbit:queue name="messages" durable="true"/>
</beans>
```

最后，实际发布和获取消息的 HomeController 变更是十分简单的：

```java
package com.rabbitmq.cftutorial.simple;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.ui.Model;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.amqp.core.AmqpTemplate;

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
}
```

现在一切就绪，最后的 vmc 更新将使应用程序完全正常运作。我们可以发布一条消息：

![publish1.png](http://support.cloudfoundry.com/attachments/token/6btegldivmhssve/?name=publish1.png)
![publish2.png](http://support.cloudfoundry.com/attachments/token/y4ls3aqh00thzen/?name=publish2.png)

并收回这条消息：

![get1.png](http://support.cloudfoundry.com/attachments/token/e5ojjwwhs6ljjwd/?name=get1.png)
![get2.png](http://support.cloudfoundry.com/attachments/token/lejqlsjmiu75lc7/?name=get2.png)

教程的内容就此结束。您可在 [RabbitMQ Web 站点](http://www.rabbitmq.com/)找到关于 RabbitMQ 和 AMQP 的更多资源。您可在 [Spring AMQP](http://www.springsource.org/spring-amqp) 网站找到关于在 Spring 应用程序中使用 RabbitMQ 的更多信息。如果您对此教程或 RabbitMQ 服务存在任何疑问或反馈，请使用 [support.cloudfoundry.com](http://support.cloudfoundry.com/) 的论坛与我们联系。

