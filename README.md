# 总体架构

在空项目的基础上创建了各个模块，分别为FiniteAutomaton、Management、PushdownAutomaton、RegularExpressions、TuringMachine、Shared，其中前五个为各自负责的模块,为HAP类型，Shared为共用模块，是HAR静态库类型。

## git分支

git除主分支外，还有5条分支，分别对应5个模块，其名称分别为5个模块的缩写，如fa,mg,pa,re,tm。

除Shared模块在主分支上开发提交，其余每个模块在各自分支上开发

## 多HAP开发和路由跳转

可参考[MultiHap: 本示例展示多HAP开发，简单介绍了多HAP的使用场景，应用包含了一个entry HAP和两个feature HAP，两个feature HAP分别提供了音频和视频播放组件，entry中使用了音频和视频播放组件。 三个模块需要安装三个hap包，最终会在设备上安装一个主entry的hap包。](https://gitee.com/harmonyos_samples/multi-hap)

## HAR静态库开发和使用

可参考[HAR-应用程序包开发与使用-应用程序包基础知识-开发基础知识-基础入门 - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/har-package-V5)

## 切换分支和更新主分支代码

添加ssh公钥到coding,方便拉取代码[配置 SSH 公钥 - 什么是 DevOps? DevOps 介绍 ｜ CODING DevOps](https://coding.net/help/docs/repo/ssh/config.html)

```
git clone git@e.coding.net:icefjl/biyesheji/bishe.git
```

通过以上命令拉取代码仓库，进入文件夹后，执行以下命令切换到对应分支

```
git checkout 分支名
```

如共享代码有更新，在你负责的分支下通过以下命令更新共享代码

```
git fetch origin
git merge origin/main
```

如有冲突，解决冲突后提交代码，再合并
