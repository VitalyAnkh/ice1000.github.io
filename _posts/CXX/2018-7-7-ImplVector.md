---
layout: post
title: C++ 模拟 Java 风格的 Vector
category: CXX
tags: Essay, C++, C
keywords: C++
description: Implementing a C++ vector
---

众所周知，我，千里冰封，是个编程菜鸡，尤其不懂 C++。
不过呢，最近突然觉醒了一些奇怪的想法，开始使用 C++ 开发一些东西了。

由于我的本职工作，或者说，最熟悉的生态系统是 Java/Kotlin 那边的，次一个等级的话应该是 Haskell/Agda/Perl （是因为最近真的没有用别的语言在编程），这些都属于自带 GC 的邪恶编程语言，我对 Java 风格的容器非常的习惯。<br/>
举个例子，下面的代码就应该是正确的：

```java
static void a(List<Object> list) {
  list.forEach(System.out::println);
}

public static void main(String... args) {
  List<String> l = new ArrayList<>();
  l.add("Oh yeah");
  l.add("Take it boy");
  l.add("Thank you sir");
  a(l);
}
```

完全一样（假设把 `List` 换成 `std::vector`）的代码，放在 C++ 里面虽然也多半可以运行，
但由于 C++ 的 `new` 是分配堆上内存，需要手动释放，否则会造成内存泄漏，因此还需要再加上一句 `delete l`。

