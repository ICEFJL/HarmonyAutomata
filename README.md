# 总体架构

在空项目的基础上创建了各个模块，分别为FiniteAutomaton、Management、PushdownAutomaton、RegularExpressions、TuringMachine、Shared，其中前五个为各自负责的模块,为HAP类型，Shared为共用模块，是HAR静态库类型。

## git分支

git除主分支外，还有5条分支，分别对应5个模块，其名称分别为5个模块的缩写，如fa,mg,pa,re,tm。

除Shared模块在主分支上开发提交，其余每个模块在各自分支上开发

## 多HAP开发和路由跳转

如需从entry模块启动多hap，可参考[MultiHap: 本示例展示多HAP开发，简单介绍了多HAP的使用场景，应用包含了一个entry HAP和两个feature HAP，两个feature HAP分别提供了音频和视频播放组件，entry中使用了音频和视频播放组件。 三个模块需要安装三个hap包，最终会在设备上安装一个主entry的hap包。](https://gitee.com/harmonyos_samples/multi-hap)的使用说明的第二步

路由跳转需要修改对应模块下的UIAbility文件，具体修改onCreate、onWindowStageCreate、onNewWant三个函数，可参考[启动应用内的UIAbility组件-UIAbility组件-Stage模型应用组件-Stage模型开发指导-Ability Kit（程序框架服务）-应用框架 - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/uiability-intra-device-interaction-V5#%E5%90%AF%E5%8A%A8uiability%E7%9A%84%E6%8C%87%E5%AE%9A%E9%A1%B5%E9%9D%A2)，此外添加页面，需要在对应模块下的src/main/resources/base/profile/main_pages.json中添加对应页面的route。

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

# 相关工具配置和使用

## 第三方库

需要先[获取命令行工具-Command Line Tools - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V14/ide-commandline-get-V14)

工程目录/模块目录下存在 oh-package.json5 文件，执行以下命令将安装满足在oh-package.json5 文件中声明版本的三方库。也可自己找包，在工程目录下载[OpenHarmony三方库中心仓](https://ohpm.openharmony.cn/#/cn/help/downloadandinstall)

```
ohpm i
```

其他模块引用本地Shared模块也需ohpm进行安装[引用共享包-开发及引用共享包-应用/元服务开发-DevEco Studio - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-har-import-V5)

## 序列化

借助三方库class-transformer和reflect-metadata实现

可参考Shared模块中Automaton和BaseAutomaton的序列化与反序列化函数，和Shared\src\test\Automaton.test.ets

[如何解析JSON字符串为实例对象-方舟编程语言（ArkTS）-ArkTS语言-应用框架开发-开发 - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs-V5/faqs-arkts-75-V5)

[编译时class-transformer中@Type报错该如何解决 #鸿蒙场景化案例#-华为开发者问答 | 华为开发者联盟](https://developer.huawei.com/consumer/cn/forum/topic/0203167419436672676)

## 单元测试

分为两种[代码测试-测试框架-应用/元服务测试-DevEco Studio - 华为HarmonyOS开发者](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-code-test-V5)

推荐**Local Test**，无需模拟器，但一些系统相关的难以测试，比如文件，就算用**Instrument Test**也不知道怎么能测，涉及到context什么的，[HarmonyOS 单元测试如何测试文件相关的操作，在单元测试中如何获取本地沙箱目录的路径 -鸿蒙开发者社区-51CTO.COM](https://ost.51cto.com/answer/36027)，所以文件的测试我在entry模块的entry\src\main\ets\test\TestFile.ets中进行，通过运行entry模块实现测试

具体使用可参考[README_zh.md · OpenHarmony/testfwk_arkxtest - Gitee.com](https://gitee.com/openharmony/testfwk_arkxtest/blob/master/README_zh.md#%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B5%8B%E8%AF%95%E6%A1%86%E6%9E%B6%E4%BD%BF%E7%94%A8%E4%BB%8B%E7%BB%8D)
