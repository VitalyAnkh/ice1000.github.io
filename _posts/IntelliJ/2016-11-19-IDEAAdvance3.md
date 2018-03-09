---
layout: post
title: IntelliJ IDEA 进阶教程： IDEA 中工程的基本概念
category: IntelliJ
tags: Java, IntelliJ IDEA
keywords: Java,IDEA, PhpStorm,WebStorm,PyCharm,Rider,RubyMine,CLion,Android Studio
description: IDEA advance chapter 3
---

## 依赖
+ 一个 JetBrains 系的 IDE

这期我说说 IntelliJ IDEA 系的 IDE 中的『工程』这一概念。所谓工程到底是什么我觉得我应该不需要解释了，看我博客的人应该都知道吧（逃

## 和 AS 的不同

AS 是 IJ 的 Android 魔改版，钦定了 Gradle 作为构建工具，因此弱化了 IDEA 中的工程概念
（破事情都让你自己写 Gradle 脚本去， AS 甩锅）。事实上， IntelliJ 的工程还是比较复杂的。

对于每一个工程(Project)， IDEA 会在开启界面显示：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/java/idea7/0.jpg)

红框中的都是 Project。右边的 Create New Project 就是创建一个新工程，这个过程是使用 IDEA 的第一关。

随便打开一个工程，可以看到左边的文件树。IDEA 根据对不同文件类型的支持情况会显示不同的图标，
比如你安装了各种语言的插件支持之后，文件树就会变得五颜六色。如果看不到文件树，那么请使用召唤术<kbd>Alt</kbd>+<kbd>1</kbd>。

### Project

一个 IDEA 窗口只能打开一个 Project ，可以理解为工作区，管理一个 Project 是通过操作 Project Structure 实现的，
快捷键<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>S</kbd>。记住它，它非常、非常常用。

如图所示是一个什么都没有的文件树，这就是一个一无所有的 Project。
（其实是『几乎』一无所有，因为有一个 LICENSE 文件和一个 dll ，和一个 gitignore。
这是一个还未进行导入的 Project ，下文将导入它）

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/java/idea7/1.jpg)

然后我们平时的工作是基于 Module 这一概念的。一个 Module 相当于是 Project 的元素，
一个 Project 是 Module 的集合。小型项目或者结构相对简单的项目，一般情况下都是一个 Project 对应一个 Module。

### Module

一个 Module 有如下特特征：

+ 一个 Module 对应一个 Makefile 文件，并且这个 Makefile 对用户不可见。
+ 每次运行一个 Module 中的 main 方法，将对这个 Module 的 Makefile 进行一次构建————也就是增量编译。 如果你一个 Module 中有未完成的代码（比如一个表达式只写了一半），那么就会错误，无法运行。不同 Module 中的代码如果不能编译，不会影响当前 Module。
+ 同一个 Module 编译生成的内容将会被放到一起，并一视同仁（即在打包 jar 之类的时候，同一个 Module 的目标文件将会被当做一个整体）。

于是我们来导入一个 Module。首先根据上文的介绍，打开 Project Structure ，并打开 Modules 选项卡，
点击绿色的加号，选择 New Module。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/java/idea7/2.png)

在弹出界面选择 Java ，然后下面的啥也别选。这个创建的文件最少，也是最适合拿来新建一个高度定制的 Module 的。
上面还会根据你的插件显示其他的 Module 选项，选择这些选项之后 IDEA 会根据插件进行一些默认的配置。
比如 Java 的话就会给你创建一个 src ，并选好 SDK 什么的。
Kotlin 的话就会导入一个 Kotlin-runtime.jar 等三个标配包， Rust 会新建 main.rs 和 Cargo 文件，
还会顺便开启 Git 支持（还给你 git init 了）。可以看到我的 IDEA 是有很多插件的。。。

可以看到我的 IDEA 是有很多插件的。。。但是啥也别勾，直接下一步。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/java/idea7/3.jpg)

然后让你输文件路径，直接选择项目根目录，这里是 JniMath 。

然后选择那个被你创建出的 Module 。可以看到，
它已经非常聪明地根据 src 目录的名称识别出了这个目录就是存放源码的目录，并且使用蓝色标记出来了。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/java/idea7/4.jpg)

选中 src ，可以看到上面的 Mark as 这一栏中的 Sources 被标出来了。取消选中它，
src 就会变得和别的目录一样————栗色。还有别的几个目录类型：

类型|作用
:---|---:
Sources|源码，在 debug 和 release 的时候被编译，同一 Module 的所有 Sources 的目标文件都放在一起。
Tests|测试代码，同一 Module 的所有 Tests 的目标文件放到一起，和 Sources 区别对待。右键这种类型的目录，会有一个选项，执行目录下所有的测试代码。
Excluded|目标文件，测试代码和源码的目标文件在这个目录下分开放置， clean 的时候会被清空，里面的东西因为都是目标文件，所以不要放置你的劳动成果，因为这个目录被 IDEA 当成垃圾桶。
剩下的|用的太少懒得说

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/java/idea7/5.jpg)

了解完作用之后我们可以把所有的目录正确标注出来————test 对应 Tests ， src 对应 Sources ， out 对应 Excluded。然后 src 和 test 目录下的文件就会被识别成 Java 的包了。这几个文件也是编译时执行 javac 的根目录。因此，包从这里开始放。test 也一样。包的图标和普通目录图标不一样，下图有个很明显的对比。 然后下图中的 Language Level 选的是 1.3 Plain Old Java ，我们改成 8。可以看到，似乎 JetBrains 已经早就把 Java10 的解析器写好了。。。

然后在左边的选项卡中选择 Project ，把 SDK 设置成你的 JDK ，然后把 Language Level 改成 8。然后把 Project compile output 设置成你刚刚在 Module 里面设置的 out 目录。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/java/idea7/6.jpg)

然后回到刚才的 Modules ，看到上面的选项卡，选择 Paths ，
compile output 选择 Inherit from Project output ，这样你的编译输出就重定向到了刚才设置的 out 里面。
在 Dependencies 里面可以设置依赖，这次先不讲。

选择 OK ，保存设置，然后你就会发现它在 Indexing ，过一会就能看到你设置好的 Module 了。
我安装了一个 gitignore 的插件，可以智能管理被 Git 忽略的文件。
没有加入 Git 监控的文件它会提示你加入 gitignore ，被 gitignore 忽略的文件它会在文件树中灰色标记。
可以看到我的 out 目录就是被灰色标记的，作为一个使用 GitHub 的程序员的基本素质就是不把目标文件上传，对吧。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/java/idea7/7.jpg)


#### 祝你用 IDEA 用的愉快。