我承认我很不擅长手动管理内存（毕竟常年使用带 GC 的语言），所以我更倾向于分配栈上内存然后将对象进行传值调用（call-by-value），如果有更改对象的需求就使用传引用调用（call-by-reference），没有`new` 过，也没有用过指针。<br/>
再者，在使用 [imgui](https://github.com/ocornut/imgui) 的时候，看到他吐槽 msvc 带的 `std::vector`（说它在 debug 模式下慢得搞笑），让我进一步对使用 STL 产生抗拒感（代码经过了一些格式化，便于阅读）:

```cpp
// Helper: Lightweight std::vector<> like class to avoid dragging dependencies
// (also: Windows implementation of STL with debug enabled is absurdly slow,
// so let's bypass it so our code runs fast in debug).
// *Important* Our implementation does NOT call C++ constructors/destructors.
// This is intentional, we do not require it but you have to be mindful of that.
// Do _not_ use this class as a std::vector replacement in your code!
template<typename T>
class ImVector
```

其实我根本没看懂他说的

> Our implementation does NOT call C++ constructors/destructors

也直接无视了他说的

> Do _not_ use this class as a `std::vector` replacement in your code!

但是还是就兴冲冲地开始在自己的代码里面使用 `ImVector` 代替 `std::vector`
（好孩子不要在家里模仿），并且直接把对象存进去（而不是指针）。

然后我发现我其实需要引用语义的容器，因为我偶尔需要取出容器里面的值，在外部改变并塞回去；
同一个对象放在多个容器里的需求也十分常见。
这样的需求，使用 `memcpy` 复制内存的 `ImVector` 肯定是无法满足的——至少我不能直接在里面存对象了。

于是在[锤哥](https://github.com/ICEYSELF)（ICEY, ICEYSELF, 冰霜之锤）的教导下，我把『存对象实体』改成了存对象『指针』，然后在 `main` 函数里分配栈上对象并把栈上对象的指针传给 `ImVector`。

这在一开始工作良好，但后来我又遇到了更复杂的需求——我需要在 `main` 之外的函数中创建对象，然后放进 `ImVector`。这样我就不能依赖栈上对象的自动回收功能了！我依然可以 `new` 一些对象进去，但我什么时候 `delete` 呢？

我觉得可能我需要手写一个小 GC 了，因为在我的印象中，C++ 程序员写大项目都比较流行用引用计数指针，
比如[夏幻](https://github.com/akemimadoka)聚聚的 [NatsuLang](https://github.com/NatsuLang/NatsuLang)，
作为全世界最好的语言的唯一编译器实现，就在大量使用引用计数指针。
然后我就去向锤哥求教，很不要脸地说『我不想用 STL，但是想要一个引用计数指针。』
锤哥说，『你要的话我马上给你写一个。』于是锤哥就给我写了一个引用计数指针 ~~（神说要有光，于是神就写了一个光）~~。

有了引用计数指针，我就可以放心地在子函数 `new` 一个对象，返回给主函数，然后等它自己 `delete` 了。
为了简单地实践引用计数指针的用法，我写了一个在析构函数里 `printf` 的 test，和期望的运行结果一致，这让我高兴地像个孩子。

根据我的理解，引用计数指针的工作原理就是先接受一个 `new` 出来的指针，
把这个指针和一个 `size_t` 存起来（这个 `size_t` 只要能存下最大函数调用栈数那么大的整数就可以了），
在拷贝构造器里面把这个 `size_t` 自增，然后在析构函数里自减。
也就是说，在传递函数参数的时候，会追踪当前传出去的指针数量，函数结束的时候就让计数器自减，等最后一个指针被析构的时候，同时析构当前指向的对象。

在没有交叉引用的时候，引用计数可以说是很好的 GC 工具了。
于是我开开心心地把 `ImVector<T *>` 改成了 `ImVector<rc_ptr<T>>`，然后继续写业务逻辑。

**然后我的代码又炸了**。

为什么这次还炸呢？为什么我在这个怎么可能完全不可能有交叉引用的场景用了引用计数指针后出现了内存错误？
我很不明白，于是去向锤哥求助。
锤哥看了下 `ImVector` 的实现，向我指出了 `ImVector` 的内存拷贝实现和开头的注释——其实就是我太菜了，无视了 `ImVector` 自己已经说明白了的坑（也可以说是我误解了 `ImVector`），
导致了这么多一系列问题。

如果我用 `std::vector`，就没有问题。

事情是这样的。在现代面向对象编程语言中，一般的『类』都有『构造函数』这一概念，即伴随实例的内存分配的一个初始化函数。
也就是说，我要创建一个对象，就需要进行两个步骤：

0. 从栈或者堆上抠一片内存下来
0. 调用构造函数

以及，特别地，在 C++ 中，有『析构函数』的概念，是和『构造函数』对应的伴随实例的内存释放的一个资源释放函数。
也就是说，我要销毁一个对象，就需要进行两个步骤：

0. 调用析构函数
0. 把内存还给栈或者堆

在 Java 里面，原本 `java.lang.Object` 的 `finalize` 方法就是充当析构函数的作用的。
但是由于 Java 是使用 GC 的语言，对象的回收时间具有不稳定性，如果 `finalize`
需要进行高耗时操作的话会卡住整个 JVM，在并发场景下尤其致命（而在 C++ 里就不会致命，因为 C++ 没有 GC），所以已经不推荐使用了，而是推荐使用手动调用 `close` 的 `java.lang.AutoCloseable`。

然后我们来看看要怎么实现一个 `Vector`。

`Vector` 需要管理成员的内存，于是和普通的对象的内存分配释放就不一样了。<br/>
为了提高 `push_back` 的性能，它需要减少内存分配的次数，
于是就需要提前为以后的对象预留一些内存（这个道理相信大家都懂，实现过一个 naive 的 `Vector` 就知道了），
一般的做法是『如果预留的内存满了就再分配现在长度 1.5 倍的内存，再把当前的对象拷贝过去，释放原来的』。
1.5 这个数字我在很多地方都看到过，比如 JetBrains 自己的 `XxxStack` 里就是 1.5 倍，
Emacs 的 Flexichain 论文也是写的 1.5 倍。

然而创建对象不仅需要分配内存，还需要调用构造函数，
在销毁对象的时候也不能简单地释放内存，还需要调用他们的析构函数。
这样才能正确地构造、释放每个成员。
尤其是引用计数指针这种在构造函数和析构函数里做了一些相当关键的手脚的东西，
必须正确调用它们的构造函数才行。

`ImVector` 的问题在于它没有调用你的构造函数和析构函数——它把你的所有成员都当成值语义的对象来看待，直接使用 `memcpy` 复制成员的内存。
因此，它不能和引用计数指针愉快地玩耍。

正确且高效的 `Vector`，需要把对象的内存分配和构造函数的调用分开。
内存肯定是提前分配的，在添加对象的时候要调用它们的拷贝构造函数，
以及在自己析构的时候要调用每个成员的析构函数。

有的时候我们不希望调用拷贝构造函数而是直接在 `Vector` 分配好的内存里就地构造以减少一次内存分配。
`std::vector` 因此搞了一个单独的 `push_back` 特殊版叫 `emplace_back`，就是转发构造器的所有参数然后就地构造成员的。

之所以 Java 没有这个问题，是因为 Java 有 GC，已经从根本上解决了 C++ 借助构造函数和析构函数解决的问题，所以大家一开始就开开心心地用 `java,util.ArrayList`，没有这些烦恼。

我把锤哥的实现放在[这里](/gist/vector/)了，欢迎大家去膜。
