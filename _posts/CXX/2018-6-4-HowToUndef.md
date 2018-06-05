---
layout: post
title: 如何取消一个 C/C++ 的符号的定义
category: CXX
tags: Essay, C++, C
keywords: C++
description: Undefine a C++ symbol
---

C++ 是一个玄妙得令人抓狂的语言，我今天遇到了一个需要取消定义一个已经定义了的类型的需求。

假定我们有一个辣鸡头文件 `notstddef.h`, 它令人不可饶恕地把 `size_t` 硬编码成了 32 位的版本:

```c
typedef unsigned int size_t;
```

然后我们有这样的代码（实际上是 `new` 里的，这里简化了情况）:

```cpp
#include <notstddef.h>

auto operator new(std::size_t __sz) -> void * {
  // 奇奇怪怪的实现
}
```

然后我们在 64 位下编译就报错啦，说什么参数类型要不得呀。

我现在希望在不修改头文件的情况下取消 `size_t` 的定义，然后我在 [栈溢出](https://stackoverflow.com/a/27907062/7083401) 查到了这么一个用法：

```cpp
#define size_t __size_t__place__holder__
#include <notstddef.h>
#undef size_t

typedef unsigned long size_t

auto operator new(std::size_t __sz) -> void * {
  // 玄妙的实现
}
```

根据需求，你可以利用 `__size_t__place__holder__` 的值做一些事情。

看起来很强的样子，至少我这个 C++ 苦手是不知道这种操作的。
