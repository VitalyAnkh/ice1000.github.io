---
layout: post
title: Agda 中的证明，从二到三
category: Agda
tags: Agda, Proof
keywords: Agda, Proof
description: Proof in Agda, from 2 to 3
inline_latex: true
agda: true
---

这篇文章我们来说说模式匹配的一种特殊情况。
到目前为止，很可能部分字符无法在一些字体下正常显示，这时候使用 LaTeX 的优越性就体现出来了。

本文主要讲如何证明一个命题是假命题，即证伪。

## 前置知识

+ [上一篇文章](../../../../2017/11/06/ProofInAgda3/)

以及，由于 Agda 语言的特殊性，本文将继续使用 LaTeX 和代码块来共同展示代码。
代码块唯一的作用在于便于复制，主要的呈现途径为 LaTeX 。

请注意，本文将使用极骚的函数命名。
请非 Agda 或 Lisp 用户不要在家模仿。

## 假命题 Bottom Type

想必写过 Scala 或者 Kotlin 的同学都很熟悉 Bottom Type 的概念，在前面两个语言当中有一个特殊的类型 `Nothing`，它是所有类型的子类型。

这些类型有一个共同的特征，就是他们**没有实例**，只有那些在求值时会导致程序中止或者死循环的表达式才会属于这个类型。

这就是为什么他们可以放在任何地方的原因，因为执行到他们这里就会异常退出或者永远无法继续，因此它的返回值根本就不存在，不需要处理。
根据它这样的特征，在支持 subtyping 的语言中，这个类型就成了所有类型的子类型。

在 Rust 中，这个类型叫 `!` 。

在 Haskell 中（其实这个并不是严格意义上的，只是功能类似，类型上并不是，要是把它真当成 Haskell 的 Bottom Type 会被喷的），这个类型叫 `Void` ，在 `Data.Void` 里。

这类类型的统称就是 Bottom Type 。
在证明中，它对应的命题是假命题。
在集合论中，它对应的集合是空集。

### 对应的 GADT

标准库的定义在 `Data.Empty` 中。
我们来看看它对应的 GADT ：

$$
\DeclareMathOperator{Set}{Set}
\DeclareMathOperator{where}{where}
\DeclareMathOperator{proof}{proof}
\DeclareMathOperator{data}{data}
\DeclareMathOperator{absurd}{absurd}
\DeclareMathOperator{intro}{intro}
\DeclareMathOperator{ff}{ff}
\DeclareMathOperator{suc}{suc}
\DeclareMathOperator{is}{is}
\DeclareMathOperator{double}{double}
\DeclareMathOperator{of}{of}
\DeclareMathOperator{refl}{refl}

\data \bot : \Set \where \\
$$

```agda
data ⊥ : Set where
```

只有一行，我们声明了这个类型，然后不给它定义构造器。
也就是说，这个东西没有 instance ，符合刚才的定义。
这意味着我们需要在证明的时候，既要保证对输入 total ，也要保证对输出的所有情况都不存在。

这个东西有什么用呢？

### 加法与乘法

比如前文所讲的 $ \land $ 类型，如果它的两个类型参数其中一个是 $ \bot $ ，那么你就无法构造这个类型了，它也变成了 Bottom Type 。

这正好和数学上的一种运算非常相似——乘法。
任何数和 $ 0 $ 进行 $ \times $ （乘法）运算都得到 $ 0 $ ，而任何类型和 $ \bot $ 进行 $ \land $ 运算都得到 $ \bot $ 。

而前文所讲的 $ \lor $ 类型，如果它的两个类型参数其中一个是 $ \bot $ ，你依旧可以从另一个类型使用对应的 $ {\lor}{-}{\intro} _x $ 构造器生成这个类型。
而这时，你只能通过另一个类型对应的 $ {\lor}{-}{\intro} _x $ 构造器生成这个类型，因此这个 $ \lor $ 后的类型和原来的非 $ \bot $ 类型等价。

这也正好和数学上的一种运算非常相似——加法。
任何数和 $ 0 $ 进行 $ \+ $ （加法）运算都得到它自己，而任何类型和 $ \bot $ 进行 $ \lor $ 运算也都得到它自己。

是不是很奇妙呢？

当然，它的应用远不止这些。
我们将在接下来的内容中看到它是如何表示假命题的。

## Absurd pattern

在 Haskell 的 `Data.Void` 中，有一个函数叫 `absurd` ，类型是 `Void -> a` 。
之所以它能写出这么骚的类型签名，是因为它不 total 。

同样，我们也可以在 Kotlin 中写出类似的东西，在有 subtyping 的情况下， `absurd` 函数直接返回参数即可：

```kotlin
fun absurd(a: Nothing): Any = a
```

完全等价的 Scala 版本：

```scala
def absurd(a: Nothing): Any = a
```

