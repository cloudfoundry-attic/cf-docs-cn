---
title: 常见问题解答

description: 常见问题解答

tags:
    - 常见问题解答

---

+ [如何上手使用 Cloud Foundry？](#getstarted)
+ [如何更改我的 CloudFoundry.com 密码？](#changepwd)
+ [我的登录凭据有问题。](#login)
+ [为何不能注册我想要的应用程序名称？](#appname)
+ [应用程序能否将本地文件系统用于存储？](#filesys)
+ [是否有会话支持？](#sessionsupport)
+ [服务对资源的使用超限时会如何？](#capacity)
+ [能否通过应用程序收发电子邮件？](#email)
+ [是否有防火墙阻止应用程序访问外部服务？](#firewall)
+ [应用程序为何返回“504 Gateway Time-out”错误？](#504)
+ [我在使用 HTTP_proxy 时遇到问题。](#http_proxy)
+ [CloudFoundry.com（测试版）支持哪些运行时？](#supportedruntimes)
+ [CloudFoundry.com（测试版）帐户在帐户、应用程序和服务方面有何限制？](#limits)
+ [应用程序停止运行。](#stoppedapp)
+ [出现 VMC 错误：“The input stream is exhausted”](#streamexhausted)
+ [能否使用 Hyperic 监视 Cloud Foundry 上的应用程序？](#hypericmonitoring)
+ [Ruby/Sinatra/Rails 应用程序启动失败。](#startfail)
+ [是否有日语版入门指南？](#japanesestart)
+ [如何更新应用程序才不会终止用户通信？](#updateapp)
+ [应用程序即使退出仍报告正在运行。](#runafterexit)



#### <a id="getstarted"></a>如何上手使用 Cloud Foundry？

有关 Cloud Foundry 入门方面的资源，请参考我们的 [入门指南](/getting-started.html)。


#### <a id="changepwd"></a>如何更改我的 CloudFoundry.com 密码？


请用以下链接重置您的 CloudFoundry.com 密码：[https://my.cloudfoundry.com/passwd](https://my.cloudfoundry.com/passwd)

#### <a id="login"></a>我的登录凭据有问题。


下面是为确保正确使用凭据而可以执行的操作：


+ 验证目标设置是否正确 ($vmc target api.cloudfoundry.com)

+ 检查目标（$vmc target 和 $vmc info）

+ 验证使用的是 vmc 客户端（$vmc login [电子邮件] [密码]）


注册后请尝试使用 Cloud Foundry 欢迎电子邮件中提供的临时密码。如果后来用“vmc passwd”命令更改过密码，也请尝试使用更改过的密码。


如果仍然无法使用 vmc，请单击“提交请求”选项卡打开问题单。请确保向我们提供详细信息，支持团队会进行详查。


#### <a id="appname"></a>为何不能注册我想要的应用程序名称？


应用程序名称长度必须在 3 个字符以上。另请注意，有些名称是系统预留名称，故即使够长也不允许使用。


如果收到此消息：“The URI:'fo.cloudfoundry.com' has already been taken or reserved”，请更改应用程序名称。



#### <a id="filesys"></a>应用程序能否使用本地文件系统进行存储？

应用程序需要将本地文件存储用作短暂存储，而当应用程序停止、崩溃或移动时该短暂存储会消失。对于用户上传的文件之类的内容，不应将本地文件存储用于持久存储。此外，如果应用程序有多个实例在运行，则本地存储仅对其中某一特定实例可见，而不是对所有实例可见或为所有实例所共享。如需永久存储，可以使用 [MongoDB GridFS](http://www.mongodb.org/display/DOCS/GridFS) 之类的本地服务或 [Box.net](http://developers.blog.box.com/2011/12/14/deploying-to-cloud-foundry-and-heroku-from-box/)、[Amazon S3](http://aws.amazon.com/s3/) 之类的外部 blob 存储。


#### <a id="sessionsupport"></a>是否提供了会话支持？

应用程序扩展到多个实例时会出现会话管理主题。Cloud Foundry 使用会话亲缘性，亦称粘性会话：当用户登录请求由某一特定应用程序实例处理时，来自该用户/会话的未来请求都将路由到该应用程序实例。粘性会话可用于所有应用程序，且不必配置，但 node.js 除外。Node.js 应用程序需要针对每个用户/会话为名为 JSESSIONID 的 cookie 分别设置一个独一无二的值。


Cloud Foundry 不提供会话复制：如果上述特定实例崩溃，用户将被路由到当前会话中无身份验证数据的另一个实例，并且需要重新登录。


#### <a id="capacity"></a>服务对容量的使用超限时会如何？

服务对资源的使用超限（例如 MySQL 达到 128MB 大小限制）时，服务会切换到只读/删除模式。例如，SQL 服务允许删除和读取数据，但不允许写入更多数据：


```bash
delete from table where ... # allowed
drop table ... # allowed
select ... from ... # allowed
insert into ... # not allowed
update ... # not allowed
```

如果某服务对资源的使用超限，则绑定到该服务的应用程序可能会出现“INSERT is disabled”之类的错误。其他服务（redis、MongoDB）也将表现出类似的行为。


#### <a id="email"></a>能否通过我的应用程序收发电子邮件？

应用程序不能通过 TCP 端口 25 发送电子邮件。应用程序可以使用其他端口提供的外部电子邮件服务（例如，端口 587 可提供 SMTP-AUTH 服务）。应用程序也无法通过侦听端口 25 来接收电子邮件。我们建议使用 [SendGrid](http://sendgrid.com/) 或 [Mailgun](http://mailgun.net/) 之类的外部邮件服务。


#### <a id="firewall"></a>是否有防火墙阻止我的应用程序访问外部服务？

没有，应用程序可以直接访问 Internet，但连接到 TCP 端口 25（用于发送电子邮件）受限。


#### <a id="504"></a>我的应用程序为何返回“504 Gateway Time-out”错误？

该错误页面源自 CloudFoundry.com HTTP 路由器，而非应用程序。路由器会终止持续 30 秒以上的应用程序请求。30 秒超时规定无法调整，且适用于 CloudFoundry.com 上运行的所有应用程序。但路由器支持周期为 30 秒的长时间轮询和流媒体传输：如果应用程序在 30 秒内将数据发送到客户端，则超时计数器复位，并在 30 秒时再次启动。为解决 504 错误，请调查是何原因造成应用程序响应延迟，并确保数据每 30 秒返回一次。



#### <a id="http_proxy"></a>我在使用 HTTP_proxy 时遇到问题。


2011 年 4 月推出 CloudFoundry.com 时，应用程序发出出站请求必须使用 HTTP 代理（对于运行的前 10 天左右）。在不需要使用代理后，我们并未去除 HTTP_PROXY、http_proxy 等环境变量。应用程序过去常常要用到这些变量，不过现在我们正在去除 HTTP_PROXY、HTTPS_PROXY、http_proxy、https_proxy、no_proxy、NO_PROXY。对于绝大多数应用程序，这种变化不会有任何影响。因为所有合理编写的应用程序不是其使用的 HTTP 客户端类能够正确处理和使用代理相关环境变量，就是其编写者编写的算法能够正确使用代理环境变量（当它们存在时）。


不过，有些应用程序可能是通过硬编码来查找以下代理相关环境变量的，同时还存在以下情况：不是用值不当，就是对缺少环境变量的情况处理不当。这些变量是：


```bash
- http_proxy

- HTTP_PROXY

- https_proxy

- HTTPS_PROXY

- no_proxy

- NO_PROXY
```

自 2012 年 5 月 14 日起，对于 CloudFoundry.com 上的应用程序将不再定义这些环境变量。如果应用程序出现异常，请检查并删除代码中对上述变量的引用。最安全的方法是在应用程序根目录中搜索代理引用：


```bash
$ cd myapp
$ grep -i -r proxy .
```

#### <a id="supportedruntimes"></a> CloudFoundry.com（测试版）支持哪些运行时？


使用 vmc runtimes 命令可以查看支持的运行时的完整列表 ($vmc runtimes)


#### <a id="limits"></a> CloudFoundry.com（测试版）帐户在帐户、应用程序和服务方面有何限制？


**帐户限制**

与 CloudFoundry.com（测试版）用户帐户相关联的限制信息可用以下命令获得。


```bash
$ vmc info

VMware's Cloud Application Platform
For support visit support@cloudfoundry.com

Target:   http://api.cloudfoundry.com (v0.999)
Client:   v0.3.10

User:     user@email.com
Usage:    Memory   (256.0M of 2.0G total)
          Services (1 of 16 total)
          Apps     (2 of 20 total)
```

对于帐户：

应用程序最多 20 个。

服务实例最多 16 个。

内存最多 2GB。



**应用程序限制**

对于各个应用程序：

内存最多 2GB。

磁盘空间最多 2GB。

CPU	限于 4 个核的公平份额。

网络	限于您的公平份额。

文件描述符最多	256.
URI 最多 4 个。


实例总数：受 2 GB 预留内存量限制。例如，如为应用程序预留 128M，则最多可有 16 个实例，相应的，预留 256M 最多可有 8 个实例，预留 512M 最多可有 4 个实例。（假定只有一个应用程序）。


此外，使用以下命令可以查看每个应用程序的使用情况统计信息：



```bash
$ vmc stats <appname>

+----------+-------------+----------------+--------------+--------------+
| Instance | CPU (Cores) | Memory (limit) | Disk (limit) | Uptime       |
+----------+-------------+----------------+--------------+--------------+
| 0        | 0.0% (1)    | 19.4M (128M)   | 14.5M (2G)   | 0d:2h:13m:6s |
+----------+-------------+----------------+--------------+--------------+
```

内存：已用 19.4M，预留 128M。（$ mem appname 命令可用于更新内存预留量，请注意，这将重新启动应用程序）


磁盘：已用 14M，最多 2G


**服务限制**

对于服务：

MySQL 数据库大小最大为	128MB。

Redis 内存最大为 16MB。

MongoDB 内存最大为 240MB。




#### <a id="stoppedapp"></a>我的应用程序停止运行。


任何应用程序在最终用户没有启动停止运行操作时停止运行，我们都视其为崩溃。


应用程序崩溃时，vcloudlabs 会让崩溃状态保持一段时间以进行自检。


可通过 **vmc crashlogs <appname>** 查看此状态


应用程序正常运行过程中出现崩溃可能是应用程序本身的问题，也可能是因应用程序使用的资源超限所致。



**vmc info**


这将显示用于内存、服务和应用程序实例的帐户范围资源。应先在此查看有关信息。



**vmc stats \<appname\>**


这将显示应用程序资源使用情况的详细信息。例如，运行 [http://www.cloudfoundry.com](http://www.cloudfoundry.com/) 的应用程序，名为 **www**，会输出如下内容：



**~> vmc stats www**

Instance   CPU (Cores)     Memory (limit)  Disk (limit)    Uptime

---------  -----------     --------------  ------------    ------
0          0.0% (8)        29.2M (64M)     824.0K (2G)     60d:19h:53m:58s

1          0.0% (8)        29.3M (64M)     816.0K (2G)     60d:19h:50m:3s



这里显示了各种资源的使用情况及其当前限制。



通常，CloudFoundry.com 会终止内存或磁盘使用超限的应用程序。这些信息将通过上文所述的 crashlogs 命令呈现给 vmc。



如果应用程序运行一段时间后意外停止，并且坚信应用程序没问题，则请使用此核对表查看是否出现了资源限制问题。



#### <a id="streamexhausted"></a>出现 VMC 错误：“The input stream is exhausted”


**问题**

在某些 Mac OSX 版本上，安装的 Stock Ruby 会导致 vmc 客户端工具无法正常运行并显示以下错误。这是因为 vmc 使用的库与 OSX 附带的 ruby 软件包不兼容。


例如，在 Mac OSX Lion 中，Stock Ruby 版本为 1.8.7，修补程序级别是 249


```bash
$ ruby --version
ruby 1.8.7 (2010-01-10 patchlevel 249) [universal-darwin11.0]
```

错误在 vmc 事务过程中显示为


```bash
$ vmc push
Would you like to deploy from the current directory? [Yn]: The input stream is exhausted.
/Library/Ruby/Gems/1.8/gems/highline-1.6.2/lib/highline.rb:608:in `get_line'
/Library/Ruby/Gems/1.8/gems/highline-1.6.2/lib/highline.rb:629:in `get_response'
/Library/Ruby/Gems/1.8/gems/highline-1.6.2/lib/highline.rb:216:in `ask'
/Library/Ruby/Gems/1.8/gems/vmc-0.3.12/lib/cli/commands/apps.rb:370:in `push'
/Library/Ruby/Gems/1.8/gems/vmc-0.3.12/lib/cli/runner.rb:428:in `send'
/Library/Ruby/Gems/1.8/gems/vmc-0.3.12/lib/cli/runner.rb:428:in `run'
/Library/Ruby/Gems/1.8/gems/vmc-0.3.12/lib/cli/runner.rb:14:in `run'
/Library/Ruby/Gems/1.8/gems/vmc-0.3.12/bin/vmc:5
/usr/bin/vmc:19:in `load'
/usr/bin/vmc:19
```

**解决方法**

此问题的解决方法是安装 [RVM](https://rvm.beginrescueend.com/) (Ruby Version Manager) 并且要安装和使用 1.8.7（或 1.9.2）版本。通常是安装较高的修补程序级别。但请注意，即使安装与 Stock Ruby 相同的修补程序级别，也能解决问题。


RVM 安装快速指南：

1.  安装 rvm ([http://beginrescueend.com/rvm/install/](http://beginrescueend.com/rvm/install/))

2.  添加以下行到 ~/.bash_profile 文件

```bash
# Ruby Version Manager
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
```
3.  打开新终端

4.  使用 rvm 重新安装 Ruby 1.9.2，并在安装了 Ruby 的 rvm 下重新安装 vmc gem

```bash
$ rvm install 1.9.2
$ rvm use 1.9.2
$ gem install vmc
```


**使用示例**

这是使用安装了 Ruby 的 rvm 的脚本。


```bash
$ rvm use 1.8.7-p249
Using /Users/Alex/.rvm/gems/ruby-1.8.7-p249
```
```bash
$ ruby --version
ruby 1.8.7 (2010-01-10 patchlevel 249) [i686-darwin11.0.0]
```
```bash
$ vmc push
Would you like to deploy from the current directory? [Yn]:
Application Name: hello-sinatra
Application Deployed URL: 'hello-sinatra.cloudfoundry.com'? hello-sinatra-alexsuraci.cloudfoundry.com
Detected a Sinatra Application, is this correct? [Yn]:
Memory Reservation [Default:128M] (64M, 128M, 256M, 512M or 1G)
Creating Application: OK
Would you like to bind any services to 'hello-sinatra'? [yN]:
Uploading Application:
  Checking for available resources: OK
  Packing application: OK
  Uploading (2K): OK
Push Status: OK
Staging Application: OK
Starting Application: OK
```


#### <a id="hypericmonitoring"></a>能否使用 Hyperic 监视 Cloud Foundry 上的应用程序？


[有](http://blog.cloudfoundry.com/2011/06/29/hyperic-brings-application-monitoring-to-cloud-foundry/)


#### <a id="startfail"></a>我的 Ruby/Sinatra/Rails 应用程序启动失败。


对 Ruby/Sinatra/Rails 应用程序执行 vmc push 并答完所有提问后，可能出现此错误：


Starting Application:............Error:Application [APP]'s state

is undetermined, not enough information available.


出现此错误的原因可能是缺少一个或多个 gem。根据问题发生位置，更多详细信息通常包含在这 4 个日志之一中：staging.log、migration.log、stderr.log 和 stdout.log


诊断：先用“vmc files app-name logs”查看日志文件，再用“vmc files app-name logs/stderr.log”查看日志。


在 Cloud Foundry 中，我们要求正式调用所有 gem 依赖项。对于简单的 Sinatra 应用程序，通常使用如下所示的简单 Gemfile（根目录中）即可解决问题：


Gemfile 包含：


```bash
source "http://rubygems.org"
gem 'bundler'
gem 'sinatra'
gem 'json'
gem 'httpclient'
gem 'redis'
```

然后运行“bundle package; bundle install”即可纠正问题


如果找不到供上传的缺失元素，请看看能否在论坛里找到答案或创建自己的问题线程。也可向我们发送电子邮件（电子邮件地址为 support.cloudfoundry.com），我们会尽力提供帮助。


演示中所示的演示示例应用程序 (hello.rb) 启动失败的常见原因之一是复制/粘贴，即复制时使用了智能引号，结果导致应用程序无法运行。请手动键入演示应用程序。另请确保源文件中不要有任何多余的制表 (\t) 字符，如果有，请用空格将其替换。



#### <a id="japanesestart"></a>是否有日语版入门指南？


[有](/getting-started-japanese.html)

#### <a id="updateapp"></a>如何更新应用程序才不会中断用户通信？


通常，利用 Cloud Foundry 开发和测试应用程序时，**vmc update** 很符合要求。


然而，如果应用程序是要“提供实时支持”的，就像我们自己的 www 站点，应遵循以下步骤，以确保更新转换期间不终止用户请求。


新应用程序将继用原应用程序的 URL 空间，我们采用这样的概念。


下面是不会出现任何停机状况的应用程序更新方法：


注意：“vmc update”将会中断通信。


- vmc push [app]NEW（绑定任何共享服务，如数据库、缓存等）


测试 [app]NEW.cloufoundry.com


- vmc map [app]NEW [app].cloudfoundry.com


测试 [app].cloudfoundry.com 若干次，现在在新旧应用程序之间循环...


- vmc unmap [app]OLD [app].cloudfoundry.com # 不会中断通信，只是切断所有新的通信


测试


- vmc delete [app]OLD



#### <a id="runafterexit"></a>我的应用程序即使在退出后仍然报告正在运行。


如用 System.exit() 退出应用程序，则 Tomcat 的安全管理器会阻止进程终止。这会导致系统报告应用程序正在运行。我们将会添加一个自定义的运行状况检查项，以便系统能检测到以这种方式终止的应用程序。



