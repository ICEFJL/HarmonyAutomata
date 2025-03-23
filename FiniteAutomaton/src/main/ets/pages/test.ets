import { router } from '@kit.ArkUI';

@Entry
@Component
struct test {
  @State message: string = 'test';

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
      Row(){
        Button('test1')
          .onClick(() => {
            router.pushUrl({ url: 'pages/test1' })
          })
        Button('Index')
          .onClick(() => {
            router.pushUrl({ url: 'pages/Index' })
          })
        Button('back')
          .onClick(() => {
            router.back()
          })
      }
    }
    .height('100%')
    .width('100%')
  }
}