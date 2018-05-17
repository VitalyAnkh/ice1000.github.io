---
layout: post
title: 对 Kotlin 的代理属性进行反射
category: Kotlin
tags: Kotlin
keywords: Kotlin
description: Kotlin delegate property reflection
---

[某微信公众号](http://weixin.qq.com/r/EjusqNHEnRnhKZXLb26W)（请使用安装了微信的移动设备打开此链接）天天[吐槽 Kotlin 的反射](https://mp.weixin.qq.com/s/geiEjW-NGf-1v2uu3gsBZA)，给了我这个公众号维护者的资深粉丝一股『Kotlin 的反射完全就是个坑嘛，根本不能用』的感觉。但是我今天使用了一下 Kotlin 的反射，配合 delegate 这个特性（就是
```kotlin
val blabla: Blabla by rua
```
这种语法），整个过程非常顺利，看了下字节码也是我想要的样子，就发篇文章好了。

首先我是需要重构下面这样一个类：

```kotlin

```

## 写后感

本文尝试模仿了 [KimmyLeo](https://www.zhihu.com/people/kimleo/activities) 聚聚的[写作风格](https://zhuanlan.zhihu.com/lessmore)，在各个梗插上链接，我的博客瞬间变得容易理解多了。  
感觉之前虽然也是写文章时字里行间都带着梗（个人感觉`[^(`[`纯学术性文章`](../../../../2017/11/09/ProofInAgda5/)`|2016 年的黑历史)]`（正则表达式）大致平均三每句话一个梗）或者元吐槽（就是对文章内容本身的吐槽，有时甚至是对评论本身进行吐槽，比如这句），却没有向读者解释，偶尔勤快了也就是加上括号注释（比如这句话的这个注释和上句话的两个注释，另外这个注释也是元吐槽。由于本人喜欢胡思乱想，在特别勤快的时候容易把注释写得 [跟 Lisp 代码一样](../../../../2017/03/10/DifferenceBetweenMeAndDragonBook/#正文)，有时自己都觉得读起来会 StackOverflow）或者使用超长定语，有点对不起自己活跃的思维呢。于是就做了这么一个尝试，希望看官们喜欢。

有什么想说的可以去 [GitHub 开个 issue](https://github.com/ice1000/ice1000.github.io/issues/new) ，贴上你想评论的文章的链接，然后我就会把评论区重定向到那个 issue 去啦。

