---
title: 安装部署 Cloud Foundry
description: 在vSphere上通过BOSH工具大规模部署Cloud Foundry
tags:
    - vSphere
    - BOSH
    - Deploy
    - IaaS
---

在前面的文章中，我们安装了Micro BOSH和 BOSH。如果一切顺利，我们已经为安装 Cloud Foundry做好准备了。首先，我们为Cloud Foundry的部署制定资源计划。

在我们编写本文时，完整的 Cloud Foundry 安装包含大约 34 个不同作业（虚拟机）。其中有些作业为核心组件，必须安装至少一个这类作业的实例；例如，Cloud Controller、NATS 和 DEA 等。有些作业应具有多个实例，具体取决于实际需求；例如 DEA 和router等。有些作业是可选的，例如服务网关和服务节点。因此，我们在安装 Cloud Foundry 前，应决定将哪些组件纳入部署范围。我们制定了要部署的组件的清单后，便可以规划每个作业所需的资源。通常，这些资源包括 IP 地址、CPU、内存和存储。下面是一个部署计划示例。

<table class="std">
<tr>
<th>作业</th>
      <th>实例数</th>
      <th>IP</th>
      <th>内存</th>
      <th>CPU</th>
      <th>磁盘 (GB)</th>
      <th>是否为必需的？</th>
    </tr>
<tr>
<td>debian_nfs_server</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>2 GB</td>
      <td>2</td>
      <td>16</td>
      <td>必需</td>
    </tr>
<tr>
<td>nats</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>ccdb_postgres</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>uaadb</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>vcap_redis</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>uaa</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>acmdb</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>acm</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>cloud_controller</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>2 GB</td>
      <td>2</td>
      <td>16</td>
      <td>必需</td>
    </tr>
<tr>
<td>stager</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>router</td>
      <td>2</td>
      <td>xx.xx.xx.xx</td>
      <td>512 MB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>health_manager</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>必需</td>
    </tr>
<tr>
<td>dea</td>
      <td>2</td>
      <td>xx.xx.xx.xx</td>
      <td>2 GB</td>
      <td>2</td>
      <td>16</td>
      <td>必需</td>
    </tr>
<tr>
<td>mysql_node</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>mysql_gateway</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>mongodb_node</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>mongodb_gateway</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>redis_node</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>redis_gateway</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>rabbit_node</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>rabbit_gateway</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>postgresql_node</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>postgresql_gateway</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>vblob_node</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>vblob_gateway</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>backup_manager</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>service_utilities</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>serialization_data_server</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>services_nfs</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>syslog_aggregator</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>services_redis</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>opentsdb</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>collector</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>dashboard</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
  <td>service_broker</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>hbase_master</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>hbase_slave</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>collector</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>login</td>
      <td>1</td>
      <td>xx.xx.xx.xx</td>
      <td>1 GB</td>
      <td>1</td>
      <td>8</td>
      <td>可选</td>
    </tr>
<tr>
<td>合计：</td>
      <td>41</td>
      <td>&nbsp;</td>
      <td>42 GB</td>
      <td>42</td>
      <td>384</td>
      <td>&nbsp;</td>
    </tr>
</table>

根据上表，我们便可以确定所需的资源池：

<table class="std">
<tr>
<th>池名称</th>
      <th>规模</th>
      <th>配置</th>
      <th>作业</th>
    </tr>
<tr>
<td>small</td>
      <td>30</td>
      <td>RAM：1 GB；CPU：1 个；磁盘：8 GB</td>
      <td>nats、ccdb_postgres、uaadb、vcap_redis、uaa、acmdb、acm、stager、health_manager、mysql_node、service_broker、hbase_master、hbase_slave、login、mysql_gateway、mongodb_node、mongodb_gateway、redis_node、redis_gateway、postgresql_node、postgresql_gateway、vblob_node、vblob_gateway、backup_manager、service_utilities、serialization_data_server、services_nfs、syslog_aggregator、services_redis、opentsdb、collector、dashboard</td>
    </tr>
<tr>
<td>medium</td>
      <td>4</td>
      <td>RAM：2 GB；CPU：2 个；磁盘：16 GB</td>
      <td>debian_nfs_server、cloud_controller、dea</td>
    </tr>
