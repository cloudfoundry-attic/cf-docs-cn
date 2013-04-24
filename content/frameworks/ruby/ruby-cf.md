---
title: Ruby、Rails 和 Cloud Foundry
description: Ruby、Rails 和 Cloud Foundry 相关事宜
tags:
    - ruby
    - rails
    - bundler
    - Gemfile
    - git
---

本文提供在 Cloud Foundry 上构建 Ruby 应用程序时的有用提示。
许多最初的限制现在已不再存在。
要查看关于 Ruby 支持的最新消息，请访问：
[http://blog.cloudfoundry.com/tag/ruby/](http://blog.cloudfoundry.com/tag/ruby/)

下面要介绍的重点主题如下：

+ 您的应用程序必须提供一个指定所有必要的 gem 的 `Gemfile`
+ 您的应用程序经过最大程度的预打包
+ 支持 Ruby 1.8 和 Ruby 1.9


## Gem 和库

关于 Gem 和 Gemfile 的重要注释：

GEM 列表完整性 － 与 Cloud Foundry 交互的正确方式是提供完整的 `Gemfile`，
并且每次使用 Gemfile 和运行 
任何 `vmc push` 或 `vmc update` 命令前还要运行 `bundle install;bundle package`。

受支持的使用 gem 的方式是通过 [捆绑程序](http://gembundler.com/)
VCAP **不支持**捆绑程序 [Isolate](https://github.com/jbarnette/isolate) 以外的其他方法。

**您的应用程序必须提供一个指定所有必要 gem 的 `Gemfile` 和一个特定 gem 版本的 `Gemfile.lock`**

有关 `bundle package` 的详细信息，请参见 [http://gembundler.com/bundle_package.html](http://gembundler.com/bundle_package.html)


## 捆绑程序(Bundler)

通常应注意复杂难懂的捆绑设置。
虽然 VCAP 会尽最大努力处理您的配置，但也有可能编写的 
Gemfile 无法满足要求，例如同时请求旧版本的 Rails 和全新版本的 Rack 时。
这样的组合请求会立即失败，因而您不必等到把应用程序推送到云后才知道
出了问题。同样道理，版本太过不清楚的 Gemfile 和 Gem 也可以进行创建。

Gemfile 可连同发布的 gem 一起通过 URL、分支名称等引用 git repo。而且捆绑程序会通过专门机制对其进行构建。
**VCAP 现在支持通过 git URL 读取 Gemfile。**

示例 `Gemfile`：

``` ruby

source :rubygems

# Gets the json gem from rubygems
gem "json", "~> 1.4.6"

# Gets the vcap_services_base gem from cloudfoundry's vcap-services-base repo on github.com at master branch
gem 'vcap_services_base', :git => 'git://github.com/cloudfoundry/vcap-services-base.git'

# Gets the vcap_logging gem from cloudfoundry's common repo on github.com at the specified ref on the master branch
gem 'vcap_logging', :require => ['vcap/logging'], :git => 'git://github.com/cloudfoundry/common.git', :ref => 'b96ec1192'

# Gets the eventmachine from cloudfoundry eventmachine repo on github.com using the release-0.12.11-cf branch
gem 'eventmachine', :git => 'git://github.com/cloudfoundry/eventmachine.git', :branch => 'release-0.12.11-cf'

```


只有路径与您的应用程序相关且路径中已构建 gem 时，才可以使用路径来链接到 gem。

+ gem :path => "some/path"

请注意现在已同时支持平台和 git URL。这样，您就可以在诸如 Windows 环境中工作，
并在您的应用程序开始运行时使用更多不必在 Cloud Foundry 上安装的 gem。

``` ruby

gem 'vcap_common', :require => ['vcap/common', 'vcap/component'], :git => 'git://github.com/cloudfoundry/vcap-common.git'
gem 'vcap_logging', :require => ['vcap/logging'], :git => 'git://github.com/cloudfoundry/common.git', :ref => 'b96ec1192'
gem 'vcap_services_base', :git => 'git://github.com/cloudfoundry/vcap-services-base.git'
gem 'warden-client', :require => ['warden/client'], :git => 'git://github.com/cloudfoundry/warden.git'

group :test do
  gem "webmock"
  gem "rake"
  gem "rack-test"
  gem "rspec"
  gem "simplecov"
  gem "simplecov-rcov"
  gem "ci_reporter"
end

```

库依赖项解析 － 当您使用的库存在依赖项时，
您需要特别注意它是怎么加载所依赖库的版本的（通过 $LOAD_PATH）。

### 捆绑程序组

完全支持组，使您可以先指定比如说 `development` 和 `test` 组，然后再从应用程序中将其去除。

示例 `Gemfile`

``` ruby

gem "sinatra"
gem "newrelic_rpm"

group :development do
  gem "vmc"
end

group :test do
  gem "webmock"
  gem "rake"
  gem "rack-test"
  gem "rspec"
  gem "simplecov"
  gem "simplecov-rcov"
  gem "ci_reporter"
end

```

请注意，现在您可以设置环境变量 `BUNDLE_WITHOUT`，以去除开发和测试功能
另外还要注意，现在 Cloud Foundry 已能使用 `RAILS_ENV` 和 `RACK_ENV` 中设定的值

``` bash

vmc push --nostart

vmc env-add <app_name> RAILS_ENV=staging
vmc env-add <app_name> BUNDLE_WITHOUT=test:development

vmc start <app_name>

```

### 平台

现在已能支持所有平台，使您针对不同的操作系统选择不同的 gem。
下面是一个能使用各种平台的 `Gemfile` 示例：

``` ruby

# Unix Rubies (OSX, Linux)
platform :ruby do
  gem 'rb-inotify'
end

# Windows Rubies (RubyInstaller)
platforms :mswin, :mingw do
  gem 'eventmachine-win32'
  gem 'win32-changenotify'
  gem 'win32-event'
end

```


## Rails 3

一般来说，Rails 3 中包括对捆绑程序的“本机”支持。
新生成的 Rails 应用程序带有一个用户可编辑的 Gemfile，
并且 Rails 能在引导时自动激活该捆绑程序。
VCAP 一旦在应用程序中发现 `Gemfile.lock`，它会确保对所需 gem 进行打包，并设定指向它们的 `BUNDLE_PATH` 环境变量。

Rails 3 捆绑程序的支持限制 － 目前 VCAP 能很好地支持简单的 gem 依赖项列表（“gem install”所能找到的任何依赖项）。
但是，对于复杂的列表，或在部署时利用多个 repo 组装成的 gem 构建脚本，VCAP 的支持非常有限。
**一般的做法是对应用程序进行最大程度的预打包处理。**



## Rails 2.3

Rails 的“config.gem”机制可供用户指定应用程序要运行的 gem 列表，
其局限性在于无法防止多重深度依赖项（利用其他 gem 的深层 gem）。
在云环境中，此问题容易引起故障。

为了降低风险，许多 Rails 2.3 已采用了 gem 捆绑程序。

**VCAP 目前不能“检测”Rails 2.3 应用程序。如果您需要运行
Ruby 2.3 应用程序，可将其伪装成 Rails 3 应用程序（通过创建一个 config/application.rb 文件和一个“config.ru”）。**

## 应用程序服务器

目前，该命令行和部署的云只能为 Sinatra 和 Rails 应用程序提供一个应用程序服务器： `Thin`.
但是，如果您使用的捆绑程序，并且捆绑程序中没有需要使用 Thin 的，VCAP 将无法安全地用它来启动应用程序。
此时，它会退回改用“rails server”运行您的应用程序，而“rails server”需使用 WEBrick。

**为了获得最佳性能和效果，我们建议在您的 Gemfile 中增加“gem 'thin'”。**


## Ruby 版本

VCAP 支持两种 ruby“runtime”：

- ruby18：Ruby 版本 1.8.7-p302（或更高版本）
- ruby19：Ruby 版本 1.9.2-p180

**默认 runtime 为 ruby18**；您也可以在 vmc 命令行中用 `--runtime` 标志来指定：

```bash
$ vmc push myapp --runtime ruby19
```

