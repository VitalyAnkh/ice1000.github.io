---
layout: post
title: 整理几个最近写的比较正常的回答
category: Misc
tags: Misc
keywords: StackOverflow
description: StackOverflow non-water answers
---

StackOverflow 是一个用实力让我知道国外程序员平均水平的网站。
菜的能让你感觉是一个小孩子在上网，叼的又能让你觉得是在学术界叱咤风云的大学教授。

由于最近需要学习之前不太了解的 Eclipse ，所以这两天上这个网站比较多，也回答了一些和 IntelliJ 平台相关的问题，
于是就顺手整理一下不是那么水的 StackOverflow 回答。

## IntelliJ Plugin Development: how to make class extend another class

[Link](https://stackoverflow.com/a/48558519/7083401)

I'm implementing a plugin in which I need to add `extends` clause for an existing class.

I have `PsiClass` instance representing say `MyClass`.

There is an API that allows to get all the classes that `MyClass` extends:

```java
PsiReferenceList extendsList = psiClass.getExtendsList()
```

And theoretically I can add something to it and that will work.

**Problem:** `PsiReferenceList.add()` consumes `PsiElement` and I don't know how to create an object of `PsiElement`
having fully qualified name of the class I want to use.

More specifically, how to transform string `com.mycompany.MyAbstractClass` to `PsiElement` representing this class?

**Update:**
I managed to achieve the result using the following logic:

```java
PsiElementFactory factory = JavaPsiFacade.getInstance(project).getElementFactory();
PsiReferenceList extendsList = aClass.getExtendsList();
PsiShortNamesCache instance = PsiShortNamesCache.getInstance(project);
PsiClass[] abstractClasses = instance.getClassesByName(
    "MyAbstractClass", 
    GlobalSearchScope.allScope(project)
);
PsiJavaCodeReferenceElement referenceElement = factory
    .createClassReferenceElement(abstractClasses[0]);
extendsList.add(referenceElement);
```

It works but I guess there should be more optimal way.

### My answer

You can make a `String` which is the code you want to generate, like

    String code = "class A extends B { }"

Then, use this code to convert text into `PsiElement`:

```java
PsiElement fromText(String code, Project project) {
  return PsiFileFactory
    .getInstance(project)
    .createFileFromText(JavaLanguage.INSTANCE, code)
    .getFirstChild()
}
```

And you'll get the corresponding `PsiElement`.

Then, `myClass.replace(fromText(code))`.

BTW you can also do `classNamePsiElement.addAfter(fromText("extends Xxx"))` which is considered more efficient.

## How to get the theme that the current user use in intellij?

[Link](https://stackoverflow.com/a/49233902/7083401)

### My answer

You can also make use of `JBColor` which displays differently under different themes.

## IntelliJ shortcut to auto complete parameters for overloaded methods?

[Link](https://stackoverflow.com/a/49143070/7083401)

If I have the following methods:

```java
void foo(int one, int two, int three, int four) {
   foo(|
}
  
void foo(int one, int two, int three, int four, int five) {
   // do something
}
```

And my cursor is where the `|` is at. Is there a shortcut to tell IntelliJ to autocomplete the parameters to pass into `foo(one, two, three, four, null)`?

### My answer

![image](https://user-images.githubusercontent.com/16398479/37070003-ba2dc920-21f0-11e8-9547-f86254cd7199.png)

No special handling is needed, <kbd>Ctrl</kbd>+<kbd>Space</kbd> will give you the completion shown above.  
All you have to do is to select your expected completion.

## How to change CMake options from the Intellij platform plugin code?

[Link](https://stackoverflow.com/a/49229339/7083401)

I want to change some options passed to the CMake command through the plugin code. Unfortunately I can't figure out how to do it.

Is there any API to communicate with CLion specific functionality?

### My answer

You said "CMake command", which is unclear. I guess you want to change the CMake location.

This code can give you a `CPPToolchains.Toolchain` instance:

```kotlin
val Project.toolchains: CPPToolchains
  get() = ServiceManager
      .getService(this, CPPToolchains::class.java)
      .toolchains
      .firstOrNull()
```

Or if you don't understand Kotlin, use Java:

```java
CPPToolchains.Toolchain tools = ServiceManager
    .getService(project, CPPToolchains.class)
    .getToolchains().get(0);
```

And you can get the settings by codes like

```java
tools.getCMake().getExecutable()
```

Or change them by invoking methods like

```
com.jetbrains.cidr.cpp.toolchains.CPPToolchains.Toolchain#setCustomMakePath
```

Just explore through those classes and methods, you'll get what you want.

If you still can't find any, try replace `CPPToolchains` in the first two codes with `CMakeSettings` and see if there's something in the class that fits your expectation.

