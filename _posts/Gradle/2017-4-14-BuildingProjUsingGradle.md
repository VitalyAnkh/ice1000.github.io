---
layout: post
title: Gradle 其实是很好用的
category: Gradle
tags: Java,Gradle
keywords: Java,Gradle
description: Gradle is actually a nice tool
---

Gradle 是一款使用 Kotlin （划掉） Groovy 编写的 JVM 构建工具，其易用性和 Maven 接近，而由于它描述逻辑采用的是 DSL 而不是辣眼睛的 xml ，
股沟也钦定他作为 Android 的指定构建工具。

## 关于 Gradle

由于 Gradle 的构建过程高度依赖网络，因此身在中国，~~在中国长城局域网的保护下的各位~~网络条件是很不好的。

这就导致，明明一个贼好用的构建工具，把绝大多数的开发者都给坑惨了。

我作为一个在 2017 年 1 月对 Gradle 黑转粉的 Gradle 用户，在这里向同学们传授中国 Gradle 的正确使用方式。

其实写这篇博客我是很犹豫的，因为我在知乎已经看到过有人描述过我想写的东西了，但是写的很粗略，所以我决定再写一次。

现在的问题就是，很多人没有 VPN。这就导致你不能用 Proxifier 这种工具实现全局翻墙，
而像开灯这种行为又不能大幅影响命令行（作为一个有梯子的人，我是不清楚的，但是在我没有梯子的时候，那叫一个痛苦）。

而他们面临着写 Android 项目的任务，想必很多人都体会过『只能在 Android Studio 里面构建，
切到命令行之后`gradlew build`之后不知道它在下什么东西，反正就是不行』的感受。

其实呀，你们只是不知道 AS 在 build 的过程中，使用了自己夹带的 gradle。我们现在要拒绝夹带私货，走向自由。

## 简要介绍

首先我说明一下一个最普通的 gradle 项目的目录结构：

```yaml
root:
  gradle:
    wrapper:
      - gradle-wrapper.properties
      - gradle-wrapper.jar
  - build.gradle
  - settings.gradle
  - gradlew.bat
  - gradlew
```

这 6 个文件缺一不可，一般使用 Android Studio 新建 gradle 项目的时候会给你弄齐。

其中：

文件|最主要功能
:---|---:
gradle-wrapper.properties|用于指定 gradle 版本号
gradle-wrapper.jar|和上面那个配套
build.gradle|构建脚本，写编译的逻辑，依赖，各种你能想到的配置
settings.gradle|指定工程名
gradlew.bat|Windows 下命令行构建时用的，一般不动它
gradlew|*nix 下命令行构建时用的，一般不动它

后两个文件随便找个 Gradle 项目（到处都是，不行也可以拿 AS 新建一个项目，自动加入）照抄即可，所以说我们要管的其实就四个文件。

### settings.gradle

一般情况下，`settings.gradle`里面就这个东西：

```
rootProject.name = 'lice'
```

就是指定项目名称的，`gradlew build`生成的 jar 包就是`[项目名称].jar`。

### gradle-wrapper.properties

这个文件一般的内容就是：

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-[版本]-bin.zip
```

其实也只有一行需要注意，就是最后一行里面的版本。本文采用的 gradle 版本是`3.0`，也就是说最后一行是：

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-3.0-bin.zip
```

早期 AS 默认的是`2.1X`，我是不推荐的，已经过时很久啦。
根据知乎评论区提醒， AS 2.3 已经将 gradle 升级到了 3.3。

不过本文的教程适用于任何版本哦。

### gradle-wrapper.jar

这个 jar 和上面的 properties 文件是配套的。

说一下以上两个文件的一般的获取方式（一般不直接写，而是找到现成的）：

在 GitHub 上随便找个使用这个版本的 Gradle 的仓库，然后`download zip`，把它使用的这俩文件拿出来。

还有一个方法，就是

```batch
gradlew wrapper --gradle-version=3.5
```

