---
title: 在 Cloud Foundry 上部署 Play Java 应用程序 TodoList
description: 在 Cloud Foundry 上部署带固定后端的 Play Java 应用程序
tags:
    - play
    - java
    - postgresql
    - mysql
    - 教程
---

本指南详细介绍 TodoList 应用程序、它涉及的用例和
各种组件。

## 应用程序用例
TodoList 用来创建和管理任务。

![todolist-usecase.png](/images/play/todolist-usecase.png)

这些任务由用户创建并将数据存储在
基础关系存储区中。
该默认教程将任务存储在 Play 框架中自带的嵌入数据库中。

## 应用程序的组件

该应用程序有四个主要组件：

+    路由器
+    控制器
+    模型
+    视图

### 路由器
应用程序的路由信息在 `conf/route` 文件中介绍，它能使 HTTP 路径
与控制器中相应的操作进行映射。

``` javascript
# Home page
GET     /                           controllers.Application.index()

# Map static resources from the /public folder to the /assets URL path
GET     /assets/*file               controllers.Assets.at(path="/public", file)

# Tasks
GET     /tasks                  controllers.Application.tasks()
POST    /tasks                  controllers.Application.newTask()
POST    /tasks/:id/delete       controllers.Application.deleteTask(id: Long)
```

### 控制器
该应用程序采用 `controllers.Application.java` 一个控制器，其操作按照以下路由文件
中提供的逻辑关系与 HTTP 路径映射：

``` java
package controllers;

import play.*;
import play.mvc.*;
import play.data.*;
import models.Task;

import views.html.*;

public class Application extends Controller {
  static Form<Task> taskForm = form(Task.class);
  public static Result index() {
    return redirect(routes.Application.tasks());
  }

  public static Result tasks() {
    return ok(views.html.index.render(Task.all(), taskForm));
  }

  public static Result newTask() {
    Form<Task> filledForm = taskForm.bindFromRequest();
  if(filledForm.hasErrors()) {
    return badRequest(
      views.html.index.render(Task.all(), filledForm)
    );
  } else {
    Task.create(filledForm.get());
    return redirect(routes.Application.tasks());
  }
  }

  public static Result deleteTask(Long id) {
    Task.delete(id);
    return redirect(routes.Application.tasks());
  }
}
```

### 模型
模型由单个对象 `models.Task` 组成。应用程序利用 JPA 识别 ID 和
所需字段。

``` java
package models;

import java.util.*;
import play.data.validation.Constraints.*;
import play.db.ebean.*;
import javax.persistence.*;

@Entity
public class Task extends Model{
  public static Finder<Long,Task> find = new Finder(
    Long.class, Task.class
  );

  @Id
  public Long id;
  @Required
  public String label;

  public static List<Task> all() {
    return find.all();
  }

  public static void create(Task task) {
    task.save();
  }

  public static void delete(Long id) {
    find.ref(id).delete();
  }
}
```
### 视图
视图是 Play 中的一个 Scala 函数，由 HTML 和 Scala 两种语句组成。我们将任务列表
和 taskForm 对象送入其中。视图中显示现有任务列表和
能否创建和删除任务。
``` html
@(tasks: List[Task], taskForm: Form[String])

@import helper._

@main("Todo list") {

    <h1>@tasks.size task(s)</h1>

    <ul>
        @tasks.map { task =>
            <li>
                @task.label

                @form(routes.Application.deleteTask(task.id)) {
                    <input type="submit" value="Delete">
                }
            </li>
        }
    </ul>

    <h2>Add a new task</h2>

    @form(routes.Application.newTask) {

        @inputText(taskForm("label"))

        <input type="submit" value="Create">

    }
}
```
## SQL 演进
Play 2.0 能根据设计的 Object 模型生成 SQL 演进文件。

### 默认演进文件
下面显示的代码是在 `evolutions/default` 文件夹中生成的默认演进文件 `1.sql`。

``` sql
 # --- !Ups

create table task (
  id                        bigint not null,
  label                     varchar(255),
  constraint pk_task primary key (id))
;

create sequence task_seq;


# --- !Downs

SET REFERENTIAL_INTEGRITY FALSE;

drop table if exists task;

SET REFERENTIAL_INTEGRITY TRUE;

drop sequence if exists task_seq;

```

