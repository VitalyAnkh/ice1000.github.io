---
layout: post
title: MPS 教程四：制作一个简易语言（下）
category: MPS
tags: MPS
keywords: MPS, LOP
description: make a simple language with MPS
---

在上一篇教程中，我们已经体验了 MPS 创建语言的所必须拥有的完整流程。
我们也注意到了生成的语言语法很丑。

接下来，我们将编写自己的 Editor ，把语法变得好看起来。

[发知乎了，求点赞](https://zhuanlan.zhihu.com/p/26354632)

这篇文章结束之后，我这个 MPS 系列就暂时告一段落了，下一波教程可能很快出来，也有可能要过很久。不过我是不会跳票的！

最早我在写这个系列的时候，就是抱着『反正肯定没人看，不过我就是要写』的任性态度写的，
结果万万没想到，有好几个人都过来跟我说『在读你的 MPS 系列』，让我内心小鹿乱撞，真是太惊喜了！
所以说我按理说还是会坚持下去的！

## 准备工作

+ 阅读[上上篇博客](../../../../2017/04/06/MakeSimpleLangWithMPS/)并完成对应的工作
+ 阅读[上一篇博客](../../../../2017/04/07/MakeSimpleLangWithMPS/)并完成对应的任务
+ 英文输入法（就是<kbd>Ctrl</kbd>+<kbd>Space</kbd>没有被占用的输入法）

## 本文主要内容

+ MPS 的 Editor
+ 加深对 MPS 原理的理解

### 有哪些新概念

+ 没有新引入的概念

## 回顾一些概念

### MPS

MPS 是一个 DSL 开发环境，采用 LOP 的理念，将模块化的组件作为一个个的 DSL。MPS 的『语言』对应 OOP 的『对象』、PP 的『过程』。

MPS 将程序保存为 AST ，在文件系统中序列化为 xml 保存，在编辑器中渲染为『代码』。

你看到的，是 MPS 根据 AST 渲染出来的类似代码的东西，但是它实际上不是代码。

### Concept

Concept 可以当成是 Java 里面的 class ，它可以有 interface concept （对应 Java 的 interface ），
可以有 abstract concept （对应 Java 的 abstract class ）。

Concept 的实例就是 AST 的节点，对应 class 的实例是对象。读者可以把 AST 节点理解为『Concept 这种类似 class 的东西的实例』。

### Generator

Generator 遍历 AST 节点，导出另一份代码。

### 我们写过的东西

Concept:

+ Println ，有一个叫 content 的 property ，类型是 string
+ PrintlnSet ，有很多 Println 的 children

Generator:

+ 给 PrintlnSet 提供的简单 Generator

## 开始吧

打开你的 MPS ，进入上次创建的工程。

### 关于 Editor

Editor 是**你的 DSL 的语法**。

一般情况下，每个 Concept 都有一个对应的 Editor。每个 Editor 有它适用的 Concept。

Editor 有两种创建方式，一种是直接创建，一种是针对一个 Concept 创建。

在你的 DSL 中，每个 AST 节点（每个 Println 是一个 AST 节点，每个 PrintlnSet 也是 AST 节点）都需要一个对应的 Editor ，
然后 MPS 根据这个 Editor 来渲染出你看到的『代码』。

Concept 有接口 Concept 来实现组件化，所以 Editor 也可以组件化——你可以做一个子 Editor ，让它『可被应用于』一个 Abstract/Interface Concept ，

然后你就可以在这个 Concept 的实现中『引用』这个 Editor。

### 默认 Editor

如果不为一个 Concept 指定 Editor ，那么 MPS 会创建一个默认的 Editor ，这个 Editor 长啥样读者在上期已经看到了。

我们在本期会为我们的 Concept 定制 Editor。

### 创建 Editor

我们就直接针对 Concept 创建了。

然后进入我们在第一篇教程中创建的『Concept』，选择 Println 这个 Concept ，打开并创建它对应的 Editor。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/0.png)

（注意，在空白处右键就可以看到截图里的 pop-up 了）

然后你就可以看到你的第一个 Editor 啦！

### 最简 Editor

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/1.png)

我们可以直接创建一个最最简单的 Editor ，先在那一片姨妈红中<kbd>Ctrl</kbd>+<kbd>Space</kbd>，选择

```
{content}
```

那个：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/4.png)

这表示，在这个位置渲染 Println 这个 Concept 的 content 属性。还记得吗？ Println 这个 Concept 的定义。

然后我们编译一下，回到我们之前在 Sandbox 里面写的 PrintlnSet ：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/5.png)

看到了木有！我们自己定义的 Editor 替换掉了原来的默认 Editor。

我们没有动自己的代码，而是改变了 Editor ，然后代码的样子就改变了。

**也就是说，代码写成啥样不重要，只要逻辑（ AST ）不变，你可以随便改变语法，显示出来的代码就会随之改变。**

