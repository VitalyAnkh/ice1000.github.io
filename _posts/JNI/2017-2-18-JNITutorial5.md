---
layout: post
title: JNI 开发：第五章 更多语言的尝试
category: JNI
tags: Java
keywords: Java,JNI,Rust,Kotlin
description: JNI Tutorial
---

## 为什么要尝试更多语言

+ 成天写 Java/C++ 你不累吗

## 为什么是 Rust 而不是 Go/D

+ 我什么时候说了是 Rust 而不是 Go/D 了
+ 其实就是 Rust ，因为 Rust 好啊
+ 因为 Go 目标文件太大
+ 因为我不会 D

## 为什么是 Kotlin 而不是 Scala

+ 问这个问题说明你不了解我

## 依赖

+ Rust 环境（包括 Cargo 构建工具）
+ Kotlin 环境（讲道理你只需要一个 IntelliJ IDEA ）
+ 上三篇教程积累的知识
+ 牢记上篇教程的代码风格约定，这次要用
+ 智商

## 先想个你要写的东西

由于目前 Rust 调用 `JNIEnv` 的方法没有成熟的解决方案（辣鸡 jni-rs （如果你不知道为什么我说他们辣鸡，看到下面你就明白了）），我们先写点简单的数值计算方法。

比如，我们要计算一个整数的平方，和它的平方根向下取整。

## 然后开始写

先使用 Kotlin 写好 JVM 端的接口。这一步非常简单，下面的代码就算你不会 Kotlin 你也能看懂个百分之八九十。

然后顺便编写对应的测试代码。这里我们就不使用自动化测试框架了，直接写进 `fun main` 即可。

需要注意的地方：

+ Java 的 `native` 保留字在 Kotlin 中对应的是 `external` 。
+ 请注意如果出现莫名其妙的 `UnsatisfiedLinkError` ，请对你的方法使用 `@JvmName("compiledMethodName")` 进行修饰。
+ 其他和 Java 基本相同。

```kotlin
package jni;

/**
 * Created by ice1000 on 2017/2/4.
 *
 * @author ice1000
 */
object Main {
  external fun getSquared(origin: Int): Int

  external fun getSqrt(origin: Int): Int

  @JvmStatic
  fun main(args: Array<String>) {
    System.loadLibrary("dll")
    println(getSquared(16))
    println(getSquared(15))
    println(getSqrt(16))
    println(getSqrt(256))
  }
}
```

上面说的莫名其妙的 `UnsatisfiedLinkError` 有很大可能是因为 Kotlin 编译到 JVM 的时候有些方法名会改变，所以我们需要使用 `@JvmName` 来控制编译器行为。

Rust 也有一些需要注意的地方。

+ 需要先定义 `jint`, `jlong` 等类型。
+ 导出的方法使用 `pub extern` 修饰，它其实就是 `JNIEXPORT` 。
+ 需要使用 `#[no_mangle]` 避免出和 Kotlin 那个一样的车祸：方法名被编译器改变。
+ `#![allow(non_snake_case, non_camel_case_types)]` 可以去掉那个很烦的 warning 。

```rust
type jint = i32;
type jlong = i64;

struct JNIEnv {}
impl JNIEnv {}

struct jclass {}
```

然后编写对应的 Rust 业务逻辑实现。

```rust
#![allow(non_snake_case, non_camel_case_types)]

#[no_mangle]
pub extern fn Java_jni_Main_getSquared(
  env: JNIEnv,
  jc: jclass,
  origin: jint) -> jint {
  origin * origin
}

//noinspection RsFunctionNaming
#[no_mangle]
pub extern fn Java_jni_Main_getSqrt(
  env: JNIEnv,
  jc: jclass,
  origin: jint) -> jint {
  let mut left = 0;
  let mut right = origin;
  while right - left > 1 {
    let mid = (left + right) >> 1;
    if mid * mid > origin {
      right = mid;
    } else {
      left = mid;
    }
  }
  left
}
```

然后在你的 Cargo.toml 里面加一句：

```c
[lib]
name = "dll"
crate-type = ["dylib"]
```

然后执行命令：

```c
cargo build --release --verbose
cd build
cd release
move dll.dll ../../
cd ../
cd ../
```

