---
layout: post
title: 如何让孩子爱上 Kotlin 第一章：环境搭建
category: Kotlin
tags: Kotlin
keywords: Kotlin
description: The way to learn kotlin
---

很早以前就打算写 Kotlin 的教程了。明天期末考试，今晚就先写一篇关于学习路线的博客吧。❤(ӦｖӦ｡)

本文主要内容是学习路线，为初学者指明一条清晰的学习路线。你并不会在本文看到关于 Kotlin 这门语言的具体信息，这些内容会在之后的博客中出现。

不要想太多，本文完全原创。我蹲在宿舍里面写的。(*´ڡ`●)

## 我是怎么认识 Kotlin 的

我作为一个 JetBrains 的脑残粉，时常拜访 JetBrains 的官网，偶尔会在一些神秘的角落发现一些很有趣的东西。ლ(´ڡ`ლ)

首页的『Language』选项卡下就有两个选项，我都有涉猎， MPS 是一个比较复杂的系统，以后的博客有一定概率会讲到。而 Kotlin 就是本文的主角了。

## Kotlin 是什么

Kotlin 是一门基于 JVM 的编程语言，支持编译成 Java 平台的.class 目标文件和 JavaScript 文件。支持 Java 字节码是因为这门语言本身基于 Java ，不过为了方便 web 开发和独立于 JVM 的运行， Kotlin 团队也引入了 JavaScript 的编译。

那么， Kotlin 作为一门编程语言，有哪些特点呢？（；^ω^）

首先，它是一门采用面向对象 (Object-Oriented) 风格的语言。
它和它的~~隔壁老王~~亲爸爸 Java 除了反射 (Reflection) 之外完美地兼容。也就是说，如果你曾经使用 Java 编写过一个工具类，不过你现在却更喜欢使用 Kotlin 编程，那么你完全可以在 Kotlin 里面像调用一个 Kotlin 类那样调用你曾经写过的 Java 类。
反过来，你也可以让你那些仍然在使用 Java 的同事直接调用你通过 Kotlin 编写的类。

至于 Kotlin 和 Java 所不那么友好的地方，大概有以下几处：

+ 反射机制不同。
+ Kotlin 支持把函数直接写在文件里(就如 C 语言一样)，而 Java 的一切的一切都在类中。
+ Kotlin 没有静态方法这个概念，却引入了`object`和`companion`的概念（就是 OO 的 based on object 形式）。
+ Kotlin 其实还是有运行时的，是一个叫`kotlin-runtime.jar`的东西，不过这个不大，体积不到 1MB。而如果要使用反射的话，还需要包含另一个 jar 包，叫`kotlin-reflection.jar`，这个就比较大了， 2MB 左右。

不过就如 Java8 引入了 lambda 一样，这门语言同样注重对于函数式编程的支持。它的优点是向下兼容到 Java6 ，也就是说 Kotlin 目标文件可以直接在原生的 mac 电脑上运行(OS X 预装 JDK6)，并且你可以在里面使用 lambda。

它和 Swift 一样，拥有空指针保护 (Null-Safety) 的特性。每个变量必须保证时刻为非`Null`，否则需要用问号来标记。在与 Java 的互相继承中， Kotlin 中被声明为非 Null 的变量在 Java 的参数表里会有`@NotNull` 标记。

