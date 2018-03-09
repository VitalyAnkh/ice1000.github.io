---
layout: post
title: MPS 教程二：制作一个简易语言（上）
category: MPS
tags: MPS
keywords: MPS, LOP
description: make a simple language with MPS
---

在上一篇教程中，我们已经简单体验过了 MPS 的一个工作流程——创建新工程，导入一个**语言**，使用这个语言编写代码。
在这篇教程中，我将向你展示如何创建一门简单的语言。

## 我们要创建的语言的功能

出于难度考虑，这次我们构建的语言将只有『向屏幕输出』的功能，也就是一个只能 println 的语言。

它没有工业价值，只有教学价值。

### 为什么这么简单

因为这篇文章要引入很多关于 MPS 创建语言的新概念

### 有哪些新概念

+ Concept
+ Editor
+ Generator

## 本文主要内容

+ Concept 的定义
+ 如何开始破界神编辑

## 依赖

+ MPS 2017.1
+ 编译原理相关知识（起码你得知道啥是 AST ， Abstract Syntax Tree ）
+ 阅读[上篇博客](../../../../2017/03/18/TryShapeWithMPS/)

上篇博客里使用的还是 2017.1 RC ， 现在已经出了正式版啦。

## 开始吧

首先我们需要打开 MPS ，并像上次一样创建一个新工程。
这次我们选择创建一个 Language 工程，并勾选**Create a SandBox Solution**选项。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/0.png)

这时，你会进入到你自己创建的工程界面。左边有一个不同于其他 JB IDE 的**logical view**，它是这个工程的逻辑结构。

打开文件系统中的 MPS 工程，你会看到一大堆：

+ *.class
+ *.java
+ *.xml
+ *.mps
+ *.mpl
+ *.msd

将代码托管到 Git 时，一般不上传 java 和 class 文件（这些文件一般都是 MPS 的 Code Generator 生成的，不是『源代码』性质的源代码）。

mpl 是整个 MPS 工程的配置文件（可以理解为： MPs Language 的缩写），而 mps 是 MPS 工程组件文件，其实就是 xml。

好，我们回到工程界面。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/1.png)

这时我们来理一下 LOP 的基本思想。其实 LOP 和 OOP、PP 多有几分相似之处，他们都是『为了实现代码复用』而做出的一种『将代码模块化』的方式。

首先声明：我没有引战，我没有说任何编程范式的好坏！！！！！

## LOP 的基本认识

首先我们和另外两种类似的编程范式对比一下：

模式|抽象出来复用的代码组织形式
:---|---:
PP （ Procedural Programming ）|函数（方法，例程）
OOP|对象（类，单例，原型）
LOP|语言

注意一下，所谓的『函数式编程（ FP ）』不属于这个分类范畴，这里不做讨论。PP 不是 FP ， PP 是有很多（大部分情况下）函数，
但是 `有函数 != 函数式编程` 请务必注意！

这是面向过程编程，听好了：

> Procedural programming is a programming paradigm, derived from structured programming, based upon the concept of the procedure call. Procedures, also known as routines, subroutines, or functions (not to be confused with mathematical functions, but similar to those used in functional programming), simply contain a series of computational steps to be carried out. Any given procedure might be called at any point during a program's execution, including by other procedures or itself.