<tr>
<td>router</td>
      <td>2</td>
      <td>RAM：512 M；CPU：1 个；磁盘：8 GB</td>
      <td>router</td>
    </tr>
</table>
根据上面两个表，我们可以修改清单文件。

我们将清单文件命名为cf.yml。以下各节详细说明了其中的字段。 完整的Cloud Foundry部署yml文件，请参考：[https://github.com/vmware-china-se/bosh_doc/blob/master/cf.yml](https://github.com/vmware-china-se/bosh_doc/blob/master/cf.yml)（注，此yml文件是用来为Cloud Foundry的BOSH部署提供配置信息，与之前介绍的BOSH yml文件不同）

**name**

这是 Cloud Foundry 部署名。我们可以随意对它命名。

**director_uuid**

director UUID 是我们部署的 BOSH Director的 UUID。我们可以通过下面的命令来检索此值：

`$ bosh status`

**release**

此Release名称应与您在创建 CF Release时输入的名称相同。版本是在创建Release时自动生成的。

**compilation、update、networks、resource_pools**

这些字段与 bosh.yml 文件中的那些字段类似。有关更多信息，请参考上一部分。

**jobs**

作业是 Cloud Foundry 的组件。每个作业在一个虚拟机上运行。各个作业的说明如下。

<table class="std">
<tr>
<th>组件</th>
      <th>说明</th>
    </tr>
<tr>
<td>debian_nfs_server、services_nfs</td>
      <td>这两个作业在 Cloud Foundry 中用作 NFS 服务器。由于它们是文件服务器，因此我们应确保“persistent_disk”属性确实存在。</td>
    </tr>
<tr>
<td>syslog_aggregator</td>
      <td>此作业用于收集系统日志并将它们存储在数据库中。</td>
    </tr>
<tr>
<td>nats</td>
      <td>NATS 是 Cloud Foundry 的消息总线。它是 Cloud Foundry 中的核心组件之一。</td>
    </tr>
<tr>
<td>opentsdb</td>
      <td>这是用来存储日志信息的数据库。由于它是数据库，因此它也需要“persistent_disk”属性。</td>
    </tr>
<tr>
<td>collector</td>
      <td>此作业用于收集系统信息并将它们存储在数据库中。</td>
    </tr>
<tr>
<td>dashboard</td>
      <td>这是基于 Web 的控制台工具，用来监视和报告 Cloud Foundry 平台的情况。</td>
    </tr>
<tr>
<td>cloud_controller、ccdb</td>
      <td>cloud_controller负责控制 Cloud Foundry 的所有组件。“ccdb”是Cloud Controller的数据库。“persistent_disk”属性在ccdb中是必需的。</td>
    </tr>
<tr>
<td>uaa、uaadb</td>
      <td>uaa用于进行用户身份验证和授权。uaadb是用来存储用户信息的数据库。“persistent_disk”属性对uaadb而言是必需的。</td>
    </tr>
<tr>
<td>vcap_redis、services_redis</td>
      <td>这两个作业用于存储 Cloud Foundry 的内部键值对。</td>
    </tr>
<tr>
<td>acm、acmdb</td>
      <td>acm是访问控制管理器 (Access Control Manager) 的简写形式。ACM 是一项服务，借助这项服务，Cloud Foundry 组件可以实现访问控制功能。“acmdb”是acm的数据库。“acmdb”也需要“persistent_disk”属性。</td>
    </tr>
<tr>
<td>stager</td>
      <td>stager 这个作业负责将用户应用程序的源代码及所有必需包打包。暂存完成后，便会将该应用程序传递给dea加以执行。</td>
    </tr>
<tr>
<td>router</td>
      <td>用于将用户的请求路由到 Cloud Foundry 中的正确目标位置。</td>
    </tr>
<tr>
<td>health_manager、health_manager_next</td>
      <td>health_manager这个作业负责监视所有用户的应用程序的运行状况。health_manager_next是health_manager的下一代版本。它们将共存一些时日。</td>
    </tr>
<tr>
<td>dea</td>
      <td>“dea”是 Droplet Execution Agent 的简写形式。所有用户的应用程序都在dea中执行。</td>
    </tr>
<tr>
<td>mysql_node、mysql_gateway、mongodb_node、mongodb_gateway、redis_node、redis_gateway、rabbit_node、rabbit_gateway、postgresql_node、postgresql_gateway、vblob_node、vblob_gateway</td>
      <td>这些作业全都是给 Cloud Foundry提供服务的。每项服务都有一个负责置备资源的节点。对应的网关位于cloud_controller与服务节点之间，担当每项服务的管理功能。</td>
    </tr>
<tr>
<td>backup_manager</td>
      <td>用于备份用户的数据和数据库。</td>
    </tr>
<tr>
<td>service_utilities</td>
      <td>服务管理实用程序。</td>
    </tr>
<tr>
<td>serialization_data_server</td>
      <td>用于在 Cloud Foundry 中对数据进行序列化的服务器。</td>
    </tr>
</table>

**properties：**

这是 cf.yml 文件中的另一个重要部分。我们应注意，此节中的 IP 地址应与 jobs 字段中的那些地址要一致。您应将此节中的密码和令牌替换成您自己的安全密码和令牌。

domain：这是供用户访问的域的名称。我们还应创建一个 DNS 服务器来将该域解析为负载均衡器的 IP 地址。在我们的示例中，我们将域名设置为cf.local，以便用户在推送应用程序时可以使用vmc target api.cf.local。

cc.srv_api_uri：此属性通常采用以下格式：`http://api.<您的域名>`。例如，如果我们将域设置为cf.local，那么srv_api_uri将为 `http://api.cf.local`。

cc.password：此密码必须包含至少 16 个字符。

cc. allow_registration：如果它为 True，则用户可以使用vmc命令注册帐户。将它设置为 False 则禁止此行为。

cc.admins：管理员用户的名单。即使allow_registration标志设置为 False，管理员用户也可以通过vmc命令进行注册。

这些属性中的大多数“nfs_server”都应设置为“services_nfs”作业的 IP 地址。

mysql_node.production：如果它为 True，则mysql_node的内存必须至少为 4 GB。在试验环境中，我们可以将它设置为 False，这样mysql_node的内存便可以设置为小于 4 GB。

在uaa的properties中jwt.signing_key这段和cc.token_secret这段保留一种就可以了。然后需要注意的是这里的uaa.clients部分指定了其他与UAA有关的组件（比如dashboard）作为client与UAA交互时的验证规则。这一部分不要轻易修改，并且需要保证配置文件中含义相同的secret要前后一致。

由于yml文件可能会随着 Cloud Foundry 新Release的问世而发生演变，因此提供了使用 BOSH 命令验证yml文件的选项。键入“bosh help”后，您便可以看到“bosh diff”的用法和解释：

`$ bosh diff [<template_file>]`

此命令会将您当前的部署清单与指定的部署清单模板进行对比。它可更新部署配置文件。最新的开发模板可以在deployment repo 中找到。

例如，您可以运行下面的命令来将yml文件与模板文件进行对比。首先，您必须切换到您的 cf.yml 文件和模板文件所在的目录，然后运行下面的命令：

`$ bosh diff dev-template.erb`

此命令将显示 cf.yml 文件中的错误。如果缺少某些字段，此命令将自动帮您填入这些字段。如果有拼写错误或其他错误，此命令将报告存在语法错误。

您可以从以下位置下载部署Cloud Foundry的示例yml文件：

[https://github.com/vmware-china-se/bosh_doc/blob/master/cf.yml](https://github.com/vmware-china-se/bosh_doc/blob/master/cf.yml)

此清单文件完成后，我们就可以开始安装 Cloud Foundry 了。

1) 在之前的步骤中，我们已经通过以下命令从Gerrit克隆了 CF 代码库：

`$ gerrit clone ssh://<your username>@reviews.cloudfoundry.org:29418/cf-release.git`

注意：如果您没有SSL证书的话，使用新版vmc是无法进行登陆我们当前的部署环境的。这时我们需要对配置文件和cf-release中的代码做如下两个修改：

1、在Cloud Foundry的部署文件cf-dev.yml中修改login的协议为HTTP：
``` ruby
    ...
    properties:

    ...

      login:
        protocol: http
      
    ...
```
      
2、修改Cloud Controller的配置文件，文件位置：`../cf-release/jobs/cloud_controller/templates/cloud_controller.yml.erb` 

``` ruby
    <% if cc_props.uaa && properties.uaa.cc %>
    uaa:
        ...
        url: https://uaa.<%= properties.domain %>
        ...
    <% else %>
    uaa:
        ...
        url: https://uaa.<%= properties.domain %>
        ...
    <% end %>
```

把上述两个https改成http。另外：如果您的网络环境比较特殊的话，还可能会出现CloudController在内网中不能通过URL直接解析到UAA的IP，那么您还需要修改下面的源文件和hosts文件：

`../cf-release/src/cloud_controller/cloud_controller/app/models/uaa_token.rb` 

把这个文件中所有的 AppConfig[:uaa][:url] 替换为 `"http://uaa.<yourdomain>:8080"` ，要记得带双引号。

然后在部署完成后CC的虚拟机hosts中添加uaa的URL来帮助内网中进行正确的解析，这一部分会在后面有说明。


2) 切换到cf-release目录，然后创建一个 CF Release，这一部分耗时较长，大概需要几十分钟，请耐心等待。


