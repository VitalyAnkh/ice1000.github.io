---
layout: post
title: 为什么我用 merge 而不用 rebase
category: Git
tags: Essay, Git
keywords: Git
description: Why merge not rebase
inline_latex: true
---

这是针对虎哥在[净土社区](https://www.eliseos.org/)的[一个问题](https://www.eliseos.org/en/water/post/23)的回答。

首先把题主批判一番，搜索都不会，来来来帮你搜索一下。

+ [https://www.zhihu.com/question/36509119](https://www.zhihu.com/question/36509119)
+ [https://www.atlassian.com/git/tutorials/merging-vs-rebasing](https://www.atlassian.com/git/tutorials/merging-vs-rebasing)

然后我正式回答问题：我不是说『要用 merge 替代 rebase』，而是我『不赞成别人使用 rebase 替代 merge』。

首先我们需要知道， merge 的作用是什么。  
merge 的存在目的是合并分支，包括但不限于合并开发分支和稳定分支、合并当前分支和 pull request 里的分支和合并远端分支和本地分支。

它的工作流程是什么？以你 pull 了一个和本地进度不同的分支为例。

+ $ \operatorname{let \ commit = unless} $ 两个需要合并的分支是否同时更改了同一个文件的同样几行
  + $ \operatorname{then \ do} $
    + 直接把两份 diff 以补丁的形式打到这两个分支的最近公共 commit 里
    + 自动产生一个叫做 merge commit 的特殊 commit
  + $ \operatorname{else \ do} $
    + $ \operatorname{let} $ 冲突 $ = $ 『更改了同样几行』的文件中的那同样的几行
    + 把冲突的两方同时插入那些文件的冲突位置，并注明各自的分支名
    + 你自己看着改，此时工作区处于一种特殊状态
    + 分别把改动的文件 add 进去
    + 撰写一个特殊 commit 叫 merge commit
+ $ \operatorname{in} $ 提交这个 $ \operatorname{commit} $

上文中，使用 LaTeX 的文本是用来描述逻辑的，其他的普通文本是说明用的自然语言。

你会在版本控制图中看见两个分支各自走着，到了这个 merge commit 后走到一起了。

你可以自由地把这份 merge 好的分支提交到你的远端。这时候，你本地的分支会被视为同时在这两个分支的前方。因此，远端分支可以直接接受你的本地分支。

那 ~~become gay~~ rebase 呢？

+ 找到两个分支的最近公共 commit ，分别把 diff 提取出来， revert 回去
+ 你自己慢慢改，自己 commit ，没有特殊 commit

可是你需要对远端使用 force push 。因为你 revert 回去了，所以说你现在的分支只是『你觉得』合并了本地和远端，对于 git 来说，远端和本地仍然是两个进展不同的分支。  
所以你需要把这份『你觉得』合并好了的代码强制覆盖到远端。

他们看起来达到的效果都是一样的。但是我们可以考虑一下，使用 force push 的危害。  
force push 工作流程是：

+ 上传完整的本地分支
+ 强制删除远端分支
+ 用本地分支代替当前远端分支

因此，原本的远端数据就没有了。如果你在手动产生这个『你觉得』合并的时候，一不小心在合并前就提交了，并且在没有注意到这一事实的时候进行了 force push ，那么你将永远失去被你提换掉的远端分支。  
**这是危害一。**

你还有可能正在编辑一个很大的 git 仓库（比如
[intellij-community](https://github.com/jetbrains/intellij-community):
[![GitHub repo size in bytes](https://img.shields.io/github/repo-size/jetbrains/intellij-community.svg)](https://github.com/jetbrains/intellij-community),
或者
[linux 内核](https://github.com/torvalds/linux):
[![GitHub repo size in bytes](https://img.shields.io/github/repo-size/torvalds/linux.svg)](https://github.com/torvalds/linux),
或者
[emacs](https://github.com/emacs-mirror/emacs):
[![GitHub repo size in bytes](https://img.shields.io/github/repo-size/emacs-mirror/emacs.svg)](https://github.com/emacs-mirror/emacs)
)，那么『上传完整的本地分支』这一过程，所花掉的时间会要了你的命。（还不如拿这时间打几百把东方星莲船）  
**这是危害二。**

针对危害一： merge 之后两个分支在 merge commit 前的完整记录都是有保留的。因此，你可以随时 checkout 回去改。  
针对危害二： merge commit 在 push 的时候是增量的。因此，你只需要上传远端没有的 diff 。

有一个见仁见智的问题，就是有人觉得：

+ merge commit 造成的这种『群分支乱舞』的分支视图里的混乱现象（ rebase 就只有一条线）很丑陋
+ merge commit 的撰写本身比较复杂

针对第一条，我并不在意，毕竟我大多数时间都在命令行下工作。非常复杂的分支视图，我反而觉得很酷炫。  
针对第二条，这些操作，在没有 IDE 的时候我也可以用命令行完成，我个人认为这都是非常简单的工作。

综上所述，我使用 merge 而不是 rebase 。
如果你觉得那两个危害确实是危害，那两个缺陷并不令人在意，你也应该很清楚你的选择。
