//import { testAutomatonToRegex } from '../test/testAutomatonToRegex';
import router from '@ohos.router';  // 引入 HarmonyOS 路由

@Entry
@Component
struct TestFile {
  @State result: string = '';

  build() {
    Column() {
      // **标题行，包含返回图标和标题**
      Row() {
        Image($r('app.media.back_icon'))
          .width(32)
          .height(32)
          .margin({ left: 16, right: 8 })
          .onClick(() => {
            router.back();  // 返回上一个界面
          });
        // **标题文本**
        Text('测试')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center);
      }
      .width('100%')
      .height(50)
      .alignItems(VerticalAlign.Center)
      .margin({ top: 16 });

      // **Run 按钮**
      Button('Run')
        .onClick(() => {
          //this.result = testAutomatonToRegex();  // 执行正则转换
        })
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center);

      // **结果文本**
      Text(this.result)
        .fontSize(30)
        .alignSelf(ItemAlign.Center)
        .margin({ top: 20 });
    }
    .height('100%')
    .width('100%');
  }
}