`$ cd cf-release`

`$ ./update`

`$ bosh create release` 


这将下载部署所需的所有包、blob 数据及其他资源。下载过程将耗费若干分钟，主要取决于网络速度。

**注意：**

1.如果您编辑了 CF Release中的代码，那么您可能需要在命令 bosh create release 中添加 --force 选项。

2.在运行此命令时系统一定要直接连接Internet。

3.如果您的网络速度慢或者您未与 Internet 建立直接连接，那么您可能需要在一个更好的环境中完成创建Release的操作。您可以在有良好 Internet 连接的机器上使用--with-tarball选项创建此Release。然后，您需要将所生成的 tar 包复制到所需系统。

如果一切都未出问题的话，您可以看到此Release的摘要，大致如下：

	Generating manifest...
	----------------------
	Writing manifest...
	Release summary
	---------------
	Packages
	+---------------------------+---------+-------+------------------------------------------+
	| Name                      | Version | Notes | Fingerprint                              |
	+---------------------------+---------+-------+------------------------------------------+
	| sqlite                    | 3       |       | e3e9b61f8cdc2610480c2aa841e89dc0bb1dc9c9 |
	| ruby                      | 6       |       | b35a5da6c214d9a97fdd664931bf64987053ad4c |
	… …
	| debian_nfs_server         | 3       |       | c1dc860ed6ab2bee68172be996f64f9587e9ac0d |
	+---------------------------+---------+-------+------------------------------------------+
	Jobs
	+---------------------------+----------+-------------+------------------------------------------+
	| Name                      | Version  | Notes       | Fingerprint                              |
	+---------------------------+----------+-------------+------------------------------------------+
	| redis_node                | 19       |             | 61098860eaa8cfb5dc438255ebe28db74a1feabc |
	| rabbit_gateway            | 13       |             | ddcc0901ded1e45fdc4f318ed4ba8d8ccca51f7f |
	… …
	| debian_nfs_server         | 7        |             | 234fabc1a2c5dfbfd7c932882d947fed331b8295 |
	| memcached_gateway         | 4        |             | 998623d86733a633c789849721e00d85cc3ebc20 |
	Jobs affected by changes in this release
	+------------------+----------+
	| Name             | Version  |
	+------------------+----------+
	… …
	| cloud_controller | 45.1-dev |
	+------------------+----------+
	Release version:95.10-dev
	Release manifest:/home/boshcli/cf-release/dev_releases/cf-def-95.10-dev.yml