Kotlin 也是一门开源的语言，源代码可以在[JetBrains 对应的 GitHub 仓库](https://github.com/JetBrains/Kotlin)找到。

另外， Scala 是什么？(；一_一)

## 适用人群

这个是按照推荐程度排序的。越前面的人群，越推荐他们使用 Kotlin。

不要为排名所误解，任何在此列出的人群都非常适合学习 Kotlin ！

1. Android 开发者(这是目前 Kotlin 的主战场)
1. J2EE 后端开发者
1. 跨平台桌面应用开发者
1. 数据库程序员
1. 厌倦 Java 啰嗦的人
1. 想学习新技术的 JVM 工作者
1. JetBrains 的粉丝

另外，十分建议在学习 Kotlin 之前先学习 Java。

## 环境搭建

Kotlin 团队为用户考虑得非常周到，不仅仅出品了 IDEA 插件，还为 Eclipse 用户提供了对应的插件。不过平心而论， IDEA 插件的体验比 Eclipse 体验真的好太多了。

独立编译器是为命令行爱好者提供的，不过其实冰封个人认为最良心的是免费的[web IDE]( http://try.kotlinlang.org)，他们称之为『try kotlin』。这个 web IDE 是开源的，也可以在 GitHub 上面找到。

而 JetBrains 出品的 IntelliJ IDEA 从 15 开始就原生支持 Kotlin。至于业界公认最强大的 IDE ， IntelliJ Renamer （误）提供的编程环境自然是有着非常好的体验。关于如何安装 IDEA 我已在另一篇博客中说明。

下载链接官网都有提供，下文有链接，请随意点击。

## 为什么选择 Kotlin

有很多语法糖啊。
这让它的语法变得非常简洁，比起 Java 那一言不合就上千行的毛病， Kotlin 要好得多。如果你对 Kotlin 足够熟练，那么你可以将更多精力放在实现逻辑上，而不是具体的『写代码』上，从而提高你的工作效率。

## 如何让孩子爱上 Kotlin

首先，了解任何东西都应该先跑到人家[华丽丽的官网](http://kotlinlang.org)逛一逛。你可以在这里找到一些关于 Kotlin 的基本信息，以及前文所提到的编译器下载，还有说明文档和 web IDE 的传送门。

官网有一个非常漂亮的 Hello World 程序。

然后就是这篇[官方教程](http://kotlinlang.org/docs/reference)了，说实话我感觉我再怎么写教程也写不过这篇官方的。。

当你看完官方教程之后，再去写一些自娱自乐的小程序来继续熟悉这门语言，就像你曾经学别的编程语言那样。

这时候你的 Kotlin 水平已经和我很接近了，差不多可以将这门语言投入你的生产了。＼(^o^)／

## 进阶学习与拓展阅读

接下来推荐大家通过这篇[来自白俄罗斯的 awesome-kotlin](https://github.com/KotlinBy/awesome-kotlin)以及他们提供的一个[awesome-kotlin 搜索器]( http://kotlin.link)来了解这个世界上的程序员们使用 Kotlin 编写的程序，以及一些很有趣很厉害的 library ，比如 NoSQL 数据库工具、Web 开发框架、Android 开发框架等。

顺带一提，我的项目[Dekoder]( https://github.com/ice1000/Dekoder)也被收录其中。(*´ڡ`●)

另外，我知道有很多英语困难的朋友们，于是我也为你们准备了一个[经过自己一节计算机课粗糙翻译的 awesome-kotlin](https://github.com/KotlinCN/awesome-kotlin)，目前还在翻译中，不过我有多懒你是知道的，况且我还有太多别的坑，所以欢迎志愿者参与维护，以及协助翻译。欢迎 pull request。

另外欢迎大家参考[我的知乎回答: Android 开发 Kotlin 你目前遇到过哪些坑？](http://www.zhihu.com/question/36735834/answer/105409238)，里面有着我的血泪史，希望大家不要重蹈我的覆辙｡･ﾟ･(ﾉД\`)･ﾟ･｡

最后啰嗦一句： anko 是真的黑科技！

## 2017 年更新

老博客真是黑历史呀，我现在已经有 4 个项目在 awesome Kotlin 了。

另外，我翻译的 awesome Kotlin 已经早就过时了，新的 awesome Kotlin 现在不仅有 badge 和网站一应俱全，
换成了基于 Kotlin 的 Web 技术搞的，还有 build.gradle.kts ，浑身都是 Kotlin 了。
