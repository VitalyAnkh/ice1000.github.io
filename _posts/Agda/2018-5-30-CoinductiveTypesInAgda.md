---
layout: post
title: Agda 中的 coinductive data type
category: Agda
tags: Agda, Proof
keywords: Agda, Proof, Coinductive
description: Proof in Agda, from 4 to 5
inline_latex: true
---

最近和 [@16](https://github.com/hexadecimaaal) 聊了一些关于 Coq 的话题，16 提到了 Coq 中的 coinductive
数据类型不能进行形如 `a = b -> P a = P b where a, b are of coinductive data type` 的推导。<br/>
由于 Agda 中（似乎？）没有像 Coq 那样区分 `coinductive` 和 `inductive`（而是作为几个 `postulate`，下面会说），所以我从来还没想过这些问题。
然后就研究了一下，感觉是之前不会的东西，就写篇博客聊聊。

本文命名比较正常，请 Haskell 程序员不要模仿。

## 从字符串说起

Agda 的内置字符串类型（ `Agda.Builtin.String`）是作为 `postulate` 定义的：

```haskell
module Agda.Builtin.String

postulate String : Set
{-# BUILTIN STRING String #-}
```

然后又 `postulate` 了一堆函数：

```haskell
postulate primStringToList   : String → List Char
postulate primStringFromList : List Char → String
postulate primStringAppend   : String → String → String
postulate primStringEquality : String → String → Bool
postulate primShowString     : String → String
```

很明显这些函数是直接映射到目标语言的原生函数的。
但是这就直接导致这些函数以及 `String` 类型自己的性质无法被用于形式验证了（因为实现对 checker 是不可见的），
所以十分鸡肋（只能说可以运行时用用吧，但 Agda 基本都是不运行的，，）。

如果是需要 Haskell 的那种

```haskell
type String = List Char
```

的 `String` 的话，又需要用 `primStringToList` 转来转去，十分 ~~键山雏~~ 麻烦。

之所以要研究这个，是因为我想试试在 Agda 里调用 `putStrLn`, whose 参数类型是 `String`。
然后我看向了 `putStrLn` 的实现：

```agda
postulate putStrLn : Costring → IO Unit
{-# COMPILE GHC putStrLn = putStrLn #-}
```



$$
\downarrow \\
\bot
$$
