---
title: 通过 VMC 调试
description: 调试应用程序的问题
tags:
    - 调试
    - vmc
---

本章包含下列主题来帮助您通过应用程序调试问题：

+ [查看日志文件](#viewing-log-files)
+ [将调试程序附加到您的应用程序](#attaching-a-debugger-to-your-application)

##查看日志文件

如果尝试部署、启动或运行应用程序时遇到错误，查看可能包含错误代码或异常的各种日志文件会有所帮助，这些错误代码或异常有助于指出问题所在。

使用 `vmc files` 命令获取可用日志文件的列表并查看特定日志文件中最近的条目。

例如，若要获取与 `hotels` 应用程序有关的所有日志文件的列表，并查看哪个日志文件为非零大小而由此包含信息，请执行以下 VMC 命令（同时显示示例输出）：

```bash

prompt$ vmc files hotels logs

  stderr.log                                2.2K
  stdout.log                                5.3K

prompt$ vmc files hotels tomcat/logs

  catalina.2011-10-18.log                   2.2K
  host-manager.2011-10-18.log                 0B
  localhost.2011-10-18.log                  247B
  manager.2011-10-18.log                      0B

```

如要查看 `logs` 目录中文件（如 `stderr.log`）的内容，请使用下列命令：

```bash
prompt$ vmc files hotels logs/stderr.log
```

若要查看 Tomcat 日志文件（如 `catalina.2011-10-18.log`）的内容，请使用下列命令：

```bash
prompt$ vmc files hotels tomcat/logs/catalina.2011-10-18.log
```

这两个命令都将信息显示在终端中，因此您如果要将该信息发送至支持部门，就必须将输出重定向至某个文件：

```bash
prompt$ vmc files hotels tomcat/logs/catalina.2011-10-18.log  > catalina.log
```

##将调试程序附加到您的应用程序

尚未提供的文档。


