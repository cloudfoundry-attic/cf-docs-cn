---
title: 访问 Cloud Foundry 服务
description: 通过 Caldecott 建立与 Cloud Foundry 服务的隧道
tags:
    - 调试
    - 隧道
    - vmc
---

Cloud Foundry 中内建了诸如数据库和消息传递之类的应用程序服务，可帮助加快开发和简化应用程序管理。您不必安装和管理服务器，因为 Cloud Foundry 平台中已包含这些服务器。您的应用程序代码与这些 Cloud Foundry 服务进行交互，但有时您需要以交互方式访问服务。例如，您可能要运行临时查询、查看数据来帮助调试问题，或导入/导出数据。

您可以利用一款称为 Caldecott（位于加州伯克利山的隧道）的应用程序在云中访问您的服务。Caldecott 使用隧道将您本地计算机上的端口连接至云中的服务。`vmc tunnel` 命令将 Caldecott 应用程序上载至您的 Cloud Foundry 实例中、设置隧道并启动计算机上的标准客户端以与服务配合使用。

## 先决条件

+	Caldecott 需要使用 Ruby 1.9.2。

+ 	您必须具有 vmc 0.3.14 或更高版本。使用下列命令检查您的版本：

```bash
$ vmc -v
```

	输入此 vmc 命令更新 vmc gem：

```bash
$ gem update vmc
```

+ 	Caldecott 可为您要访问的服务启动一个客户端程序，例如为 MySQL 启动 `mysql`，为 PostgreSQL 启动 `psql`。该客户端必须安装在您的计算机上并执行 PATH，以便 Caldecott 脚本可以启动该客户端。如果您要使用另一个客户端，Caldecott 将显示连接到该服务所需的连接信息和凭据。下表显示了 Caldecott 可为每项服务启动的客户端程序。

<table class="std">
	<tr>
		<th>服务</th>
		<th>客户端</th>
	</tr>
	<tr>
		<td>MongoDB</td>
		<td><tt>mongo</tt></td>
	</tr>
	<tr>
		<td>MySQL</td>
		<td><tt>mongo</tt></td>
	</tr>
	<tr>
		<td>PostgreSQL</td>
		<td><tt>mongo</tt></td>
	</tr>
	<tr>
		<td>rabbitmq</td>
		<td><i>none</i></td>
	</tr>
	<tr>
		<td>Redis</td>
		<td><tt>mongo</tt></td>
	</tr>
</table>

## 设置 Caldecott

通过该命令安装 Caldecott Ruby gem：

```bash
$ gem install caldecott
```

注意：
Caldecott gem 目前需要 eventmachine gem，而 eventmachine 又需要本机编译。我们正努力对此进行简化。

## 使用 Caldecott

* 将 Cloud Foundry 实例设为目标并利用您的 Cloud Foundry 凭据登录：

```bash
$ vmc target api.cloudfoundry.com
$ vmc login

```

* 使用此命令查看现有服务：

```bash
$ vmc services
```

	命令输出分为两部分。首先是系统服务，报告可在 Cloud Foundry 实例中配置的服务。您感兴趣的是第二部分 — 已配置的服务，该服务列出了您现有的服务。

		=========== 已配置的服务 ============

	    +------------------+------------+
	    | 名称             | 服务    |
	    +------------------+------------+
	    | mongodb-12345    | mongodb    |
	    | mysql-12345      | mysql      |
	    | postgresql-12345 | postgresql |
	    | redis-12345      | redis      |
	    +------------------+------------+

* 创建通向服务的隧道。例如，要连接到 MySQL 服务：

```bash
$ vmc tunnel mysql-12345
	Trying to deploy Application: 'caldecott'.
	Create a password:

```

	首次创建隧道时，vmc 会将 Caldecott 应用程序上载至您的 Cloud Foundry 实例，然后提示您设置一个密码来保护该应用程序。将来每当您创建一个通往该 Cloud Foundry 实例的隧道时，都需要提供该密码。

	提供该密码后，将会上载 Caldecott 应用程序：

```bash
Uploading Application:
      Checking for available resources: OK
      Processing resources: OK
      Packing application: OK
      Uploading (1K): OK
    Push Status: OK
    Binding Service [mysql-12345]: OK
    Staging Application: OK
    Starting Application: OK

```

	请参阅[有关 Tunnel 命令的更多信息](#more-about-the-tunnel-command)以了解 `vmc tunnel` 命令选项的完整说明。

* Caldecott 将建立隧道并提示您启动客户端。以下是使用 `mysql` 访问 Cloud Foundry 中的数据的会话示例：

```bash

	Getting tunnel connection info: OK

	Service connection info:
	  username : um4rwWyhwa07B
	  password : pBiBlqjINB6cm
	  name     : dd368741dbc1945cfb62315565efcf1b5

	Starting tunnel to mysql-24e9c on port 10000.
	1: none
	2: mysql
	Which client would you like to start?: 2
	Launching 'mysql --protocol=TCP --host=localhost --port=10000
	--user=um4rwWyhwa07B --password=pBiBlqjINB6cmdd368741dbc1945cfb62315565efcf1b5'

	Welcome to the MySQL monitor.  Commands end with ; or \g.
	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
		.
		.
		.
	mysql>

```

* 退出客户端时，隧道将会断开连接。

	如果选择 `1: none` 选项，或如果 Caldecott 没有用于该服务的默认客户端，请在另一窗口中启动您的首选客户端，并在您准备关闭隧道前一直保持该终端窗口不受干扰。然后完成时按 `Ctrl-C` 退出 vmc。

## 有关 Tunnel 命令的更多信息

您输入 `vmc tunnel` 命令并对提示做出响应即可创建隧道。您利用该命令可从现有已配置服务的列表中进行选择，因此无需提前知道该服务名。

`vmc tunnel` 命令的完整语法为：

	vmc tunnel [<servicename>] [--port <portnumber>] [<clientcmd>]

`<servicename>` 参数为服务名称，如 `vmc services` 命令所示。如果排除 `<servicename>`，vmc 将提供可从中进行选择的现有服务的列表。

`<portnumber>` 参数是本地计算机上要使用的端口。如果忽略，vmc 将从 0~10000 的范围内选择一个可用端口。

`<clientcmd>` 参数是要启动的客户端程序的名称。只有表的 [Prerequisites](#prerequisites) 部分显示的客户端名称才是此参数支持的客户端。


