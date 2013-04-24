---
title: 向开源软件 Cloud Foundry 添加运行时
description: 向开源软件 Cloud Foundry 添加运行时
tags:
    - runtimes
---

_作者：**Jennifer Hickey**_

本文档说明如何在使用 [dev_setup 安装](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/single_and_multi_node_deployments_with_dev_setup)的 Cloud
Foundry 中添加运行时来供现有框架使用。有关如何添加框架的说明，请查看[此处](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/adding_a_framework)。

本文档将以添加 Ruby 1.9.3 为例说明添加新运行时所需的步骤。

下文所述的所有修改都应在 [vcap repo](https://github.com/cloudfoundry/vcap) 中进行。

## 添加或修改用来安装运行时的 Cookbook
由于我们是要添加现有运行时的一个新版本，因此我们需要修改位于 dev_setup/cookbooks/ruby 中的 Ruby cookbook。

1. 添加一个 recipe

   在实际情况中，您可能会安装诸如 Rubygem、Bundler 和 Rake 等其他工具。对于本示例，我们将仅安装 Ruby 1.9.3。

   Ruby cookbook 中的现有 recipe 使用存储在 Cloud Foundry blobstore 中的二进制文件。由于大众无法向此 blobstore 上传内容，因此我们建议编写您自己的 recipe 来使用 Chef 的[远程文件](http://wiki.opscode.com/display/chef/Resources#Resources-RemoteFile)提供程序从 URL 下载二进制文件。当您向 Cloud Foundry 贡献代码时，必要时我们会将代码修改为使用 blobstore。

   dev_setup/cookbooks/ruby/recipes/ruby193.rb：
   ```
   ruby_path = node[:ruby193][:path]
   ruby_version = node[:ruby193][:version]
   ruby_tarball_path = File.join(node[:deployment][:setup_cache], "ruby-#{ruby_version}.tar.gz")

   remote_file ruby_tarball_path do
     owner node[:deployment][:user]
     source node[:ruby193][:source]
     checksum node[:ruby193][:checksums][node[:ruby193][:version]]
   end

   directory ruby_path do
     owner node[:deployment][:user]
     group node[:deployment][:group]
     mode "0755"
     recursive true
     action :create
   end

   bash "Install Ruby #{ruby_path}" do
     cwd File.join("", "tmp")
     user node[:deployment][:user]
     code <<-EOH
     # work around chef's decompression of source tarball before a more elegant
     # solution is found
     tar xzf #{ruby_tarball_path}

     cd ruby-#{ruby_version}
     # See http://deadmemes.net/2011/10/28/rvm-install-fails-on-ubuntu-11-10/
     sed -i 's/\\(OSSL_SSL_METHOD_ENTRY(SSLv2[^3]\\)/\\/\\/\\1/g' ./ext/openssl/ossl_ssl.c
     ./configure --disable-pthread --prefix=#{ruby_path}
     make
     make install
     EOH
   end
   ```
   上述 recipe 引用应在 dev_setup/cookbooks/ruby/attributes/ruby193.rb 中定义的属性：
   ```
   include_attribute "deployment"

   default[:ruby193][:version] = "1.9.3-p194"
   default[:ruby193][:source]  = "http://ftp.ruby-lang.org//pub/ruby/1.9/ruby-#{ruby193[:version]}.tar.gz"
   default[:ruby193][:path]    = File.join(node[:deployment][:home], "deploy", "rubies", "ruby-#{ruby193[:version]}")
   default[:ruby193][:checksums]["1.9.3-p194"] = "46e2fa80be7efed51bd9cdc529d1fe22ebc7567ee0f91db4ab855438cf4bd8bb"
   ```
   此二进制文件的校验和可以使用“sha256sum”命令加以计算。

## 添加运行时元数据


1. 向 dev_setup/cookbooks/cloud_controller/templates/default/runtimes.yml.erb 中添加一个条目

   ```
   ruby193:
     version: "1.9.3p194"
     description: "Ruby 1.9.3"
     executable: "< %= File.join(node[:ruby193][:path], "bin", "ruby") %>"
     version_flag: "-e 'puts RUBY_VERSION'"
     additional_checks: "-e 'puts RUBY_PATCHLEVEL >= 194'"
     version_output: 1.9.3
     environment:
       PATH: < %= File.join(node[:ruby193][:path], "bin") %>:$PATH
   ```
   必需的属性：version、description、executable、version_output

   可选属性：version_flag（默认为 -v）、additional_checks、environment

   我们选择的键（“ruby193”）将是用户在选择该运行时之时必须指定的名称。此名称以及版本和说明用于供“vmc   runtimes”显示。

   其余属性由 DEA 使用，Stager 可能也会使用它们。DEA 将使用指定的 version_flag 来运行指定的可执行文件来验证它是否具有所需的运行时版本（输出应包含指定的 version_output）。可选的 additional_checks 字段用于执行其他验证。最后，指定的环境将以环境变量的形式传递给使用此运行时的应用程序。

   如果您要编写或修改插件来提供[框架支持](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/adding_a_framework)，您可以选择添加其他属性供 Stager 使用。

2. 向框架添加运行时

   运行时必须添加到框架的暂存清单中才能使用。在本例中，我们将通过修改 dev_setup/cookbooks/cloud_controller/templates/default/standalone.yml.erb 来使 Ruby 1.9.3 可供独立应用程序使用：
   ```
   runtimes:
  - "ruby193"
     default: false

## 将运行时添加到 DEA 中

1. 将运行时添加到 DEA 属性中

   在 dev_setup/cookbooks/dea/attributes/default.rb 中：
   ```
   default[:dea][:runtimes] = ["ruby18", "ruby19", "ruby193", "node04", "node06", "node08", "java", "java7", "erlang", "php", "python2"]
   ```

2. 启用方法

   将新方法添加到 dev_setup/cookbooks/dea/recipes/default.rb 中
   ```
   node[:dea][:runtimes].each do |runtime|
     case runtime
     when "ruby193"
       include_recipe "ruby::ruby193"
   ```

3. 将运行时添加到 DEA 配置中

   DEA 仅允许将应用程序与 dea.yml 中列出的运行时一起部署。

   修改 dev_setup/cookbooks/dea/templates/default/dea.yml.erb：
   ```
   runtimes:
   < % if node[:dea][:runtimes].include?("ruby193") %>
     - ruby193
   < % end %>
   ```

## 试一下
一旦成功运行 dev_setup，就可以使用 vmc 验证已经添加了运行时。“vmc runtimes”应该会列出运行时信息。请注意，目前稳定版本的 vmc 要求运行时至少要添加到一个框架中，这样运行时才能在上述文件中列出。

我们使用 vmc 应该可以推送简单的独立 Ruby 应用程序。下面这个应用程序可以轻松地输出 Ruby 版本，然后一直休眠：

```
$ more simple.rb
puts "Running Ruby #{RUBY_VERSION}"
sleep

$ vmc push
Would you like to deploy from the current directory? [Yn]:
Application Name: simple
Detected a Standalone Application, is this correct? [Yn]:
...
11: ruby193
Select Runtime [ruby18]: 11
Selected ruby193
Start Command: ruby simple.rb
Application Deployed URL [None]:
Memory reservation (128M, 256M, 512M, 1G, 2G) [128M]:
How many instances? [1]:
Bind existing services to 'simple'? [yN]:
Create services to bind to 'simple'? [yN]:
Would you like to save this configuration? [yN]:
Creating Application: OK
Uploading Application:
  Checking for available resources: OK
  Packing application: OK
  Uploading (0K): OK
Push Status: OK
Staging Application 'simple': OK
Starting Application 'simple': OK

$ vmc logs simple
====> /logs/stdout.log <====

Running Ruby 1.9.3
```
