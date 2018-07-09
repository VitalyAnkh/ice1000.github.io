---
layout: page
title: 关于
description: 关于
keywords: ice1000
comments: true
menu: 关于
permalink: /about-cn/
---

[English](../about/)

欢迎来到我的博客『中间表示 (IR) 』。

我是一个因兴趣而编程的学生，喜欢研究代码编辑器和程序语言的设计和实现；
热爱小动物（比如蛇）和运动（游泳，足球和悠悠球）。

一般使用『ice1000』，『千里冰封』或『Tesla Ice Zhang』作为我的 ID 。

+ [简历](../resume-cn/)
+ [**我的开源社区贡献**](../opensource-contributions/)
+ 在 [YouTrack][yt] 活跃

+ 社交账户
  + [GitHub][gh]
  + [Bintray][bt]
  + [StackOverflow][so]
  + [CodeWars][cw]

+ 联系我
  + [QQ 群](http://shang.qq.com/wpa/qunwpa?idkey=b75f6d506820d00cd5e7fc78fc5e5487a3444a4a6af06e9e6fa72bccf3fa9d1a)
  + [电子邮件][mail]
+ 订阅
  + [其他方式](../subscribe-cn/)
  + [RSS](../feed.xml)
+ 个人信息
  + [GitHub 用户分析][gh sum]
  + [CodeWars](../codewars-cn/)
  + [**StackOverflow 开发者故事**][so ds]
    + [保存为 pdf][so ds pdf]
+ [一些有趣的代码片段](../gists/)

[![](http://stackexchange.com/users/flair/9532102.png)](http://stackoverflow.com/users/7083401/ice1000 "profile for ice1000 at Stack Overflow, Q&A for professional and enthusiast programmers")

 [gh]: https://github.com/{{ site.github_username }}
 [gh sum]: https://github-profile-summary.com/user/ice1000
 [bt]: https://bintray.com/ice1000
 [so]: http://stackoverflow.com/users/7083401/ice1000
 [so ds]: http://stackoverflow.com/story/ice1000
 [so ds pdf]: https://stackoverflow.com/users/story/pdf/7083401?View=Pdf
 [cw]: http://www.codewars.com/users/ice1000
 [yt]: https://youtrack.jetbrains.com/issues?q=by:%20ice1000
 [mail]: mailto:ice1000@kotliner.cn

### 这个博客的名字的含义

> 如果翻译器对程序进行了彻底的分析而非某种机械的变换，而且生成的中间程序与源程序之间已经没有很强的相似性，我们就认为这个语言是编译的。彻底的分析和非平凡的变换，是编译方式的标志性特征。

-- 《 Programming Language Pragmatics 》

> 如果你对知识进行了彻底的分析而非某种机械的套弄，在你脑中生成的概念与生硬的文字之间已经没有很强的相似性，我们就认为这个概念是被理解的。彻底的分析和非凡的变换，是获得真知的标志性特征。

-- 我的一个朋友

<!-- ## StackExchange 网站 -->

<!-- + [![](https://gamedev.stackexchange.com/users/flair/106607.png)](https://gamedev.stackexchange.com/users/106607/ice1000 "profile for ice1000 at Game Development Stack Exchange, Q&A for professional and independent game developers") -->
<!-- + [![](https://codegolf.stackexchange.com/users/flair/70943.png)](https://codegolf.stackexchange.com/users/70943/ice1000 "profile for ice1000 at Programming Puzzles & Code Golf Stack Exchange, Q&A for programming puzzle enthusiasts and code golfers") -->
<!-- + [![](https://askubuntu.com/users/flair/721173.png)](https://askubuntu.com/users/721173/ice1000 "profile for ice1000 at Ask Ubuntu, Q&A for Ubuntu users and developers") -->
<!-- + [![](https://tex.stackexchange.com/users/flair/145304.png)](https://tex.stackexchange.com/users/145304/ice1000 "profile for ice1000 at TeX - LaTeX Stack Exchange, Q&amp;A for users of TeX, LaTeX, ConTeXt, and related typesetting systems") -->

<!-- ## Contact -->

<!-- {% for website in site.data.social %} -->
<!-- * {{ website.sitename }}：[@{{ website.name }}]({{ website.url }}) -->
<!-- {% endfor %} -->

## 博客政策

<!--
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/协议-知识共享署名--非商业性使用--禁止演绎%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc-nd/4.0/)
<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">
<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" />
</a>
-->

所有这个网站的博客和文章都采用
<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">
知识共享署名-非商业性使用-禁止演绎 4.0 国际许可协议</a>。

## 友情链接

{% for link in site.data.links %}
{% if link.name_cn == nil %}
* [{{ link.name }}]({{ link.url }})
{% else %}
* [{{ link.name_cn }}]({{ link.url }})
{% endif %}
{% endfor %}
