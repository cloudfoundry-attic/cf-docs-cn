---
title: Play Java
description: 利用 Cloud Foundry 开发 Play Java 应用程序
tags:
    - play
    - java
    - 教程
---

本文介绍 Java 开发人员如何使用 Play 框架在 Cloud Foundry 上
构建和部署应用程序。它告诉您如何设置并成功在 Cloud Foundry 上部署
Play Java 应用程序。

Play 基于轻型、无状态、适合 Web 体系的架构，具有资源消耗（CPU、内存、线程）可预见且极少的特点，非常适合
扩展性非常强的应用程序使用。
Cloud Foundry 为 Play 2.0 应用程序提供运行时环境，且 Cloud Foundry 
部署工具能自动识别 Play 应用程序。

开始前请做好以下准备：

+  一个 [Cloud Foundry 帐户](http://cloudfoundry.com/signup)

+  [vmc](/tools/vmc/installing-vmc.html) Cloud Foundry 命令行工具

+  [Play 2.0 ](http://www.playframework.org/documentation/2.0.2/Home) 安装程序

## 将 Play Java 应用程序部署到 Cloud Foundry

在 Cloud Foundry 中部署 Play 应用程序时，当前目录必须包含
该应用程序、配置文件夹和 Cloud Foundry 用来检测 Play 应用程序的
应用程序文件夹。

以下是创建和部署“hello world”Play 应用程序的步骤。

### 安装 Play

请按照 [Play 网站](http://www.playframework.org/documentation/2.0.2/Installing)上提供的说明下载和安装 Play 2.0。

请确保在您的路径中有 play 脚本。在 Linux 或 Mac 环境中，可以使用以下命令来检查

``` bash
export PATH=$PATH:/path/to/play20
```
在 Windows 中，您需要在全局环境变量中对其进行设置。

### 检查是否存在 play 命令。
在 shell 中运行 `play help` 命令。

``` bash
$play help
```
应该显示以下屏幕。

![play-help.png](/images/screenshots/play/play-help.png)

### 创建应用程序

要创建应用程序，请键入以下命令：

``` bash
$ play new helloworld-java

```
选择相应的模板（本例中为 Java）。

``` bash
$play new helloworld-java
       _            _
 _ __ | | __ _ _  _| |
| '_ \| |/ _' | || |_|
|  __/|_|\____|\__ (_)
|_|            |__/

play! 2.0.2, http://www.playframework.org

The new application will be created in /Users/[username]/play/mysamples/helloworld-java

What is the application name?
> helloworld-java

Which template do you want to use for this new application?

  1 - Create a simple Scala application
  2 - Create a simple Java application
  3 - Create an empty project

> 2

OK, application helloworld-java is created.

Have fun!
```

可以创建以下目录结构：

```bash
$cd helloworld-java
$ls
README
app
conf
project
public
```
这样就创建了一个新目录 `helloworld-java`。

### 在本地运行默认应用程序

试着在本地 play 控制台中用以下命令运行应用程序：

```bash
[helloworld-java] $ run

[info] Updating {file:/Users/[username]/play/mysamples/helloworld-java/}helloworld...
[info] Done updating.
--- (Running the application from SBT, auto-reloading is enabled) ---

[info] play - Listening for HTTP on port 9000...

(Server started, use Ctrl+D to stop and go back to the console...)
```
您应该能看到 `http://localhost:9000` 提供的默认 Play 模板。

![default-play-home.png](/images/screenshots/play/default-play-home.png)

### 修改控制器

在本步骤中，我们将修改控制器 `helloworld-java/app/controllers/Application.java`

```java
package controllers;

import play.*;
import play.mvc.*;

import views.html.*;

public class Application extends Controller {

  public static Result index() {
    return ok("HelloWorld Java");
  }
}

```
浏览器中的默认视图应是下面的样子：

![play-helloworld-java.png](/images/screenshots/play/play-helloworld-java.png)


### 部署应用程序

使用以下命令构建 Play 分发：

```bash
$play dist
[info] Loading project definition from /Users/[username]/vmware/play/mysamples/helloworld-java/project
[info] Set current project to helloworld (in build file:/Users/[username]/vmware/play/mysamples/helloworld-java/)
[info] Packaging /Users/[username]/vmware/play/mysamples/helloworld-java/target/scala-2.9.1/helloworld_2.9.1-1.0-SNAPSHOT.jar ...
[info] Done packaging.

Your application is ready in /Users/[username]/vmware/play/mysamples/helloworld-java/dist/helloworld-1.0-SNAPSHOT.zip

[success] Total time: 3 s, completed Jul 26, 2012 10:55:56 PM
```
选择 Cloud Foundry 作为目标并用您的 Cloud Foundry 凭据登录：

```bash
$ vmc target api.cloudfoundry.com
$ vmc login

```

推送应用程序。在大部分提示下都可以按 `Enter` 接受默认设置，
但一定要为应用程序输入一个唯一的 URL。下面是一个推送的示例：

``` bash
$vmc push --path=dist/helloworld-1.0-SNAPSHOT.zip
Application Name: helloworld-java
Detected a Play Framework Application, is this correct? [Yn]: Y
Application Deployed URL [helloworld-java.cloudfoundry.com]:
Memory reservation (128M, 256M, 512M, 1G, 2G) [256M]:
How many instances? [1]: 1
Bind existing services to 'helloworld-java'? [yN]: N
Create services to bind to 'helloworld-java'? [yN]: N
Would you like to save this configuration? [yN]: y
Manifest written to manifest.yml.
Creating Application: OK
Uploading Application:
  Checking for available resources: OK
  Processing resources: OK
  Packing application: OK
  Uploading (66K): OK
Push Status: OK
Staging Application 'helloworld-java': OK
Starting Application 'helloworld-java': OK
```

请注意 vmc 是如何自动检测 Play 应用程序的。

根据指定的 URL（本例中为
[http://helloworld-java.cloudfoundry.com](http://helloworld-java.cloudfoundry.com)）通过浏览器访问应用程序。

![play-helloworld-java-cf.png](/images/screenshots/play/play-helloworld-java-cf.png)


## 接下来的步骤

+    [MySQL 的 Java 应用程序](/frameworks/play/java-mysql.html)
+    [PostgreSQL 的 Java 应用程序](/frameworks/play/java-postgresql.html)