上文摘自[Wikipedia](https://en.wikipedia.org/wiki/Procedural_programming)

英语不好的看中文：

> 过程式程序设计（英语： Procedural programming ），又称过程式编程、过程化编程，一种编程范型，有时会被视为是命令式编程的同义语。派生自结构化编程（ Structured programming ），主要采取程序调用（ procedure call ）或函数调用（ function call ）的方式来进行流程控制。流程则由包涵一系列运算步骤的程序（ Procedures ），例程（ routines ），子程序（ subroutines ）, 方法（ methods ），或函数（ functions ）来控制。在程序运行的任何一个时间点，都可以调用某个特定的程序。任何一个特定的程序，也能被任意一个程序或是它自己本身调用。

上文摘自[Wikipedia 中文区](https://zh.wikipedia.org/zh-hans/%E8%BF%87%E7%A8%8B%E5%BC%8F%E7%BC%96%E7%A8%8B)

想想，

+ 在 PP 里面，函数可以调用其他函数。
+ 在 OOP 里面，对象可以『拥有』其它对象。

那么在 LOP 里面，『语言』这个概念也被泛化了——所有的*语言*都是 DSL ，所有的*语言*之间都是可以交互的，你可以把很多门*语言*混着写。

一门*语言*可以是另一门*语言*的子集，你也可以扩展现有的语言。也就是说，

编程范式|编程过程
:---|---:
PP|写函数 -> 写程序
OOP|写类/单例/原型 -> 写程序
LOP|写语言 -> 写程序

这里的*语言*的概念有点不同于以前的语言，因此我使用了斜体标注。如果你没有看到斜体，说明这文章是从我博客原文抄过去的没注意格式，请帮我举报一下。

下文的*语言*除非特别注明，都是指 LOP 中的*语言*，为了方便，我不再使用斜体标注。

## MPS 中的 LOP

MPS 中，语言是由很多**Concept**组成的，这些**Concept**有各自的属性、限制等，它们相当于是**AST 中的节点**。

由于现在的编程模式大多数都是*写代码*，于是 MPS 也把程序编辑的过程弄成了*一种类似写代码*的形式，叫**破界神编辑**，上文已经说过啦。

因此，我们需要定义语言的*语法*。语言的语法，在 MPS 里面叫做**Editor**。

我们通过 MPS 创建的语言所编写的代码，需要通过**Generator**生成目标代码（比如本文使用的 Java ）。

因此本文（及后文）介绍的三个概念你应该很清楚了——

+ Concept
+ Editor
+ Generator

## 创造语言

说下这个语言的设计：

每个文件有一个 PrintlnSet （类似容器），里面放一堆 Println ，每个 Println 对应一个输出。

### 导入一些东西

对左边 Logical View 的**VerboseLang**使用<kbd>Alt</kbd>+<kbd>Enter</kbd>，
然后按 Dependency 选项卡下的绿色加号的导入 JDK 这个 Dependency ：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/8.png)

### Concept

我们首先创建我们需要的 Concept——PrintlnSet ，和 Println。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/2.png)

然后我们需要让它们：

Println:

+ 不能是 AST 根节点
+ 拥有一个 String
+ 键入 p 就可以出来（这是一个类似 Live Template 的效果，在语言中不是必须的，但是就顺便讲下）

PrintlnSet:

+ 可以是 AST 根节点
+ 拥有很多 Println

于是这就是 Println 了：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/3.png)

请注意我红框标注的需要填写的内容，和上面说的几个需求一一对应。

请注意，编辑完之后请<kbd>Ctrl</kbd>+<kbd>S</kbd>保存，这样 MPS 才会识别你的编辑结果。

另外，请时不时记得按下<kbd>Ctrl</kbd>+<kbd>F9</kbd>来*编译*你的语言。因为语言要编译了才能使用。

然后这是 PrintlnSet ：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/4.png)

然后我们就成功地写好我们的两个**Concept**啦。

### 第一次使用自己的语言

请注意这里的语言并不能运行。

点击你的 Generator （我们现在不需要过多接触它）。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/5.png)

在 root mapping rules 里面添加这么一段：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/6.png)

设置它对应的 Concept 为 PrintlnSet。

然后对那个红色的 No Template 使用<kbd>Alt</kbd>+<kbd>Enter</kbd>，然后**选择 class**，
让它~~怀疑人生~~创建一个新的 class 的 Template ：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/7.png)

然后你左边的 Logical View 会多出来一个自动生成的 map_PrintlnSet ，先不管它。

**编译一下。**

我们右键左边的晾了很久的**sandbox**，创建一个 PrintlnSet ：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/9.png)

你可以看到已经有一个 PrintlnSet 出现了！激动吧！

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/10.png)

然后你在那个

```
<< ... >>
```

处按下`p`，然后你发现出来了一个 Println ！

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/11.png)

你可以在 content 里面输入一个字符串：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/1/12.png)

欧耶\~ 现在我们的语言的最小组成部分已经完成了一大半了。

你已经可以像编辑上次介绍的[ShapeLanguage](../../../../2017/03/18/TryShapeWithMPS/)那样进行破界神编辑了。

## 下次讲什么

下次我们将让它生成 Java 代码，运行起来。
