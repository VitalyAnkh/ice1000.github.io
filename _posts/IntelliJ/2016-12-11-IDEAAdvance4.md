---
layout: post
title: IntelliJ IDEA 进阶教程： 测试框架
category: IntelliJ
tags: Java, IntelliJ IDEA
keywords: Java,IDEA, PhpStorm,WebStorm,PyCharm,Rider,RubyMine,CLion,Android Studio,JUnit
description: IDEA advance chapter 4
---

## 依赖
+ 一个 JetBrains 系的 IDE

## 测试是啥

当你知道你在程序中使用了过多奇技淫巧时，你可能时常对你的程序会出现 bug 一事而感到担忧。
虽然像 Kotlin, Java, C# 等这种规律性强的语言可以通过**静态分析**工具（比如 IntelliJ 或者 Rider ）
在编译前就完成复杂的检查，
但是像 Ruby 这种动态元编程能力吊炸天的语言就不好办了。因此 RubyMine 也被迫『静态分析基本不报错』。

所以 Ruby 这种东西啊，对动态的测试具有很强的依赖性。
测试就是开发者编写一段可执行的代码，调用自己写的『被测试』代码，然后进行一些输入，然后获取输出检验正确性。
因为只有开发者知道自己想干嘛， IDE 只知道代码结构。你的代码的语法错误 IDE 可以帮你纠正，
但是逻辑错误就只能靠单元测试了。

于是我最近写 JNI 的东西，也遇到了需要单元测试的需求。。所以就顺便说说 IntelliJ 的单元测试框架吧。

本例使用 JUnit4 ，当然 IDEA 也支持 TestNG-J ，在 IDE 中的操作都是一样的。

## 首先你需要包（非必须）

IDEA 安装目录的 lib 子目录下有一大堆 jar ，这里先导入两个：

+ junit-4.12.jar
+ hamcrest-core-1.3.jar

这两个都是必须的，第一个是 JUnit 本体，第二个是 JUnit 的依赖。想当年我只导入了 junit-4.12.jar ，
编译报错了半天。。。

从 IDEA 安装目录下导入 jar 比官网下包方便多了对吧。

我是建议读者自行导包的，如果你是一个懒人那么可以跳过这一步。

## 然后你需要写测试

比如说你现在有一个类，名叫 BoyNextDoor 。

没导入类库的同学请看这里：

然后你把光标移动到类名处， <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>T</kbd> ，选择 Create New Test 。
当然如果你只需要测试一个方法，那就在方法名上面 Create New Test 。

现在我在学校，垃圾电脑没有截图工具，我就上代码了。

```java
public final class BoyNextDoor {
  public String ohThatsGood() {
    System.out.println("美国的华莱士");
    return "美国的华莱士";
  }
}
```

然后 IDEA 会弹出一个窗口，最上面的 Testing library 选 JUnit4 。如果它提示你 JUnit library not found 啥的，
你就点 Fix ，然后有一个选项是 use library from IntelliJ IDEA distribution 。选它就好了。

好了，手动导入类库的同学可以继续看了。

然后你把创建出来的类放在 test 目录里面。至于如何创建一个 test 目录请参考我上一篇博客。

```java
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class BoyNextDoorTest {
  @Test
  public void ohThatsGoodTest() {
    BoyNextDoor door = new BoyNextDoor();
    assertEquals("美国的华莱士", door.ohThatsGood());
  }
}
```

首先可以看到，类名左边有一个双重三角形，点它将会运行这个类里面所有含有 `@Test` 这个 annotation 的方法。
当然每个以 `@Test` 修饰的方法左边也有一个单三角形。
点它就可以执行这个方法。这就是在 IDEA 里面运行测试代码的方法。

然后 JUnit4 为你提供了一些测试的 utilities ，比如各种 `assertEquals`, `assertArrayEquals` 等，
你可以根据方法名推断他们的作用。
这些 static 的方法一般情况下都是 `import static` 的，就像上面的代码那样。这就是 JUnit4 的基本用法了。

同样的方法对于 Kotlin ， Scala ， Groovy 等语言的代码都是有效的。是不是很劲。

## 然后还能干什么呢

比如我这种测试 JNI 的。需要执行一次 `System.loadLibrary("jni")`，当然你又不需要在每个测试方法中执行，
只需要在每次测试的刚开始执行。
也就是说，你需要进行一些全局性质的初始化。

那么，请创建一个 `static` 的方法，使用 `@BeforeClass` 修饰。就可以自动跑了。

```java
import org.junit.BeforeClass;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class BoyNextDoorTest {
  @BeforeClass
  public static void init() {
    System.loadLibrary("jni");
  }

  @Test
  public void ohThatsGoodTest() {
    BoyNextDoor door = new BoyNextDoor();
    assertEquals("美国的华莱士", door.ohThatsGood());
  }
}
```

顺便炫耀一下我的测试全过的截图：<br/>
![test all passed](https://coding.net/u/ice1000/p/Images/git/raw/master/test1.png)

顺便贴一段我的算法库的测试，作为参考：

```kotlin
package org.ice1000.bit

import org.ice1000.math.MathUtils
import org.ice1000.test.loop
import org.junit.Assert.assertEquals
import org.junit.BeforeClass
import org.junit.Test
import java.util.*

class IntervalUpdateIntervalQueryTest {

  /**
   * http://www.codevs.cn/problem/1082/
   */
  @Test
  fun test() {
    val bit = IntervalUpdateIntervalQuery(3, 1, 2, 3, 2)
    bit.update(2, 3, 2)
    assertEquals(9, bit.query(2, 3))
  }

  @Test(timeout = 1000)
  fun strongTest() {
    val max = 300
    val bruteForce = BruteForce(max)
    val bit = IntervalUpdateIntervalQuery(max)
    val rand = Random(System.currentTimeMillis())
    loop(1000) {
      loop(10) {
        var num1 = MathUtils.abs(rand.nextInt(max) - 2) + 2
        var num2 = MathUtils.abs(rand.nextInt(max) - 2) + 2
        if (num2 < num1) {
          val tmp = num1
          num1 = num2
          num2 = tmp
        }
        val value = rand.nextLong()
        bruteForce.update(num1, num2, value)
        bit.update(num1, num2, value)
      }
      loop(100) {
        var num1 = MathUtils.abs(rand.nextInt(max) - 2) + 2
        var num2 = MathUtils.abs(rand.nextInt(max) - 2) + 2
        if (num2 < num1) {
          val tmp = num1
          num1 = num2
          num2 = tmp
        }
        assertEquals(bruteForce.query(num1, num2), bit.query(num1, num2))
      }

    }
  }

  /**
   * brute force implementation of binary indexed tree.
   */
  private inner class BruteForce(length: Int) {
    private val data = LongArray(length)

    fun update(from: Int, to: Int, value: Long) {
      (from..to).forEach { i -> data[i] += value }
    }

    fun query(from: Int, to: Int): Long {
      var ret = 0L
      (from..to).forEach { i -> ret += data[i] }
      return ret
    }
  }

  companion object Initializer {
    @BeforeClass
    @JvmStatic
    fun loadJniLibrary() {
      System.loadLibrary("jni")
    }
  }
}

```

祝你测试愉快。
