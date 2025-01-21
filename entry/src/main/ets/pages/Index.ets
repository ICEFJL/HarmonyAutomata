// Index.ets
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Column() {
        Text(this.message)
          .id('HelloWorld')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center)

        Button('Go to TestFile Page')
          .onClick(() => {
            router.pushUrl({
              url: 'test/TestFile',
              params: {
                message: 'Hello World'
              }
            });
          })
          .margin({ top: 20 })
          .alignSelf(ItemAlign.Center)
      }
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
    }
    .height('100%')
    .width('100%')
  }
}
