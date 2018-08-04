---
layout: post
title: Agda 实现类型安全的 printf
category: Agda
tags: Agda, Proof
keywords: Agda, Proof, Printf
description: Agda type safe printf
inline_latex: true
agda: true
---

[完整问题描述](https://pdfs.semanticscholar.org/27f2/393d75a63288871c546b57c03bb4d8ae7a19.pdf)

首先我自己想了一个比较 naive 的实现，是把`printf`的填充变量的参数做成一个`List`，然后对这个`List`通过 dependent function 的特性进行一些限制，达到类型安全的效果（比如传入一个该`List`合法的证明）。<br/>
于是我写了一个很丑很幼稚很年轻很简单的实现，最后发现传递证明比较繁琐，肯定是不理想的，遂放弃（并没有很好地理由 dependent type 的类型系统对输入做约束）。代码已经写不下去了，存了一个在[gist](/gist/safe-printf-agda-givenup/)上。<br/>
然后我看到了 dram 的回答，写的很 inspiring（首先用一个函数根据输入类型返回`printf`的类型，然后再写真正的实现），然后我学习了一波之后弄了一个 Agda 的。由于 Agda 对浮点的支持好像很挫，我就把对浮点数的支持改成了对`Char`类型的支持。<br/>
我们先导入一些必需的东西，需要标准库。

```agda
module Printf where

open import Data.List using (List; _∷_; [])
open import Data.Char renaming (Char to ℂ; show to showℂ)
open import Data.Nat using (ℕ; _+_)
open import Data.Nat.Show renaming (show to showℕ)
open import Data.Empty
open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import Relation.Nullary using (yes; no)
open import Function
open import Coinduction

open import Data.String using (toList; fromList; String; _++_)
```

思路是：

0. 对格式化字符串进行解析，返回一个带元信息的`List`
0. 实现一个带元信息的`List`到完整`printf`类型的函数
0. 实现`printf`

首先我们需要定义这个带元信息的`List`的成员的 ADT：

```agda
data Fmt : Set where
  fmt : ℂ → Fmt
  lit : ℂ → Fmt
```

然后实现『根据格式化字符判断类型』的函数和『根据格式化字符和对应的类型的值返回字符串』的函数（过于简单，不予赘述。全部照抄 dram 版本）：

```agda
ftype : ℂ → Set
ftype 'd' = ℕ
ftype 'c' = ℂ
ftype _ = ⊥

format : (c : ℂ) → ftype c → String
format 'd' = showℕ
format 'c' c = fromList $ c ∷ []
format _ = const ""
```

然后实现『解析格式化字符串，返回带元信息的List』：

```agda
parseF : List ℂ → List Fmt
parseF [] = []
parseF (x ∷ xs) with xs | x ≟ '%'
...         | '%' ∷ xss | yes _ = lit '%' ∷ parseF xss
...         |  c  ∷ xss | yes _ = fmt c ∷ parseF xss
...         | [] | yes _ = lit '%' ∷ []
...         | _  | no  _ = lit x ∷ parseF xs
```

然后这个函数 Agda 给我报了个 termination error，我觉得不大对劲。于是我去[问了](https://github.com/agda/agda/issues/3173)，维护者说是因为`with`给函数加了一层 pm 导致 Agda 无法判断这个函数是正确的。<br/>
这也太智障了吧，但好在我看懂了 dram 的实现，就重写了一个不用`with`的（其实我也不是很懂为什么 dram 要用`with`，我觉得超难用）：

```agda
parseF : List ℂ → List Fmt
parseF [] = []
parseF ('%' ∷ '%' ∷ cs) = lit '%' ∷ parseF cs
parseF ('%' ∷  c  ∷ cs) = fmt c ∷ parseF cs
parseF ( c  ∷  cs) = lit c ∷ parseF cs
```

然后这个就 check 了，我们再实现『根据格式化字符串判断`printf`完整类型』的函数：

```agda
ptype : List Fmt → Set
ptype [] = String
ptype (fmt x ∷ xs) = ftype x → ptype xs
ptype (lit x ∷ xs) = ptype xs

printfType : String → Set
printfType = ptype ∘ parseF ∘ toList
```

最后实现`printf`的逻辑：

```agda
printfImpl : (fmt : List Fmt) → String → ptype fmt
printfImpl [] pref = pref
printfImpl (fmt x ∷ xs) pref val = printfImpl xs $ pref ++ format x val
printfImpl (lit x ∷ xs) pref = printfImpl xs $ pref ++ (fromList $ x ∷ [])
```

然后把它包一层：

```agda
printf : (fmt : String) → printfType fmt
printf s = printfImpl (parseF $ toList s) ""
```

随手证明：

```agda
proof₀ : printf "Hello, World!"
              ≡ "Hello, World!"
proof₀ = refl

proof₁ : printf "%% %% (%d + %d = %d) (toChar %d = %c)" 114 514 628 6 '6'
              ≡ "% % (114 + 514 = 628) (toChar 6 = 6)"
proof₁ = refl
```

我们还可以加入字符串支持。
修改以下函数：

```agda
ftype : ℂ → Set
ftype 'd' = ℕ
ftype 'c' = ℂ
ftype 's' = String
ftype _ = ⊥

format : (c : ℂ) → ftype c → String
format 'd' = showℕ
format 'c' c = fromList $ c ∷ []
format 's' = id
format _ = const ""
```

然后验证：

```agda
proof₂ : printf "%d岁，是%s" 24 "学生"
              ≡ "24岁，是学生"
proof₂ = refl
```

错误情况的证明：

```agda
proof₃ : printf "%d岁，是%s" 25 "学生"
              ≢ "24岁，是学生"
proof₃ ()
```

怎么样，是不是妙不可言。
错误情况的证明需要修改一句`import` ：

```agda
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl)
```

[完整实现](/gist/safe-printf-agda/)

$$
\downarrow \\
\bot
$$
