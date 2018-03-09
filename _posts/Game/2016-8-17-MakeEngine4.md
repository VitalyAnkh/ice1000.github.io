---
layout: post
title: 轮子狂魔造引擎 第四章
category: Game
tags: Java, Game, Engine
keywords: Java,Game,Engine
description: make a game engine chapter 4
---

这几天要么刷题，要么写引擎，要么写文章，都没怎么说好玩的事，这期我来讲讲我开发引擎过程中遇到的二三事吧。

比较杂乱，想到哪写到哪，主要娱乐向。

## 第一件事

首先我在第三篇中已经提到了，作为一个 OIer 我也遵循膜蛤的传统。昨天为了庆祝长者的生日，我使用新引入的粒子系统做了一个膜蛤向的游戏。截图如下，当时写出来的时候只有 69 行，一样的很少，不禁为自己的引擎的神奇感到惊叹。（又厚颜无耻地在表扬自己了）

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/game/4/1.png)

这是通过 Windows 的截图工具截的图，是一个我随手画的图形射出我随手画的星星，击中了『长者の镜』会发出音效。音效是我从极乐净土前奏中剪出来的， wav 格式，只有一秒左右。

然后我录下了整个开发过程，稍加剪辑、精简就发到 bilibili 上去了。然后我收到系统消息，说我的视频违反了基本法？还有**下次再犯就封号？**

WTF ！？手动黑人问号！？

我了个大槽，这什么 JB 东西？是要我粉转黑吗？

## 第二件事
OIer 日常膜蛤已经不是啥稀奇事， release 里面放毒：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/game/4/0.png)

然后有个看我文章的人下载了。。。

你看 GitHub 多开放，比 B 站不知道高到哪里去了。

## 第三件事
下文涉及比较复杂的 Kotlin 语言特性。

那就是我终于体会到了什么叫『对一种技术上瘾到走火入魔』的感受。曾经看到知乎上一个问题叫『玩 C++模板元编程到走火入魔是怎样的体验？』，看到了许多我这个不会写工程 C++的弱渣看不懂的代码。我只知道，那满屏的 template 就是这些吸毒者的罪恶之源。

真爱生命，远离模板。而且 OI 有句古话，『有了 STL ，妈妈再也不用担心我 TLE 了！』，毕竟 STL 里面有些本身可以 O(1)的算法经常为了内存上的优化而做成了 O(n)的， Java 的范型集合库也有这个问题，这多半就是那天我在一张图片里面广搜搜半天出不来结果的原因（长跪不起）。

那么我是又是玩什么走火入魔了呢？使用 Kotlin+anko 开发过 Android 的人，应该对这个东西不陌生吧：

```swift
async() {
  // Access network or database, or some bad stuff #(滑稽)
  uiThread {
    // Display data
  }
}
```

著名的 async 代码块，再也不需要那糟糕的 AsyncTask 了。而我也实现了这么一个代码块：

```swift
inline fun <T> T.async(crossinline block: T.() -> Unit): T {
  Thread({ block.invoke(this) }).start()
  return this
}
```

然后你在你的代码里面可以直接调用（这也是寒冰引擎截图功能的正确使用方式）：

```swift
async() {
  ImageIO.write(getScreenCut().image, "png", File("截屏" + cnt++ + ".png"));
}
```

然后我发现这太好玩了，于是专门在 utils 包下弄了个叫 kotlin 的包，里面专门放这种东西。因为 extension 只有在 Kotlin 中使用才会体现出它的方便，所以这些东西只支持 Kotlin。

我还把这段代码扔到了 gist 上面：
 
<script src="https://gist.github.com/ice1000/16d851883e0ac61f905cbb891d20a155.js"></script>

没错，压行的习惯是 OI 捡来的。

然后你们曾经在第二章看到过的那一段刷新主线程的代码，已经发生了翻天覆地的变化：

```swift
// Original 原来的样子
while (true) if (!paused && !stopped) {
  try {
    onRefresh()
  } catch (ignored: Exception) { }
  timeListeners.forEach { it.check() }
  panel.repaint()
  Thread.sleep((1000.0 / refreshPerSecond).toLong())
}

// Current 魔改版
loopIf({ !paused && !stopped && refresh.ended()}) {
  forceRun { onRefresh() }
  timeListeners.forEach { it.check() }
  panel.repaint()
}
```

数据库读写、音频播放什么的全部都被我下了毒。。。

## 第四件事
那就是我发现了发文章的时间对文章的赞同数是有影响的。

第一篇文章我是在晚上发的，当天晚上就来了 60 多个赞同。第二天早上我就把第二章发了，结果到现在也只有 13 个。
第三篇是当天中文发的（间隔时间也太短了吧。。），效果接近。

估计是因为晚上大家都在线，我一发文章，你们在时间线里面就看得到。所以我决定在晚上发这篇文章。嘿嘿。

说实话赞同数对于写文章的人来说是一种莫大的鼓励啊！

## 第五件事
我一直对 Java 的性能很不自信，以为 Java 卡， Java 慢，反正就是垃圾语言。所以我一开始给引擎固定的刷新率是 40fps
（我提供了 API 修改这个值），然后整个画面看起来有点卡，不过还行，起码看得过去。然后后来在和凯凯（ 3A ）聊天时，提到了 fps 这个东西。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/game/4/5.jpg)

凯凯是元火引擎的作者，元火是个 C++引擎。我发现 fps 原来都是几百上千的，于是也想试试，看看 Java （ Kotlin ）引擎性能怎么样。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/game/4/6.jpg)

然后我把这个调到了 1000fps ，发现毫无卡顿，如丝般顺滑。。我当时就被这个流畅的画面惊艳到了， Java 的渲染也没那么糟糕嘛。
看来无论什么事都得试试才行啊。

说实话我对 Java 的负面印象全是 C++吧吧务团队给我留下的，我曾经以 Java 厨的身份被他们集体吊打，
并且被打为『可见 Java 厨并不知道 Java 是什么，就厨了』，当时给我留下了很深的阴影（特大雾），让我再一次意识到自身的弱小。。

重拾自信！

## 第六件事
上期已经说过了，在 commit message 里面写 fuck JRuby ，被 JRuby 的开发者之一上门查水表，看到邮件吓得我一身冷汗。
这件事告诉我们不能在 commit message 里面乱写东西。不过人家还帮我解决了疑惑，让我受宠若惊。

另外，总感觉 JRuby 的人在盯着我。。

## 第七件事
读者们，这玩意挂在 GitHub 上，求各位客官给个 star ，或者把 release 弄下来写点小游戏呗。

随时欢迎各种 pull request ，各种 issue ，一定看得到！五天写了 6k+行代码，删了 2k+行代码，
还是在我是压行狂魔的基础上，我写这个一直乐在其中。但是没人用就很尴尬了，我的 wiki 写的挺详（ la ）细（ ji ），
最多遗漏一两个刚更新的 API。我的 README 也写的很诱（ wei ）人（ suo ），但是就是没人用啊，唉。。。。

## 顺带一提
寒冰引擎的截图略扯淡，虽然画面很流畅，但是截图出来的效果是这样的：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/game/4/2.png)

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/game/4/3.png)

谜之错位。更神奇的是，那个我吹了很多次的 65 行 Flappy bird ，我加了几行代码，让它在你死的时候截图，效果出来是这样的：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/old/game/4/4.png)

这个 bird 的力气真大，柱子都被你撞动了。当时看到图的时候真是戳笑点，哈哈。








