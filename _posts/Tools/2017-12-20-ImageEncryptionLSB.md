---
layout: post
title: 基于图像的 LSB 隐写术科普
category: Tools
tags: Misc
keywords: LSB
description: Very simple image processing
---

这是 SKE 文章[无良小编想和泥玩捉迷藏！](https://zhuanlan.zhihu.com/p/32092460)的 Java 翻译。  
文章不是我写的，代码是我写的。

下面是内容。

## 0x00 先放图

![](https://raw.githubusercontent.com/SKE48Cyto/Rem_steg/master/Rem_secret.png)

窝究竟在蕾(lao)姆(po)的皂片里面藏了什么？  
LSB 算法鲁棒性比较低，窝建议泥通过[这里](https://raw.githubusercontent.com/SKE48Cyto/Rem_steg/master/Rem_secret.png)下载原图 >ω<  
（注：博客里使用的图片是直接引用的原图，所以你也可以右键保存）

大佬们现在就可以试一下辣！很简单！  
嘛\~ 如果泥还不知道该怎么办，那么阅读本文，泥就会找到答案辣！

## 0x01 什么是隐写术？

维基百科对隐写术的定义：

> 隐写术是一门关于信息隐藏的技巧与科学，所谓信息隐藏指的是不让除预期的接收者之外的任何人知晓信息的传递事件或者信息的内容。
一般来说，隐写的信息看起来像一些其他的东西，例如一张购物清单，一篇文章，一篇图画或者其他『伪装』(cover)的消息。

换而言之，隐写不同于加密，加密是一段你看不懂的东西，隐写是一段你似乎能看懂的东西，但是实际上不是表面看上去那么简单。  
而对应把隐藏的东西提取出来的技术称为隐写分析。

接下来，无良小编就来科普一个非常非常非常简单的以数字图像为载体的 LSB 算法与相应的隐写分析\~

## 0x02 LSB算法

### 像素与 RGB

计算机保存的图像是以数值保存每一个像素点。  
数字图像有很多种，比如二值图像，每个像素点不是 0 ，就是 1 ；再比如灰度图像，每个像素取值从 0 到 255 。

### 通道

> 通道，是数字图像中存储不同类型信息的灰度图像。一个图像最多可以有数十个个通道，常用的 RGB 和 Lab 图像默认有三个通道。

（摘自维基百科）

RGB，这里指灰度图像里的以 RGB 模式存储数字图像的模型。其中，R 是 Red 的首字母，G 是 Green 的首字母，B 是 Blue 的首字母，它们分别代表一个通道，在每个通道上，保存一个代表该通道亮度的数字，取值范围从 0 到 255 。

举个例子。

以上面那张图为例，窝们用 Java 读取它的第一个像素值（不像 Python ， Java 自带了库，哼）：

```java
import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;

public class Main {
	public static void main(String... args) throws IOException {
		BufferedImage image = ImageIO.read(new File("Rem_secret.png"));
		System.out.println(new Color(image.getRGB(0, 0)).toString());
	}
}
```

运行结果：

```
java.awt.Color[r=73,g=158,b=225]
```

Java 返回了一个 `int`，为了方便观察，我们把它转为一个`java.awt.Color`对象。  
其中有三个元素，分别对应 RGB 三个通道的亮度值，R 通道的亮度值为 73 ，G 通道亮度值为 158 ，B 通道亮度值为 225 ，三个通道的颜色混合在一起，也就构成了第一个像素点所显示的颜色~

### 肉眼难分的『色号』

窝们用 Java 生成一个每隔 30 个像素，R 通道上亮度值减 1 的图像。

```java
import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;

public class Main {
  private static void putPixel(BufferedImage image, int widthStart, int height, int rgb) {
    for (int h = 0; h < height; ++h)
      for (int i = 0; i < 30; i++) image.setRGB(widthStart + i, h, rgb);
  }

  public static void main(String... args) throws IOException {
    int width = 30, height = 30;
    BufferedImage img = new BufferedImage(width * 10, height, BufferedImage.TYPE_INT_RGB);
    int r = 255, g = 0, b = 0;
    for (int i = 0; i < 10; i++) {
      putPixel(img, i * 30, height, new Color(r - i, g, b).getRGB());
    }
    ImageIO.write(img, "png", new File("tmp.png"));
  }
}
```

生成的图像

![](https://raw.githubusercontent.com/SKE48Cyto/Rem_steg/master/tmp.png)

似乎……比专柜上的口红色号还难分诶……QAQ

（扯个皮，口红试色的时候，专柜的灯光比平时的灯光亮好多倍，所以会导致一些深的颜色看起来很浅，选口红的时候要注意哦，窝交了好些智商税才想明白这个道理 QAQ ）

所以呢，如果把像素的亮度值加一或减一，肉眼根本分辨不出来~那么，窝们就可以利用这个藏一点儿小秘密辣！

对应于把像素加一减一这样的操作，在用二进制表示像素亮度值的情况下，也就是改变这个二进制的最低位，也就是最低有效位 (Least Significant Bit, LSB) 算法。

## 0x03 开篇那张图

开篇那张图，窝就是把一张神秘图像（此处手动滑稽）二值化了一下，藏到了蕾姆老婆的图像的 R 通道的最低位中惹。

所以，得到那张神秘图像的办法，就是读取蕾姆老婆的图像的 R 通道的最低位，根据最低位的值，0 或者 1 ，还原出原来的图像。

```java
import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class Main {
  public static void main(String... args) throws IOException {
    BufferedImage secretImg = ImageIO.read(new File("Rem_secret.png"));
    int width = secretImg.getWidth(), height = secretImg.getHeight();
    for (int w = 0; w < width; w++) {
      for (int h = 0; h < height; h++) {
        Color color = new Color(secretImg.getRGB(w, h));
        int lsb = color.getRed() % 2; // 个人建议把 % 2 写成 & 1
        secretImg.setRGB(w, h, (lsb == 0 ? new Color(0, 0, 0) : new Color(255, 255, 255)).getRGB());
      }
    }
    ImageIO.write(secretImg, "png", new File("secret.png"));
  }
}
```

原文的代码是这样子的，不过如果是我的话我会写成这个样子：

```java
public class Main {
  public static void main(String... args) throws IOException {
    BufferedImage secretImg = ImageIO.read(new File("Rem_secret.png"));
    for (int w = 0; w < secretImg.getWidth(); w++)
      for (int h = 0; h < secretImg.getHeight(); h++) {
        int lsb = new Color(secretImg.getRGB(w, h)).getRed() % 2; // 个人建议把 % 2 写成 & 1
        secretImg.setRGB(w, h, (lsb == 0 ? new Color(0, 0, 0) : new Color(255, 255, 255)).getRGB());
      }
    ImageIO.write(secretImg, "png", new File("secret.png"));
  }
}
```

所以，快去试一下，看看窝到底藏了什么吧~

+ [本篇科(水)普(文)全部内容的下载地址](https://github.com/SKE48Cyto/Rem_steg)

## 参考资料

+ 用于隐写的原图的分享者为 Midia，[原图地址](https://wall.alphacoders.com/big.php?i=729168)
+ 隐写术_维基百科
+ 通道_维基百科
+ 《数据隐藏技术揭秘》
+ 《隐写分析原理与应用》

## 最后的最后

好吧，其实窝就是想让泥萌扫下二维码  
为了让泥萌扫下这个二维码，窝连蕾(lao)姆(po)都不放过，内心不安，于是只好自称无良小编来缓解一下内心的愧疚 QAQ 泥萌不要打窝 QAQ

另外，本人水平有限，如有错误，敬请指正，非常感谢 >ω<
