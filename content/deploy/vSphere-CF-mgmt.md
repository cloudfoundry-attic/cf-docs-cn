---
title: 扩展内容
description: 在vSphere上通过BOSH工具大规模部署Cloud Foundry
tags:
    - vSphere
    - BOSH
    - Deploy
    - IaaS
---

在上一篇文章里我们已经完成了Cloud Foundry的安装过程，这一部分我们将在前面工作的基础上进行一些扩展功能的使用。

**如何使用Dashboard来对Cloud Foundry 进行监控**

在Cloud Foundry的组件里面，有一个叫dashboard的job，它可以让管理员监控Cloud Foundry的运行状态，这是日常运维中不可或缺的工具。在Dashboard中使用了OpenTSDB作为其数据存储。在我们部署Cloud Foundry的yml中已经给出了Dashboard这个job的配置方法。Dashboard需要使用OpenTSDB和collector， 而OpenTSDB的正常运行则依赖于HBase Master和HBase Slave。因此，如果我们想要使用Dashboard，首先需要确认这些有关的job都在Cloud Foundry的yml文件中正确地配置并部署了。 这里需要注意的是这些job是存在依赖关系的，所以要保证他们在yml里的描述定义按照如下顺序 ：hbase_slave，hbase_master，opentsdb，collector，dashboard。
由于Dashboard的用户认证采用了UAA模块，因此我们在使用之前还要配置管理员用户和赋予其使用Dashboard的管理权限。配置的过程如下：

首先我们安装一个叫做uaac的命令行工具，登录到BOSH CLI这台虚拟机上安装必要的依赖：


    for GEM in bundler rake rspec simplecov simplecov-rcov ci_reporter highline rest-client yajl-ruby eventmachine launchy em-http-request ; do
        gem install $GEM
    done

下载uaa的源码并使用源码安装uaac：

    gerrit clone ssh://<username>@reviews.cloudfoundry.org:29418/uaa
    cd uaa/gem
    bundle install
    gem build cf-uaa-client.gemspec
    gem install cf-uaa-client-<gem version>.gem 
    uaac -v


uaac 安装成功以后我们需要使用他来完成添加用户的操作：

    $ uaac target http://uaa.<YOURtarget>.com
    $ uaac token client get dashboard --secret <copy-paste the secret from UAA clients>
    $ uaac member add dashboard.user <username1> <username2> ... <usernameN>
    # For eg. - $ uaac member add dashboard.user admin@vmware.com
    $ uaac token delete

如果在上面的操作中有错误提示group不存在，可参照uaac帮助信息来执行uaac group add [name]就可以了。命令中的secret就是在Cloud Foundry的yml文件中定义的属性值uaa.clients.dashboard.secret，dashboard.user是赋予用户使用dashboard的权限，username1等用户名就是我们配置过的Cloud Foundry管理员用户邮箱（比如：admin@vmware.com）。
配置完成后，我们就可以登录Dashboard了。登录过程会跳转到UAA的页面，登录成功后就可以看到Dashboard的页面了。如果这一步登录后只显示登录成功没有跳转到Dashboard，手动访问一下Dashboard的URL(dashboard.yourdomain.com)即可。


![fig29.png](/images/deploy/fig29.png)

我们可以看到在这个页面上有多个标签页，每一个标签页代表了一种我们的监控项。现在我们切换到System标签页，有可能发现这一页上是没有数据的。System标签页负责监控当前环境中所有Cloud Foundry虚拟机的资源状况，这些数据的来源需要BOSH的HealthMonitor组件和Cloud Foundry的OpenTSDB一起来负责。所以查看我们的BOSH部署文件bosh.yml中HealthMonitor的properties部分，我们会看到tsdb部分被注释掉了：

    hm:
        ...
        smtp:
          ...
        # tsdb_enabled: true
        # tsdb:
          # address: 10.40.97.85
          # port: 4242


之所以注释掉的原因是这里HM依赖的OpenTSDB是Cloud Foundry的一个job，也就是说我们在部署BOSH的时候OpenTSDB还没有安装，所以需要暂时注释掉了这个部分。 当我们按照文章第三部分部署过Cloud Foundry之后，OpenTSDB就存在了，所以我们只需要把这部分注释去掉（注意tsdb要和上面的smtp处于同一级别），然后重新deploy一次BOSH就可以了。由于BOSH的部署是增量式的，所以这次更新BOSH的操作只需要很短的时间就能完成。
    
    $ bosh target http://<ip_of_micro_bosh>:25555
    $ bosh deployment bosh.yml
    $ bosh deploy

部署完成后，直接访问Dashboard并查看System标签页，我们就能看到System的数据了。


**如何使用BOSH扩展Cloud Foundry**

在BOSH的帮助下我们如果想要对Cloud Foundry进行水平扩展的话是一件非常容易的事情。

以DEA为例子，打开我们用来部署Cloud Foundry的cf.yml文件，找到其中定义DEA job的部分：


    - name: dea
      template: dea
      instances: 2
      resource_pool: medium
      networks:
      - name: default
        static_ips:
        - 10.40.97.65
        - 10.40.97.66


