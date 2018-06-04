---
layout: post
title: 代码编辑器系列 &num;2 文本的存储 远古篇
category: Editor
tags: Kotlin
keywords: Kotlin, Code Editor
description: Text Editor series &num;1 architecture and decoupling
---

在[上一篇文章](../../../4/29/CodeEditor2/)中我介绍了提到了两种代码编辑器—— LSP 式和 JB 式的区别，并表明以后的文章会是关于 JB 式的编辑器的。
那么这篇文章先说点别的吧。
我自己的实验项目里是直接使用 Java 的 `StringBuilder` 作为文本存储工具的（由于 Swing 的 API 看起来更低效，所以我直接在这个地方弃疗了），
因为 Java 的 `String` 是 immutable 的，对大规模的读写、插入删除、拼接拆分非常不友好，于是我就使用了相对高效的。