正如您可以看到的那样，dev-releases 目录包含此Release的 yml 清单文件（如果启用了 --with-tarball 选项，则还包含一个 tar 包文件）。

3) 将 BOSH CLI 的目标设为 BOSH 的director。如果您不记得该director的 IP，您可以在第 III 部分中的 BOSH 部署清单中找到它。

`$ bosh target 10.60.98.117:25555`

`Target set to 'bosh_director (http://10.60.98.117:25555) Ver:0.5.1 (release:abb3e7a4 bosh:2c69ee8c)'`

4) 通过生成的清单(manifest)文件（例如，示例中的 cf-def-95.10-dev.yml）上传 CF Release。

`$ bosh upload release cf-def-95.10-dev.yml`

这一步将复制安装包和作业，并将它们构建成一个 tar 包，然后对此Release进行验证以确保文件和依赖项正确无误。验证完毕后，它会上传Release并创建新的作业。最后，会看到Release已上传的信息：

		Task 317 done
		Started		2012-08-28 05:35:43 UTC
		Finished	2012-08-28 05:36:44 UTC
		Duration	00:01:01
		Release uploaded

您可以通过以下命令验证上传的Release：

`$ bosh releases`

您可以查看列表中所有新上传的Release：

		+--------+---------------------------------------------------------------------------+
		| Name   | Versions                                                                                  |
		+--------+----------------------------------------------------------------------------+
		| cf-def | 95.1-dev, 95.8-dev, 95.9-dev, 95.10-dev |
		| cflab  | 92.1-dev                                                                                  |
		+--------+-------------------------------------------------------------------------+

