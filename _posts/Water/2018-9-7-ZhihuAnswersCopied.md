---
layout: post
title: 为什么这么多人喜欢写编译器
category: Water
tags: Misc
keywords: ice1000
description: Zhihu answer copy
---

## 原文

首先为什么有那么多编程语言？为什么你们都不去用 C 语言？

面对服务端开发，我们有了 Py，Ruby，Java，Go，Rust；面对科学计算我们有 Julia，R；面对网页应用我们有 JS，TS；面对 Gnome 的 GUI 开发我们有了 Vala；面向字符串拼接我们有了 AWK，Perl，SNOBOL4；面向拯救人类我们有 Coq，Agda，Idris，F\*，面向游戏我们有 Lua，C\#，F\#，面向毁灭宇宙我们有 NatsuLang。

不同的领域需求不一样，之前你很熟悉，觉得很好用的 XX 领域语言在 YY 领域不一定很好用。

比如 Java 写 GUI 就很难受（因为没有多继承），Perl 拿来写游戏速度又不够。没有 F*、Agda 怎么拯救人类？没有 NatsuLang 怎么毁灭宇宙？没有 Coq 的女装是没有灵魂的，对不对。

比如我要描述一些专门拿来拼字符串的逻辑，就有很多复杂的正则之类的逻辑，我相信会正则表达式的程序员很多都只会使用『匹配』这一功能，会把值 `group` 出来的就少很多，知道实现的又少很多，知道正则可以编译的又少很多，知道正则还能 JIT 的就更少了，你怎么又能保证没有希望使用正则代替 bnf 的愿望呢？这些需求，编程复杂度层层叠加，有时使用通用语言不得不写出大而繁琐的库。这时你可以就希望把这些复杂的需求写成一些 DSL ，然后发现，为什么不再弄一个单独的语言，去掉其他你觉得不必要的特性，把你想做的 DSL 直接弄进去呢？有些语言的部分功能会阻止优化（比如某缩进带语义的语言的JIT），如果你希望你的DSL跑的像射命丸文一样快，你可以把这些特性去掉，然后你就能在你自己的编译器里做优化（inline，JIT，fusion，tco，lazy，unwrap lambda）了。

然后你又会发现，这些其实很简单的东西知乎上的程序员似乎觉得这很高大上诶！那些脑子转不过来的程序员连 Parser Combinator 都搞不懂，用 JS 写出 JS 的 Parser、写出 C 语言的 Tokenizer 和 Grammar Analyzer 就能称霸一方，你一去他们岂不是集体跪拜？然后你在社区获得了正反馈，积累来的编程语言优化经验给了你大厂的工作机会，公司的网站又快了几倍，被无所事事的同事抢了三分之二的功劳剩下的钱也够你过上学生时代希望的平淡生活了。

编译技术就是这样的，好玩。

## 一些解释

这部分内容是知乎上没有的。

+ 前面说的受语义影响导致做不了 JIT 的是 Python。
+ 反观语言简单的 Java，就有 JIT，而且分两道 pass，很科学。
+ Haskell 有很厉害的 fusion。
+ Haskell，Idris，Agda 都有 lazy。
+ unwrap lambda 是一个叫 absal 的语言里出现的，是沙沙告诉我的。
+ 正则表达式的编译和 JIT 是梨梨喵弄的，类似 `Pattern.compile` 但是还可以弄虚拟机，优化字节码什么的。
+ Tokenizer 和 Grammar Analyzer 是梗，只会这些当然是不可能称霸一方的。
+ NatsuLang 确实是世界上最好的语言。
+ Perl6 和 Nimlang 可以修改自己的语法。

From https://www.zhihu.com/question/39304476/answer/484974255
