---
layout: post
title: 知乎那神一般的糖
category: Arkirina
tags: zhihu
keywords: zhihu
description: SUGER in Zhihu
---

上回说到，知乎毕竟也是收集信息的APP。这次就是请求头里的东西了（虽然我早就忘记了上次说了啥嘻嘻。

这次的是在众多请求里可以见到的头：`X-SUGER` （就像糖。看起来是这样子的：

> X-SUGER: SU1FST0z??I2MjU??????????????U5EUk9JRF9JRD02ODcyZD??????????MGJiO01??????DowMDo????iMzow??????==

其实就是base64编码了的东西。

> IMEI=XXXX25909XXXXXX;ANDROID_ID=XXXXd2dXXXX4XXXX;MAC=08:00:XX:XX:09:XX

（打码了抱歉

然后我们在知乎5.14.1的安卓版APK里面得到了这段反编译的Java代码：

```java
package com.zhihu.android.sdk.launchad.utils;

/* HIDDEN import */

public class XSugerUtils {
  private static long coordTimeStamp;
  private static double mCoordLat;
  private static double mCoordLng;
  private static String mDeviceId;
  private static String mMacId;
  
  private static String getDeviceId(Context paramContext) {
    // ...
  }
  
  public static String getValue() {
    StringBuilder localStringBuilder = new StringBuilder();
    setBuffer(localStringBuilder, "IMEI", mDeviceId);
    setBuffer(localStringBuilder, "ANDROID_ID", LaunchAdApiInfo.AndroidId());
    setBuffer(localStringBuilder, "MAC", mMacId);
    if ((mCoordLat != 0.0D) || (mCoordLng != 0.0D)) {
      setBuffer(localStringBuilder, "COORD_LAT", Double.valueOf(mCoordLat));
      setBuffer(localStringBuilder, "COORD_LNG", Double.valueOf(mCoordLng));
      setBuffer(localStringBuilder, "COORD_TIMESTAMP", Long.valueOf(coordTimeStamp));
    }
    return Base64.encodeBase64String(localStringBuilder.toString().getBytes());
  }
  
  private static void setBuffer(StringBuilder paramStringBuilder, String paramString, Object paramObject) {
    // ...
  }
  
  public static void setValue(Context paramContext, double paramDouble1, double paramDouble2) {
    // ...
  }
}
```

看起来挺多东西的啊哈。也就是说还是有地理位置坐标？？？？？？麻烦您先HASH一下好吗！！！
