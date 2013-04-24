---
title: 向开源软件 Cloud Foundry 添加框架 
description: 向开源软件 Cloud Foundry 添加框架 
tags:
    - frameworks
---

_作者：**Jennifer Hickey**_

本文档说明如何在使用 [dev_setup 安装](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/single_and_multi_node_deployments_with_dev_setup)的 Cloud
Foundry 中添加框架。有关如何添加运行时的说明，请查看[此处](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/adding_a_runtime)。

## 创建暂存插件
每个框架都应有一个暂存插件。暂存插件应扩展 [StagingPlugin](https://github.com/cloudfoundry/vcap-staging/blob/master/lib/vcap/staging/plugin/common.rb) 类并且应命名为 FrameworknamePlugin。有关示例，请查看 [Sinatra 插件](https://github.com/cloudfoundry/vcap-staging/blob/master/lib/vcap/staging/plugin/sinatra/plugin.rb)。

1. 实现所需的方法

   新的暂存插件必须实现 stage_application 方法。stage_application 方法应包含将相应应用程序复制到暂存区域以及创建启动和停止脚本所需的全部功能。这通常通过调用诸如 create_app_directories、copy_source_files、create_startup_script 和 create_stop_script 等方法来做到。

   大多数插件还实现了 start_command 方法，该方法由 create_startup_script 加以调用。Sinatra 插件还覆盖了 startup_script 方法以便向应用程序启动脚本添加额外的环境变量。再次重申，暂存插件的主要目的是创建一个包含该应用程序及其启动和停止脚本的目录。该插件可能会顺便添加一些帮助器功能，例如安装用户的 gem、运行数据库迁移或自动配置数据库连接。

2. 测试和构建暂存插件

   如果您要保留自己的分支（或者反过来向 Cloud Foundry 贡献您的插件），您可以将自己的暂存插件包含在 vcap-staging gem 中；您也可以创建自己的 gem 来容纳自己的暂存插件。vcap-staging repo 包含一个测试工具，借助此工具可以轻松地对您的新插件进行单元测试。有关示例，请参见 [Sinatra 规范](https://github.com/cloudfoundry/vcap-staging/blob/master/spec/unit/sinatra_spec.rb)。

   运行“bundle exec rake build”即可构建 vcap-staging gem。

3. 安装暂存插件

暂存插件由 [Stager](https://github.com/cloudfoundry/stager) 进行加载。请在 Stager 的 Gemfile 中添加您的自定义 gem 或者更新 vcap-staging gem 的版本以使该插件可用。

## 创建暂存清单
每个框架都应有一个在 [dev_setup 云控制器 cookbook](https://github.com/cloudfoundry/vcap/tree/master/dev_setup/cookbooks/cloud_controller/templates/default) 中定义的清单。下面是 sinatra.yml.erb 的内容：
```
name: "sinatra"
runtimes:
  - "ruby18":
      default: true
  - "ruby19":
     default: false
detection:
  - "*.rb": "\\s*require[\\s\\(]*['\"]sinatra['\"(/base['\"])]" # .rb files in the root dir containing a require?
  - "config/environment.rb": false # and config/environment.rb must not exist
```
此框架名称是用户在选择该框架时必须指定的名称。此名称还必须与 StagingPlugin 类的名称匹配。一个框架必须支持至少一个运行时。如果该框架有默认运行时，则用户在推送该框架类型的应用程序时无需选择运行时。最后，框架可以定义检测规则。新版的 vmc 使用这些检测规则来自动选择应用程序的默认框架。暂存框架也可以使用这些检测规则。Sinatra 插件使用第一项检测规则来选择要运行的主文件。

请通过修改 dev_setup/cookbooks/cloud_controller/attributes/default.rb 确保将此清单复制到了相应的位置。

```
default[:cloud_controller][:staging][:sinatra] = "sinatra.yml"
```

## 试一下
成功运行 [dev_setup](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/single_and_multi_node_deployments_with_dev_setup) 后，请使用 vmc 来验证是否已添加该框架。“vmc frameworks”应该会列出该框架的信息。如果您使用的是测试版 vmc（通过 gem install vmc --pre 安装），则该框架应自动可供选择，检测规则也应该会应用。较旧版的 vmc 要求修改 [frameworks.rb](https://github.com/cloudfoundry/vmc/blob/master/lib/cli/frameworks.rb)
