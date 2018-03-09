---
layout: post
title: 简要介绍 IntelliJ 和 Eclipse 的插件系统
category: Java
tags: Java
keywords: Java, Eclipse, IntelliJ
description: Java type inferencer
---

由于最近工作需要，我去研究了下 Eclipse 的插件系统，对比 IntelliJ IDEA 的，让我有了些写博客的欲望。

## 相似之处

IntelliJ IDEA 和 Eclipse 的插件架构其实比较接近的，基本上都是通过 "extension point" 这一概念展开的插件系统。
一个插件可以针对 extension point 进行扩展，也可以定义自己的 extension point 。
一般每个 extension point 会需要填写 `id`，`class`（或者`implementation`之类的）的字段，前者就是个识别用的字符串，
后者是你的实现，一般是根据 extension point 的要求会实现一个接口。  
比如我给 `fileTypeFactory` 这个 extension point 进行了扩展，那么定义这个 extension point 的人就可以获取到我自己填进去的`class`，
然后调用接口的方法，就能实现让你的代码在一定的 context 下被执行。

### 插件 xml

插件开发者在一个 plugin.xml 里填写自己插件的详细信息（比如发布者信息，版本，给哪些 extension point 进行了扩展，
自己有哪些 extension point，etc.），这里 IntelliJ IDEA 和 Eclipse 都差不多，比如 Eclipse 写一个扩展大概是这样：

```xml
<extension point="yesYesYesOhMyGod">
  <yesYesYesOhMyGod
     class="org.ice1000.MyYesYesYesOhMyGodExtension"
     icon="icons/ice1000.png"/>
</extension>
```

而 IntelliJ IDEA 是这样：

```xml
<yesYesYesOhMyGod
  implementation="org.ice1000.MyYesYesYesOhMyGodExtension"
  icon="icons/ice1000.png"/>
```

### 事件系统

然后 IntelliJ 有一个叫 Action 系统（Action System）的东西，是用来管理各种按钮
（右键菜单的，设置里面的，按钮上的，etc）的点击事件/各种快捷键事件/各种重构事件的。  
如果想自定义一个事件，那么就需要写一个类继承 `AnAction` 。

注册的话，代码应该是这么写：

```xml
<action
  id="Ice1000.Yes"
  text="say yes"
  description="yes, yes, yes, oh my god."
  class="org.ice1000.MyYesYesYesOhMyGodAction">
  <add-to-group group-id="NewGroup" anchor="after" relative-to-action="NewFile"/>
</action>
```

在 Eclipse 中，等价的东西叫做 `Handler` ，一般是写一个类继承 `AbstractHandler` 。  
代码是这样的：

```xml
<extension point="org.eclipse.ui.commands">
  <command
    categoryId="org.eclipse.ui.commands.category"
    id="Ice1000.Yes"
    description="yes, yes, yes, oh my god."
    name="say yes"
    defaultHandler="org.ice1000.MyYesYesYesOhMyGodHandler"/>
</extension>
```

然后各个 `Action` 或者 `Handler` 都肯定是可以被 disable/enable 的，而两个 IDE 对此提供了不同形态的支持。

对于 IntelliJ ，开发者可以 `@Override` 一个叫 `update` 的方法，在个方法里可以通过对 `e.isVisible = true` 或者 `e.isEnabled = false` 之类的代码来实现隐藏、标灰等功能。  
举个例子：

```kotlin
override fun update(e: AnActionEvent) {
  e.presentation.isEnabledAndVisible =
    fileType(e) and e.project?.run { juliaSettings.settings.unicodeEnabled }.orFalse()
}
```

而 Eclipse 在这点我觉得是做了一个不太好的设计，或者说，过度的抽象。  
我感觉是开发者试图把这个和运行本身无关的逻辑放进配置文件而不是写进代码，于是就让你手动提供这个判断语句的 AST ，大概长这样：

```xml
<visibleWhen>
 <not>
  <iterate operator="and">
   <test
     property="org.eclipse.core.resources.projectNature"
     value="com.sourcebrella.cpp.PinpointNature"/>
  </iterate>
 </not>
</visibleWhen>
```

我觉得不够自由，而且写起来很冗长。

到现在为止都是他们的相似点。

## 不同之处

但是他们管理工程、页面、各种扩展点的生命周期之类的东西就有区别了。

### 项目管理

像 IntelliJ IDEA ，就是将大部分『设置』（比如 Java SDK 的路径， Julia SDK 的路径，上次运行代码时的设置，上次复制粘贴的内容，等）放进了一个 `PicoContainer`，
这个东西据说可以管理嵌套的初始化关系，比较像一个用来对运行时的初始化进行拓扑排序的工具，非常厉害。这也是我能在各种 `Configurable` 的构造器里面加
`Project` 之类的参数的原因，因为这其实就是表明我的初始化依赖 `Project` ，因此它会先被初始化然后被 `PicoContainer` 传给我（
一开始我还以为这个特性是硬编码进去的。。。果然是我太年轻）。  
要不是 IntelliJ IDEA 我还不知道这个东西的存在呢。这里贴一个[官方的 intro](http://picocontainer.com/introduction.html)
以及它的[中文翻译](http://www.cnblogs.com/yaoxiaohui/archive/2009/03/08/1406228.html)，我就不展开说了。

反观 Eclipse ，就使用全局变量（各种 `static` 的变量 `get` 来 `set` 去的，满天飞），我感觉就更糟了。主要是因为静态的初始化顺序始终很坑，经常有莫名其妙的 NPE。

这个特点从两者的 IDE 使用方式就可以看出， Eclipse 是只开一个窗口，里面显示多个项目；而 IntelliJ 是可以开多个窗口，然后每个窗口一个 project。  
分别对应全局和局部。

### 代码分析

在语言代码的 Parsing 方面， Eclipse 选择了使用类似 VSCode 的 Language Server Protocol 的技术，即不断地尝试编译代码（应该是只执行了 Parsing 和 reference resolving 的过程），然后对错误的位置进行报错。  
好处是能保证正确性，坏处是不够实时，而且拿到的信息不够。

相对 IntelliJ 就更有造轮子精神了，所有的 Parser 都是自己写的。  
好处是有足够丰富的信息和封装的很完善的各种 Utils ，坏处是不一定和编译器行为一致（默默看向 Scala, Rust）。

当然 IntelliJ 里面也有一些意义不明的代码，比如 `com.intellij.execution.process.ProcessWrapper`，让我感到十分费解。

## 结束

大概就这样，这只是一个对比，还有很多东西没说。  
以后再写。
