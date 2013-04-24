---
title: 安装 Ruby 和 RubyGems
description: 如何安装 Ruby 和 RubyGems
tags:
    - 教程
    - ruby
    - vmc
    - Gemfile
---

以下章节介绍关于如何在 Windows 和各种 Linux 计算机上安装 Ruby 和 RubyGems 的基本信息。

## Windows
下载和安装 [Windows 的 Ruby 安装程序](http://www.rubyinstaller.org/ "ruby installer for windows")。该安装程序中已经包括 RubyGems。

您在随后安装和使用 `vmc` 时请务必使用支持 Ruby 的命令提示符窗口。您可以通过 Windows“开始”菜单访问此命令提示符（**“所有程序”> Ruby \<版本\> >“使用 Ruby 启动命令提示符”**）。

最后，通过以下 Ruby 命令提示符更新 RubyGems：

    prompt> gem update --system

### 对 Windows Gemfile 的支持

安装 Ruby 后，请阅读 [Cloud Foundry 上的 Ruby 应用程序](ruby-cf.html)中的说明，以了解关于推送应用程序和使用 Gemfile 的详细信息

Windows 用户需注意以下问题：

在 Windows 机器上生成 `Gemfile.lock` 时，其中包含的 gem 会采用 Windows 特定的版本。
mysql2、thin 和 pg 等 gem 版本的最后包含有“x86-mingw32”。

例如，在 Windows 机器上使用以下 Gemfile 运行 `bundle install` 时：

``` ruby
gem ‘sinatra’
gem ‘mysql2’
gem ‘json’
```

将生成以下 Gemfile.lock 文件：

``` ruby
GEM
  remote: http://rubygems.org/
  specs:
    json (1.7.3)
    mysql2 (0.3.11-x86-mingw32)
    rack (1.4.1)
    rack-protection (1.2.0)
      rack
    sinatra (1.3.2)
      rack (~> 1.3, >= 1.3.6)
      rack-protection (~> 1.2)
      tilt (~> 1.3, >= 1.3.3)
    tilt (1.3.3)

PLATFORMS
  x86-mingw32

DEPENDENCIES
  json
  mysql2
  sinatra

```

现在，Cloud Foundry 将能够可靠安装这类 gem 而不必修改 `Gemfile.lock`

## Mac OS X
Mac OS X 的 10.5 和更高版本出厂时已经安装了 Ruby 和 RubyGems。

如果您正在使用较早版本的 Mac OS，请先下载和安装最新版本的 [Ruby](http://www.ruby-lang.org/en/downloads/ "ruby source code")，然后再安装 [RubyGems](http://rubygems.org/pages/download)。

## Ubuntu

在终端上用 `apt-get` 命令行工具安装 Ruby 和 RubyGems 时的步骤如下：

1. 安装整个 Ruby 包和 RubyGems：

    `prompt$ sudo apt-get install ruby-full rubygems`

    有关 `sudo` 命令的任何必要的身份验证凭据，请咨询您的系统管理员。

2.  通过测试以确保您的路径中有 `gem` 命令：

    `prompt$ which gem`

    如未找到该命令，请相应的更新 `PATH` 变量。例如，可使用以下命令行更新您的 `.bashrc` 文件：

    `export PATH=$PATH:/var/lib/gems/1.8/bin`

3.	更新 RubyGems：

    Ubuntu 10.04

        prompt$ sudo gem install rubygems-update
        prompt$ sudo /var/lib/gems/1.8/bin/update_rubygems

    Ubuntu 11.10

        prompt$ sudo su -
        prompt# export REALLY_GEM_UPDATE_SYSTEM=true
        prompt# gem update --system
        prompt# exit

## RedHat/Fedora

在终端上用 `yum` 命令行工具安装 Ruby 和 RubyGems 时的步骤如下：

1. 安装 Ruby：

    `prompt$ sudo yum install ruby`

2.  如果您正在使用 RedHat Enterprise Linux 6，请*可选* 登录 [Red Hat Network (RHN)](https://rhn.redhat.com/) 启用您主机的通道。

3. 安装 RubyGems：

    `prompt$ sudo yum install rubygems`

## Centos
在终端上用 `yum` 命令行工具安装 Ruby 和 RubyGems 时的步骤如下：

1. 安装基本的 Ruby 包：

    `prompt$ yum install -y ruby`

2. 安装其他 Ruby 包和文档：

    `prompt$ yum install -y ruby-devel ruby-docs ruby-ri ruby-rdoc`

3. 安装 RubyGems：

    `prompt$ yum install -y rubygems`

## SuSE

在终端上用 `yast` 命令行工具安装 Ruby 和 RubyGems 时的步骤如下：

1. 安装 Ruby：

    `prompt$ yast -i ruby`

2. 安装 RubyGems：

    `prompt$ yast -i rubygems`

## Debian

您可以用 Ruby Version Manager (`rvm`) 在 Debian 上安装 Ruby 和 RubyGems。如果您还没有安装，可以通过下面步骤安装 `rvm`。

1.  使用以下 `apt-get` 命令行工具安装所需包：

    `prompt$ sudo apt-get install gcccurl git-core build-essential libssl-dev libreadline5
    libreadline5-dev zlib1g zlib1g-dev`

2.  运行 `bash` 在 [Ruby Version Manager](https://rvm.beginrescueend.com/install/rvm) 中安装 `rvm`。

    `prompt$ bash << curl -s https://rvm.beginrescueend.com/install/rvm`

3.  按照前面步骤中介绍的 RVM 安装步骤编辑*~/.bashrc* 文件。

4. 使用 `rvm` 安装 Ruby 和 RubyGems，如下所示：

    `prompt$ rvm package install zlib`

    `prompt$ rvm install 1.9.2 -C --with-zlib-dir=$rvm_path/usr`

    `prompt$ rvm use 1.9.2`


