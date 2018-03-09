---
layout: post
title: LiceIntelliJ 插件图标制作过程
category: Kotlin
tags: Essay
keywords: Kotlin
description: IntelliJ Plugin Icon
---


这是只属于没有 Photoshop 的人的悲哀。

首先先大吼一声——

> 劳资终于做出了高清无码的 Lice 图标！

## 直接进入正题

其实我还是想说一下事情的发展过程的——

我想照着 IntelliJ IDEA 的图标风格做一个 Lice 插件的文件图标，于是就先各种找图标源。

本来可以去翻 IntelliJ Community 源码，后来直接在 IntelliJ 安装目录找到了这个文件。在:

```
安装目录/lib/icons.jar
```

里面，打开它，寻找 fileTypes 目录，里面有几乎所有文件格式对应的图标。JB 为每种文件提供了四个图标文件——

+ 16 x 16 png
+ 16 x 16 svg
+ 32 x 32 png
+ 32 x 32 svg

其中，我个人认为有用的，只有第零个。因为我运行插件之后，发现 IntelliJ 不会自动缩放文件图标（一开始我整了个长宽都是几百像素的图片，吓尿了，效果你们可以自己看，我就懒得复现再截图了）

## 所以现在可以进入正题了

为了保证清晰度，我找到了 CSS 文件对应的图标：

![CSS](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/5/css.png)

然后将它拖到一个[在线 SVG 编辑器](http://editor.method.ac)里面，开始魔改。中途花费了两个小时左右（我简直想死的心都有了，终于体会到 SuperSodaSea 做像素画的辛苦了），
然后撸出了一个能看的 svg 图标。这个图标放在插件仓库里面，由于目前插件还不能见人，感兴趣的就自己去翻我 commit 记录找，不是特别感兴趣的就先别忙看吧。

我将它转成 PNG 之后发现，~~尼玛这就是 AV 画质嘛。。~~啥都看不清楚啊！

我当时的内心就是崩溃的，做了这么久的 SVG （为什么花了那么久？因为调整透明度啊 颜色啊 字体啊 文字位置啊 改完了还得导出 SVG ，编辑一下 XML ，来手动控制一下那些元素的位置），居然没·有·用！

不要气馁，我们换个方法搞定它——做个 PNG 吧。于是我开始手动编辑 PNG ，过程极其痛苦。因为找不到可以进行像素级编辑的编辑器（真是太痛苦了），唯一一个可以进行像素级编辑的 Windows 自带的画图工具不支持透明度。

于是我回到了当年撸图的流水线——画图撸原型，然后光影魔术手进行透明度调整。然后整了半天，终于整出了这个效果：

![TEMP](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/5/lice.png)

我满心欢喜地打开 IntelliJ IDEA 插件工程，把文件拷过去，然后我看到了这一幕：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/5/0.png)
![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/5/1.png)

我突然发现，原版图标每个像素都是有一定透明度的，而我只是粗暴地将空白部分做成了透明的。

> 你永远不懂我伤悲，像白天不懂夜的黑 <br/> ![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/5/3.png)

然后我实在没办法了。

怎么办呢？

我苦苦思寻，渐渐地进入了回忆之中，脑中浮现出一个画面——当年我还是个小小少年，刚开始接触 Kotlin ，拿着 Swing 的图形 API 把玩。

！！！！！！！！！！

我可以使用 Kotlin 代码操作 png 图片的每一个像素，反正都是 RGB 值，这多简单啊！

然后我就撸了个 Kotlin 程序，想起了当年写位运算程序的辛酸日子：

```kotlin
fun main(args: Array<String>) {
  val origin = ImageIO.read(File("lice.png"))
  (0..origin.width - 1).forEach { x ->
    (0..origin.height - 1).forEach { y ->
      val o = origin.getRGB(x, y)
      origin.setRGB(x, y, o + (0x22 shl 24))
    }
  }
  ImageIO.write(origin, "PNG", File("lice-edited.png"))
}
```

希望它能带来改变。

然后编辑之后导出了一张几乎是透明的图片。。。。

这就很尴尬了，这也不是我想要的啊，我只是想要一张高仿的 png 图片啊！

我此时智商上线，灵光再一次闪现！

我发现这样不行，无论怎样硬编码 RBGA 的 A 值，都是不靠谱的。

既然是高仿，那就应该拿出高仿的样子！

我拿出了 IntelliJ 自带的 CSS 图片的 png 文件，直接将它的 RGBA 值抄过去。然后发现原版图标写了 CSS 字样的部分，每个像素的透明度都不一样。

于是我就只能『只抄没字样的部分，字样直接采用彩色背景的透明度』。

> 你永远不懂我伤悲，像白天不懂夜的黑 <br/> ![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/5/2.png)

最后版本：

```kotlin
fun main(args: Array<String>) {
  val origin = ImageIO.read(File("lice.png"))
  val css = ImageIO.read(File("css.png"))
  val alphaPosition = 0xFF shl 24
  val bottomAlpha = css.getRGB(css.width - 1, css.height - 1) and alphaPosition
  (0..origin.width - 1).forEach { x ->
    (0..origin.height - 1).forEach { y ->
      val o = origin.getRGB(x, y)
      origin.setRGB(x, y,
          if (y <= 9 || x < 1) o + (css.getRGB(x, y) and alphaPosition)
          else o + bottomAlpha
      )
    }
  }
  ImageIO.write(origin, "PNG", File("lice-edited.png"))
}
```

导出之后感觉效果还不错：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/5/4.png)

累死我了 QwQ

明天还要上课背单词....睡觉睡觉
