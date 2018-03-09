---
layout: post
title: JNI 开发：结语+带逛一波
category: JNI
tags: Java
keywords: Java,JNI
description: JNI Tutorial End
---

那么我自己总结的关于 JNI 的东西就差不多这些了，我也看过很多相关资料，在这里带逛一波（是不是可以称之为冰带逛啊///////）。

## 为什么要看我带逛而不是自己 Google

搜出来的东西大部分没啥质量，基本是搜出来 10 篇文章，去掉重复的、抄袭的，只剩两篇。而且质量极低，讲来讲去都是那些玩玩 javah 就会的东西。

你们可以把它当做这个 JNI 系列教程的延伸阅读。

## 冰带逛时间

### 全方位参考向

+ 首先肯定是最推荐的维基了 [Wikipedia](https://en.wikipedia.org/wiki/Java_Native_Interface)
+ 然后还有 [官网 spec](https://docs.oracle.com/javase/8/docs/technotes/guides/jni/)
+ 没看过，但是 Wikipedia 推荐的： [Java Native Interface: Programmer's Guide and Specification](https://web.archive.org/web/20120728074805/http://java.sun.com/docs/books/jni/)

### 参考资料向

+ [如何获得 C Linkage 中符号的类型，并进行 JNI 类型检查？ OpenJDK 是如何实现这个功能的？](https://www.zhihu.com/question/52655861)，一个知乎问题，名义上还是我提的，有轮子和 R 大的回答
+ [IBM 良心文章，一堆 Best Practice](https://www.ibm.com/developerworks/java/library/j-jni/index.html)，和我自己总结的基本吻合，相见恨晚系列
+ [IBM 文章的辣鸡中文翻译，来自 Infoq](http://www.ibm.com/developerworks/cn/java/j-jni/)，我本来以为我可以去翻译结果看到了这个，虽然很烂但是它让我失去了翻译的欲望，因此更烂
+ [一位可爱的小姐姐的博客文章，讲解 CriticalNative](http://blog.hakugyokurou.net/?p=1758)

## 结语

研究 JNI 算是一件非常『非主流』的事情了，因为这方面的人都是这样学习的：

听说了 JNI -> 想学 -> 自己做实验，发现确实快 -> 想深入学习 -> Google -> 发现文章只有一点点 -> 看完了，全是垃圾 -> 找官文/爆栈/上知乎提问 -> 自己踩坑 -> 顺便学了一堆附加技能，比如 Rust/定制 JVM 等 -> 想写教程，发现内容太多，又懒 -> 放弃写教程

于是你并不能找到什么好的教程。

希望我那几篇原创教程能给你带来一些经验，少踩点坑，多认识一些 Better/Best Practice 。我觉得这对整个人类都有好处。

上面列出的文章除了我声明的那篇之外，别的我都是认真读过一遍的，觉得写的好才推荐出来，这可以帮助那些人寻找资源。 CriticalNative 我本来也想写篇文章讲讲的，但是尊重原作者权利（因为我来写的话基本等于就是用自己的话把她的原文复述一遍），于是我只是给出了原文链接。

如果你时间很少，那么就看参考资料向的最后俩文章吧，一篇讲 Best Practice ，一篇讲黑科技 CriticalNative 。都是相同地位资料巨少的。起码我就看到这么一两篇。

愿世界少点抄袭，多一份尊重。

JNI 是好东西。请正确、优雅地使用它。
