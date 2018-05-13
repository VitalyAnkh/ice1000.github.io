---
layout: post
title: 一个你可能没听说过的 Java 语法
category: Java
tags: Java
keywords: Java
description: Java syntax
---

当然这肯定也是标题党了，比如 [Glavo](https://github.com/Glavo) 就是反例，怎么可能有 Glavo 没听说过的 Java 语法呢。

所以说这是什么语法呢？

首先我是在提出[这个问题](https://stackoverflow.com/q/50273581/7083401)之后自己撕烤的时候突然脑补出的这个语法。

问题中首先摆出了这么一个语法：

```java
void f(@NotNull List<@NotNull String> strings) {
}
```

函数 `f` 的参数的类型是 `@NotNull List<@NotNull String>`，表示这个参数本身不能为 `null` ，而它作为一个 `List`，它的成员也都不能是 `null` 。
这个看起来非常好理解，因为它实际上就是它看起来那样，很符合直觉。

其实还有这种操作：

```java
<E> void f(@NotNull WhatEver<@NotNull ? extends @NotNull List<@NotNull E>> whatEver) {
}
```

但是如果这个参数是一个数组呢？

```java
void f(@NotNull String[] /* emmm... */ strings) {
}
```

这个时候，我甚至不知道这个 `@NotNull` 注解的对象是什么（是参数？是 `String`？是 `String[]`？）。  
在 Kotlin 中，我们可以写 `Array<String?>` 和 `Array<String>?`，分别是本身不能为 `null` 但成员可以为 `null` 的数组和本身可以为 `null` 但成员不能为 `null` 的数组，这样的两种不同的类型在 Java 里面又应该怎么表达呢。

在 SO 提问之余，我就自己研究了一下。  
我猜测，可能 `[]` 前面也能写东西？于是我试了一下：

```java
void f(@NotNull String @NotNull [] strings) {
}
```

这个代码居然编译过了（提醒一下读者：不是所有注解都可以这么用的，如果你在使用自己写的注解尝试这个例子，请给你使用的注解加上 `@Target({ElementType.TYPE_USE})`。）。
我很是震精，于是我开始试图了解它背后的含义。这个时候最方便的测试方法当然就是看 `@NotNull` 系列注解在 Kotlin 里的表现啦。  
首先我们写一个这样的函数：

```
import org.jetbrains.annotations.Nullable;

public class A {
  public static void main(@Nullable String[] args) {
  }
}
```

然后我在 Kotlin 里面调用它，发现它的签名是这样的：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/21/0.png)

说明 Kotlin 把这个注解同时应用到了 `Array` 和 `String` 上。

而如果把注解写在我之前猜的那个位置的话：

```java
import org.jetbrains.annotations.Nullable;

public class A {
  public static void main(String @Nullable [] args) {
  }
}
```

Kotlin 就直接无视了它（感叹号表示 Platform Type，是『未被标注为 `@NotNull` 或者 `@Nullable` 的意思』）：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/21/1.png)

别急，在不知道这个东西的语义的时候先不要急着批判 Kotlin。  
我们编译一下这个代码里的两个函数，看看字节码吧：

```java
import org.jetbrains.annotations.Nullable;

public class A {
  public static void main(String @Nullable [] args) {
  }
  public static void main(@Nullable Number [] args) {
  }
}
```

然后使用这个命令看看字节码（`javap` 的 `-v` 参数表示输出额外信息，这里不需要 `-c`（显示方法体）和 `-p`（显示 `private` 的东西））：

```shell
$ gradle assemble
$ javap -v A.class
```

看到 `javap` 输出了以下结果（已经省略了 80% 对本文无意义的内容了）：

