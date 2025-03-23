import { router } from '@kit.ArkUI';

@Entry
@Component
struct test1 {
  @State message: string = 'test1';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      Button('back')
        .onClick(() => {
          router.back()
        })
    }
    .height('100%')
    .width('100%')
  }
}