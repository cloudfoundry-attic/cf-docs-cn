---
title: 在非交互模式下使用 VMC

description: 如何在非交互模式下使用 vmc

tags:
    - vmc

    - 非交互

---

VMC 客户端的默认操作模式为“交互式”。


在非交互模式下，通过使用下列其中一个命令行开关，即可调用 VMC。


```bash
    -n, --no-prompt
        --noprompt
        --non-interactive
```

例如：VMC 在交互模式下：（单击“返回”采用默认值）


```bash
$ vmc push hello
Would you like to deploy from the current directory? [Yn]:
Application Deployed URL: 'hello.vcap.me'?
Detected a Sinatra Application, is this correct? [Yn]:
Memory Reservation [Default:128M] (64M, 128M, 256M, 512M, 1G or 2G)
Creating Application: OK
Would you like to bind any services to 'hello'? [yN]:
Uploading Application:
  Checking for available resources: OK
  Packing application: OK
  Uploading (0K): OK
Push Status: OK
Staging Application: OK
Starting Application: OK
```

VMC 在非交互模式下：


```bash
$ vmc push hello -n
Creating Application: OK
Uploading Application:
  Checking for available resources: OK
  Packing application: OK
  Uploading (0K): OK
Push Status: OK
Staging Application: OK
Starting Application: OK
```

对于任何交互式问题，如果该问题需要非默认值，则可以将该值传入命令行。（例如 --mem 表示 memory）。


若要获得 VMC 支持的所有选项的列表，请尝试


```bash
$ vmc help options
```

