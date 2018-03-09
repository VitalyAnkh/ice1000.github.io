---
layout: post
title: 如何让孩子爱上 Kotlin ： DSL （下）
category: Kotlin
tags: Essay
keywords: Kotlin
description: Kotlin DSL 2 inline
---

## Kotlin 传教文

本文向您介绍 Kotlin 语言的一些奇特之处，方便您对 Kotlin 这门语言建立一个简单的概念。

我就开门见山地接着上次的讲了。

Kotlin 的 extension 是个很神奇的东西。在第一篇文章中我就讲到了 extension ，但是 extension 可不仅仅能这样使用。它还有两种更高级的用法。

## 泛型
没错， extension 可以和泛型一起使用。比如这个方法：

```kotlin
val file: File // 一个 Property ，重载 get 方法
	internal get() {
		val f = File("boyNextDoor") // 新建一个 File 类型的变量
		if (!f.exists()) f.createNewFile() // 如果不存在那么新建一个
		return f // 返回这个文件对象
	}
```

看起来是不是很臃肿？明明只需要使用一次的临时产生的变量，却由于需要进行一步额外的操作（检查是否存在）而不能通过匿名的形式直接构造后返回。
它让你必须声明一个对应的变量。这曾经让我很苦恼，但是 extension 却解决了这个问题。
配合 Lambda 使用，根本不需要为此增加一个变量。

```kotlin
// 声明
fun File.apply(block: (File) -> Unit): File {
	block(this)
	return this
}
// 调用
val file: File
	internal get() = File("boyNextDoor").apply { f ->
		if (!f.exists()) f.createNewFile()
	}
```

这里有个令人困惑的地方。block 是一个签名为`(File) -> Unit` 的 Lambda ，为什么在调用的时候传入了一个 `this` 呢？这个 `this` 指的是什么？

还记得第一篇里面讲的 extension 的 JVM 实现吗。
扩展方法实际上是把第一个参数前面再增加了一个参数，它是调用者自己。
这样，在方法内部，上下文就是这个调用者了。
你可以理解为它将全部的自己的方法调用（就是可以写成 `this.fuck()`这种形式的）全部加上 `this` ，然后把 `this` 换成了`$reciver`,即编译后生成的那个被增加的参数。

为了增加这个 `apply` 方法的普适性，我们把它写成泛型形式的：

```kotlin
fun <T> T.apply(block: (T) -> Unit): T {
	block(this)
	return this
}
```

注意，这里的 `fun <T>`在调用的时候根本不需要写成 `van.apply<Aniki>(params)`的形式，那个尖括号的类型声明是没有必要的。
因为你写了 `T.apply` ，当你写下 `van.apply` 的时候，编译器就已经知道，这个 `T` 应该是 `van` 的类型。于是就不需要再显式声明了。

基于那个『扩展其实就是把调用者变成第一个参数』的说法，我们可以做一些有趣的事情。

```kotlin
fun <T> T.apply(block: /*区别在这里！*/T.() -> Unit/*签名不一样！*/): T {
	block(this)
	return this
}
```

把参数中的 Lambda 也写成了 extension 的形式。在调用的时候，传入参数 `this` ，作为第一个参数。
然后在调用的时候，比如刚刚说的那个检查文件存在的例子，就不需要写带参数的 Lambda 了。上下文直接就是 `File` 对象了。

```kotlin
val file: File
	internal get() = File("boyNextDoor").apply {
		if (!exists()) createNewFile()
	}
```

看到了吗？省去了`f ->`以及两处`f.`。这时候你可能会问了，这特性有什么卵用？

构造 DSL 啊！

```kotlin
@JvmName("game")
fun game(block: LanguageSystem.() -> Unit) {
	LanguageSystem(block)
}

class LanguageSystem(val block: LanguageSystem.() -> Unit) : Game() {
		override fun onLastInit() {
		super.onLastInit()
		block.invoke(this)
	}

	fun size(width: Int, height: Int) {
		size = Dimension(width, height)
	}

	fun log(s: String) {
		val f = File(logFile)
		if (!f.exists()) f.createNewFile()
		f.appendText("$s\n")
	}

	fun rectangle(block: DSLShapeObject.() -> Unit) {
		val so = DSLShapeObject(ColorResource.西木野真姬, FRectangle(50, 50))
		block(so)
		addObject(so)
	}

	fun oval(block: DSLShapeObject.() -> Unit) {
		val so = DSLShapeObject(ColorResource.西木野真姬, FOval(25.0, 25.0))
		block(so)
		addObject(so)
	}

	fun image(block: ImageObject.() -> Unit) {
		val io = ImageObject(ImageResource.empty())
		block(io)
		addObject(io)
	}

	fun text(block: SimpleText.() -> Unit) {
		val st = SimpleText("", 0.0, 0.0)
		block(st)
		addObject(st)
	}

	fun button(block: SimpleButton.() -> Unit) {
		val sb = SimpleButton("", 0.0, 0.0, 80.0, 30.0)
		block(sb)
		addObject(sb)
	}
}
```

上面是我的 Frice 引擎的 Kotlin DSL 的一部分。这样声明之后，调用的代码就像这样：

```kotlin
game {
	log("game start!")

	rectangle {
		x = 100.0
		height = 200.0
	}
	oval {
		y = 30.0
	}
}
```

是不是感觉完全不会编程的人都能看懂这代码！没错，这就是 DSL 的魔力。（想起了曾经被 Rails 洗脑的恐惧，躲墙角抱头蹲）

于是。。。

### 本垃圾说完了

嘛，就这样啦。欢迎围观 Frice 全家桶：

+ [Frice-JVM](https://github.com/icela/FriceEngine)，引擎最初版， Kotlin 写的 JVM 版，对 Java 的支持很好
+ [Frice-CLR](https://github.com/icela/FriceEngine-CSharp)，引擎 C#版，目前跑起来最快的
+ [Frice-Designer](https://github.com/icela/FriceDesigner)，引擎设计器，目前还有 bug
+ [Frice-Demo](https://github.com/icela/FriceDemo)，各语言版本引擎的 Demo 大集结
+ [Frice-DSL](https://github.com/icela/FriceEngine-DSL)， JVM 版引擎的基于 Kotlin 的 DSL 系统
+ [Frice-Racket](https://github.com/icela/FriceEngine-Racket)，引擎 Racket 版，逐步完善中
+ [Frice-Android](https://github.com/icela/FriceEngine-Android)，引擎 Android 版，依然是 Kotlin。和最初版不一样， extension 用的比较多，对 Java 不是那么友好


求 star 求 follow ！(°ー°〃)