这里顺便提供一个[`3.0`版本的 gradle wrapper 的下载](https://www.jianguoyun.com/p/DaYFXnoQl_iYBhifkyo)，
里面包含了 properties 文件和 jar 文件。

所以说现在只有`build.gradle`需要注意了。这也是全文的重点。

### 如何配置 build.gradle

其实很简单，举个例子你们就民白了。

## 给一个项目加上 gradle 支持

一般情况下， Gradle 默认的项目结构是：

```yaml
root:
  build:
    - 编译输出
  src:
    main:
      java:
        - 代码的包
      kotlin:
        - Kotlin 代码的包
    test:
      java:
        - 测试代码的包
      kotlin:
        - Kotlin 测试代码的包
  gradle:
    wrapper:
      - gradle-wrapper.properties
      - gradle-wrapper.jar
  - build.gradle
  - settings.gradle
  - gradlew
  - gradlew.bat
```

但是我们先不管，毕竟我要带你入坑，所以说我们要把一个原本不是这样目录结构的项目引入 Gradle 支持！

我们现在需要把这样一个项目加上 gradle 支持：

```yaml
root:
  demo:
    - demo 代码的包
  src:
    - 下面就是 Java 的 package 了，比如 org/frice/dsl 什么的
  test:
    - 测试代码的包
```

很明显，这是个极其非主流的项目，它不符合 Gradle 的默认要求。

这其实就是我的一个个人项目，为了简化教程，我把其中的一个子项目的构建给省略了。

现在我们先给他加上一些必须的文件（就是前面提到的除了`build.gradle`之外的）

```yaml
root:
  gradle:
    wrapper:
      - gradle-wrapper.properties
      - gradle-wrapper.jar
  demo:
    - demo 代码的包
  src:
    - 下面就是 Java 的 package 了，比如 org/frice/dsl 什么的
  test:
    - 测试代码的包
  - settings.gradle
  - gradlew
  - gradlew.bat
```

然后我们给他加上一个`build.gradle`。首先你要确认你的项目的如下信息分别是什么（其实就根据你的情况自己编）。

这里我给一个表格，并展示我在这个例子中为这些信息带入的值。

信息|这个例子中的值
:---|---:
包名|org.frice
项目名|dsl
依赖、版本|JUnit 4.12 和 JetBrains annotation 15.0
版本|1.0
语言|Java
Java 版本|1.6
源代码目录|`/src`
测试代码目录|`/test`和`/demo`

为什么选 Java6 呢？因为我这个项目其实是 2%的 Java 加 98%的 Kotlin ，那部分 Java 代码没有用到 Java8 的新特性，
我就选个兼容性更好的吧。

### 关于 Kotlin 的配置

这里说下 Kotlin 的配置（因为我这个项目是 Kotlin 的），不用 Kotlin 的同学可以跳过：

由于 Kotlin 的编译需要加个 Kotlin 编译器插件和一些库，所以需要一些额外配置：

信息|这个例子中的值
:---|---:
Kotlin 版本|1.1.1

## 编写 build.gradle

首先我们根据如下模板填写我们的信息：

```groovy
group '[包名]'
version '[版本]'

buildscript {
  repositories {
    mavenCentral()
  }
}

apply plugin: 'java'

sourceCompatibility = [语言版本]
targetCompatibility = [语言版本]

repositories {
  mavenCentral()
}

sourceSets {
  main.java.srcDirs += '[源代码目录]'
  test.java.srcDirs += '[测试代码目录]'
}

dependencies {
  compile group: '[依赖的包名]', name: '[依赖的名称]', version: '[依赖版本]'
  testCompile group: '[测试代码依赖的包名]', name: '[测试代码依赖的名称]', version: '[版本]'
}
```

### 和 Kotlin 有关的信息

如果需要 Kotlin 支持，需要添加如下额外信息：

```groovy
buildscript {
  ext.kotlin_version = '[Kotlin 版本]'
  dependencies {
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
  }
}

apply plugin: 'kotlin'

sourceSets {
  main.kotlin.srcDirs += '[Kotlin 源码目录]'
  test.kotlin.srcDirs += '[Kotlin 源码目录]'
}

dependencies {
  compile "org.jetbrains.kotlin:kotlin-stdlib-jre8:$kotlin_version"
  testCompile "org.jetbrains.kotlin:kotlin-test-junit:$kotlin_version"
}
```

### 引入来自 JitPack 的依赖

[JitPack](https://jitpack.io)是一个免费的远端仓库，我们如果需要引入这个仓库的包的话，需要再加一句：

```groovy
allprojects {
  repositories {
    maven { url 'https://jitpack.io' }
  }
}
```

### 最后的结果

根据我们此处的信息（再合并 Kotlin、JitPack 相关的依赖），应该这样填入：

```groovy
group 'org.frice'
version '1.0'

allprojects {
  repositories {
    maven { url 'https://jitpack.io' }
  }
}

buildscript {
  ext.kotlin_version = '1.1.1'
  repositories {
    mavenCentral()
  }
  dependencies {
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
  }
}

apply plugin: 'java'
apply plugin: 'kotlin'

sourceCompatibility = 1.6
targetCompatibility = 1.6

repositories {
  mavenCentral()
}

sourceSets {
  main.kotlin.srcDirs += 'src'
  main.java.srcDirs += 'src'
  test.kotlin.srcDirs += 'test'
  test.java.srcDirs += 'test'
  test.kotlin.srcDirs += 'demo'
  test.java.srcDirs += 'demo'
}

dependencies {
  compile "org.jetbrains.kotlin:kotlin-stdlib-jre8:$kotlin_version"
  compile group: 'org.jetbrains', name: 'annotations', version: '15.0'

  testCompile group: 'junit', name: 'junit', version: '4.12'
  testCompile "org.jetbrains.kotlin:kotlin-test-junit:$kotlin_version"
}
```

### 尝试命令行构建

然后我们在命令行运行（请一定要进行一次尝试！）：

+ \*nix ：

```shell
chmod a+x gradlew
```

+ Windows:

```batch
./gradlew build
```

然后你会发现它开始下载 gradle 的本体了。。。~~我们身处中国长城局域网，~~下载这个速度是极慢的。

<kbd>Ctrl</kbd>+<kbd>C</kbd>，把它停下吧。

你可能已经意识到了，接下来我们要解决一个巨大的问题，就是下载包的问题。

## 下载 Gradle 本体

我们现在把灯打开（脑补丑八怪歌词），然后登陆[Gradle 官网](https://gradle.org/)找到[下载页面](https://gradle.org/releases)
下载对应版本的 Gradle （或者你也可以从一些国内网站下载，比如 CSDN ）。

我们现在使用的是 gradle 3.0 （如果你是从我给的那个链接下载的 Gradle wrapper 的话），于是我们需要下载
[这个](https://services.gradle.org/distributions/gradle-3.0-bin.zip)：

https://services.gradle.org/distributions/gradle-3.0-bin.zip

上面那个链接直接点就好了。

下载好后，放进这个目录：

+ Windows

`C:/Users/[用户名]/.gradle/wrapper/dists/gradle-3.0-bin/2z3tfybitalx2py5dr8rf2mti/`

+ \*nix

`/home/[计算机名]/.gradle/wrapper/distsgradle-3.0-bin/2z3tfybitalx2py5dr8rf2mti/`

这个诡异的路径会被自动创建，你只要执行一次`gradlew build`它就会自动创建。因此我建议大家让它自己创建，免得打错。

然后重新回到刚才的项目目录，执行[刚才说过的指令](#尝试命令行构建)，会看到它没有在下载了，而是开始 unzip 我们刚才下载的

然后你就等编译吧，我自己的编译结果是这样的（为了模拟第一次配置（就是刚手动下载完 gradle ），
我还特地删除了我本地已经解压好的包（但是我已经提前下载好 Kotlin 的 Gradle 插件了，这个也比较大，各位 Kotlin 猿请耐心等待！））：

编译环境： Windows10 专业版

```batch
D:\git-repos\FriceEngine-DSL>gradlew build
Unzipping C:\Users\ice1000\.gradle\wrapper\dists\gradle-3.0-bin\2z3tfybitalx2py5dr8rf2mti\gradle-3.0-bin.zip to C:\Users\ice1000\.gradle\wrapper\dists\gradle-3.0-bin\2z3tfybitalx2py5dr8rf2mti
Starting a Gradle Daemon, 17 busy and 3 incompatible and 4 stopped Daemons could not be reused, use --status for details
:compileKotlin UP-TO-DATE
:compileJava UP-TO-DATE
:copyMainKotlinClasses UP-TO-DATE
:processResources UP-TO-DATE
:classes UP-TO-DATE
:jar UP-TO-DATE
:assemble UP-TO-DATE
:compileTestKotlin
Using kotlin incremental compilation
w: The '-d' option with a directory destination is ignored because '-module' is specified
:compileTestJava UP-TO-DATE
:copyTestKotlinClasses
:processTestResources UP-TO-DATE
:testClasses UP-TO-DATE
:test
:check
:build

BUILD SUCCESSFUL

Total time: 40.232 secs
```

编译报错的话，检查一下是不是你的代码本身就是错的。

Enjoy Gradle!
