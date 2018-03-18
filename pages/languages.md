---
layout: page
title: Programming Languages I contributed to
description: ice1000 contributed languages
keywords: ice1000
menu: Languages
permalink: /languages/
---

[简体中文](../languages-cn/)

# Lice

My first programming language, created before learning compiler theories because I want to put some ideas into practise.  
Its syntax looks like Lisp, and I removed all syntax sugars to make the parser's time complexity proportional to the code length.
Encouraged by Marisa, I successfully implemented three evaluation models -- call by name (like but not C's macro),
call by value (the most common one) and call by need (lazy evaluation).  
It's written in Kotlin, execute through traversing AST (it's naive, I know). It also has a unfinished Haskell implementation.  
This language doesn't have reserved words, all the language construct (including control flows like `if` `while`, anonymous function creation like `lambda` `expr` `lazy`,
very basic stuffs like `def` `def?` `defexpr`) are implemented in the standard library.  
The way standard library is provided is bizarre: I write a Kotlin class and bind all their methods to Lice's symbol table.  
Lice's purpose is to be a scripting language depends on JVM languages, all the complicated programs should be written in JVM languages and invoked
in Lice by using Lice's API.

The worst point of Lice is it's name -- it means a kind of insect, but I didn't know this when I name it (I was at school, no internet access)

### Related Links

+ [IntelliJ IDEA-based IDE](https://plugins.jetbrains.com/plugin/10319-lice)
+ [Command line REPL](https://github.com/lice-lang/ldk)（支持彩色输出和代码补全）
+ [Android RPEL](https://github.com/lice-lang/lice-android)
+ [Language Reference](https://github.com/lice-lang/lice-reference)
+ [Interpreter Source](https://github.com/lice-lang/lice)
+ [Tiny Interpreter](https://github.com/lice-lang/lice-tiny)

The AST Editor, code formater appeared with the first version are all lost along with the change of my working environment.

Here's a video about Lice:

<iframe width="560" height="315" src="https://www.youtube.com/embed/c-l9bZmT-ow?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

# CovScript

This is a programming language created by my friend Michael Lee, written in C++. The detailed description is on it's website so I'll just put some comments here. 
This is a C-like language (at least the function call syntax is of C style), while functions, structs, namespaces are ends with `end` like Ruby, and it has the concepts of `package` `import` `using` (the module system).  
Its parser is hand-written (very complex, although parsers are trivial), which impressed me (I didn't even think of that when working on Lice, I just wrote an AST evaluator).  
This language supports invoking functions written in C++, like JNI.

CovScript mostly features its powerful standard library, which has database, GUI, web access, regular expressions.

### Related Links

+ [IntelliJ IDEA-based IDE](https://plugins.jetbrains.com/plugin/10326-covscript/), my new year present for MikeCovLee in 2018
+ [Interpreter Source](https://github.com/covscript/covscript)
+ [Website](http://covscript.org)
+ [Documentation](../cov-docs/)


