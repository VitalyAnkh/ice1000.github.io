---
layout: post
title: 解决一个神奇的webpack问题 - Cannot find module 'webpack/schemas/WebpackOptions.json'
category: Arkirina
tags: webpack
keywords: webpack
description: WebOptions.json not found in Webpack
---

偷懒并不想写多少甚至还提早一年发布的我。

在使用webpack的时候有时会出现这样子的错误：

```
Error: Cannot find module 'webpack/schemas/WebpackOptions.json'
```

不过网上并没有什么资料？？？？

事实上只是忘记在项目里面`npm install --save-dev webpack`罢了。
