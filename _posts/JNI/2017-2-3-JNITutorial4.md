---
layout: post
title: JNI 开发：第四章 个人经验分享
category: JNI
tags: Java
keywords: Java,JNI,C++
description: JNI Tutorial
---

## 为什么要学习我的个人经验分享

+ 因为我已经验证过代码的正确性了（难道不是必须的吗喂
+ 免得莫名其妙被坑
+ 因为我觉得我的这些东西是有普适性的
+ 因为我刚看完 IBM 一篇讲这个的文章，虽然这篇可能不会提到

## 为什么不看 IBM 的文章而看我的博客

+ 因为我还会写不一样的
+ 因为我的是中文的
+ 因为我觉得我写的很搞笑或者说很残念，能不能 get 到笑点就是你的事了

## 为什么我要说是我的经验分享

+ 因为这真的是我自己意淫出来的
+ 怕甩锅到别人身上，误伤别人导致别人中伤我，还不如一开始就火力集中到我身上
+ 反正我就是个辣鸡，都是你们迈向成功之路的垫脚石

## 为什么我又开始勃化了

+ 因为我太失败了

## 好了住脑。说正事。

## 依赖

+ 上三篇教程积累的知识
+ 牢记上篇教程的代码风格约定，这次要用
+ 智商

## 先想个你要写的东西

比如离散化一个 int 序列

## 然后开始写

先写好 Java 接口。

```java
package jni;

/**
 * Created by ice1000 on 2017/2/4.
 *
 * @author ice1000
 */
public class Main {
  public static native int[] discretization(int[] data);
}
```

然后编译， javah 获取头文件。其实就是老早就做过好几遍的事情，我们再做一遍。然后编写对应的实现：

```cpp
#include "Main.h"

template<typename T1, typename T2>
class Pair {
public:
  T1 first;
  T2 second;
  constexpr Pair(const T1 &f, const T2 &s) : first(f), second(s) {}
  constexpr explicit Pair() : first(), second() {}
  void setValue(const T1 &f, const T2 &s) { first = f, second = s; }
  constexpr auto operator<(const Pair &o) const -> const bool { return first == o.first ? second < o.second : first < o.first; }
};

template<typename T>
auto merge_sort_recursive(T arr[], T reg[], jsize start, jsize end) -> void {
  if (start >= end) return;
  auto len = end - start, mid = (len >> 1) + start;
  auto start1 = start, end1 = mid;
  auto start2 = mid + 1, end2 = end;
  merge_sort_recursive(arr, reg, start1, end1);
  merge_sort_recursive(arr, reg, start2, end2);
  auto k = start;
  while (start1 <= end1 and start2 <= end2) reg[k++] = arr[start1] < arr[start2] ? arr[start1++] : arr[start2++];
  while (start1 <= end1) reg[k++] = arr[start1++];
  while (start2 <= end2) reg[k++] = arr[start2++];
  for (k = start; k <= end; ++k) arr[k] = reg[k];
}

template<typename T>
auto merge_sort(
    T *arr,
    const jsize length) -> void {
  auto reg = new T[length]();
  merge_sort_recursive(arr, reg, 0, length - 1);
}

template<typename T>
inline auto discretization(
    T *data,
    const jsize len) -> T * {
  auto pair = new Pair<T, jint>[len]();
  auto after = new T[len]();
  for (auto _ = 0; _ < len; ++_) pair[_].setValue(data[_], _);
  merge_sort(pair, len);
  for (auto _ = 0, __ = 0; _ < len; ++_, ++__) {
    after[pair[_].second] = __;
    if ((_ + 1 < len) and pair[_].first == pair[_ + 1].first) --__;
  }
  delete[] pair;
  return after;
}

JNIEXPORT auto JNICALL Java_jni_Main_discretization(
    JNIEnv *env,
    jclass,
    jintArray _data) -> jintArray {
  jboolean *option = nullptr;
  auto len = env->GetArrayLength(_data);
  auto data = env->GetIntArrayElements(_data, option);
  auto ret = discretization(data, len);
  env->ReleaseIntArrayElements(_data, data, JNI_ABORT);
  auto _ret = env->NewIntArray(len);
  env->SetIntArrayRegion(_ret, 0, len, ret);
  delete option;
  delete ret;
  return _ret;
}
```

然后编译，像教程一里面那样运行。我觉得应该不会有啥问题，这个 native 返回的是 data 离散化的结果。
为了避免被打脸（毕竟这东西我是准备发知乎的，上一篇文章就被知乎突然出现的『大神』给喷了，着实让我捏了一把汗），我又去写了个程序验证上面的代码的正确性。

可以写一下测试代码，下面给出我自己测试用的代码：

```java
public static void main(String[] args) {
  System.loadLibrary("jni");
  Random random = new Random(System.currentTimeMillis());
  int[] origin = new int[]{
    random.nextInt(233333),
    random.nextInt(233333),
    random.nextInt(233333),
    random.nextInt(233333),
    random.nextInt(233333),
    random.nextInt(233333),
    random.nextInt(233333),
    random.nextInt(233333)
  };
  System.out.println(Arrays.toString(origin));
  System.out.println(Arrays.toString(discretization(origin)));
  System.out.println(Arrays.toString(origin));
}
```

