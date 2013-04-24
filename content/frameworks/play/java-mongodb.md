---
title: Cloud Foundry 上的 Play Java MongoDB 应用程序

description: Cloud Foundry 上部署的采用 MongoDB 后端的 Play Java 应用程序

tags:
    - play

    - java

    - mongodb

    - 教程

---

本指南面向使用 Play 框架和 MongoDB NoSQL 数据库

在 Cloud Foundry 上构建和部署自己的应用程序的 Java 开发人员。
它说明了如何使用本机 Java 驱动程序来

设置和访问 MongoDB。
该应用程序使用 MongoDB 的本地实例进行开发，使用

在 Cloud Foundry 上运行的一项现有 MongoDB 服务进行部署。


开始前，您需备妥以下内容：


+  一个 [Cloud Foundry 帐户](http://cloudfoundry.com/signup)


+  [vmc](/tools/vmc/installing-vmc.html) Cloud Foundry 命令行工具


+  [Play 2.0 ](http://www.playframework.org/documentation/2.0.2/Home) 安装程序


+  一个本地 [MongoDB](http://www.mongodb.org/downloads) 服务器和客户端环境


## 简介


在本教程中，我们将采用以下简单的用例：


修改 [TodoList]( http://www.playframework.org/documentation/2.0.2/JavaTodoList )

应用程序并将其部署到通过持久层与 MongoDB NoSQL 数据库相连的 Cloud Foundry。
由于原始

应用程序是为采用 Ebean 的 SQL 数据存储编写的，因此我们将重新编写

此应用程序的控制器和模型以便将其与 MongoDB 后端搭配使用。


## TodoList Play 应用程序


TodoList 用来创建和管理任务。


![todolist-usecase.png](/images/play/todolist-usecase.png)

这些任务由用户创建并将数据存储在

基础关系存储区中。


下面提供了使用 Play 运行时和 MongoDB 的应用程序的

简要交互图：


![play-mongodb.png](/images/play/play-mongodb.png)

### 此应用程序的创建步骤

在本节中，我们将概括基于默认的 Play 应用程序模板创建此应用程序的步骤。


#### 创建一个新的 Play 应用程序


在命令行中键入 `play new todolist-java-mongodb` 命令。
选择选项 2 以创建

一个简单的 Java 应用程序。


```bash
$ play new todolist-java-mongodb
       _            _
 _ __ | | __ _ _  _| |
| '_ \| |/ _' | || |_|
|  __/|_|\____|\__ (_)
|_|            |__/

play! 2.0.2, http://www.playframework.org

The new application will be created in /Users/rajdeepd/vmware/play/mysamples/todolist-java-mongodb

What is the application name?
> todolist-java-mongodb

Which template do you want to use for this new application?

  1 - Create a simple Scala application
  2 - Create a simple Java application
  3 - Create an empty project

> 2

OK, application todolist-java-mongodb is created.

Have fun!
```

#### 创建一个 Eclipse 项目


使用 Play 的“eclipsify”命令创建一个 Eclipse 项目。


```bash
$ cd todolist-java-mongodb
$ play
[info] Loading project definition from /Users/<username>/play/mysamples/
todolist-java-mongodb/project
[info] Set current project to todolist-java-mongodb (in build file:/Users/<username>/play/mysamples/todolist-java-mongodb/)
       _            _
 _ __ | | __ _ _  _| |
| '_ \| |/ _' | || |_|
|  __/|_|\____|\__ (_)
|_|            |__/

play! 2.0.2, http://www.playframework.org

> Type "help play" or "license" for more information.
> Type "exit" or use Ctrl+D to leave this console.

[todolist-java-mongodb] $ eclipsify
[info] About to create Eclipse project files for your project(s).
[info] Updating {file:/Users/<username>/play/mysamples/todolist-java-mongodb/}todolist-java-mongodb...
[info] Done updating.
[info] Compiling 4 Scala sources and 2 Java sources to /Users/<username>/play/mysamples/
todolist-java-mongodb/target/scala-2.9.1/classes...
[info] Successfully created Eclipse project files for project(s):
[info] todolist-java-mongodb
[todolist-java-mongodb] $
```
通过“文件”->“导入”将所创建的项目导入到 Eclipse 中，然后指向

`todolist-java-mongodb` 项目的根文件夹。


![eclipse-import-mongoproject-1.png](/images/screenshots/play/eclipse-import-mongoproject-1.png)

![eclipse-import-mongoproject-2.png](/images/screenshots/play/eclipse-import-mongoproject-2.png)

#### 将 MongoDB 驱动程序和 Gson Jar 添加到此项目


下载 MongoDB 驱动程序文件和 Gson Jar，然后将它们添加到此项目的 lib 文件夹中。


  + [mongo-0.2.8.jar](http://www.mongodb.org/downloads)
  + [gson-2.2.2.jar](http://code.google.com/p/google-gson/downloads/list)

#### 修改路由器

在 `routes` 配置文件中定义以下路由。
该文件会将相对 URL

映射到 `controllers.Application.java` 中的相应操作


##### 索引页

下面的映射将 `HTTP GET` 调用映射到 `/` URL，后者继而映射到 index.html 页面。


``` javascript
GET     /                           controllers.Application.index()
```

##### 获取所有任务

下面的映射使用 `HTTP GET` 调用列出位于 URL `/tasks` 处的所有任务。


``` javascript
GET     /tasks                  controllers.Application.tasks()
```

##### 创建任务

下面的映射将 `controllers.Application.newTask()` 控制器操作映射到 `HTTP POST` 调用，后者继而映射到 URL `/tasks`。


``` javascript
POST    /tasks                  controllers.Application.newTask()
```

##### 删除任务

下面的映射将 `controllers.Application.deleteTask(:id Long)` 控制器操作映射到

`HTTP POST` 调用，后者继而映射到 URL `/tasks/:id/delete`，其中 id 是该任务的唯一 id。


``` javascript
POST    /tasks/:id/delete        controllers.Application.deleteTask(id: Long)
```

##### 完整列出



``` javascript
# Home page
GET     /                       controllers.Application.index()

# Map static resources from the /public folder to the /assets URL path
GET     /assets/*file           controllers.Assets.at(path="/public", file)

# Tasks
GET     /tasks                  controllers.Application.tasks()
POST    /tasks                  controllers.Application.newTask()
POST    /tasks/:id/delete       controllers.Application.deleteTask(id: Long)
```

#### 修改模型

在模型包中创建一个将与底层 MongoDB 驱动程序进行交互的 Task 类。

Task 包含两个公共字段：`id` 和 'label`。

``` java
package models;

public class Task {
  public Long id;
  public String label;

}
```

#### 修改控制器

在本节中，您将通过执行以下任务来实现控制器功能：


##### 创建操作方法

打开控制器文件，然后添加以下操作。


``` java
public class Application extends Controller {

  public static Result index() {
      return tasks();
  }

  public static Result tasks() {

  }

  public static List<Task> getTaskList() {

  }

  public static Result newTask() {
     
  }
}
```

##### 添加用来访问 MongoDB 的 Utility 方法

此方法返回 MongoDB 的本地或远程实例，具体取决于布尔

参数 `local`。


对于本地实例，请设置 `local=true`。
当我们将它部署到 cloudfoundry.com 时，请设置 `local=false`。


``` java
private static DB getDb() {
    String userName = play.Configuration.root().getString("mongo.remote.username");
    String password = play.Configuration.root().getString("mongo.remote.password");
    String langs = play.Configuration.root().getString("application.langs");
    boolean local  = true;

    String localHostName = play.Configuration.root().getString("mongo.local.hostname");
    Integer  localPort = play.Configuration.root().getInt("mongo.local.port");

    String remoteHostName = play.Configuration.root().getString("mongo.remote.hostname");
    Integer remotePort = play.Configuration.root().getInt("mongo.remote.port");

    Mongo m;
    DB db = null;
    if(local){
        String hostname = localHostName;
        int port = localPort;
        try {
            m = new Mongo( hostname, port);
            db = m.getDB( "db" );
        }catch(Exception e) {
            Logger.error("Exception while intiating Local MongoDB", e);
        }
    }else {
        String hostname = remoteHostName;
        int port = remotePort;
        try {
            m = new Mongo( hostname , port);
            db = m.getDB( "db" );
            boolean auth = db.authenticate(userName, password.toCharArray());
        }catch(Exception e) {
            Logger.error("Exception while intiating Local MongoDB", e);
        }
    }
    return db;
}
```

#### 向 application.config 添加参数

MongoDB 驱动程序使用以下参数来连接到位于本地计算机上

或 cloudfoundry.com 内的 MongDB 服务器。


``` javascript
mongo.local.hostname=localhost
mongo.local.port=27017

mongo.remote.hostname="172.30.XX.XX"
mongo.remote.port=25189
mongo.remote.username=<username obtained from caldecott>
mongo.remote.password=<password obtained from caldecott>
```

## 在本地构建和运行该应用程序

在本地运行该客户端前，请确保 MongoDB 在本地处于运行状态。


``` bash
$ ./mongod --dbpath=../../mongo/db/
Thu Aug 30 18:24:09 [initandlisten] MongoDB starting : pid=45601 port=27017 dbpath=
../../mongo/db/ 64-bit host=username.local
Thu Aug 30 18:24:09 [initandlisten] db version v2.0.6, pdfile version 4.5
Thu Aug 30 18:24:09 [initandlisten] git version: e1c0cbc25863f6356aa4e31375add7bb49fb05bc
Thu Aug 30 18:24:09 [initandlisten] build info: Darwin erh2.10gen.cc 9.8.0 Darwin Kernel s
Version 9.8.0: Wed Jul 15 16:55:01 PDT 2009; root:xnu-1228.15.4~1/
RELEASE_I386 i386 BOOST_LIB_VERSION=1_40
Thu Aug 30 18:24:09 [initandlisten] options: { dbpath: "../../mongo/db/" }
Thu Aug 30 18:24:09 [initandlisten] journal dir=../../mongo/db/journal
Thu Aug 30 18:24:09 [initandlisten] recover : no journal files present, no recovery needed
Thu Aug 30 18:24:09 [websvr] admin web console waiting for connections on port 28017
Thu Aug 30 18:24:09 [initandlisten] waiting for connections on port 27017

```
您可以从应用程序文件夹中使用标准命令在本地运行该应用程序。


``` bash
$play run
```
当您的浏览器指向 `http://localhost:9000` 时，您应该会看到下面的屏幕。


![play-todolist-java-mongodb-local.png](/images/screenshots/play/play-todolist-java-mongodb-local.png)

您可以使用 `mongo` 命令行 shell 连接到本地 MongoDB 实例，然后查询该集合。

`mongo` 是 shell 二进制文件。
确切位置可能会因安装方法和所用平台而异。


``` bash
$ ./mongo
MongoDB shell version: 2.0.6
connecting to: test
> use db;
switched to db db
> db.tasklist.find();
{ "_id" : ObjectId("50403ee86970ef63a14dea87"), "id" : NumberLong(0), "label" : "Drink Coffee" }
{ "_id" : ObjectId("50403efc6970ef63a14dea88"), "id" : NumberLong(1), "label" : "Write Play tutorial" }
{ "_id" : ObjectId("504044386970ef63a14dea89"), "id" : NumberLong(2), "label" : "" }
>
```

## 在 Cloud Foundry 上部署应用程序

在 Cloud Foundry 上部署可用两个简单的步骤完成：


+  创建分发

+  使用 `vmc push` 推送该分发


以下命令提供了部署应用程序时的准确命令和输出。


``` bash
$ play dist
[info] Loading project definition from /Users/<username>/vmware/play/mysamples/
todolist-java-mongodb/project
[info] Set current project to todolist-java-mongodb (in build file:/Users/<username>/
vmware/play/mysamples/todolist-java-mongodb/)
[info] Compiling 1 Java source to /Users/<username>/vmware/play/mysamples/
todolist-java-mongodb/target/scala-2.9.1/classes...
[info] Packaging /Users/<username>/vmware/play/mysamples/todolist-java-mongodb/target/
scala-2.9.1/todolist-java-mongodb_2.9.1-1.0-SNAPSHOT.jar ...
[info] Done packaging.

Your application is now ready in /Users/<username>/vmware/play/mysamples/todolist-java-mongodb/dist/
todolist-java-mongodb-1.0-SNAPSHOT.zip

[success] Total time: 8 s, completed Aug 31, 2012 12:06:54 AM

$ cd dist

$ vmc push
Would you like to deploy from the current directory? [Yn]: Y
Application Name: todolist-java-mongodb
Detected a Play Framework Application, is this correct? [Yn]: Y
Application Deployed URL [todolist-java-mongodb.cloudfoundry.com]:
Memory reservation (128M, 256M, 512M, 1G, 2G) [256M]:
How many instances? [1]: 1
Bind existing services to 'todolist-java-mongodb'? [yN]: y
1: mongodb-a1c55
2: mysql-2c653
3: mysql-2ea2b
4: mysql-c92b7
5: mysql-eeb13
6: mysql-first_app_ruby
7: postgresql-9a20a
8: rabbitmq-b25e8
Which one?: 1
Bind another? [yN]: N
Create services to bind to 'todolist-java-mongodb'? [yN]: N
Would you like to save this configuration? [yN]: y
Manifest written to manifest.yml.
Creating Application: OK
Binding Service [mongodb-a1c55]: OK
Uploading Application:
  Checking for available resources: OK
  Processing resources: OK
  Packing application: OK
  Uploading (84K): OK
Push Status: OK
Staging Application 'todolist-java-mongodb': OK
Starting Application 'todolist-java-mongodb': OK


```

部署完成后，我们可以打开 URL `[app-name].cloudfoundry.com]` 看一下实际的应用程序


![play-todolist-java-mongodb.png](/images/screenshots/play/play-todolist-java-mongodb.png)

## 总结

在本教程中，我们学习了如何使用本机 MongoDB 驱动程序构建和部署以 MongoDB 作为后端的

基本 Play Java 应用程序。




