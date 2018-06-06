---
layout: post
title: 代码编辑器系列 &num;2 文本的存储 远古篇
category: Editor
tags: Kotlin
keywords: Kotlin, Code Editor
description: Text Editor series &num;2 how are text stored and managed
---

在[上一篇文章](../../../04/29/CodeEditor2/)中我介绍了提到了两种代码编辑器—— LSP 式和 JB 式的区别，并表明以后的文章会是关于 JB 式的编辑器的。
那么这篇文章先说点别的吧。
我自己的实验项目里是直接使用 Java 的 `StringBuilder` 作为文本存储工具的（由于 Swing 的 API 看起来更低效，所以我直接在这个地方弃疗了），
因为 Java 的 `String` 是 immutable 的，对大规模的读写、插入删除、拼接拆分非常不友好，
于是我就使用了相对高效的、使用数组作为 buffer 的 `StringBuilder`（至少比拿 `String` 拼来拆去好一些）。

`StringBuilder` 应该是众多支持简单插入删除的字符串存储数据结构中最蠢的了（和 `ArrayList<Character>` 差不多），
这里用只是因为这并不是当时写编辑器时关心的重点。

这个东西学问非常大，这里就先聊聊远古编辑器 Vim 和 Emacs 各自所使用的字符串存储数据结构吧。

## Emacs

Emacs 使用的数据结构相当简单，叫做『[gap buffer](https://en.wikipedia.org/wiki/Gap_buffer)』。

这种数据结构的优点有很多，显而易见的是它的简单性（易于实现），以及针对小文件的性能很不错（是 piece table 的论文说的，其实我不太明白为什么）。<br/>
它的缺点也很明显，遇到大文件的时候非常崩溃，以及难以应付大规模的插入删除（比如删除或者粘贴大段文本），并且对惰性地、部分地读写文件非常不友好。

它的实现有很多，比如 [Flexichain](https://www.common-lisp.net/project/flexichain/download/StrandhVilleneuveMoore.pdf)
（04 年的论文，比较简单，至少我感觉读下来没太多收获，不过列举了不少编辑器的实现，还算可以）.

### 简易实现

举个例子，比如我们有这么一个字符串 `Hi, world!`，然后光标在 `,` 前面，用 IntelliJ 的测试框架的数据集表示方法的话就是 `Hi<cursor>, world!`。<br/>
gap buffer 会先创建一个这样的数组（假定 gap 的长度是 4 且只有一个（事实上可能有不少这种 gap），`\xx` 表示 ASCII 码为 16 进制数 `xx` 的字符）：

```
[0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [a] [b] [c] [d]
'H' 'i' \00 \00 \00 \00 ',' ' ' 'w' 'o' 'r' 'l' 'd' '!'
```

然后当用户删除一个字符后，变成这样：

```
[0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [a] [b] [c] [d]
'H' \00 \00 \00 \00 \00 ',' ' ' 'w' 'o' 'r' 'l' 'd' '!'
```

然后用户输入 `ello`，变成这样：

```
[0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [a] [b] [c] [d]
'H' 'e' 'l' 'l' 'o' \00 ',' ' ' 'w' 'o' 'r' 'l' 'd' '!'
```

然后用户右移了一下光标，变成这样：

```
[0] [1] [2] [3] [4] [5] [6] [7] [8] [9] [a] [b] [c] [d]
'H' 'e' 'l' 'l' 'o' ',' \00 ' ' 'w' 'o' 'r' 'l' 'd' '!'
```

大概就是这样了，如果遇到 buffer 满了的情况就需要重新分配内存然后复制数据，所以面对大文件就比较蛋疼了。

我们用这种方式表示整个编辑流程：

```
Hi<cursor>[    ], world!
H<cursor>[     ], world!
Hello<cursor>[ ], world!
Hello,<cursor>[ ] world!
```

### Variations

有个我觉得很可取的做法，来自 Hemlock 编辑器（[论文](http://repository.cmu.edu/cgi/viewcontent.cgi?article=2861&context=compsci)， 1989 的）。

它把文本按行分成一个链表，光标所在的那一行是 gap buffer ，其他行是直接存的字符串。
它很明显可以有效缓解巨大的、每行其实不怎么长的文本的编辑时的内存和时间开销，
但单行大文件依然无解，不过这是个比较少见的情况，因此它还是能解决一些问题的。

顺带一提，这个 30 年前的文本编辑器有一股挺浓的 Emacs 的味道，不知道是谁先来的，反正已经变成这样了。

## Vim

Vim 使用的数据结构相对 Emacs 要复杂一些，但是对于 OI/ACM 选手来说依然是小儿科。
名字叫做『[rope](https://en.wikipedia.org/wiki/Rope_(computer_science))』，又名『cord』，本质就是对字符串特化的平衡树
（应该和具体哪种平衡树没关系，论文里说的是 Splay，但我感觉其他的平衡树也可以做到一样的效果）。

[论文](http://citeseer.ist.psu.edu/viewdoc/download?doi=10.1.1.14.9450&rep=rep1&type=pdf)是 1995 年的，比 Flexichain 那个还老，
有伪代码实现和一个比较严谨的 benchmark ，算是一些有趣的内容。<br/>
里面提到了不少现在已经是历史的眼泪的编程语言，
比如活跃于 60 年代、已经被 90 年代的 Python、Ruby 之流取代的已经被 70 年代的 Perl、AWK 之流取代的 Cedar 编程语言和 SNOBOL 编程语言（这个似乎还有好几代）。

### 简易实现

由于它真的就只是对字符串特化的平衡树，所以插入删除查询之类的操作就不讲了（我觉得你们应该都会写平衡树），
这里讨论一下它对最小粒度的字符串的抽象。

由于这个平衡树是对字符串特化的而不是对字符特化（不然就是 `BalancedTree<Character>` 了，就没意思了）的，它在处理不同量级的、不同来源
（来自文件（中等成本读写）、内存（低成本读写）、网络（极高成本读写）、压缩文件（较高成本读写））的文本的时候可以使用不同的『字符串』。

这里的字符串是个抽象概念，它可以是：

+ 一个 `std::string` 或者 `java.lang.String` 这类东西的实例
+ 一个返回上述实例的函数，比如惰性的字符串，或者文件解压的 callback
+ 另一种对这一小段文本更适合的字符串存取数据结构的实例

所以这个平衡树其实可以只作为一个上层抽象，然后把细粒度的字符串用其他更优的数据结构表示出来。

### Benchmark

自己看论文去

## 更深层次的抽象

受 Rope 的启发我们可以想到，字符串并不一定需要是 `List<Character>`，我们应该视之为 `List<Item>`，然后这个 `Item` 应该可以有多种实现，
不仅仅是 `Character` 或者 `String`。

字符串也可以以惰性的形式存储，这种惰性的字符串也可以是一种 `Item`。这种抽象思路同样适用于 `gap buffer` 一类的数据结构。

再往上我们可以抽象文件的概念了——这个留到以后讲虚拟文件系统（IntelliJ Platform 的一个东西）的时候再讨论。
