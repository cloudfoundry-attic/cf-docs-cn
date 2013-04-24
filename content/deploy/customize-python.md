---
title: Cloud Foundry 开源软件中的 Python 支持
description: Cloud Foundry 开源软件中的 Python 支持
tags:
    - Pythone
---

## Python 支持

**仅在来自于 [https://github.com/cloudfoundry/vcap](https://github.com/cloudfoundry/vcap) 的开源软件 vcap 环境中或在 [ActiveState Stackato](http://www.activestate.com/stackato) 中才提供 Python 支持。在 CloudFoundry.com 或微 Cloud Foundry 中尚不提供此支持。** 

Python 应用程序是通过 WSGI 协议获得支持的。Gunicorn 用作为 WSGI 应用程序（包括 Django）服务的 Web 服务器。非 Django 应用程序必须有公开一个应用程序变量的顶级 wsgi.py 且该变量必须指向一个 WSGI 应用程序。

## 使用 pip 安装依赖项

应用程序的 Python 包必备组件可以在顶级 
requirements.txt 文件（请参见[格式文档](http://www.pip-installer.org/en/latest/requirement-format.html)）中定义， 
pip 使用该文件来安装依赖项。

### 限制

  * 包依赖项从不缓存，每次更新或重新启动您的应用程序时都将下载（并安装）这些依赖项。

## Django 支持

存在一个称作“Django”的专用框架，它也用来执行特定于 Django 的暂存操作。目前，此框架以非交互方式运行 syncdb 来初始化数据库。

### 访问数据库

Cloud Foundry 通过 VCAP_SERVICES 环境变量使服务连接凭据可作为 JSON 使用。知道这一点后，您便可以在您自己的 settings.py 中使用下面的代码段：

    # 获取 CloudFoundry 的生产设置  
    if 'VCAP_SERVICES' in os.environ:  
        import json  
        vcap_services = json.loads(os.environ['VCAP_SERVICES'])  
        # XXX：在此避免硬编码  
        mysql_srv = vcap_services['mysql-5.1'][0]  
        cred = mysql_srv['credentials']  
        DATABASES = {  
            'default': {  
                'ENGINE':'django.db.backends.mysql',  
                'NAME':cred['name'],  
                'USER':cred['user'],  
                'PASSWORD':cred['password'],  
                'HOST':cred['hostname'],  
                'PORT':cred['port'],  
            }  
        }  
    else:  
        DATABASES = {  
            "default": {  
                "ENGINE":"django.db.backends.sqlite3",  
                "NAME":"dev.db",  
                "USER": "",  
                "PASSWORD": "",  
                "HOST": "",  
                "PORT": "",  
            }  
        }

### 限制

  * 由于是以非交互方式运行 syncdb 的，将不会创建超级用户，因此 Django 管理员（如果您的应用程序使用它）将无法使用。
  * 不支持迁移工作流，如 [South](http://south.aeracode.org/) 的迁移工作流。

## VMC

要想发现并利用 Python 支持，您需要使用 VMC_0.3.14_ 或更高版本：
    
    $ vmc -v
    vmc 0.3.16.beta.5
    
    # 升级到最近版本：
    $ gem update vmc

## 示例应用程序

在 [https://github.com/cloudfoundry/vcap-test-assets/tree/master/django](https://github.com/cloudfoundry/vcap-test-assets/tree/master/django) 上提供了示例应用程序
