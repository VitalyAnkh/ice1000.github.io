---
layout: post
title: 如何让孩子爱上 Kotlin ： DSL （中）
category: Kotlin
tags: Essay
keywords: Kotlin
description: Kotlin DSL 2 inline
---

## Kotlin 传教文

本文向您介绍 Kotlin 语言的一些奇特之处，方便您对 Kotlin 这门语言建立一个简单的概念。

我就开门见山地接着上次的讲了。

## 何为 inline

相信写过 C 系列语言的同学应该都十分熟悉 `inline` 这个修饰符了吧——而且好像不止 C 系列有 `inline`。
没事这里我继续说说 Kotlin 的 `inline`。本文篇幅非常短，因为 `inline` 是个很简单的东西。

`inline` 修饰符其实就是告诉编译器，把这个方法的调用行为优化掉。
怎么优化呢？就是直接省掉调用行为，直接把方法的内容写到调用的地方。
但是 Kotlin 中的 `inline` 有所不同是， `inline` 一般只修饰含有单个 block 参数的方法。
别的方法也可以用 inline 修饰，语法上不会报错，但是如果你使用的 IDE 是 IntelliJ IDEA 
，它会告诉你『nothing to inline』，并高亮提示。

然后这就是 `inline` 了。。你可以使用 `inline` 做这样的事情：

```kotlin
// inline 方法调用
lock(l) { foo() }

// 普通的写法
l.lock()
try {
  foo()
}
finally {
  l.unlock()
}
```

是不是挺好的。。。

为什么这种事情要 `inline` 来做呢？因为函数调用传递参数是需要消耗时间的。。。
而且需要一层函数调用栈。。但是 `inline` 就把这些都省去了呢。。。

有个破孩子看了上面那段话，不明白啥意思，我补个例子：

```kotlin
// 首先假设 fuck ()是一段代码。不考虑 fuck 的开销。
// 编译前
inline fun a() = fuck ()
a()
a()
// 产生了两次函数调用
//  编译后
fuck ()
fuck ()
// 没有函数调用了
```

当然以上代码并不是正确的，因为 Kotlin 的 `inline` 不是随随便便就能 `inline` 的。

原本 lambda 开销就大，你需要专门搞个匿名内部类，再传递它的实例，其实你只是想丢个 lambda。

Java 程序员:

> 我能怎么办，我也很绝望啊

内联了，这个 lambda 对象/类就不会产生了。

另外一个作用就是。。。

```kotlin
inline fun assWeCan(block: () -> Unit) {
	// codes
}

fun boyNextDoor(block: () -> Unit) {
	// codes
}

fun foo() {
	boyNextDoor {
		// 这种写法是不能通过编译的，因为有两个函数。你必须使用 return@assWeCan 或者 return@foo 这种写法指定要 return 的 Context。
		return
	}
	assWeCan {
		// 这种写法可以通过编译，因为你 inline 了之后这个 Lambda 就没有了， Context 只有一个。
		return
	}
}
```

以上代码在 [try kotlin](http://try.kotlinlang.org) 上编译通过。

所以啊， `inline` 博大精深。

## noinline 和 crossinline

那么， `noinline` 和 `crossinline` 又是什么鬼呢。。。

其实 `inline` 这种东西啊，在一些比较奇怪的时候，会有各种各样的问题啦。。比如各种东西的作用域啊。。
Context 不一样啦。。。。 Lambda 被传递到了其他地方导致不能 `inline` 啦。。
所以 Kotlin 又弄了俩 `inline` 方法的 Lambda 参数的修饰符。

注意， `inline` 是方法的修饰符， `crossinline` 和 `noinline` 是参数的修饰符，而且仅限参数！

其实理解起来很简单。请先仔细阅读上文中的代码。

### crossinline

考虑如下代码，这段代码是编译不过的。编译器会提示你加个 `crossinline`。

```kotlin
inline fun f(body: () -> Unit) {
  val f = Runnable { body() }
}
```

`crossinline` 就是在你的 lambda 没有被普通地直接在上下文中调用而是被传到了其他地方作为嵌套在内部的代码，
在这种情况下就不能做到简单的 `inline` （会有上下文中的流程控制语句导致的问题）。

比如下面这样，就必须 `crossinline` ：

```kotlin
inline fun f(crossinline body: () -> Unit) {
  val f = Runnable { body() }
}
```

### noinline

这个东西告诉编译器，不要 `inline` 这个 Lambda 。也就是说，依旧产生这个 Lambda 对象。但是函数还是可以内联。

有时由于你需要把这个 Lambda 作为参数传到别的地方去，导致内联做不到，所以使用 `noinline` 。比如：

```kotlin
inline fun test(f: () -> Unit) {
  thread(block = f)
  // 你也可以这样写，下面这种写法也不能通过编译
  // thread(f)
}
```

你就必须使用 `noinline` ：

```kotlin
inline fun test(noinline f: () -> Unit) {
  thread(block = f)
  // 你也可以这样写，下面这种写法也不能通过编译
  // thread(f)
}
```

不过其实你可以在任意时候使用 `noinline` 的：

```kotlin
inline fun test(noinline f: () -> Unit) {
  f()
}
```

以上两份代码你会收到一个可爱的 warning 。

因为这 `inline` 本来是个可以优化调用（节约一个 Lambda 对象）的操作，你非要写成这样就失去了 `inline` 的意义了，所以警告一下啦。

Kotlin 就是要求你写的清晰。为了节约你的时间和精力，她帮你推断类型。
为了节约你的 debug 和 code Review 时间，她强制让你声明一些别的语言里面不强制的东西（比如任何数值类型必须显示 cast ，
显示声明 `infix` ，显示声明 `tailrec` ， `crossinline` ， `noinline` 等等等等）。

像某些语言的隐式转换啊，就是专门让别人在不开 debugger 的情况下看不懂你的代码的。。（逃

于是。。。

### 本垃圾说完了

嘛，就这样啦。欢迎围观寒冰 Frice 全家桶：

+ [Frice-JVM](https://github.com/icela/FriceEngine)
+ [Frice-CLR](https://github.com/icela/FriceEngine-CSharp)
+ [Frice-Designer](https://github.com/icela/FriceDesigner)
+ [Frice-Demo](https://github.com/icela/FriceDemo)
+ [Frice-DSL](https://github.com/icela/FriceEngine-DSL)


，求 star 求 follow ！ QwQ
