---
layout: post
title: 龙书撞枪系列 1 ： Lice 的动态作用域实现
category: Lisp
tags: Lisp
keywords: Lisp,Kotlin,Lice
description: lice' dynamic scoping implementation
---


## 关于龙书提到的一种作用域优化的具体实现

本文基于我自己实现的 Lisp——Lice ，源码可以在[GitHub](https://github.com/ice1000/lice)上找到。

### 为什么基于我自己实现的 Lisp

+ 我在实现了一个 Lisp 后又大致了解了下 Clojure、Scheme、Racket、EmacsLisp、CommonLisp 等常用 Lisp ，使用他们写了一些小程序
（比如最大公约数啊，斐波那契啊，还有集合框架、并行框架的使用）发现他们都已经上升到一个境界了，我怕是不能搞得很清楚。
+ 我对自己实现的 Lisp 非常了解
+ 我自己实现的 Lisp 非常简单
+ 我觉得我应该去学习开源哥的 LoLi

### 只有作用域优化吗

+ 起高哟，我还有一些其它的和龙书里面提到的不同的实现思路
+ 只不过这篇文章暂时只讲作用域优化

### 为什么主流语言不这样优化

+ 似乎这样优化后只能 dynamic scoping
+ 优秀的语言都是 lexical scoping
+ 我不优秀

### 正文

前段时间想学习编译原理，准备和[@lfkdsk](https://github.com/lfkdsk)一样走风骚路线（就是先不学习相关知识，凭感觉撸一个解释器出来），
于是就花了两星期的晚自习时间翘课到社团活动教室（我可是把作业做完了的）去撸了个 Lisp 的解释器，从只支持全局变量到可以有函数局部参数。

现在开始慢慢啃龙书（没错，我专门来趟浑水的，偏不听老人言（也没网上说的那么难啊（主要之前有人在吹龙书的不友好），难道是因为难点在后面）），
发现自己也命中了不少知识点，而且最令我高兴的是，我花了两节英语课想出来的高效低成本处理作用域的方法（还被老师当成是睡觉，我冤枉啊）
居然在龙书上就有提及（目前我只看到它提了一下，没有展开讲解），被称为是『作用域的优化』。也就是说我重新发明了轮子；

还有一个就是使用 int （地址）代替字符串（名字）查询，可以把哈希表的访问时间成本在编译期解决掉，然后运行时就不管了。这种方法在龙书上也提到了，
但是因为我实现的语言是解释性的，也就是说把编译（就是解析成语法树的过程，我也不知道这么说准不准确）和运行分的太开了也没啥卵用，
编译的时间和运行的时间是一体的。我也想过搞成字节码，然后自己写虚拟机运行它（这样可以在编译成字节码的时候进行一些作用域啥的处理），
后来想了想时间成本，还是放弃了。

现在的 Lice 还是有一些缺陷，比如它会遇到这种问题：

```lisp
Lice > (+(+ 1 2) 3)
undefined function: (+
at line: 1

Lice > (+ (+ 1 2) 3)
6 => java.lang.Integer
```

不过我觉得这不是事，可以称之为 feature （不服啪♂我啊）。

话先说在前面， Lice 是 dynamic scoping。这看起来很不靠谱，但是起码能做到对递归的支持，比如说我有一个递归求斐波那契数列的函数：

```lisp
; 定义
(def fib n (if
  (in? (list 1 2) n)
  1
  (+ (fib (- n 1)) (fib (- n 2)))))

; 然后在 repl 里面调用
Lice > (for-each i (.. 1 15) (print (fib i) " "))
1 1 2 3 5 8 13 21 34 55 89 144 233 377 610   => java.lang.String
```

其实想这个问题是因为我在处理 Lice 的作用域的时候遇到了一个问题：

+ 每层代码块嵌套都得新建一个 Env 对象
+ 每次调用变量得从这个 Env 树从底层递归（其实更像一个栈）往外面找变量
+ 显然每个 Env 里面都有一个哈希表，那么内存占用呵呵，而且经常是一个哈希表只插入了几个键值对
+ 如果你不用哈希表而是使用 List+遍历查找，那么变量一多呵呵

尤其是哈希表那一条，稍有常识的人都能知道，哈希表这种空间换时间的数据结构优势在于数据量大的场合，一个程序可能会有很多很多变量，
但是一个作用域内（比如一个方法体内部）能定义多少？你专门为此开个哈希是不是有点浪费了？

但是又有那么一些情况是需要较多变量的，这时如果你使用 List+遍历查找来存变量，也会变得很慢。

以上有可能是因为我的心理作用，毕竟 OI 后遗症，而且它确实是个问题啊，
我怎么看都觉得这样写很搓（尤其是因为我一开始只想到了这个方法，我执着地认为一定有更好的）。

也就是说，现在的问题是，我需要一个既节省空间（比如减少 Env 对象的数量）又能保证高效查询（就不能遍历 List ）的方法。

我曾经在一节数学课上想到：可以在解析的时候做一个符号表，然后在解析的时候就处理作用域的问题，然后生成类似字节码的东西
（也就是说在解析的时候明确指定每一个『名字』所代表的变量在变量池里的地址。运行的时候就不需要寻址了，再怎么查询也是一个 int 的查询而不是 String 了）。
这其实就是上面提到的使用 int （地址）代替字符串（名字）查询。

后来我尝试去写，发现写不出来（解析的时候还是需要那么多个哈希）。

我又在一节语文课上想到：可以只整一个全局符号表，不过符号表的值（键值对的值）是一个栈，进入作用域就往里面塞对象，覆盖的时候就再塞，离开作用域就弹。
后来想去实现，发现我需要创建大量的栈对象，每个栈对象都是 Vector 的子类（开销啊开销， Vector 的访问还带了锁的），我写着又觉得不舒服。
虽然这是可行的（比创建大量的哈希好，时间也节约了（但是需要对象数量+1 个栈（算上 JVM 的函数调用栈）））。

和学姐讨论这个问题的时候她也是这么说的，但是我当时已经有谱了：

最后我想到的解决方案是：

0. 你首先需要**一个**（注意只要一个）符号表，称之为全局符号表
0. 每次进入一个新的作用域，需要在头部进行值绑定的声明（就是标准的 Lisp 的 let 块， Racket 和 Scheme 都有，或者直接写 lambda 块）
0. 声明后，我拿到这堆声明，然后先对全局符号表中的这几个值绑定的名字进行备份（比如我在这个作用域声明了 a ，那么先备份全局符号表中既有的 a ）
0. 把全局符号表里面的值进行重新绑定
0. eval 这个作用域的块
0. 把之前备份的变量重新绑回去，作用域内的变量就离开作用域，被 replace 回去。
0. JVM 会 GC 掉这部分内存（不知道会不会）
0. 程序继续下去

是不是很有意思呢。。。

它的优点：

+ 节约空间（只有一个哈希）
+ 查询时间开销小（哈希的查询，没有之前说的大量的栈，只有 JVM 的函数调用栈）
+ 全局符号表方便调试（你只需要盯着一个 HashMap 看）

我觉得这是极好的，于是给 Lice 实现了这样的作用域（用于处理函数、递归什么的），然后成功地实现了带参数的函数定义。

然后成功地递归了（我测试递归时写了阶乘和斐波那契，都能正常求值）。

我非常兴奋，于是又去写了[两个工具](../../../../2017/03/07/LiceTools.html)，然后就去读龙书了。

然后我看到了这个：

![car crash with dragon book](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/2/1.jpg)

完美的撞车。。。龙书使用更精简的语言描述了我对作用域的处理方式，而且完全一样。

龙书把我的方法称为『块作用域的**优化**』，这让我很是高兴，因为我自己脑补出了别人所认为是『优化』的方法 ：）

但是这样写的话会有这个问题，就是因为只有一个全局符号表，因此不能处理块中间的定义，只能处理头部的（也就是函数中只有参数是局部变量）。

还有一个问题，就是：

```lisp
(-> a 199)

(def get-a a)

(println a) ; 199

(def print-a a (println (get-a)))

(print-a 233) ; 233
```

如果是静态作用域的语言，```(print-a 233)```无论传入和值，因为```print-a```的行为已经在前面确定了，所以最后一行输出应该是 199 才对。

但是这其实是一种合法的表现（ dynamic scoping 似乎都是这样的），
我在[灰灰简书一篇文章](http://www.jianshu.com/p/cdebb5965000)里看到了关于这两者的定义。龙书其实也有：

![dragon book talks about scoping](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/2/2.jpg)

但是我还有一个费解的地方，就是我问灰灰：

> lexical scoping 是不是编译的时候解析每个 identifier 所指代的变量，然后事先区分好

灰灰说不是，我觉得比较费解嗯。。等我解决了再写篇文章。

**好了那么这就是关于 Lice 作用域的实现，本文结束。**

> Talk is cheap...

打住，我马上贴代码，对不起（ Tab 死忠粉向空格势力屈服了， Markdown 渲染器总是把 Tab 渲染成 8 空格，真是傻逼）。

```kotlin
  defineFunction("def", { ln, ls ->
    val name = (ls[0] as SymbolNode).name
    val body = ls.last()
    val params = ls
        .subList(1, ls.size - 1)
        .map {
          when (it) {
            is SymbolNode -> it.name
            else -> typeMisMatch("Symbol", it.eval(), ln)
          }
        }
    defineFunction(name, { ln, args ->
      val backup = params.map { getVariable(it) }
      if (args.size != params.size)
        numberOfArgumentNotMatch(params.size, args.size, ln)
      args.forEachIndexed { index, node ->
        setVariable(params[index], ValueNode(node.eval().o ?: Nullptr))
      }
      val ret = ValueNode(body.eval().o ?: Nullptr, ln)
      backup.forEachIndexed { index, node ->
        if (node != null)
          setVariable(params[index], node)
      }
      ret
    })
    getNullNode(ln)
  })
```

很短对不对！

## 2017 6 月更新

现在的 Lice 步入 3.X 阶段，开始引入三种求值模型（ call by name, call by need, call by value ）的支持，也引入了 first class 的
Lambda ，更新了很多，编译器的 API 也成熟了，这是最新的代码：

```kotlin
@SinceKotlin("1.1")
typealias Mapper<T> = (T) -> T

private var lambdaNameCounter = -100

internal fun lambdaNameGen() = "\t${++lambdaNameCounter}"

inline fun Any?.booleanValue() = this as? Boolean ?: (this != null)

val defFunc = { name: String, params: ParamList, block: Mapper<Node>, body: Node ->
  defineFunction(name, { ln, args ->
    val backup = params.map { getFunction(it) }
    if (args.size != params.size)
      numberOfArgumentNotMatch(params.size, args.size, ln)
    args
        .map(block)
        .forEachIndexed { index, obj ->
          if (obj is SymbolNode) defineFunction(params[index], obj.function())
          else defineFunction(params[index], { _, _ -> obj })
        }
    val ret = ValueNode(body.eval().o ?: Nullptr, ln)
    backup.forEachIndexed { index, node ->
      if (node != null) defineFunction(params[index], node)
      else removeFunction(params[index])
    }
    ret
  })
}
val definer = { funName: String, block: Mapper<Node> ->
  defineFunction(funName, { meta, ls ->
    if (ls.size < 2) tooFewArgument(2, ls.size, meta)
    val name = (ls.first() as SymbolNode).name
    val body = ls.last()
    val params = ls
        .subList(1, ls.size - 1)
        .map { (it as? SymbolNode)?.name ?: InterpretException.notSymbol(meta) }
    val override = isFunctionDefined(name)
    defFunc(name, params, block, body)
    return@defineFunction ValueNode(DefineResult(
        "${if (override) "overridden" else "defined"}: $name"))
  })
}
definer("def", { node -> ValueNode(node.eval().o ?: Nullptr) })
definer("deflazy", { node -> LazyValueNode({ node.eval() }) })
definer("defexpr", { it })
val lambdaDefiner = { funName: String, mapper: Mapper<Node> ->
  defineFunction(funName, { meta, ls ->
    if (ls.isEmpty()) tooFewArgument(1, ls.size, meta)
    val body = ls.last()
    val params = ls
        .subList(0, ls.size - 1)
        .map { (it as? SymbolNode)?.name ?: typeMisMatch("Symbol", it.eval(), meta) }
    val name = lambdaNameGen()
    defFunc(name, params, mapper, body)
    SymbolNode(this, name, meta)
  })
}
lambdaDefiner("lambda", { node -> ValueNode(node.eval().o ?: Nullptr) })
lambdaDefiner("lazy", { node -> LazyValueNode({ node.eval() }) })
lambdaDefiner("expr", { it })
```

怎么样，漂亮不 （并不

## 真·结束

下期讲值类型的隐式转换在解释性语言里的实现问题。