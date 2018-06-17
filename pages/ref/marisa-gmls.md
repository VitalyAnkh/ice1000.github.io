---
layout: page
title: 怪名乱神
description: marisa's post
keywords: marisa
---

我想给大家介绍一门语言。

C\*。

C\*有什么特点呢？很著名很流行。

我们可以看看 TIOBE Index：
到 2017 年 12 月，这门语言的 rating 达到了 30.965% 以上，比 Java ，下一个最热的语言，高了一倍有余。

这门语言被广泛使用于各种领域：操作系统（ Linux, Windows ），分布式（ Spark ），深度学习（部分 tensorflow ），区块链（ bitcoin ），游戏引擎（ Unity ）。

同时， C\* 的方言包含 C , C++ , Java , C\# 等知名语言。

我们先从语法开始介绍：
C\* 的一个程序，由多个声明组成。其中，一些声明属于函数声明，而一个函数又由多条语句组成。。。

是不是觉得很荒谬？ C 没有 Class , C++没有垃圾回收， Java 跟 C\# 水火不容，为什么被认作同一语言？

而如果我告诉你，现实比这还魔幻呢？世界上有很多语言正被冠以 'C\*' 这样的名字，而这些语言中，毫无共通点？
这些语言中，有的有静态类型，有的有动态类型，有的两个都有，有的 GC ，有的是为 Arduino 设计的，有的在 JVM 上，有的有 Class ，有的有 Reflection ，有的没有 Assignment ，有的基于 Lambda Calculus ，有的则不是，有的可以任意改自身语法，有的语法是二维的，是个表格，而不是线性的，而有的甚至自带 GUI ，是 livecoding 的鼻祖之一。。

而这些语言，通通被称作同一个语言： Lisp 。

而更魔幻的在后面：于是，有很多人开始讨论，为啥这门语言没有取得主流化，为啥这门语言效率这么高。。。然后得出很多答案，其中一半的直接是错误的，如：

> Lisp 是第二早的高级语言，所以 XXX ，所以效率很高

最早的编程语言 Plankalkül ，是 1942 到 1945 设计的，然后 Fortran 也比任何被称为 Lisp 的语言早。
就算我们取最乐观的时间， 1946 到 1955 之间差了 10 年，里面出现了各种语言， AutoCode , ShortCode , Flow Chart , Haskell Curry 的语言。。。

不过上述问题是技术错误，下面的论证则更离谱：

> Lisp 社区很分裂，大家无法合作，所以没有流行

。。。 Excuse Me ？如果有一天，C , C++ , Java , C\# 都衰落了，再也没有人用，是不是因为 C\* 社区很分裂， C/C++/Java/C\# ，你任意选出一对，肯定在互捏？
大家无法合作也是啊， Java 自己有一套库， C\# 自己一套， C 跟 C++ 也是，这么分裂，不衰退才怪！

欲加之罪，何患无辞啊！本来就不是同一个语言，为啥要放一起论证，然后去吐槽大家之间不兼容？

在一推只是因为历史原因被称作一家族的语言之间，找共通点，然后去论证这些语言的兴衰，特性，适用范围。。。能找出啥有价值，nontrivial的insight才怪。

至于 S 表达式？ Logo 不用括号， Racket 有 2d syntax ，也有 infix expression , Common Lisp 有 reader macro。。。试问这些语言是不是 Lisp ?
而 JMC 也说过我们应该往 M 表达式迁移，那是不是 JMC 发现了 Lisp 的本质劣根性？
我们也可以用 argument by absurdity ，论证 C\* 这个词的合理性 - 有花括号跟分号的就是 C\* ， C\*成为世界上最主流语言， C\* 万岁！

'Lisp' ，这个词，已经没有任何有价值的意义，早就该被废弃，或者仅仅指 JMC 在 1950 末造的一个语言。
就如同 C\* 这个词不应该被引入一样。

另：
最后，我想吐槽小部分所谓的 ‘Lisp’ 厨。
往往，当你问， ‘Lisp有什么优势/值得学’ 的时候（我们先不吐槽这问题提得很糟糕，就如同你不会问为啥要学 C\*/C\* 有啥优势），会跳出大致如下的答案：

> 大部分主流语言的特性，早在 Lisp 中存在。主流 PL 发展只不过是 catch up 1960 Lisp。

这回答并很具误导性。

因为 1960 的时候，JMC 的确公开了一个语言，但是这个语言没有 macro ，是 dynamic scope （读作：没有符合 lambda calculus 的 first class function），连 special form quote 也没有（取而代之的是一个 atom ，换句话说你要 quote compound expression 得手动把 `(A B)` 转成 `(pair A B)` ）。
在 1967 年，影响了 Smalltalk 跟无数学计算机人士的 Logo 出世，而在 1970 年， Scheme 借鉴了 Algol ，修复了 dynamic scope ，也有 macro 跟 continuation 。
Common Lisp 在 1984 诞生，又在 1990 带来了 Common Lisp Object System ，跟 metaobject protocol 。
1994, racket 诞生，又在 2002 带来了 composable \& compilable macro 。
在今年，则出现了 Collapsing Tower of Interpreter ，实现了看上去有无数个 interpreter ，并且可以到达任何一个 interpreter ，更改语义，最后再运行普通的代码（并且看到更改语义带来的 change ），也出现了 Type System as Macro ，可以用宏代表静态类型。

这些语言都很有价值，很多都值得看。

但是没有一门叫 Lisp 的，在 1960 ，搞对了 Lambda Calculus ，拥有大量影响力，有各种现代语言特性(Continuation, Type, Reflection, Macro)，有各种库，然后只有 7 条规则的语言。

我希望大家在讨论/宣传这些语言之一的时候，明白自己是在说啥。
想说历史影响，可以用 Scheme ，玩极简主义，可以用 JMC 的 Lisp ，讨论 OO ，上 Common Lisp ，用 Type/Contract ，搞 Racket 。
而不是一棒子打死，认为这些语言之间有任何共通点。

原作者： 雾雨魔理沙  
原文： https://zhuanlan.zhihu.com/p/32085338