5) 在我们已经上传了Release和stemcell（就是第 III 部分中的那个stemcell）后，部署清单(deployment manifest)也已准备就绪，那么就将BOSH的部署配置设置为此部署清单吧：

`$ bosh deployment cf-dev.yml`

设置完毕：

`Deployment set to '/home/boshcli/cf-dev.yml'`

现在我们就可以部署 Cloud Foundry 了，这一部分是最耗时的，根据您的网速情况可能需要1个小时以上甚至两个小时：

`$ bosh deploy`

这将为每个作业创建虚拟机、编译包并安装依赖项。此过程将耗费十几分钟到几小时，快慢取决于服务器的硬件条件。您可以看到大致如下的输出：

		Preparing deployment
		binding deployment (00:00:00)                                                                     
		binding releases (00:00:01)                                                                       
		  … …
		Preparing package compilation
		  … …
		Compiling packages
		   … …
		Preparing DNS
		binding DNS (00:00:00)    
		Creating bound missing VMs
		  … …                                                             
		Binding instance VMs
		  … …                                                                      
		Preparing configuration
		binding configuration (00:00:03)                                                                  
		  … …
		Creating job cloud_controller
		cloud_controller/0 (canary) (00:02:45)        
		  … …                                                    
		Done                    1/1 00:08:41                                                                

		Task 318 done
		Started		2012-08-28 05:37:52 UTC
		Finished	2012-08-28 05:49:43 UTC
		Duration	00:11:51
		Deployed 'cf-dev.yml' to 'bosh_director'

要查看您的部署，可以使用下面的命令：

`$ bosh deployments`

		+----------+
		| Name     |
		+----------+
		| cf.local |
		+----------+
		Deployments total: 1

您还可以验证每个虚拟机的运行状态：

`$ bosh vms`

		+-----------------------------+---------+---------------+-------------+
		| Job/index                   | State   | Resource Pool | IPs         |
		+-----------------------------+---------+---------------+-------------+
		| acm/0                       | running | small         | 10.60.98.58 |
		| acmdb/0                     | running | small         | 10.60.98.57 |
		| cloud_controller/0          | running | medium        | 10.60.98.59 |
		 … … …
		+-----------------------------+---------+---------------+-------------+
		VMs total: 40


#####注意：#####
    
    前面提到在缺少SSL证书且网络环境比较特殊的情况下还需要修改Cloud Controller的hosts文件来使uaa的URL能够正确解析：

    登录到所有CloudController的虚拟机中，在他们的hosts中添加这样一行即可：

    <IP_of_uaa> uaa.<yourdomain>