我们只需要把这里的instance变成3，然后在static_ips部分分配一个新的IP就可以了：


    - name: dea
      template: dea
      instances: 3
      resource_pool: medium
      networks:
      - name: default
        static_ips:
        - 10.40.97.65
        - 10.40.97.66
        - 10.40.97.110


由于我们新添加了一个DEA，所有首先我们需要保证我们新添加的IP是有效的，也就是在我们cf.yml里面指定的network.static范围内，否则的话就需要调整这部分IP的范围。 另外，新添加的DEA还会多使用一个medium大小的资源，所以我们还需要把cf.yml文件中reousrce_pools部分对应的medium资源的size由4增加1到5：

    - name: medium
      network: default
      size: 5
      stemcell:
        name: bosh-stemcell
        version: 0.6.4
      cloud_properties:
        ram: 2048
        disk: 16384
        cpu: 2

然后重新执行bosh deploy即可，BOSH会提示你当前部署文件发生的改动如下图所示，请一定要认真确认过之后再执行部署:
![fig30.png](/images/deploy/fig30.png)

如果一切正常，执行bosh vms命令就可以查看到新添的DEA实例，其index为2。

**如何使用BOSH更新Cloud Foundry的代码**

BOSH可以在线升级Cloud Foundry的系统，即新版本的代码可以平滑地切换到生产系统中，整个升级过程不影响生产系统的运行。我们以升级Cloud Controller为例子，对这个过程做个介绍。
假定Cloud Foundry里面有若干个Cloud Controller的实例，我们要把它们从版本V1升级到V2。BOSH在升级的时候首先部署一个V2版本的Cloud Controller实例，称为金丝雀实例(Canary)。它的作用是验证新版本V2是否可部署成功并运行。如果该实例不能正常运行，则整个升级过程报错并停止。如果金丝雀实例部署成功，则在系统里面部署更多的V2实例，同时删除旧的V1实例，直到整个过程完成。在整个过程中，系统中始终有可以正常工作的Cloud Controller提供服务，因此对用户来说感觉不到系统的停滞。整个过程如下图所示：
![fig31.png](/images/deploy/fig31.png)
![fig32.png](/images/deploy/fig32.png)

在DEA结点的更新上，BOSH会给旧版本DEA 中的agent发出一个叫”Drain”(排干)的指令，使DEA可以处理完目前所有的请求，然后才把该DEA下线。该旧版DEA上面的应用会迁移到新版本的DEA实例上继续运行，后续的请求将会转发到这些新版本的DEA实例中。
如果我们要升级运行中的Cloud Foundry实例，可以下载github上面最新的cf-release代码，再执行一次前述的部署过程即可。BOSH会自动比较新旧两个release的代码并且只升级代码变动了的组件。

另一种升级的情况是，如果你对Cloud Foundry的代码进行了修改，需要在修改代码之后重新进行create release的过程。下面的操作发生前我们正在使用的release版本为123.2-dev。


首先我们将DEA代码（cf-release/src/dea/lib/dea/agent.rb）中定义的VERSIOIN常量的值从0.99修改为:

    - VERSION = 0.99
    + VERSION = 0.999991

然后执行:

`bosh create release --with-tarball --force`

加--force的原因是因为我们修改了代码，而create release时BOSH会检查本地git库与远程github上的代码相比是否发生了变化，如果有更改，BOSH会提示我们提交修改或者加force选项。


    | common                    | 5        |             |
    | dea                       | 51.2-dev | new version |
    | cloud_controller_ng       | 7.1-dev  |             |

release成功创建后BOSH标识出了DEA的新版本，并且列出代码更改影响到的job：


    +-------+----------+
    | Name  | Version  |
    +-------+----------+
    | dea   | 21       |
    +-------+----------+


同时，我们也可以看到release的版本号增加到了123.3-dev：

    Release version: 123.3-dev
    Release manifest: /home/bosh/cf-release/dev_releases/cf-dev-123.3-dev.yml
    Release tarball (1.5G): /home/bosh/cf-release/dev_releases/cf-dev-123.3-dev.tgz


接下来我们上传这个新release：
`bosh upload release cf-dev-123.3-dev.tgz`

完成后，查看当前可用的releases：

    +--------+------------+
    | Name   | Versions   |
    +--------+------------+
    | cf-dev | 123.3-dev  |
    | cf01   | 123.2-dev* |
    +--------+------------+
    (*) Currently deployed


然后在我们的cf.yml文件中修改release的版本和名字：

    release:
      name: cf-dev
      version: 123.3-dev


接下来我们就可以执行bosh deploy了，等待部署过程完成后，我们可以使用：

`bosh ssh dea 0` （这里请求的密码是个临时密码，您可以随意设置一个自己记住的值即可）

登录到DEA的虚机中，然后查看下DEA的日志文件（/var/vcap/sys/log/dea/dea.log）的第一句：

`[2012-12-28 07:46:02.124445] dea - pid=24397 tid=030f fid=3ade   INFO -- Starting VCAP DEA (0.999991)`

我们可以看到DEA的VERSION信息已经变成了我们自己设置的值0.999991，代码修改生效了。

综合上述，我们看到BOSH不仅可以部署Cloud Foundry，而且可以帮助我们动态监控和调整系统资源，并且可以在线升级系统代码。因此生产系统中都需要使用BOSH来管理和运维Cloud Foundry 平台。