注意体会一下我之前很早就说过的『MPS 显示的其实是渲染的 AST』。再次提醒自己，你在屏幕上看到的不是文本。

### 是不是有点懵

没错我似乎没怎么解释 Editor 工作的机制。

MPS 会遍历这个 AST 的每个节点，针对每个节点，寻找它的 Editor ，然后根据 Editor 绘制这个节点。

在这个例子中，我们的 Editor 就只有一个 `{content}` **元素**，因此 MPS 也就直接把这些节点的 content 属性渲染出来了。

我们需要一个更加人性化的 Editor ，起码得有个提示语吧？比如：

```
text: {content}
```

类似这样的如何？

### MPS 的 Editor

MPS 的 Editor 默认只有一个用来放元素的位置，叫做 Editor 的根元素。一般情况下，这个根元素会放一个**集合**，
在**集合**里面再挨个添加我们需要的元素，而不是像我们刚才那样直接把一个 `{content}` 放进去。

### 稍微好看点的 Editor

我们需要一个 Editor 元素的**集合**。

于是我们在那一片姨妈红中<kbd>Ctrl</kbd>+<kbd>Space</kbd>，然后输入一个减号，选择**collection (indent)**：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/2.png)

然后我们就有了一个用来放元素的集合了。

我们可以在集合中间输入一个提示语。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/6.png)

输入完然后回车，这样 MPS 会创建一个新元素，并进入之：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/7.png)

然后我们在这个元素中再放入 `{content}`
（注意不能直接输入 `{content}` ，必须使用<kbd>Ctrl</kbd>+<kbd>Space</kbd>后代码补全里面给出的 `{content}`）。
最终的样子应该是这样：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/8.png)

然后编译一下，回去看我们的 Sandbox 里的 PrintlnSet。

可以看到，效果已经出来了：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/9.png)

### 稍微复杂点的 Editor

我们还需要为 PrintlnSet 创建一个 Editor。考虑如下因素：

+ PrintlnSet 有很多个 Println ，这个数目是不定的
+ 我们需要一个提示语
+ 元素竖着排列

（想了半天发现好像就这几个因素）

然后我们可以考虑直接使用 MPS 提供的默认方法来创建这个 Editor ，就是这个：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/10.png)

然后它会自己出来一堆东西，我们不管它，先编译看效果：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/11.png)

它直接把所有的 Println 全部塞一行了！这样是不行的！我们需要一个竖着的！

#### 关于 ChildNodeList

**child node list**是 MPS 提供来放置『数量不定的 AST 子节点』的 Editor 元素，它有横着的，也有竖着的。

所以我们来，先弄个提示语，然后选择**child node list(vertical)**，这个就是竖着的 ChildNodeList。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/12.png)

然后我们看到它出现了一堆元素。不要慌，我们挨个填。

首先，在 `<no link>` 这个地方填入你要 link 到的 AST 子节点——在这里，就是我们的 `clauses` 。

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/13.png)

然后编译一下。

### 最后的样子

回到 Sandbox 里面，我们可以看到这个东西的语法又变了，变成了我们想要的样子：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/14.png)

```
set: text: Fuck you ZhiHu Editor!!!!
     text: My name is Van, I'm an artist.
     text: I'm a performance artist.
```

### 其他 Editor 功能

比如我们想把那些 text 换到下一行去，可以在 `(\` 上使用<kbd>Alt</kbd>+<kbd>Enter</kbd>，然后选择『Add On New Line』：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/15.png)

贴图真的很累，我就不截操作之后的效果图了，反正这样处理之后代码是这样的：

```
set: 
text: Fuck you ZhiHu Editor!!!!
text: My name is Van, I'm an artist.
text: I'm a performance artist.
```

其实 Editor 还有更多功能，远不止这点。

## 本文没有讲到的点

真的是篇幅所限！我其实很想把这些都说完的。

+ 类似括号配对的效果，可以对你指定的两种（任意！不一定是括号！可以是 begin end 这种） Editor 元素进行高亮配对
+ 改变前景/背景颜色（可以参考我[之前的那个 ShapeLang](../../../../2017/03/18/TryShapeWithMPS/)里面的效果）
+ 根据 AST 节点属性的情况，按需显示 Editor 元素
+ 显示表格
+ 奇怪的对齐方式
+ 显示图片
+ 显示 Swing 控件

还有很多别的，我现在脑子有点乱，就不一一列举了。

## 还能这么玩

我稍微改了下这个 Editor 的样子，最终渲染出来的代码是这样的，可以作为作业，读者可以试着自己弄一个出来：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/16.png)

看到了吗？模仿 Java。我们还可以再改改：

![](https://coding.net/u/ice1000/p/Images/git/raw/master/blog-img/mps/3/17.png)

看到了吗？模仿 C#。

**而进行这样的语法改动，只需要动 Editor ，完全不需要动代码。**

## 结束

那么 MPS 的最最简单的入门教程就这么结束啦\~

我也得睡觉了，休息可是很重要的呢 DAZE\~
