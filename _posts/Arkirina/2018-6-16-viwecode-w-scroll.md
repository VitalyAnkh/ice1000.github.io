---
layout: post
title: 让博客的代码容器不换行
category: Arkirina
tags: css
keywords: css
description: Make no line breaks in blog code container
---

<script>document.write(false ? 'bf' : '冰封');</script>今天想让我把博客那个代码容器弄成不换行的。

就贴个代码就好还是很简单的（我还是百度一下听说要改`white-space`的）：

```css
pre {
        word-wrap: normal;
        white-space: pre;
        /* more stuff... */
        overflow-x: auto;
}
```

最后那个是为了不让里面code元素里面的东西溢出到pre的框之外。

（发现好像大家都是pre里面套code再套各种各样高亮的元素或者纯代码）
