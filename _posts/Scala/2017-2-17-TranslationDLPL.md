---
layout: post
title: （翻译）从编程语言的角度看深度学习
category: Scala
tags: Scala,NN,ML,DL,PLT
keywords: DeepLearning,Scala,Kotlin,Java
description: (Translation) See DL from PL's point of view
inline_latex: true
---

[原文传送门](https://zhuanlan.zhihu.com/p/24941985)

## (翻译) 从编程语言的角度看深度学习

看到翻译二字很多人会认为是 En -> Ch ，其实本文是 Scala -> Java && Scala -> Kotlin 。

说白了就是把原文的代码翻译了一下，方便那些不会 Scala 的同学们。。。呃。。。

由于 Jawa 没有 Lambda 对象这概念，我就使用实现单方法接口的匿名内部类的方式来代替 Lambda 对象了。

下文是学姐写的，也就是说下文中的『我写的』『我做的』这种话都是指学姐啦。

### 正文

想必大家都听说过[Artificial Neural Network](https://en.wikipedia.org/wiki/Artificial_neural_network)（如果没有，快去看），
但是具体来说，什么是反向传播呢？
反传背后的 Intuition 又是啥？我会试着从编程语言的角度，说明深度学习的各种东西，并且指出从编程语言看待深度学习的潜在好处。
同时，我也会介绍一下我从这角度写的深度学习框架 [DeepDarkFantasy](https://github.com/ThoughtWorksInc/DeepDarkFantasy)
，以展示编程语言里面的各种东西可以如何应用上神经网络框架。

什么是神经网络？ 

一言蔽之，一个神经网络就是一个带有一定未知参数的程序！这些未知参数，是一个神经网络的权重。正向传播，就是运行这个程序的过程。深度学习，就是寻找这些参数。

比如说，假设我们有如下的神经网络（并假设用的激活函数为 Relu （为了方便描述，这是个很小的网络））：

输入 0 -----输出 0

输入 1 -------/\

这个神经网络，如果转为 Java 代码，就是

```java
public static Function<Double, Function<Double, Function<Double, Double>>> nn(final Double in0) {
	return (final Double in1) -> (final Double w0) -> (final Double w1) -> Math.max(in0 * w0, in1 * w1);
}
```

Java 的 Lambda 对象调用只能这么写：

```java
public static void main(String[] args) {
	nn(0.1).apply(0.1).apply(0.1).apply(0.1);
}
```

如果转为 Kotlin 代码，就是

```kotlin
fun nn(in0: Double) = { in1: Double -> { w0: Double -> { w1: Double -> Math.max(in0 * w0, in1 * w1) } } }
```

调用和原文中的 Scala 一样所以不写了。

### 如何训练神经网络？ 

怎么找出最优的未知参数呢？

首先，什么叫‘最优’的参数呢？我们可以引入一个函数：指标。
指标接受权重，用这些权重运行神经网络，最后得出一个分数。最优的未知参数最小化/最大化这个指标。这个指标叫做 Loss Function。

Java 并没有类型别名。所以有：

```kotlin
typealias Weight = Double
//假设只有一个 Weight ，为 Double
typealias LossFunction = (Weight) -> Double
//LossFunction 是一切接受权重，返回 Double 的函数
```

很常见的 Loss Function ，有 Mean Square Error ：


对于一个多维度输出跟预期输出的每一维度，平方(该维度输出-该维度预期输出)，并把结果累加，最后除以维数。如果只有一个维度，这就等于平方(输出-预期输出)。很明显，这是一个 scala 函数。

```kotlin
fun MSE(l: List<Weight>) = { r: List<Weight> -> l.zip(r).map { p -> p.first * p.second }.sum() / l.size }
```

这并不是上面定义的 LossFunction 形式。但是，如果我们有一个确定的数据集（ List[(Input, Output)] ），就可以写一个 wrapper ：
输入权重，对于给定的数据集，对每一个数据点（一个输入，跟一个输出），用给定的权重，跟该数据点的输入，运行神经网络，把结果跟该数据点的输出相减取绝对值，最后累加起来。

可以对 LossFunction 做转换，比如可以 Scale 之：

```kotlin
fun Scale(d: Weight) = { lf: LossFunction -> { w: Weight -> d * lf(w) } }
```

梯度下降/梯度上升之间的转换，就是 Scale -1 ：

更多的转换：也可以把两个 LossFunction 加起来：

```kotlin
fun Plus(l: LossFunction) = { r: LossFunction -> { w: Weight -> l(w) * r(w) } }
```

也有其他的 LossFunction ，比如 L1 L2 Regularization ，主要用于防止过大权重：

```kotlin
fun L1() = { a: Weight -> Math.abs(a) }
fun L2() = { a: Weight -> a * a }
```

如果想对一个已有的 LossFunction 加上 L2 ，很简单：我们先把 L2 scale 一个超参数，以调节 Regularization 的程度，然后跟原 LossFunction 相加。

回到正文，要最少化某个 LossFunction ，最常见的办法是，


0. 找一些随机值作为初始参数
0. 算出在这些参数上， Loss 的导数（在多个权重下，是个 gradient ）
0. 如果导数为正，就降低权重，如果导数为负，就增加权重（在多个权重下，为往 gradient 的反方向 update ）
0. 循环往复 1,2 ，直到你喜欢为止。

这叫梯度下降（按着某个梯度的方向降低权重），是深度学习里面很多优化算法的简化版。

反向传播，就是找出导数，然后更新的流程。


导数从那里来？ 

按照自动化程度排序：

+ 手动写出来（这是 PHD 存在的意义（划掉））
+ 手动写出神经网络层的求导，然后一层层的组合起来。Caffe 就是这样的：在里面，模块就是一层神经网络，比如说有 Convolution 层（用于 CNN ），有 FullyConnected （叫 InnerProduct ）层，这些层都要框架程序员手写，但是其他人可以调用他们组合出自己的神经网络
+ 提供一个 DSL ，并用这个 DSL 实现神经网络层，或者其他样式的神经网络架构。如果 DSL 中一切都可以求导，实现出来的神经网络层就是可以求导的。这时候，深度学习框架就变成了一个带求导功能的编程语言（因为我们不跟 Caffe /手写比较，我们以后就称一切深度学习框架为 DSL ，并且称神经网络为程序）。 Tensorflow 就是这样的

细心的同学可以发现，这三者都可以视为同一件东西：我们定义一个 DSL ，手动写出 DSL 的 primitive 的求导算法，然后用这个 DSL 定义自己需要的东西。

在 Caffe-like 的情况下，这个 DSL 的基础操作就是层，并且可以把层组合起来（不算很灵活，不过聊胜于无），更极端的情况（全手动）下，这个 DSL 的基础操作只有一个（整个算法），并且没有任何组合方法。这样看，其实一切都是基础操作粒度大小之争（粗粒度细粒度之争）。越细的粒度，就越灵活，（不考虑性能）实现框架也就越简单。

当然，并不是越细粒度越好-现阶段，由于优化不够好，手动写得越多，效率越高-有多少人工，就有多少智能。

同时，有三种导数的表示，根据灵活性排序（ again ，不是越灵活越好，因为效率问题）：

0. 对于一个 DSL 中的程序，返回一个求导函数（不在 DSL ）中。 Caffe
0. 对于一个 DSL 中的程序，返回一个 DSL 中的程序（这样可以后接优化，或者再次求导）。 Theano 。 DeepDarkFantasy。
0. DSL 中有一个函数：求导。 StalinGrad 。


DeepDarkFantasy 有什么特点？

尽管深度学习框架是程序语言，但是他们支持的操作并不多：有基础的四则运算，有一定的条件控制/循环，有的有 scan/变量（见 tensorflow 白皮书），然后就没啥了。 DDF 中则加入了各种编程语言的操作，在上面的基础下加入了递归，跳转（ Continuation ），异常， IO ，等等。

跟其他 AD 语言比起来， DDF 的特点是，是一个 Typed Extensible Embedded DSL - 这 DSL 造出的 AST 是 scala 中强类型的 term ，并且这个 DSL 可以很简单的在 scala 中扩展。同时， DDF 是 Typed 的-我们可以给出任意 type 的导数类型，也可以对任意 term 求导（并且有正确的 type ）。我们也同时（未完成）给出了一个算法是正确的证明。

DDF 的原理是？

对于任意一个 term ，如果要找出他的导数形式，我们只需要把所有 Double 换成对应的二元数。但是，转换完以后，跟一般的，得出一个函数的二元数实现不同，得出的依然是一个 AST-换句话说， AD 其实可以是 Symbolic 的。这是 DDF AD 的原理。

换句话说， DDF 抛弃了‘导数’这个概念。在 DDF 中，对一个东西求导以后，不会得出他的导数，只会得出该 term 跟该 term 的导数的一个混合物。打个比方：

```scala
Either[Double, (Double, Double)] => Either[Double, Double]
```

并没有一个所谓的‘导数’。

但是可以把导数插进上面的类型，得出

```scala
Either[(Double, Double), ((Double, Double), (Double, Double))] => Either[(Double, Double), (Double, Double)]
```

这是上面类型的 term ，但是所有 Double 跟 Double operation 都转换成二元数的 term ，的类型。

注：的确可以给函数， Sum Type ，找出单独的类型，早期 DDF 也是这样做的，但是我不喜欢，放弃了。

至于如何做 Typed Extensible EDSL ，可以看[Finally Tagless](https://www.cs.cornell.edu/info/projects/nuprl/PRLSeminar/PRLSeminar2011/Chung-chiehShan-FinallyTaglessPartiallyEevaluated.pdf)

至于如何表示 Lambda Abstraction ，可以看 [Compiling Combinator](https://zhuanlan.zhihu.com/p/22231273)

形式化定义：

可能这些东西都太玄乎，大家都没理解，于是我就给出一个缩小版的 DDF ， DDF-min ，并更严谨地定义 DDF-min ，希望能帮助学过点 Type Theory 的人理解：

DDF-min 基于 Call By Value Simply Typed Lambda Calculus ，带有 Real ， Sum Type, Product Type, Recursion （ using Y schema ）

有 with\_grad\_t 函数，可以 traverse type structure ，然后把所有遇到的 Real 转换成 Real * Real。

还有 with\_grad 函数，可以 traverse AST ，然后把类型转换成 with\_grad\_t

然后有个 logical relation ，对于函数外的东西，都是 trivial 的定义，或者简单的 recurse 进去。

对于 A -> B ，除了普通的‘对所有符合 logical relation 的 A ， application 满足 logical relation’外，还有：如果

$$
A \rightarrow B = Real \rightarrow Real
$$

，这个函数的 with_grad 加点 wrapper 就是这个函数的 Denotational Semantic 的导数函数。

另：这根[MarisaKirisame/DDFADC](https://github.com/MarisaKirisame/DDFADC)中描述的有一定出入。

Forward Mode AD 会不会有性能问题？

如果对 AD 很熟的朋友，肯定会指出一个问题：如果有 N 个 Double 输入， Forward Mode AD 就要运行 N 次。对于有着很多参数的神经网络来说，这无法忍受！

解决办法是，我们对 Dual Number 做一次 Generalization ： Dual Number 并不一定是`(Double, Double)`，也可以是`(Double, (Double, Double))`。用后者，可以运行一次，算出两个导数。

比如说，给定 $ x, y, z $ 并且想知道 $ (x+y) \times z $ 对于 x, z 的导，可以写出

$$
((x, (1, 0)) + (y, (0, 0))) \times (z, (0, 1)) = \\

(x + y,(1, 0)) \times (z, (0, 1)) = \\

((x + y) \times z, (z, x + y)) \\
$$

在这里面， pair 的第 0 项就是表达式的值， pair 的第 1 项就是另一个 pair ，其中第 0,1 ，项分别是表达式对于 x ， y 的导。

或者，可以用 `(Double, Double => Double[1000])`（注： `Double[1000]`不是真正的 scala 代码）代替`(Double, Double[1000])`-这样，当整个 term 要乘以一个 literal 的时候，并不需要进入整个 Array 去算，只需要 update 该 Double 则可-这就是反向传播。

在实现中，这通过引入一个 Typeclass ， Gradient （满足的有 `Unit, (Double, Double),(Double => Double[1000])`等），（并限制 Gradient 一定要满足 field 的一个 variation （其实本质上还是一个 field ，只不过为了提速）），并用之于 Dual Number 之上（第二个参数不再是 Double ，而是该 Gradient ）。然后， AD 的四则运算就可以利用 Field 的操作写出。

这有什么用？

我们希望能做到[Neural Networks, Types, and Functional Programming](https://colah.github.io/posts/2015-09-NN-Types-FP/)里面给的例子

DDF 可以很简单的给出有递归/循环的函数的高阶导。这点 tensorflow 就不支持（ [Gradients of non-scalars (higher rank Jacobians) · Issue #675 · tensorflow/tensorflow](https://github.com/tensorflow/tensorflow/issues/675)）。

除了写神经网络以外，我们也希望可以写任意普通的算法，程序（但是带有未知变量），然后用 DDF 自动求导，以找出最优的这些变量。

能不能给个例子？[这](https://github.com/ThoughtWorksInc/DeepDarkFantasy/blob/master/doc/poly.md)
是一个用梯度下降解 $ x \times x+2x+3=27 $ 的例子。

## 没了

翻译感言：垃圾 Jawa





