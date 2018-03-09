---
layout: post  
title: 多线程快排测试 CPU 性能
category: OI
tags: Misc, NOIP
keywords: NOIP, OI
description: Multi-threading quick sort
---

今天随手撸了个小玩具，算是让我见识了一下 AMD RyZen 那改天换地的强大力量。

想必大家都知道快排，就是快速排序嘛，一种基于分治法的排序。这东西有很多种方法可以优化，比如随机化，比如按位拆分等各种很牛逼的方法。
*算导*曾经说过，

> 当序列长度小于 k 时就不进行处理，排序出来的当然是一个『非常接近有序的序列』，最后对这个序列来一波插入排序。

这是极骚的。

我在简书看到[一篇文章](http://www.jianshu.com/p/6777a3297e36)专门讲快排优化，放在这里提供参考。感兴趣的读者可以对这个链接进行一次 dfs。

而且，它是可以多线程进行的，每次分治都开一个新的线程去执行，
这样最终就能实现每一步都是同时计算的，可以达到更快的速度（）。

我尝试手撸了一个之后发现并不能跑，并行这种东西是很傲娇的，按理说是要上锁的，或者 `wait` 线程。
但是我已经不想折腾这些了，而且我的打算是把它弄进之前那个算法库的，所以说我应该使用 Java 写。

但是，我已经太久没接触 Java 了（逃

所以说我还是股沟了一下，找到了[这篇文章](https://www.oschina.net/code/snippet_145230_44938)。

里面有一个 2014 年的大龄程序员手撸的并行快排。感谢这位程序员。根据原文的说法，

> Java 多线程 快速排序 1 亿数据 3.5 秒 <br/>
写了个 Fork/Join 的，但好像并没有更快。

然后我把代码抄下来（这正是我等垃圾程序员的职责所在啊），在自己的笔记本上跑了一波， 1716ms。
这次运行我没有保留截图，因为下面有更精彩的。

我把运行脚本和 JRE 环境打包发给了我的朋友 psc ，他是拥有**AMD RyZen 1700X**的男人！

这是我们在原本的数据范围时的运行结果对比：

+ 我的：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/4.png)

+ 他的：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/3.jpg)

然后他把开线程的阈值减小了之后，发来如下运行截图：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/0.png)

卧槽吓尿了。

然后 psc 说，整数排序太垃圾了，上浮点吧。

于是我改了代码（ `double` 占内存，要用 `float` ），直接添加到压缩文件，手写 Manifest.MF ，又打包了一个。这里我把这个 jar 上传了，
[点击这里](https://coding.net/u/ice1000/p/Images/git/raw/master/run.jar)可以下载。

运行时，请先确保将 JRE 的 bin 目录添加到环境变量（也就是说可以直接在命令行调用 java 命令），
然后在通过以上链接下载的**run.jar**文件所在的目录下执行以下命令：

```shell
java -jar run.jar 30 120000000 -Xmx11550m -Xmn2000m
```

我发现由于内存限制，数据量已经不能再大了，于是我就把程序循环了十遍。
[最终的代码](https://github.com/ice1000/algo4j/blob/master/src/main/java/org/algo4j/util/ParallelQuickSorters.java)我已经挂在 GitHub 上啦。

### 本机运行效果

这是任务管理器里 CPU 的状态，可以明显地看到那十次执行时 CPU 占用率的提高：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/1.png)

多线程运行时控制台的输出，可以看到每次排序所用的时间：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/2.jpg)

为了检验多线程的效果，我又把开线程的阀值设的和数据量一样大，这样程序就是单线程的了。
效果如下：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/2.png)

说明多线程还是有用的。

我把这个小程序发到少女编程团。

### 其他人的测试

有一位同学的运行效果如下：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/3.png)

平均来说比我慢了一秒，这已经是非常好的成绩了。

CPU 占用：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/6.png)

### i7 6700HQ 的测试

还有一位拥有**i7 6700HQ**的男人，他也运行了那个小程序，比我不知道高到哪里去了：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/5.png)

然后我把这个程序发给了 psc 同学。。。

<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>

前方高能！

<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>

### AMD RyZen 1700X 的测试

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/1.jpg)

<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>

没错，这就是 RyZen ，是 6700HQ 的两倍。

> 来自 AMD 用户的嘲讽：<br/>
![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/9/7.png)



