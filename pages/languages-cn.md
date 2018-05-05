---
layout: page
title: 我参与开发的编程语言
description: ice1000 contributed languages
keywords: ice1000
menu: Languages
permalink: /languages-cn/
---

[English](../languages/)

# Lice

我的第一门编程语言，学习编译原理前为了保留想法而写的。  
语法继承自 Lisp 并去掉了所有语法糖，以实现时间复杂度正比于代码长度的 Parser。
我在实现这个语言的时候，在魔理沙的鼓励下做出了三种求值模型—— call by name （类似但不是 C 语言的宏）,
call by value （最普通的传值调用）, call by need （惰性求值）。
主体实现是 Kotlin ，运行是通过解释 AST 实现的（可以说是很幼稚了），有一个还未成型的 Haskell 实现。  
语言没有关键字，所有的语言构件（包括 `if` `while` 这种控制流， `lambda` `expr` `lazy` 这种匿名函数创建，
`def` `def?` `defexpr` 这种在其他语言里面肯定是关键字的东西）全部是通过标准库实现的。
标准库的提供方式很奇妙，是通过编写一些 Kotlin 类，然后将他们的方法绑定给 Lice 的符号表的。  
Lice 现在的存在目的是作为一个依附于 JVM 语言的脚本语言，所有的大型任务通过 JVM 语言编写并通过 Lice 的 API
传给 Lice ，然后再结合 Lice 本身提供的基础语言构件来使用。

这门语言最失败的地方应该就是起名字了， Lice 是头虱的意思，但我想这个名字的时候并不知道（呃，是在学校里，没有网）。。

### 相关链接

+ [基于 IntelliJ IDEA 的 IDE](https://plugins.jetbrains.com/plugin/10319-lice) 和对应的[视频教程](http://www.bilibili.com/video/av18223568/)
+ [命令行 REPL](https://github.com/lice-lang/ldk)（支持彩色输出和代码补全）
+ [Android 上的 RPEL](https://github.com/lice-lang/lice-android)
+ [语言参考](https://github.com/lice-lang/lice-reference)
+ [解释器源码](https://github.com/lice-lang/lice)
+ [解释器，微缩版](https://github.com/lice-lang/lice-tiny)

伴随最初版本一起出现的 AST 编辑器、导出格式化代码的工具等都已经随着我数次迁移工作环境丢失了。

一个关于 Lice 的视频：

<iframe src="//player.bilibili.com/player.html?aid=18335710&cid=29931062&page=1" scrolling="yes" border="0" frameborder="yes" framespacing="0" allowfullscreen="true">
</iframe>

# CovScript

这是我的朋友李登淳创造的一门编程语言，用 C++ 实现，具体介绍在官网还是比较详细的，我在这里就只写点我自己的看法吧。  
这门语言本身是类 C 的（至少表达式和函数调用是 C 风格），而函数、结构体、命名空间定义等是 Ruby 风格的 `end` 结尾，并有 `package` `import` `using` 的概念（也就是模块系统）。  
老李的 Parser 是手写的（可以说复杂度很高了，虽然 Parser 是很 trivial 的），让我对他的耐力很佩服（同为高二学生，
我在写 Lice 的时候就没有这份心思，只是做了个很灵活的 AST evaluator 而已）。  
这门语言支持调用 C++ 实现的函数，形式类似 JNI 。  
CovScript 的类 C 语法让它能写起来很愉快，再加上对 lambda 的支持，可以说是一个 real-world 的编程语言了（
不像 Lice 这种，是以辅助另一门语言为目标的）。

最大的特色应该是它功能齐全的标准库，有数据库、 GUI （有个命令行的图形库，感觉碉堡）、网络编程、正则等库，感觉写程序很方便啊。

### 相关链接

+ [基于 IntelliJ IDEA 的 IDE](https://plugins.jetbrains.com/plugin/10326-covscript/) ，这是我送给老李的 2018 新年礼物
+ [解释器源码](https://github.com/covscript/covscript)
+ [官网](http://covscript.org)
+ [文档](../cov-docs/)