在 Agda 中，假命题可以推出任何命题，比如假命题可以推出假命题，因为假命题都成立了，那还有什么不能成立的（而这种就是一个吃饱了撑的证明）。
在程序的角度来看，一个函数以一个没有值的类型作为参数，那么对它的调用就是不可能发生的，因此随便返回啥都行。

因此，我们一般证明的是其他类型在经过各种组合下可以被推为假命题的情况。
也就是说，在一般情况下，它作为证明的结论。

所以我们一般在函数的返回值里看到它（而不是参数）。

在定义一个 Agda 的函数时，我们需要对参数进行模式匹配。
如果有多种情况，我们需要一一把它们写出来（参照前文的与 $ \lor $ 有关的函数）。

但是如果只有零种情况，或者说，没有情况呢？

比如，我们要写一个上面说的那个吃饱了撑的的证明，应该怎么写呢？

### 零种情况

我们先来写下类型签名：

$$
\absurd : \bot \rightarrow \bot
$$

```agda
absurd : ⊥ → ⊥
```

然后我们在模式匹配的时候，使用 `()` 来代表零种可能的匹配的情况：

$$
\absurd \ ()
$$

```agda
absurd ()
```

好， it checks 。

这个 `()` 就是 absurd pattern 了。
在匹配的模式中，如果使用了 absurd pattern ，那么就不需要，也不能写对应的函数体了。
它的名字也可以说是借鉴了 Haskell 中的这个函数名。

### 其他例子

同理，我们可以写一些类似的代码（关于 $ \land $ 和 $ \lor $ 的定义请参考前文），练习一下对 absurd pattern 的使用：

$$
\begin{align*}
& \proof _0 : \forall \{A\} \rightarrow \bot \land A \rightarrow \bot \\
& \proof _0 \ ({\land}{-}{\intro}\ ()\ \_) \\
\\
& \proof _1 : \forall \{A\} \rightarrow \bot \lor A \rightarrow A \\
& \proof _1 \ ({\lor}{-}{\intro} _0 \  ()) \\
& \proof _1 \ ({\lor}{-}{\intro} _1 \  x) = x
\end{align*}
$$

```agda
proof₀ : ∀ {A} → ⊥ ∧ A → ⊥
proof₀ (∧-intro () _)

proof₁ : ∀ {A} → ⊥ ∨ A → A
proof₁ (∨-intro₀ ())
proof₁ (∨-intro₁ x) = x
```

而真正地表达那种正正经经的假命题，可以看这个例子（ $ \equiv $ 的定义参照前文）：

$$
\begin{align*}
& \proof _2 : \{ a : \Bbb{N} \} \rightarrow a \equiv \suc a \rightarrow \bot \\
& \proof _2 \ ()
\end{align*}
$$

```agda
proof₂ : {a : ℕ} → a ≡ suc a → ⊥
proof₂ ()
```

由于 `a` 不可能等于 `a` 的继数，因此直接使用 absurd pattern 即可证伪。

好，我们现在不仅知道知道如何表达假命题，而且知道如果要证明一个命题是假命题，
只需要写一个函数，以该命题为参数，返回一个 $ \bot $ 类型就好了。

## 一个简单的证明

我们来定义一个 GADT ，表达两个自然数为两倍关系：

$$
\begin{align*}
& \data \_{\is}{-}{\double}{-}{\of}\_ : \Bbb{N} \rightarrow \Bbb{N}
  \rightarrow \Set \where \\
& \ \ \intro : \forall \{n \ m\} \rightarrow n + n \equiv m
  \rightarrow m \ {\is}{-}{\double}{-}{\of} \ n
\end{align*}
$$

```agda
data _is-double-of_ : ℕ → ℕ → Set where
  intro : ∀ {n m} → n + n ≡ m → m is-double-of n
```

然后我们可以简单地证明 $ 8 \ {\is}{-}{\double}{-}{\of} \ 4 $ 成立：

$$
\begin{align*}
& 8{=}4{\times}2 : 8 \ {\is}{-}{\double}{-}{\of} \ 4 \\
& 8{=}4{\times}2 = \intro \refl
\end{align*}
$$

```agda
8=4×2 : 8 is-double-of 4
8=4×2 = intro refl
```

而我们可以很容易地证伪 $ 9 \ {\is}{-}{\double}{-}{\of} \ 4 $ ：

$$
\begin{align*}
& 9{\neq}4{\times}2 : 9 \ {\is}{-}{\double}{-}{\of} \ 4 \\
& 9{\neq}4{\times}2 \ (\intro \ ())
\end{align*}
$$

```agda
9≠4×2 : 9 is-double-of 4 → ⊥
9≠4×2 (intro ())
```

是不是很简单呢。

## 结束

是的，我说完了。

$$
\downarrow \\
\bot
$$
