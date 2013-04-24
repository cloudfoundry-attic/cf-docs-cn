---
title: VMC 快速参考
description: 所有可用的 vmc 命令
tags:
    - vmc
    - CLI
---

本节将主要的 VMC 命令分为多个功能类别并提供了一般用法。在示例中，显示为 `<this>` 之类的文本表示值特定于您的环境的变量。

运行 `vmc help` 查看 VMC 命令及其参数与简要说明的完整列表。

## 副标题

+ [获取最新版 VMC](#getting-the-latest-version-of-vmc)
+ [隐藏提示以在非交互模式下运行](#suppressing-prompts-to-run-in-non-interactive-mode)
+ [以 Cloud Foundry 为目标](#targeting-cloud-foundry)
+ [登录并管理帐户](#logging-in-and-managing-accounts)
+ [部署应用程序](#deploying-applications)
+ [更新部署](#updating-a-deployment)
+ [管理部署生命周期（启动、停止、删除）](#managing-the-deployment-lifecycle-start-stop-delete)
+ [管理和绑定服务](#managing-and-binding-services)
+ [获取有关 Cloud Foundry 目标的信息](#getting-information-about-the-cloud-foundry-target)
+ [获取有关应用程序的信息](#getting-information-about-applications)

## 获取最新版 VMC

`vmc` 作为 Ruby gem 提供，并不断以新命令或新选项对现有命令进行更新。因此，请通过执行下列 RubyGems 命令确保您拥有最新版本：

```bash
prompt$ gem update vmc
```

##隐藏提示以在非交互模式下运行

默认情况下，`vmc` 以交互式模式操作，执行多个命令会导致针对特定选项的值出现多次提示。若要在非交互模式下使用 `vmc` 并在命令中提供选项，请使用下列语法：

```bash
prompt$ vmc *command* -n --options
```

例如，若要部署应用程序并针对所有提示采用默认值：

```bash
prompt$ vmc push <appname> -n
```

若要显示可用作命令行参数的所有命令和选项：

```bash
prompt$ vmc help options
```

## 以 Cloud Foundry 为目标

在云中以 Cloud Foundry 为目标：

```bash
prompt$ vmc target api.cloudfoundry.com
```

以您的本地虚拟机上运行的独立 Micro Cloud Foundry 为目标：

```bash
prompt$ vmc target api.<domain>.cloudfoundry.com
```

**注意**：在您最初安装 Micro Cloud Foundry 时，指定*domain* 的值。

显示当前的目标 URL：

```bash
prompt$ vmc target
```

显示已知目标和相关授权令牌的列表：

```bash
prompt$ vmc targets
```

## 登录并管理帐户

利用您的帐户信息向 Cloud Foundry 标识您的身份：

```bash
prompt$ vmc login <youremail@email.com> --passwd <yourpassword>
```

更改密码：

```bash
prompt$ vmc passwd
```

从您当前的会话中注销：

```bash
prompt$ vmc logout
```

获取有关 Cloud Foundry 帐户的信息、您所用 VMC 的版本以及您消耗的资源总数：

```bash
prompt$ vmc info
```

（仅限 Micro Cloud Foundry）注册新用户。需要管理员权限：

```bash
prompt$ vmc add-user --email <newemail@email.com> --passwd <newpasswd>
```

（仅限 Micro Cloud Foundry） 删除注册用户以及与该用户相关的所有应用程序和服务实例。需要管理员权限：

```bash
prompt$ vmc delete-user <useremail@email.com>
```

##部署应用程序

通过从包含应用程序项目（如 `myapp.war` 或 `myapp.rb`）的目录中执行命令来部署该应用程序。这是交互式的应用程序部署方式，而 VMC 命令会提示您以下信息：如应用程序名称、其部署 URL、其编程框架、内存分配以及与其绑定的服务实例。然后该命令会将应用程序部署至您当前会话与之关联的目标，将其暂存，然后启动该应用程序以使其立即可用。

```bash
prompt$ vmc push
```

您可以指定下列一个或全部选项以传递部署值，如果您不指定选项，`vmc push` 将以交互方式提示您指定该选项：

```bash
prompt$ vmc push <appname> --path <directory> --url <deploymentURL> --instances <instance-number>  --mem <MB> --no-start
```

其中：

+ *appname* 指您要为应用程序指定的内部名称。
+ *directory* 指包含应用程序的绝对或相对本机目录名称。注意，目录中的*所有* 文件都将由 `vmc push` 命令推送，因此请确保只包含要在目录中部署的文件。
+ *deploymentURL* 指稍后要在浏览器中用于调用应用程序的 URL；默认值为 `<appname>.cloudfoundry.com`
* *instance-number* 指定要启动的应用程序的实例数；默认值为 1
+ *MB* 指定应用程序的内存上限，单位为 MB；默认值为 512 MB
+ *--no-start* 指定您尚未打算让 Cloud Foundry 实际启动应用程序，默认情况下将执行该操作。

即使您指定以上所有选项，`vmc push` 命令仍将提示您提供运行时和相关服务实例。

例如：

```bash
prompt$ vmc push hello --path /usr/bob/sample-apps/hello --url hello-bob.cloudfoundry.com --instances 2 --mem 64 --no-start
```

##更新部署

以当前目录中的应用程序位更新已部署的应用程序：

```bash
prompt$ vmc update <appname>
```

**注意**：确保指定应用程序的*名称* （`vmc apps` 输出的第一列）而非其部署 URL。

上述命令会立即结束任何连接到已部署应用程序的现有用户会话。

更新已为现有部署保存的内存（单位为 MB）；该应用程序将自动重新启动：

```bash
prompt$ vmc mem <appname> <MB>
```

**注意**：使用 `vmc stats <appname>` 查看当前为该应用程序保留的内存以及该应用程序当前使用的内存量。

将新部署 URL 注册为现有已部署的应用程序；此命令将该 URL *添加至* 已注册 URL 的现有列表中：

```bash
prompt$ vmc map <appname> <URL>
```

**注意**：使用 `vmc apps` 查看当前注册的已部署应用程序的 URL 列表。

取消注册已部署应用程序的 URL：

```bash
prompt$ vmc unmap <appname> <URL>
```

通过更改当前部署的实例数调整应用程序的规模（扩大或缩小）：

```bash
prompt$ vmc instances <appname> <number-of-instances>
```

**注意**：使用 `vmc apps` 查看已部署应用程序的最新实例数。

##管理部署生命周期（启动、停止、删除）

停止当前正在运行的部署：

```bash
prompt$ vmc stop <appname>
```

**注意**：确保指定应用程序的*名称* （`vmc apps` 输出的第一列）而非其部署 URL。

启动当前停止的部署：

```bash
prompt$ vmc start <appname>
```

重新启动当前正在运行的部署：

```bash
prompt$ vmc restart <appname>
```

删除应用程序：

```bash
prompt$ vmc delete <appname>
```

重新命名应用程序：

```bash
prompt$ vmc rename <appname> <new-appname>
```

##管理和绑定服务

显示支持的服务类型及已经配置的服务的实例：

```bash
prompt$ vmc services
```

**注意**：上述命令的输出分为两个表：第一个表显示可用于应用程序的服务类型，第二个表显示已为其创建实例的服务（使用 `vmc create-service` 命令。）这些服务称为*已配置的服务*. 使用 `vmc apps` 命令确定这些服务实例中的哪些实例当前绑定至已部署的应用程序。

创建服务类型的新实例并为其分配一个名称：

```bash
prompt$ vmc create-service <service-type> <service-instance-name>
```

**注意**：使用 `vmc services` 查看可为其创建实例的可用服务类型的列表。使用第一个表的第一列中列出的服务类型的名称。

创建服务类型的新实例，为其分配一个名称并立即将其绑定至已部署的应用程序：

```bash
prompt$ vmc create-service <service-type> <service-instance-name> <appnam>
```

将服务实例绑定至已部署的应用程序。假设您已使用 `vmc push` 部署了该应用程序：

```bash
prompt$ vmc bind-service <service-instance-name> <appname>
```

**注意**：使用 `vmc services` 查看服务实例的名称（第二个表的第一列）。

移除服务实例与应用程序之间的绑定：

```bash
prompt$ vmc unbind-service <service-instance-name> <appname>
```

删除服务的实例：

```bash
prompt$ vmc delete-service <service-instance-name>
```

要在使用 `vmc push` 部署应用程序的同时绑定现有服务实例，请在两个提示符处输入 `y`，然后从提供的列表中指定服务实例的数目。例如（仅显示 `vmc push` 命令的相关输出和提示）：

```bash
prompt$ vmc push
        ...
        Would you like to bind any services to 'pizza-juliet'? [yN]: y
        Would you like to use an existing provisioned service [yN]? y
        The following provisioned services are available:
        1. Insight-19ff7b1
        2. mysql-juliet
        Please select one you wish to provision: 2
        Binding Service: OK
        Uploading Application:
        ...
        Starting Application: OK

```

要在部署应用程序时创建新的服务实例，然后将新的服务实例绑定至应用程序，请指定与新服务实例有关的相应提示和信息。例如（仅显示 `vmc push` 的相关输出和提示）：

```bash
prompt$ vmc push
        ...
        Would you like to bind any services to 'pizza-juliet'? [yN]: y
        Would you like to use an existing provisioned service [yN]? n
        The following system services are available:
        1. mongodb
        2. mysql
        3. postgresql
        4. rabbitmq
        5. redis
        Please select one you wish to provision: 2
        Specify the name of the service [mysql-ab63]: mysql-new
        Creating Service: OK
        Binding Service: OK
        Uploading Application:
        ...
        Starting Application: OK

```



##获取有关 Cloud Foundry 目标的信息

显示支持的编程语言：

```bash
prompt$ vmc runtimes
```

显示支持的编程框架：

```bash
prompt$ vmc frameworks
```

显示支持的服务类型（如 MySQL 和 RabbitMQ）及您所创建的这些服务类型的实例：

```bash
prompt$ vmc services
```

**注意**：上述命令的输出分为两个表：第一个表显示可用于应用程序的服务类型，第二个表显示已为其创建实例的服务（使用 `vmc create-service` 命令。）使用 `vmc apps` 命令确定这些服务实例中的哪些实例当前绑定至已部署的应用程序。

##获取有关应用程序的信息

显示当前针对您的帐户部署的应用程序的列表，其中包含实例、运行状态及相关服务实例：

```bash
prompt$ vmc apps
```

显示应用程序的标准输出日志条目：

```bash
prompt$ vmc logs <appname>
```

**注意**：确保指定应用程序的*名称* （`vmc apps` 输出的第一列）而非其部署 URL。

显示特定应用程序最近的崩溃情况：

```bash
prompt$ vmc crashes <appname>
```

显示应用程序发生的严重错误：

```bash
prompt$ vmc crashlogs <appname>
```

显示已部署应用程序的每个实例的资源信息（如内核使用率、内存、磁盘空间和运行时间）：

```bash
prompt$ vmc stats <appname>
```

列出应用程序的环境变量：

```bash
prompt$ vmc env <appname>
```

将环境变量添加至应用程序：

```bash
prompt$ vmc env-add <appname> <variable=value>
```

删除以前添加至应用程序的环境变量：

```bash
prompt$ vmc env-del <appname> <variable>
```





## 在不影响用户通信的情况下更新应用程序

通常，利用 Cloud Foundry 开发和测试应用程序时，**vmc update** 很符合要求。

然而，如果应用程序是要“提供实时支持”的，就像我们自己的 www 站点，应遵循以下步骤，以确保更新转换期间不终止用户请求。

新应用程序将继用原应用程序的 URL 空间，我们采用这样的概念。

下面是不会出现任何停机状况的应用程序更新方法：

注意：“vmc update”将会中断通信。

- vmc push [app]NEW（绑定任何共享服务，如数据库、缓存等）

测试 [app]NEW.cloudfoundry.com

- vmc map [app]NEW [app].cloudfoundry.com

测试 [app].cloudfoundry.com 若干次，现在在新旧应用程序之间循环...

- vmc unmap [app]OLD [app].cloudfoundry.com # 不会中断通信，只是切断所有新的通信

测试

- vmc delete [app]OLD


