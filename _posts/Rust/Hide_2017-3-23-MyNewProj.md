---
layout: post
title: 新个人项目简介：项目管理器
category: Rust
tags: Rust
keywords: rust
description: new proj, proj_manager
---

## 最近新写的玩具

我这几天为了学习 Rust （这是一门很好的语言，我觉得就语言本身来说，比 Kotlin 更吸引我，但是因为 Kotlin 是 JetBrains 的，所以我本命还是 Kotlin ），
写了个小玩具，叫[proj_manager](https://github.com/ice1000/proj_manager)。之所以起这个名字是因为：

+ 项目名使用下划线是 Rust 规定的命名风格
+ project_manager 太长

也遇到了不少问题，写了不少幼稚的代码。不过 Rust 确实非常厉害，这也是我第一次在生产环境大量使用**模式匹配、Monad、代数数据类型（ ADT ）** 等东西，
还有一些我通过 Rust 才第一次接触的**Ownership、Move、Borrow**等概念。这种感觉已经很久没有过了
（我有一段时间没有这样集中地学习、练习一门全新的语言了，上次我大量学习 Lisp 的时候其实没有太多新概念，完全没有这次多），是一种非常美妙的感觉。
学习新知识的感觉真是妙不可言 DA★ZE ！

这也归功于送了我几本 Rust 书的打印版的[Glavo 小可爱](https://github.com/Glavo)，我花下课和晚自习时间啃完了《Rust Primer》，
写的也很不错，还是莎莎审校的，解决了我以前在知乎上看教程时对于 Deref 等概念的困惑。。感谢 wayslog 大佬 DA★ZE 。。。

回到正题，这个玩具是什么呢？

## 关于这个玩具

其实这个玩具是我很早之前就想过要写东西，现在还非常不成熟，只不过已经具备的功能都是完好的。它是一个命令行工具，不支持参数而是支持指令。

Windows 用户可以在 GitHub 的 release 界面找到可执行 exe 下载，其它系统的用户可以自己使用 Cargo 构建 DA★ZE。

## 使用方法

先打开命令行，进入到你的项目所在的位置（顾名思义， Project Manager 是帮助你管理你的项目的）。

直接打开，会看到一个 panic ，或者在之后的版本看到一个错误提示。这时因为你没有配置文件的缘故。在当前目录下新建一个文件『proj_config』就可以了。

这个文件是 proj_manager 的配置文件，等会告诉你咋用。

也就是说你现在的文件目录是：

```yml
root:
  - proj_manager.exe
  - proj_config
  - 其它文件
  - .git(可选)
```

好，然后重新运行这个程序，可以看到它进入了一个类似某解释性语言的 repl 的模式 DA★ZE。根据提示先输入 help ，看看都有哪些指令。

```c
Commands:
data           -- print the meta data stored in the cofiguration file.
ls             -- print all the files.
exit           -- exit project manager.
help           -- print this doc.
line           -- see how many lines of code is here in your project.
git            -- print git status.
```

这些命令都不带参数，使用非常非常无脑，对用户非常友好。~~其实是懒得整。~~

比如说我们输入 data ，可以看到配置信息。我们现在好像还没有配置所以你看不到什么东西。

我们输入 ls ，可以看到它遍历了这个文件树，输出了每个文件的文件相对路径和识别到的语言：

```c
.\.git\COMMIT_EDITMSG     => Language: Unknown
.\.git\config             => Language: Unknown
.\.git\description        => Language: Unknown
.\.git\HEAD               => Language: Unknown
.\.git\hooks\README.sample => Language: Unknown
.\.git\index              => Language: Unknown
.\.git\logs\HEAD          => Language: Unknown
.\.git\logs\refs\heads\master => Language: Unknown
.\.git\objects\32\4d8bc4cf4a34e72f448461c5e0884133cf2786 => Language: Unknown
.\.git\objects\5a\3d2bbbf812c45239d9db7de008957132fca245 => Language: Unknown
.\.git\objects\64\eb8ae3950d3fcc6bd929d7c33192c2437389e2 => Language: Unknown
.\.git\objects\78\7286b443d183264b5ba97217081560bc89fdc7 => Language: Unknown
.\.git\objects\92\c7c0394e0c70e8b209788f9816b8d3202a7962 => Language: Unknown
.\.git\objects\94\00d904e904901d5ba42c04b258c4a4b599d18a => Language: Unknown
.\.git\objects\96\bb2a832825dda878c23248489630ea6f7a17a2 => Language: Unknown
.\.git\objects\98\2f491c23bcad3f829eda13e912023d47d8ccb0 => Language: Unknown
.\.git\objects\9b\965543c46f7fd2876fc06f58aebbd70a04a7b9 => Language: Unknown
.\.git\objects\a9\d37c560c6ab8d4afbf47eda643e8c42e857716 => Language: Unknown
.\.git\objects\b0\4685e99846eeceb661e7210db3c420856fa3cf => Language: Unknown
.\.git\objects\de\c7ea91d56717ae950b14fba683bb73a4d6a245 => Language: Unknown
.\.git\objects\e6\9de29bb2d1d6434b8b29ae775ad8c2e48c5391 => Language: Unknown
.\.git\objects\f6\49e9d9b8009b6be7eca50451c5a299568a7da7 => Language: Unknown
.\.git\objects\pack\pack-17ecd6d39e4096275bc4f382dbe482b953ac44a5.idx => Language: Unknown
.\.git\objects\pack\pack-17ecd6d39e4096275bc4f382dbe482b953ac44a5.pack => Language: Unknown
.\.git\packed-refs        => Language: Unknown
.\.gitignore              => Language: Git Ignore
.\build.bat               => Language: Batch
.\Cargo.toml              => Language: TOML
.\clean.bat               => Language: Batch
.\LICENSE                 => Language: Unknown
.\proj_config             => Language: proj_manager config
.\src\bin\command.rs      => Language: Rust
.\src\bin\drug.rs         => Language: Rust
.\src\bin\string_apis.rs  => Language: Rust
.\src\config.rs           => Language: Rust
.\src\files.rs            => Language: Rust
.\src\funcs.rs            => Language: Rust
.\src\lang.rs             => Language: Rust
.\src\main.rs             => Language: Rust
.\src\model.rs            => Language: Rust
```

可以看到，由于 Git 的原因，它识别出了巨量的、你不想统计的文件 DA★ZE。于是我引入了忽略功能，等会讲。

我们输入 line ，可以看到它统计了代码行数：

```c
In .\.gitignore              => 12  lines, 6  per line.
In .\build.bat               => 17  lines, 32 per line.
In .\Cargo.toml              => 8   lines, 20 per line.
In .\clean.bat               => 11  lines, 38 per line.
In .\LICENSE                 => 675 lines, 52 per line.
In .\proj_config             => 15  lines, 12 per line.
In .\src\bin\command.rs      => 12  lines, 18 per line.
In .\src\bin\string_apis.rs  => 8   lines, 11 per line.
In .\src\config.rs           => 77  lines, 25 per line.
In .\src\files.rs            => 34  lines, 24 per line.
In .\src\funcs.rs            => 164 lines, 23 per line.
In .\src\lang.rs             => 172 lines, 21 per line.
In .\src\main.rs             => 53  lines, 22 per line.
In .\src\model.rs            => 92  lines, 17 per line.
Total: 1350 lines of code.
```

输入 git 可以查看一些基本信息（有哪些文件是改动了的，哪些改动暂存了的），以及自动运行`git gc`。
这不会对你造成什么影响，但是会减少 Git 的哈希文件数量，方便压缩拷贝什么的：

```c
Git root detected in project_manager.
On branch master
Changes to be committed:
        modified:   clean.bat
        modified:   src/lang.rs
Changes not staged for commit:
        modified:   src/funcs.rs
        modified:   src/lang.rs
Running git gc..
Git gc finished.
```

这些是截止本文发布时的基本指令，以后可能有更多。

然后就是关于这个 proj_config 配置文件的说明了。

## 配置

语法采用键值对的形式，类似 properties ：

```c
键:值
```

注意冒号是半角。不理解的可以看下面的 Sample 。如果是不存在的键值，或者你压根就没按照格式写，那么该行会被当成注释。

首先是几个最基本的配置 DA★ZE ：

键|值
:---|---:
ign|忽略给定名字的文件
ign-sfx|忽略具有给定扩展名的文件
name|项目名称

好，我们看个例子：

```c
name:project_manager
ign:Cargo.lock
ign:.idea
ign:.git
ign:target
ign-sfx:exe
ign-sfx:o
ign-sfx:jar
ign-sfx:class
ign-sfx:d
```

这就是我的项目自己在用的配置 DA★ZE ，忽略了扩展名为 jar、class、o、exe 的文件，忽略了.git 和.idea 目录，以及 Cargo.lock。

项目名是 project_manager。于是我们在更改配置为以上内容时，就可以通过 data 命令来查看数据：

```c
Name:
        project_manager
Path:
        ./proj_config
Ignored:
        Cargo.lock
        .idea
        .git
        target
Ignored Suffix:
        exe
        o
        jar
        class
        d
```

使用 ls 和 line 指令，被忽略的文件不会被显示出来：

```c
.\.gitignore              => Language: Git Ignore
.\build.bat               => Language: Batch
.\Cargo.toml              => Language: TOML
.\clean.bat               => Language: Batch
.\LICENSE                 => Language: Unknown
.\proj_config             => Language: proj_manager config
.\src\bin\command.rs      => Language: Rust
.\src\bin\drug.rs         => Language: Rust
.\src\bin\string_apis.rs  => Language: Rust
.\src\config.rs           => Language: Rust
.\src\files.rs            => Language: Rust
.\src\funcs.rs            => Language: Rust
.\src\lang.rs             => Language: Rust
.\src\main.rs             => Language: Rust
.\src\model.rs            => Language: Rust
```

刚才那个被.git 目录下的哈希文件污染的问题已经得到完美解决。但是，如果是 Frice 这种目录较长的项目， ls 命令还是会遇到对齐的问题：

```c
.\.classpath                     => Language: Unknown
.\.gitignore                     => Language: Git Ignore
.\.project                       => Language: Unknown
.\apis.md                        => Language: Markdown
.\build.bat                      => Language: Batch
.\FriceEngine.iml                => Language: XML
.\LICENSE                        => Language: Unknown
.\proj_config                    => Language: proj_manager config
.\README.md                      => Language: Markdown
.\res\META-INF\MANIFEST.MF       => Language: Manifest
.\src\org\frice\game\anim\FAnim.kt => Language: Kotlin
.\src\org\frice\game\anim\move\Move.kt => Language: Kotlin
.\src\org\frice\game\anim\RotateAnim.kt => Language: Kotlin
.\src\org\frice\game\anim\scale\Scale.kt => Language: Kotlin
.\src\org\frice\game\event\Events.kt => Language: Kotlin
.\src\org\frice\game\Game.kt     => Language: Kotlin
.\src\org\frice\game\obj\button\Buttons.kt => Language: Kotlin
.\src\org\frice\game\obj\button\Texts.kt => Language: Kotlin
.\src\org\frice\game\obj\effects\Effects.kt => Language: Kotlin
.\src\org\frice\game\obj\Objects.kt => Language: Kotlin
.\src\org\frice\game\obj\sub\BoneObject.kt => Language: Kotlin
.\src\org\frice\game\obj\sub\ImageObject.kt => Language: Kotlin
.\src\org\frice\game\obj\sub\ShapeObject.kt => Language: Kotlin
.\src\org\frice\game\platform\adapter\JvmAdapter.kt => Language: Kotlin
.\src\org\frice\game\platform\Adapter.kt => Language: Kotlin
.\src\org\frice\game\resource\FResource.kt => Language: Kotlin
.\src\org\frice\game\resource\graphics\GraphicsResource.kt => Language: Kotlin
.\src\org\frice\game\resource\image\ImageResource.kt => Language: Kotlin
.\src\org\frice\game\resource\manager\Managers.kt => Language: Kotlin
.\src\org\frice\game\special\gal\GalGame.kt => Language: Kotlin
.\src\org\frice\game\special\package-info.kt => Language: Kotlin
.\src\org\frice\game\utils\audio\AudioManager.kt => Language: Kotlin
.\src\org\frice\game\utils\audio\AudioPlayer.kt => Language: Kotlin
.\src\org\frice\game\utils\data\Databases.kt => Language: Kotlin
.\src\org\frice\game\utils\data\FileUtils.kt => Language: Kotlin
.\src\org\frice\game\utils\graphics\shape\Shapes.kt => Language: Kotlin
.\src\org\frice\game\utils\graphics\utils\ColorUtils.kt => Language: Kotlin
.\src\org\frice\game\utils\message\error\FatalError.kt => Language: Kotlin
.\src\org\frice\game\utils\message\FDialog.kt => Language: Kotlin
.\src\org\frice\game\utils\message\log\FLog.kt => Language: Kotlin
.\src\org\frice\game\utils\misc\KotlinUtils.kt => Language: Kotlin
.\src\org\frice\game\utils\misc\QuadTree.kt => Language: Kotlin
.\src\org\frice\game\utils\misc\TestUtils.kt => Language: Kotlin
.\src\org\frice\game\utils\time\Clock.kt => Language: Kotlin
.\src\org\frice\game\utils\time\Timers.kt => Language: Kotlin
.\src\org\frice\game\utils\web\HTMLUtils.kt => Language: Kotlin
.\src\org\frice\game\utils\web\WebUtils.kt => Language: Kotlin
.\test\Java.java                 => Language: Java
.\test\org\frice\game\PreferenceTest.kt => Language: Kotlin
.\test\org\frice\game\Test.kt    => Language: Kotlin
.\test\org\frice\game\Test2.kt   => Language: Kotlin
.\test\org\frice\game\Test3.kt   => Language: Kotlin
.\test\org\frice\game\XMLPreferenceTest.kt => Language: Kotlin
```

于是你就需要通过配置文件来指定对齐了。现在有如下可以定制的对齐，请在这些键对应的地方写上合法的整数：

键|值
:---|---:
idt-ls-1|ls 命令的`=\>`左边对齐
idt-line-1|line 命令的`=\>`左边对齐
idt-line-2|line 命令的`lines`左边对齐
idt-line-3|line 命令的`per`左边对齐

举个例子，我们有：

```c
idt-line-1:60
idt-ls-1:60
idt-line-3:3
```

然后对 Frice 使用 ls ：

```c
.\.classpath                                                 => Language: Unknown
.\.gitignore                                                 => Language: Git Ignore
.\.project                                                   => Language: Unknown
.\apis.md                                                    => Language: Markdown
.\build.bat                                                  => Language: Batch
.\FriceEngine.iml                                            => Language: XML
.\LICENSE                                                    => Language: Unknown
.\proj_config                                                => Language: proj_manager config
.\README.md                                                  => Language: Markdown
.\res\META-INF\MANIFEST.MF                                   => Language: Manifest
.\src\org\frice\game\anim\FAnim.kt                           => Language: Kotlin
.\src\org\frice\game\anim\move\Move.kt                       => Language: Kotlin
.\src\org\frice\game\anim\RotateAnim.kt                      => Language: Kotlin
.\src\org\frice\game\anim\scale\Scale.kt                     => Language: Kotlin
.\src\org\frice\game\event\Events.kt                         => Language: Kotlin
.\src\org\frice\game\Game.kt                                 => Language: Kotlin
.\src\org\frice\game\obj\button\Buttons.kt                   => Language: Kotlin
.\src\org\frice\game\obj\button\Texts.kt                     => Language: Kotlin
.\src\org\frice\game\obj\effects\Effects.kt                  => Language: Kotlin
.\src\org\frice\game\obj\Objects.kt                          => Language: Kotlin
.\src\org\frice\game\obj\sub\BoneObject.kt                   => Language: Kotlin
.\src\org\frice\game\obj\sub\ImageObject.kt                  => Language: Kotlin
.\src\org\frice\game\obj\sub\ShapeObject.kt                  => Language: Kotlin
.\src\org\frice\game\platform\adapter\JvmAdapter.kt          => Language: Kotlin
.\src\org\frice\game\platform\Adapter.kt                     => Language: Kotlin
.\src\org\frice\game\resource\FResource.kt                   => Language: Kotlin
.\src\org\frice\game\resource\graphics\GraphicsResource.kt   => Language: Kotlin
.\src\org\frice\game\resource\image\ImageResource.kt         => Language: Kotlin
.\src\org\frice\game\resource\manager\Managers.kt            => Language: Kotlin
.\src\org\frice\game\special\gal\GalGame.kt                  => Language: Kotlin
.\src\org\frice\game\special\package-info.kt                 => Language: Kotlin
.\src\org\frice\game\utils\audio\AudioManager.kt             => Language: Kotlin
.\src\org\frice\game\utils\audio\AudioPlayer.kt              => Language: Kotlin
.\src\org\frice\game\utils\data\Databases.kt                 => Language: Kotlin
.\src\org\frice\game\utils\data\FileUtils.kt                 => Language: Kotlin
.\src\org\frice\game\utils\graphics\shape\Shapes.kt          => Language: Kotlin
.\src\org\frice\game\utils\graphics\utils\ColorUtils.kt      => Language: Kotlin
.\src\org\frice\game\utils\message\error\FatalError.kt       => Language: Kotlin
.\src\org\frice\game\utils\message\FDialog.kt                => Language: Kotlin
.\src\org\frice\game\utils\message\log\FLog.kt               => Language: Kotlin
.\src\org\frice\game\utils\misc\KotlinUtils.kt               => Language: Kotlin
.\src\org\frice\game\utils\misc\QuadTree.kt                  => Language: Kotlin
.\src\org\frice\game\utils\misc\TestUtils.kt                 => Language: Kotlin
.\src\org\frice\game\utils\time\Clock.kt                     => Language: Kotlin
.\src\org\frice\game\utils\time\Timers.kt                    => Language: Kotlin
.\src\org\frice\game\utils\web\HTMLUtils.kt                  => Language: Kotlin
.\src\org\frice\game\utils\web\WebUtils.kt                   => Language: Kotlin
.\test\Java.java                                             => Language: Java
.\test\org\frice\game\PreferenceTest.kt                      => Language: Kotlin
.\test\org\frice\game\Test.kt                                => Language: Kotlin
.\test\org\frice\game\Test2.kt                               => Language: Kotlin
.\test\org\frice\game\Test3.kt                               => Language: Kotlin
.\test\org\frice\game\XMLPreferenceTest.kt                   => Language: Kotlin
```

使用 line ：

```c
In .\.classpath                                                 => 8    lines, 38  per line.
In .\.gitignore                                                 => 42   lines, 12  per line.
In .\.project                                                   => 50   lines, 23  per line.
In .\apis.md                                                    => 316  lines, 30  per line.
In .\build.bat                                                  => 11   lines, 12  per line.
In .\FriceEngine.iml                                            => 19   lines, 51  per line.
In .\LICENSE                                                    => 675  lines, 52  per line.
In .\proj_config                                                => 12   lines, 12  per line.
In .\README.md                                                  => 89   lines, 40  per line.
In .\res\META-INF\MANIFEST.MF                                   => 4    lines, 10  per line.
In .\src\org\frice\game\anim\FAnim.kt                           => 15   lines, 19  per line.
In .\src\org\frice\game\anim\move\Move.kt                       => 180  lines, 22  per line.
In .\src\org\frice\game\anim\RotateAnim.kt                      => 11   lines, 19  per line.
In .\src\org\frice\game\anim\scale\Scale.kt                     => 29   lines, 20  per line.
In .\src\org\frice\game\event\Events.kt                         => 55   lines, 16  per line.
In .\src\org\frice\game\Game.kt                                 => 523  lines, 26  per line.
In .\src\org\frice\game\obj\button\Buttons.kt                   => 97   lines, 25  per line.
In .\src\org\frice\game\obj\button\Texts.kt                     => 33   lines, 22  per line.
In .\src\org\frice\game\obj\effects\Effects.kt                  => 128  lines, 27  per line.
In .\src\org\frice\game\obj\Objects.kt                          => 187  lines, 22  per line.
In .\src\org\frice\game\obj\sub\BoneObject.kt                   => 13   lines, 22  per line.
In .\src\org\frice\game\obj\sub\ImageObject.kt                  => 69   lines, 30  per line.
In .\src\org\frice\game\obj\sub\ShapeObject.kt                  => 80   lines, 28  per line.
In .\src\org\frice\game\platform\adapter\JvmAdapter.kt          => 94   lines, 31  per line.
In .\src\org\frice\game\platform\Adapter.kt                     => 172  lines, 23  per line.
In .\src\org\frice\game\resource\FResource.kt                   => 10   lines, 16  per line.
In .\src\org\frice\game\resource\graphics\GraphicsResource.kt   => 198  lines, 30  per line.
In .\src\org\frice\game\resource\image\ImageResource.kt         => 118  lines, 25  per line.
In .\src\org\frice\game\resource\manager\Managers.kt            => 85   lines, 22  per line.
In .\src\org\frice\game\special\gal\GalGame.kt                  => 190  lines, 24  per line.
In .\src\org\frice\game\special\package-info.kt                 => 7    lines, 18  per line.
In .\src\org\frice\game\utils\audio\AudioManager.kt             => 23   lines, 20  per line.
In .\src\org\frice\game\utils\audio\AudioPlayer.kt              => 66   lines, 21  per line.
In .\src\org\frice\game\utils\data\Databases.kt                 => 179  lines, 26  per line.
In .\src\org\frice\game\utils\data\FileUtils.kt                 => 34   lines, 26  per line.
In .\src\org\frice\game\utils\graphics\shape\Shapes.kt          => 115  lines, 22  per line.
In .\src\org\frice\game\utils\graphics\utils\ColorUtils.kt      => 34   lines, 22  per line.
In .\src\org\frice\game\utils\message\error\FatalError.kt       => 15   lines, 17  per line.
In .\src\org\frice\game\utils\message\FDialog.kt                => 64   lines, 31  per line.
In .\src\org\frice\game\utils\message\log\FLog.kt               => 38   lines, 16  per line.
In .\src\org\frice\game\utils\misc\KotlinUtils.kt               => 75   lines, 20  per line.
In .\src\org\frice\game\utils\misc\QuadTree.kt                  => 144  lines, 21  per line.
In .\src\org\frice\game\utils\misc\TestUtils.kt                 => 18   lines, 18  per line.
In .\src\org\frice\game\utils\time\Clock.kt                     => 40   lines, 20  per line.
In .\src\org\frice\game\utils\time\Timers.kt                    => 50   lines, 23  per line.
In .\src\org\frice\game\utils\web\HTMLUtils.kt                  => 46   lines, 20  per line.
In .\src\org\frice\game\utils\web\WebUtils.kt                   => 64   lines, 22  per line.
In .\test\Java.java                                             => 24   lines, 22  per line.
In .\test\org\frice\game\PreferenceTest.kt                      => 25   lines, 16  per line.
In .\test\org\frice\game\Test.kt                                => 122  lines, 30  per line.
In .\test\org\frice\game\Test2.kt                               => 43   lines, 25  per line.
In .\test\org\frice\game\Test3.kt                               => 37   lines, 23  per line.
In .\test\org\frice\game\XMLPreferenceTest.kt                   => 33   lines, 16  per line.
Total: 4809 lines of code.
```

快去愉快地玩耍吧！顺便求 Rust 聚聚帮我看看代码，初学者的代码是肯定会有大量的 worst practise 和 naive codes ，
请感到自由来帮我指出来（谜之英语）！
