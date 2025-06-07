import { Const, FunctionUrl } from 'shared';

@Component
export struct Home {
  startAbility: Function = () => {}

  @Builder
  NavigationTitleBar() {
    Row() {
      Text('功能')
        .fontSize(24)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .margin(10)
    }
    .backgroundColor(Color.White)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  build() {
    NavDestination() {
      Column({ space: 10 }) {
        // 使用 Array.from 将 IterableIterator 转换为数组
        ForEach(Const.FUNCTION, (item: string) => {
          Row() {
            Text(item)
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
            this.startAbility(Const.FUNCTION_URL_MAP.get(item), Const.FUNCTION_ROUTER_MAP.get(item))
          })
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
