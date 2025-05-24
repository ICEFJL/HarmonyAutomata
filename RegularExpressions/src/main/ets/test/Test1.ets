import Regular_Expression from '../datastructure/Regular_Expression';  // 引入 Regular_Expression 类
import { LogUtil, FileUtil } from '@pura/harmony-utils';
import router from '@ohos.router';  // 引入 HarmonyOS 路由
import 'reflect-metadata';

@Entry
@Component
struct TestFile {
  private regularexpression: string = '';
  private saveFileName: string = '';  // 保存文件名
  private loadFileName: string = '';  // 读取文件名
  @State result: string = '';

  build() {
    Column() {
      // **标题行，包含返回图标和标题**
      Row() {
        // **返回图标**
        Image($r('app.media.back_icon'))
          .width(32)
          .height(32)
          .margin({ left: 16, right: 8  })
          .onClick(() => {
            router.back();  // 返回上一个界面
          });

        // **标题文本**
        Text('正则表达式输入与保存')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
          .alignSelf(ItemAlign.Center);
      }
      .width('100%')
      .height(50)
      .alignItems(VerticalAlign.Center);

      // **正则表达式输入框**
      TextInput({ text: this.regularexpression, placeholder: "输入正则表达式" })
        .onChange((value: string) => {
          this.regularexpression = value;  // 更新输入值
        })
        .width('80%')
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center);

      // **保存文件名输入框**
      TextInput({ text: this.saveFileName, placeholder: "输入保存文件名" })
        .onChange((value: string) => {
          this.saveFileName = value;  // 更新保存文件名
        })
        .width('80%')
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center);

      // **保存按钮**
      Button('保存')
        .onClick(() => {
          const regex = new Regular_Expression(this.regularexpression);
          // 使用保存文件名作为第二个参数
          //this.result = regex.saveToFile("EX", this.saveFileName);  // 保存到文件
        })
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center);

      // **读取文件名输入框**
      TextInput({ text: this.loadFileName, placeholder: "输入读取文件名" })
        .onChange((value: string) => {
          this.loadFileName = value;  // 更新读取文件名
        })
        .width('80%')
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center);

      // **读取按钮**
      Button('读取')
        .onClick(() => {
          // 使用读取文件名作为第二个参数
          this.loadRegexFromFile("EX", this.loadFileName);  // 读取文件中的正则表达式
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

  // **从文件读取正则表达式**
  private loadRegexFromFile(dirPath: string = "", fileName: string = "test.json"): void {
    try {
      let filePath = FileUtil.getFilesDirPath(dirPath, fileName);  // 使用传入的文件名

      // **检查文件是否存在**
      if (!FileUtil.accessSync(filePath)) {
        LogUtil.error("读取失败: 文件不存在 " + filePath);
        return;
      }

      // **直接读取文本**
      let bufferStr = FileUtil.readTextSync(filePath, "utf-8");

      LogUtil.info("读取的正则表达式: " + bufferStr);
      this.result = "读取的正则表达式: " + bufferStr;
    } catch (err) {
      LogUtil.error(`读取正则表达式失败: ${err.message}`);
    }
  }
}
