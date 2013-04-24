---
title: Lift
description: 在 Cloud Foundry 中使用 Lift
tags:
    - scala
    - lift
---

## 背景信息

在宣布支持 [Scala / Lift on CloudFoundry](http://blog.cloudfoundry.com/2011/06/02/cloud-foundry-now-supporting-scala/) 的那篇博客中提供了关于如何在 CloudFoundry 中部署 Lift 应用程序的宝贵信息。本知识库文章介绍有助于解决部署中常见问题的补充材料和信息。

请注意，本说明已利用 Maven 在 Lift v2.3 和 Scala v2.8.1 上进行了测试。如果使用更新版本的 Lift 和 Scala 时此流程出入较大，请告知我们。

## 创建 Lift 项目

您可以按照 [Lift 的“入门”一节](http://www.assembla.com/spaces/liftweb/wiki/Getting_Started)说明创建 Lift 项目，
正如该节重点指出的那样，项目可以用 [Maven](http://www.assembla.com/wiki/show/liftweb/Using_Maven)、[SBT](http://www.assembla.com/wiki/show/liftweb/Using_SBT)、[Gradle](http://www.assembla.com/wiki/show/liftweb/Using_Gradle) 或 [Ant](http://www.assembla.com/spaces/liftweb/wiki/Using_Ant) 进行设置。

## 对服务依赖项配置进行外部化

不使用任何服务（如数据库、键值存储或消息总线）的 Lift 应用程序在 Cloud Foundry 上运行时不需要进行修改，而使用服务的应用程序应根据应用程序对该服务的配置进行外部化。

在使用上述说明（比如使用 Maven）时，生成的项目结构对数据库所需的服务配置进行了外部化。请注意，其前提是您使用的项目原型生成了数据库物件（如使用 Maven 时生成的“lift-archetype-basic” 或“lift-archetype-jpa”）。例如：

```java
mvn archetype:generate \
 -DarchetypeGroupId=net.liftweb \
 -DarchetypeArtifactId=lift-archetype-basic_2.8.1 \
 -DarchetypeVersion=2.3 \
 -DarchetypeRepository=http://scala-tools.org/repo-releases \
 -DremoteRepositories=http://scala-tools.org/repo-releases \
 -DgroupId=com.company \
 -DartifactId=lift_test \
 -Dversion=1.0
```

生成的项目物件中包含本地开发的常用配置，其路径为 $APPLICATION_HOME/src/main/resources/props/default.props. 这种文件的示例如下。

```java
db.class=com.mysql.jdbc.Driver
db.url=jdbc:mysql://localhost/my_app
db.user=root
db.pass=root
```

## 解析应用程序中使用的外部化服务配置

Lift 利用外部化配置信息使应用程序不需要修改直接在各种环境中运行。根据应用程序运行环境的不同，需要使用不同的属性文件。确定所用属性文件的规则在 Lift 实用程序类 net.util.liftweb.Props 中指定。应用程序的[运行模式](http://www.assembla.com/wiki/show/liftweb/Run_Modes)指定应用程序运行的环境。只要在 $APPLICATION_HOME/src/main/resources/props/<run-mode>.props 中存在根据此规则命名的属性文件，就会用到该文件。如果没有，则使用 default.props 文件。部署属性文件的示例[在此处提供](http://www.assembla.com/spaces/liftweb/wiki/Properties)。

使用外部服务配置的代码物件
如果给定了采用外部化数据库配置进行设置的项目，就可以用 net.util.liftweb.Props 实用程序来获取相关属性。使用 Props 实用程序的代码示例如下。该代码取自 $APPLICATION_HOME/src/main/scala/bootstrap/liftweb/Boot.scala 文件：

```java
def boot {
    if (!DB.jndiJdbcConnAvailable_?) {
      val vendor =
            new StandardDBVendor(Props.get("db.class") openOr "Invalid Class",
                 Props.get("db.url") openOr "Invalid DB url",
                 Props.get("db.user"),
                             Props.get("db.pass"))

      LiftRules.unloadHooks.append(vendor.closeAllConnections_! _)

      DB.defineConnectionManager(DefaultConnectionIdentifier, vendor)
    }
```

在上述代码中，运行模式用来生成要使用的属性文件，然后根据该文件读取关联属性以连接数据库。

## 在 Cloud Foundry 中部署 Lift 应用程序时自动重新配置数据库配置

只要应用程序使用上述外部化服务配置并绑定了 Cloud Foundry (mysql) 的数据库服务实例，在 Cloud Foundry 中部署该应用程序（使用“vmc”或 STS）应该非常容易。
应用程序自动重新配置并启动后，将生成以下样式的新运行模式属性文件：$APPLICATION_HOME/src/main/resources/props/<username>.<hostname>.props，其中 <username> 对应部署应用程序的用户，<hostname> 对应应用程序启动的主机和应用程序上绑定的数据库服务实例终端的 db. * 值。此时 Lift 应用程序应启动并连接数据库。

## 在 Lift 中手动绑定数据库和其他服务配置

配置未进行外部化（即配置采用硬代码）或使用非数据库类的服务（目前，Cloud Foundry 自动重新配置仅对 Lift 数据库服务的单个实例有效）的应用程序需显示解析其配置依赖项。
为此，Lift 项目需要在其依赖项中添加 Cloud Foundry 运行时。该运行时是一个 Java 包，该包可提供对提供给用户的所有服务终端信息的访问。为使 Maven 中包括依赖项，您需要在 pom.xml 中添加以下元素[属性和依赖项]。最好采用最新版本的运行时。

```xml
...
  <properties>
    ...
    <org.cloudfoundry-version>0.6.1</org.cloudfoundry-version>
    ...
  </properties>

  ...

  <dependencies>
    ...
    <!-- CloudFoundry -->
    <dependency>
      <groupId>org.cloudfoundry</groupId>
      <artifactId>cloudfoundry-runtime</artifactId>
      <version>${org.cloudfoundry-version}</version>
    </dependency>
    ...
  </dependencies>
  ...
```

为了获取代码中的服务属性，您需要按以下方式使用云运行时：

在环境中导入 "import org.cloudfoundry.runtime.env._"
导入服务专用运行时包如 "org.cloudfoundry.runtime.service.relational._"
最后调用方法创建服务并取得和它的连接。
使用示例如下：

```java
object DBVendor extends ConnectionManager {
  def newConnection(name: ConnectionIdentifier): Box[Connection] = {
    try {

      import org.cloudfoundry.runtime.env._
      import org.cloudfoundry.runtime.service.relational._
      Full(new MysqlServiceCreator(new CloudEnvironment()).createSingletonService().service.getConnection())

    } catch {
      case e : Exception => e.printStackTrace; Empty
    }
  }
```

