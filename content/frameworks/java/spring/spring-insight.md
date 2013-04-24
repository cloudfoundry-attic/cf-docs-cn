---
title: 将 Spring Insight 应用于 Cloud Foundry 的常见问题解答

description: 使用 Spring Insight 监控 Cloud Foundry 上的 Java 应用程序

tags:
    - spring-insight

    - 常见问题解答

---

**问题：什么是 Insight？**
Insight 是一款针对开发和生产的字节码监控工具。它的设计提供了一种以可视化的方式轻松查看用户应用程序操作的方法，并使应用程序能够更加便捷地过渡到生产阶段。Insight for Cloud Foundry 适用于测试阶段，拥有访问令牌的人员都可以使用它。


**问题：如果出现问题，应该联系何人？**
请将问题和疑问提交到 Cloud Foundry 的支持网站：[http://support.cloudfoundry.com](http://support.cloudfoundry.com/)

**问题：将 Insight 应用于 Cloud Foundry 意味着什么？**
一旦安装了 Insight 仪表板，它就可以用于针对用户 Cloud Foundry 帐户中所安装的所有 Java 应用程序启用代码级监控。


**问题：如何开始监控 Cloud Foundry 上的 Java 应用程序？**
在通过 [http://insight.cloudfoundry.com](http://insight.cloudfoundry.com/) 安装仪表板之后，您应重定向到仪表板。仪表板的“Cloud Foundry”选项卡 (1) 上应列有您的所有应用程序。能够使用 Insight 进行监测的应用程序上将出现一个小的 Spring 叶片图标 (2)。对于这些应用程序，您可以通过详细信息面板 (3) 启用 Insight。被监控的数据将出现在“浏览资源”选项卡 (4) 上的“应用程序”下。


**问题：Insight-[randomid].cloudfoundry.com 是什么？**

这是您的个人仪表板。您的各种应用程序所发送的所有数据都会发送到此应用程序中。由于它就像是 VMC 中的另一应用程序一样可供用户查看，因此您甚至可以卸载这一仪表板，方法与您卸载正常的 Cloud Foundry 应用程序的方法一样。


**问题：支持哪些应用程序框架？**
我们当前支持 Java、Spring 以及 Grails Web 应用程序。


**问题：使用该服务会影响到我的 Cloud Foundry 应用程序吗？**
当激活 Insight 时，Cloud Foundry 会在运行您的应用程序的 Tomcat 上安装一个代理。我们的测试表明，此代理对性能几乎没有什么影响，仅仅会增加响应的时间（以毫秒为单位）。


**问题：Insight 如何影响客户的 Cloud Foundry 配额？**
Insight 仪表板是一款安装在您的帐户中的 Web 应用程序。它会占用您 512MB 的配额。另外，我们还配置了 RabbitMQ 服务，可供 Insight 代理用于与 Insight 仪表板进行通信。Insight 仪表板算作一个应用程序，RabbitMQ 服务算作您帐户的一个服务。监控每个应用程序将需要更多的内存。虽然这根据负载和监测的情况而有所不同，但我们建议您使用至少 256MB 的内存配额来部署应用程序。


**问题：谁是目标最终用户？**
目标最终用户是那些希望确保其应用程序能够按预期在 Cloud Foundry 中运行并需要一种能够帮助他们实时解决问题的工具的开发人员。


**问题：Insight 何时全面上市？**
我们于 2011 年 10 月在 SpringOne 2GX 大会上公布了 Insight for Cloud Foundry 的内部测试版。我们计划在 SpringOne 大会的几星期后公布公共测试版，但在这之前我们会确保一切都能够按预期进行。


**问题：如何使用 Insight 与我自己的插件在 Cloud Foundry 以外配合使用？**
可通过 TC Server Developer Edition 或 Spring 工具套件免费下载 Insight：[http://springsource.org/insight](http://springsource.org/insight)

**问题：新用户如何在 Cloud Foundry 上获取 Insight 的访问权？**
要在 Cloud Foundry 上获取 Insight 的访问权，您将需要成为 Cloud Foundry 的注册用户。在测试版中，您也需要拥有令牌。当我们准备好增加测试版的测试组时，我们会分发令牌。


**问题：Spring Insight 的工作原理是什么？**
Insight 使用面向方面的编程语言根据用户应用程序中的精选方法来创建附加的工具层。这些方面中所包含的数据将传递到次级 Web 应用程序，该应用程序随即压缩、筛选数据并将数据转发到 Insight 仪表板，以供用户查看。


**问题：当 Insight 监控应用程序时，必须再向应用程序分配多少附加内存？**
Cloud Foundry 会将 Web 应用程序的最小和最大堆大小设置为配置的应用程序内存，但使用进程的驻留大小 (RSS) 来验证合规性。这一方法不会计算通过本地库或内存映射文件使用的 PermGen 内存使用量或一般进程的资源开销。由于通过 AspectJ 生成类会使 Insight 使用更多的 PermGen，因此我们建议为每个应用程序最少分配 256MB，具体取决于复杂程度。另外，我们需要安装 Insight 仪表板，它会占用 512MB 的内存。


**问题：我的应用程序内存不足，Cloud Foundry 将关闭应用程序。我应该如何配置内存设置呢？**

您可能需要更改您应用程序的内存设置，以避免 Cloud Foundry 关闭您的应用程序。Cloud Foundry 会使用进程的 RSS（驻留集大小）来确定您的应用程序所使用的内存量，如果 RSS 超过了您应用程序的配置内存阈值，Cloud Foundry 就会关闭应用程序。这在 Java 中具有特殊的含义，因为应用程序的 –Xmx（最大堆使用量）通常都低于 RSS。


为避免出现超过 RSS 但未达到最大堆使用量的情况，请增加为您的应用程序分配的内存，或减小其堆大小。


例如，如果您的应用程序运行时占用 256MB 内存（但尚未达到该限制）：


```bash
  $  vmc mem my-application 300m
  $  vmc env-add my-application INSIGHT_OVERRIDES="-Xmx200m"
```

注意，对内存设置的这一修改并非特定于 Insight；Cloud Foundry 将关闭未达到最大堆使用量的常规 Java 应用程序，但 Insight 监测的应用程序更可能因为信任堆外部、PermGen 内和代码缓存中的 JVM 数据结构而达到这些限制。


**问题：我的应用程序报告存在重复的 RabbitServiceInfo Bean，如何解决此问题？**
RabbitServiceInfo 是为 VCAP_SERVICES 列表中的每个 rabbit 条目所创建的。该列表将包含应用程序 rabbit 服务以及 Insight 服务。通过一些配置，这会导致出现重复的 Spring Bean。备选方案是直接使用唯一 ID 编写 RabbitServiceInfo。