```
... 省略 ...
Constant pool:
... 省略 ...
  #16 = Utf8               Lorg/jetbrains/annotations/Nullable;
... 省略 ...
  public static void main(java.lang.String[]);
... 省略 ...
    RuntimeInvisibleTypeAnnotations:
      0: #16(): METHOD_FORMAL_PARAMETER, param_index=0

  public static void main(java.lang.Number[]);
... 省略 ...
    RuntimeInvisibleTypeAnnotations:
      0: #16(): METHOD_FORMAL_PARAMETER, param_index=0, location=[ARRAY]
    RuntimeInvisibleParameterAnnotations:
      0:
        0: #16()
}
... 省略 ...
```

在常量池里面我们可以看到 `#16` 就是 `@Nullable` 注解：

```
Constant pool:
  #16 = Utf8               Lorg/jetbrains/annotations/Nullable;
```

然后在两个测试函数中，可以看到 `#16` 注解在不同的地方生效了。
首先是 `String @Nullable [] args` 的第一个函数：

```
RuntimeInvisibleTypeAnnotations:
  0: #16(): METHOD_FORMAL_PARAMETER, param_index=0
```

然后是 `@Nullable Number [] args` 的第二个函数：

```
RuntimeInvisibleTypeAnnotations:
  0: #16(): METHOD_FORMAL_PARAMETER, param_index=0, location=[ARRAY]
RuntimeInvisibleParameterAnnotations:
  0:
    0: #16()
```

呃。。。好吧，首先很明显第二个 `@Nullable` 同时生效于类型和参数本身了，而第一个只在类型上生效了。
不过我还是不知道他们各自在类型上生效时的字节码的意思（看不懂字节码真是对不起呢），于是就使用控制变量法，再写两个函数对比一下（之所以使用两个不同的 `List` 实现，是因为 `List` 和数组不一样，擦除了就一样了所以 JVM 签名就冲突叻）：

```
import org.jetbrains.annotations.Nullable;

import java.util.ArrayList;
import java.util.LinkedList;

public class A {
  public static void main(ArrayList<@Nullable String> args) {
  }
  public static void main(@Nullable LinkedList<Number> args) {
  }
}
```

字节码出来是这样的（已经省略了 90% 对本文无意义的内容了）：

```
... 省略 ...
Constant pool:
... 省略 ...
  #20 = Utf8               Lorg/jetbrains/annotations/Nullable;
... 省略 ...
  public static void main(java.util.ArrayList<java.lang.String>);
... 省略 ...
    RuntimeInvisibleTypeAnnotations:
      0: #20(): METHOD_FORMAL_PARAMETER, param_index=0, location=[TYPE_ARGUMENT(0)]

  public static void main(java.util.LinkedList<java.lang.Number>);
... 省略 ...
    RuntimeInvisibleTypeAnnotations:
      0: #20(): METHOD_FORMAL_PARAMETER, param_index=0
    RuntimeInvisibleParameterAnnotations:
      0:
        0: #20()
}
```

和我想的差不多，写在整个参数前面（`@Nullable List<String>` 或者 `@Nullable String[]`）就是对外部的类型和参数同时进行注解，而写在类型参数或者数组的 `[]` 前面（`List<@Nullable String>` 或者 `String @Nullable []`）就是对类型参数进行注解。

再看看对于泛型类型，Kotlin 的处理方法吧。首先就是刚才那个 Java 代码，Kotlin 表示：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/21/0.png)

原来你丫不仅认识对参数的注解，还认识对类型参数的注解啊。

好了，谜底揭晓\~ 于是我们可以说是 Kotlin 对这个语法的处理是错误的啦。
至于 Kotlin 是否能对二进制的 Java 代码中的这个语法正确处理呢，我已经没有耐心去测试了（Kotlin 的 Java 和 JVM bytecode 前端就是 IntelliJ IDEA 的 Java 和 JVM bytecode 前端，但我也不想再去看了）。

关于 Kotlin 的这个问题我已经在 YouTrack 上开 [issue](https://youtrack.jetbrains.com/issue/KT-24392) 了，大家可以去围观或者 upvote（逃

其实最靠谱的参考还是 [Java 标准](https://docs.oracle.com/javase/specs/jls/se8/html/jls-9.html#jls-9.7.4)里对这个 case 的说明啦。