确认一下你的文件树是这样的：

```yml
root:
  - src:
    - dll.rs
    - jni:
      - Main.kt
  - out:
    - jni:
      - Main.class
  - build:
    - release:
      - 一大堆鬼迷日眼的东西
  - dll.dll
```

然后运行刚才那段 Kotlin 代码。如果你运气比较好，那么你可以看到这样的输出：

```c
256
225
4
16
```

没错，分别输出了这段代码

```c
System.loadLibrary("dll")
println(getSquared(16))
println(getSquared(15))
println(getSqrt(16))
println(getSqrt(256))
```

中， 15 16 的平方，和 16  256 的平方根。至于求平方根更好的算法，不是这里讲解的重点，重点是讲清楚怎么在 Rust 和 Kotlin 中使用 JNI 。

如果你运气不好，遇到了鬼迷日眼的 `UnsatisfiedLinkError` ，那么换上女装再试一次吧。

然后你肯定会很想问:

> 怎么使用 `GetIntArrayElements` 这类方法呢？

于是我们求助于社区。  
然后整个过程大概就是。。。我给你们看一个链接你们就应该明白了。虽然这个 issue 是因为我傻逼，但是可以看出他们这个破 jni-rs 还是 Naive ，还需要学习一个。

[jni-rs issues #2](https://github.com/prevoty/jni-rs/issues/5#issuecomment-277795235)

我也 build 了他们的东西。在 cargo.toml 里面添加：

```c
[dependencies]
jni = "0.3.1"
```

然后光是把 cargo 下载依赖整好就折腾了半天。

然后下载了一大堆我光是看名字就知道自己用不上的依赖：

```c
ascii-21c43b555f075c9d
backtrace-3bc1ff360ebb00cb
backtrace-sys-e84e02e57cb850a4
cesu8-67886d5f49b68223
cfg-if-dd9ed43624aace3d
combine-b36e394ecdb45337
dbghelp-sys-63f6e37cae1a7d6b
error-chain-e215757679ae6df4
gcc-962dde8a8894372f
jni-3686c3400dd8597a
jni-28808a6cc0b9af70
jni-sys-a76cb6d12a58aa0d
kernel32-sys-d6afa5bd3d7cfaef
libc-690db683275b166f
log-2de875c5fdd1481e
rustc-demangle-174da41c622e12db
RustSamples-c6ebe66deca030b5
winapi-05520e89b7656dc3
winapi-build-cdb03c7a2d525dd2
```

我有一句

然后加了这个依赖之后编译生成的 dll ，足足有 5mb 之多。我又有一句。

我在很多裙里面问了这样的问题：

```rust
// 我有：
type jsize = i64;
type jint = i32;
struct jintArray {}

struct _JNINativeInterface {}
impl _JNINativeInterface {
  fn NewIntArray(&self, len: jsize) -> jintArray {}
}

type JNIEnv = *const _JNINativeInterface;

// 现在有如下代码：
pub extern fn Java_jni_Main_newIntArray(env: JNIEnv, jc: jclass, jint len) {
  // 如何通过 env 调用 NewIntArray 方法？
}
```

只有觉同学给了一个在 `unsafe` 块里调用的方法。。。。而且我自己也没有测试能不能跑。

所以我还是老老实实 C++ 吧。

## 进阶研究

参考如下代码。放心，不会超过上文知识范围。你可以通过 javah/jd-gui 等工具来探究这些东西该怎么实现。

还可以帮助你了解 Kotlin 一些奇技淫巧的 JVM 实现。

我就不讲解了，反正也是我编的，那我就肯定知道这些东西该咋实现，就是拿给那些想踩坑的家伙做实验的。还可以继续了解 Kotlin ，何乐不为呢。

```kotlin
  val boy = 0
    external get

  var next = 0
    external set
    external get

  external fun String.isIntRepr(): Boolean

  external fun <T> getObjectJvmPointer(obj: T): Int
```

祝你研究愉快。

## 你学到了什么

+ Kotlin 如何使用 JNI
+ Rust 如何使用 JNI
+ 如何使用二分法求平方根（这是个人都会吧喂）

