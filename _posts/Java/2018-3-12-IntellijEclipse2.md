---
layout: post
title: 吐槽 IntelliJ 和 Eclipse 的实现细节
category: Java
tags: Java
keywords: Java, Eclipse, IntelliJ
description: Java type inferencer
---

其实这是标题党，因为我本身不太了解 Eclipse 的源码架构，只是稍微看过一部分，满足工作需求而已，浅尝辄止。

## 设置的传递

前者一直都是蛮争议的东西，有的人觉得应该使用全局变量，有的人觉得应该处处传递。
对于 Haskell 来说，后者应该是很明显的最佳选择。但当我们使用支持变量和赋值的语言时，就存在一个选择的问题。
个人觉得，原则上来说应该减少全局变量的使用，不仅仅是因为线程竞争等问题，还有关于设置对象的拷贝、克隆之类的问题。

IntelliJ 存数据使用能处理依赖关系的 `org.picocontainer.PicoContainer` ，而 Eclipse 使用全局变量，高下立判。

## 数据持久化

在数据持久化上， IntelliJ 将 『.idea』这个目录里的 xml 文件读写封装到可以说是完全无痛的程度，
基本上就是把需要持久化的 Java Bean 放进泛型参数里之后，多写两个函数调用就可以直接把这个 Java Bean 当成是
『本来就不会因为软件关闭而丢失的数据』使用了。

IntelliJ 会在 lose focus 或者关闭的时候自动对每一个 `com.intellij.openapi.components.PersistentStateComponent`
调用 `getState` ，也就是以一个低但足够有效的频率不停地写设置。

而 Eclipse 即使有 `org.eclipse.core.resources.IProjectNature` 这种东西（类似 IntelliJ 里的 `projectService` ，或者说， `globalService`），比起 IntelliJ 的自动存储的 `PersistentStateComponent` ，它完全没有还手之地 —— 它需要你手动读写文件来持久化设置数据，完全没有考虑过 IntelliJ 那种做法。

IntelliJ 提高了一个 `@State` 和一个 `@Storage` 注解，可以用于指定存储的位置 —— 这其实是个很平凡的设计，
我不是很懂不将它做成一个接口的抽象方法的用意。

所以，在这个方面， Eclipse 可以说是落后了不少，仔细算算应该落后了几十年了吧，四舍五入就是一个世纪啊。

## 吐槽

这次再扯几个这些 IDE 源码的槽点。

### 好玩的那种

+ `com.intellij.lexer.__XmlLexer`, `com.intellij.lexer._XmlLexer` 和 `com.intellij.lexer.XmlLexer` ，禁忌的三重存在，前两个都是手写的。  
在后者的构造器里面，有一句
```java
new _XmlLexer(new __XmlLexer((Reader)null), conditionalCommentsSupport)
```
。。。

+ XML 的 Parser 也有这种嵌套关系， `com.intellij.psi.impl.source.parsing.xml.XmlParsing` 是 Parser 的具体实现，包了一层 `com.intellij.psi.impl.source.parsing.xml.XmlParser` 放在 `ParserDefinition` 里面。  
是手写的，命名极为规范，有种 [@Sona](https://github.com/ILoveChenKX) 写的代码的味道。

+ Eclipse 的 `enableWhen` 遇到复杂的逻辑完全就成了一坨晦涩难懂的 AST Dump ：

```xml
<visibleWhen
      checkEnabled="false">
   <with
         variable="selection">
      <count
            value="1">
      </count>
      <iterate>
         <adapt
               type="org.eclipse.core.resources.IProject">
            <not>
               <test
                     value="uafmarker.sampleNature"
                     property="org.eclipse.core.resources.projectNature">
               </test>
            </not>
         </adapt>
      </iterate>
   </with>
</visibleWhen>
```

### 很烦的那种

+ 关于 `com.intellij.ui.ComboboxWithBrowseButton`  
我们知道：

```java
public class JComboBox<E> extends JComponent
implements ItemSelectable, ListDataListener, ActionListener, Accessible
```

但是在这个非常常用的封装里，把 `JComboBox<E>` 的这个宝贵的反省参数给擦除了：

```java
public class ComboboxWithBrowseButton extends ComponentWithBrowseButton<JComboBox>
```

导致我现在需要 cast 或者 `toString()` 很多下，很讨厌（体现出了不用 Kotlin 的坏处）。

+ 测试框架坑爹。  
IntelliJ IDEA 的 Parsing 测试框架在使用了 `Convention` 大于 `Configuration` 的场合还不好好写文档，最早的时候着实把我坑了一波（关于 testData 的文件路径问题）。

+ `org.eclipse.jface.viewers.IStructuredSelection` 里的各种擦除  
看看它的方法签名就知道这货有多邪恶：

```java
public Object getFirstElement();
public Iterator iterator();
public int size();
public Object[] toArray();
public List toList();
```

具体是什么类型，全靠运行时猜。

![](https://coding.net/u/ice1000/p/Gifs/git/raw/master/emacs.gif)

你看，就连 Emacs 也觉得它特邪恶。