到这里，Cloud Foundry 已经完全安装好了。如果您迫不及待地想要验证此安装，您可以使用vmc命令将其中一个router的 IP 地址设为目标，然后在该目标上部署一个测试用的 Web 应用程序（见后一节）。由于此时没有配置 DNS 服务，因此，在vmc客户端以及运行浏览器来测试的机器的 hosts 文件需包含至少以下两行内容：

		<router的 IP 地址>  api.yourdomain.com  
		<router的 IP 地址>  <youapp>.yourdomain.com  

如果上述测试顺利通过，则说明您的 Cloud Foundry 实例正常工作。最后要做的是部署负载均衡器和 DNS服务。它们不属于 Cloud Foundry 的组件，但在生产环境中往往需要正确地设置它们。我们简要地介绍一下如何设置。

您可以部署一个硬件或软件负载均衡器 (LB) 来均匀地向多个router实例分配负载。在我们的示例部署中，我们有两个router。对于软件 LB，您可以使用Stingray 流量管理器。可从以下位置下载该软件：[https://support.riverbed.com/download.htm?filename=public/software/stingray/trafficmanager/9.0/ZeusTM_90_Linux-x86_64.tgz](https://support.riverbed.com/download.htm?filename=public/software/stingray/trafficmanager/9.0/ZeusTM_90_Linux-x86_64.tgz)

要解析 Cloud Foundry 实例所属的域名，需要有 DNS 服务器。基本而言，DNS 服务器会将像 *.yourdomain.com 这样带通配符的域名解析为负载均衡器的 IP 地址。如果您没有 LB，您可以设置 DNS Rotation，从而以循环方式将域解析为各个router的地址。

LB 和 DNS 设置妥善后，您便可以开始在您的实例上部署应用程序。

VMC 是使用Cloud Foundry的命令行工具。它可以执行 Cloud Foundry 上的大多数操作，例如配置应用程序、将应用部署到 Cloud Foundry 以及监控应用程序的状态。要安装 VMC，需要先安装 Ruby 和RubyGems（ Ruby Gem管理器）。目前支持 Ruby 1.8.7 和 1.9.2。接着，您可以通过下面的命令安装 VMC（有关 VMC 安装的更多信息，请参见[http://docs.cloudfoundry.com/tools/vmc/installing-vmc.html](http://docs.cloudfoundry.com/tools/vmc/installing-vmc.html)）：

`$ sudo gem install vmc`

现在，可指定该 Cloud Foundry 实例的目标，相应的 URL 应形如 api.yourdomain.com，例如：

`$ vmc target api.cf.local`

使用管理员用户和密码（部署清单中指定了该凭据）登录：

`$ vmc login`

起初，系统将要求您为自己的帐户设置密码。登录后，您可以获得自己 Cloud Foundry 实例的信息：

`$ vmc info`

现在，我们来创建并部署一个简单的 Hello World Sinatra 应用程序以验证该实例。


    $ mkdir ~/hello
    $ cd ~/hello


创建一个名为hello.rb且包含以下内容的 Ruby 文件：


    require 'sinatra'
    get '/' do
      "Hello from Cloud Foundry"
    end


保存此文件，接下来我们要上传此应用程序：

`$ vmc push`

回答提示问题，如下所示

		Would you like to deploy from the current directory?[Yn]: 
		Application Name:hello
		Detected a Sinatra Application, is this correct?[Yn]: 
		Application Deployed URL [hello.cf.local]: 
		Memory reservation (128M, 256M, 512M, 1G, 2G) [128M]: 
		How many instances? [1]: 
		Bind existing services to 'hello'?[yN]: 
		Create services to bind to 'hello'?[yN]: 
		Would you like to save this configuration?[yN]: 

稍等片刻后，您将看到以下内容：

		Creating Application:OK
		Uploading Application:
		Checking for available resources:OK
		Packing application:OK
		Uploading (0K):OK   
		Push Status:OK
		Staging Application 'hello':OK                                                 
		Starting Application 'hello':OK   

现在，到浏览器中访问该应用程序的 URL：hello.cf.local。如果您可以看到下面的文本，则说明您的应用程序已成功部署。

![fig27.png](/images/deploy/fig27.png)

恭喜！您的 Cloud Foundry 实例已经完全设置好了。它在功能上与 cloudfoundry.com 完全相同。








