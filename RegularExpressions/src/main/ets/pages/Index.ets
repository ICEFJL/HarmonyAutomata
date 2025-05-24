import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State options: string[] = [
    "正则表达式",
    "有穷自动机->正则表达式",
    "正则表达式->有穷自动机",
    "判题器",
  ];
  @Builder
  NavigationTitleBar() {
    Row() {
      // **返回图标**
      Image($r('app.media.back_icon'))
        .width(32)
        .height(32)
        .margin({ left: 16, right: 8  })
        .onClick(() => {
          router.back();  // 返回上一个界面
        });
      Text('正则')
        .fontSize(24)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .margin(10)
    }
    .backgroundColor(Color.White)
    .width('100%')
    //.justifyContent(FlexAlign.SpaceBetween)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
  build() {
    Navigation()
    //NavDestination()
    {
      Column({ space: 10 }) {
        // 使用 Array.from 将 IterableIterator 转换为数组
        Row() {
          Text("正则表达式")
            .textAlign(TextAlign.Center)
            .fontSize(20)
            .layoutWeight(1)
            .margin(10)
        }
        .width('100%')
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/RegexFileList',
            params: {
              message: '已保存',
            }
          });
        })
        Row() {
          Text("有穷自动机->正则表达式")
            .textAlign(TextAlign.Center)
            .fontSize(20)
            .layoutWeight(1)
            .margin(10)
        }
        .width('100%')
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/AutomatonToRE',
            params: {
              message: '有穷自动机->正则表达式'
            }
          });
        })
        Row() {
          Text("正则表达式->有穷自动机")
            .textAlign(TextAlign.Center)
            .fontSize(20)
            .layoutWeight(1)
            .margin(10)
        }
        .width('100%')
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .onClick(() => {
          router.pushUrl({
            //url: 'test/Test3',
            url: 'pages/REToAutomaton',
            params: { regularExpression: "" }
          });
        })

      }
      .padding(20)
    }
    .title(this.NavigationTitleBar())
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f3f5')
  }


}