不管你们知不知到啥是离散化，这个代码先将就看一下吧。输出：

```c
[34867, 145256, 603, 199480, 30917, 19756, 169700, 165310]
[3, 4, 0, 7, 2, 1, 6, 5]
[34867, 145256, 603, 199480, 30917, 19756, 169700, 165310]
```

可以看到，原来的序列并没有被改变，这是个纯函数。至于离散化是什么，你们可以看看这些：

+ [有梯子的看 Wikipedia](https://zh.wikipedia.org/zh-hans/%E7%A6%BB%E6%95%A3%E5%8C%96)
+ [没梯子的看百度百科](http://baike.baidu.com/view/3392254.htm)

可以发现很多问题：

+ 并不能实现范型，如果你需要对多个值类型进行支持的话（比如同时写 int long short 的离散化），就需要写三份不同的代码。
+ 如果你使用宏解决上面那个问题，你发现 SetIntArrayRegion 这类函数都是把 Int 这个类型信息硬编码进去的。
+ 然后你发现不能实现代码复用真的太难受了，简直想抠断自己的指甲。
+ 每次都需要搞个 jboolean * 的指针太难受了，这玩意我又不用，又怕啥时候重构了伤到。
+ 然后你发现每次都 GetArrayLength GetIntArrayElements SetIntArrayRegion 这么长太难受了。
+ 然后你突然想起了宏可以对代码进行字符串式的连接。
+ 然后你回忆起了上一篇博客的代码命名风格约定。

于是我们可以编写一个这样的头文件来解决函数名长、 jboolean 指针的问题，顺便把类型给参数化了：

```c
#define __JNI__FUNCTION__INIT__ \
jboolean *option = NULL;

#define __JNI__FUNCTION__CLEAN__ \
delete option;

#define __release(type, name) \
env->Release ## type ## ArrayElements(_ ## name, name, JNI_OK);

#define __abort(type, name) \
env->Release ## type ## ArrayElements(_ ## name, name, JNI_ABORT);

#define __get(type, name) \
auto name = env->Get ## type ## ArrayElements(_ ## name, option);

#define __new(type, name, len) \
auto _ ## name = env->New ## type ## Array(len);

#define __set(type, name, len) \
env->Set ## type ## ArrayRegion(_ ## name, 0, len, name);

#define __len(name) \
env->GetArrayLength(_ ## name)

#ifdef _
#undef _
#endif /// _
```

然后你终于发现了之前那么约定命名的好处！比如说刚才的离散化函数是这样：

```cpp
JNIEXPORT auto JNICALL Java_jni_Main_discretization(
    JNIEnv *env,
    jclass,
    jintArray _data) -> jintArray {
  jboolean *option = nullptr;
  auto len = env->GetArrayLength(_data);
  auto data = env->GetIntArrayElements(_data, option);
  auto ret = discretization(data, len);
  env->ReleaseIntArrayElements(_data, data, JNI_ABORT);
  auto _ret = env->NewIntArray(len);
  env->SetIntArrayRegion(_ret, 0, len, ret);
  delete option;
  delete ret;
  return _ret;
}
```

现在你能把它水成这样：

```cpp
JNIEXPORT auto JNICALL Java_jni_Main_discretization(
    JNIEnv *env,
    jclass,
    jintArray _data) -> jintArray {
  __JNI__FUNCTION__INIT__
  auto len = __len(data);
  __get(Int, data);
  auto ret = discretization(data, len);
  __abort(Int, data);
  __new(Int, ret, len);
  __set(Int, ret, len);
  __JNI__FUNCTION__CLEAN__
  delete ret;
  return _ret;
}
```

是不是一瞬间觉得清真了很多（其实就是变瘦+类型参数化，这样可以方便做宏）。

我在代码里面到处使用这套宏。因为它有这些：

## 优点：

+ 非常简短
+ 如果发现这是 bad practise ，可以直接改宏，方便重构
+ 类型参数化，不再硬编码
+ ~~是我自己意淫出来的，可以拿出去吹（你们不适用~~

### 缺点：

别人猛然看见你的代码，可能会说：

> 卧槽什么破玩意，这变量哪里定义的，这啥时候又回收了

不过我觉得那个缺点并不是问题。~~因为反正也没人看我的项目，就我一个人嗨，还好我有磷~~。况且熟悉 JNI 的人看见你的代码可以望文生义。

再说了，我们不是有 CLion 和 Dev Cpp 的跳转到定义功能吗（逃

## 你学到了什么

+ 数组离散化（喂这也算吗
+ 使用一套宏来代替巨长的 `SetIntArrayRegion` `GetArrayLength` `GetIntArrayElements`
+ 如何自己吐槽自己（我真是够了

