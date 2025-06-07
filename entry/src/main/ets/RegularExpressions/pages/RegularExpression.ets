import Regular_Expression from '../datastructure/Regular_Expression';  // 引入 Regular_Expression 类
import { LogUtil
//, FileUtil
} from '@pura/harmony-utils';
import type { Context } from '@ohos.abilityAccessCtrl';
import { AutomatonToRegexConverter } from '../convert/AutomatonToRegexConverter';
import router from '@ohos.router';  // 引入 HarmonyOS 路由
import 'reflect-metadata';
import 'reflect-metadata';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
import { ToastUtil } from '@pura/harmony-utils';
import { FileUtil } from '../datastructure/FileUtil';
//import Ability from '@ohos.application.Ability';

@Entry
@Component
struct RegularExpression {

  //@Prop context: Context;
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
        Text('正则表达式')
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
          let result = regex.isValidRegex();
          if (!result) {
            ToastUtil.showToast("错误原因: " + regex.errorMessage);
            console.log("错误原因: " + regex.errorMessage);
          } else {
            ToastUtil.showToast("保存成功");
            console.log("正则表达式合法");
            ToastUtil.showToast("化简后："+AutomatonToRegexConverter.simplify(this.regularexpression))
            //regex.saveToFile("EX", this.saveFileName);  // 保存到文件
            // 调用保存文件
            //console.log('context:', this.context);
            const saved = FileUtil.saveFile("EX", this.saveFileName, this.regularexpression);
            if (saved) {
              ToastUtil.showToast("保存成功");
              console.log("保存成功");

              // 刷新文件列表 - 需要你的文件列表组件支持刷新
              // 比如发事件通知，或者直接调用加载方法
              // this.loadRegexFiles(); // 视你结构而定
            } else {
              ToastUtil.showToast("保存失败");
              console.error("保存失败");
            }
          }
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
          //this.result=this.loadFromFile("", this.loadFileName);  // 读取文件中的正则表达式
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
  /*public loadFromFile(dirPath: string = "", fileName: string = "test.json"): string {
    let filePath = FileUtil.getFilesDirPath(dirPath, fileName, false);
    let readTextOptions: ReadTextOptions = {
      offset: 0,
      length: 0,
      encoding: 'utf-8'
    };
    let stat = fs.statSync(filePath);
    readTextOptions.length = stat.size;
    return fs.readTextSync(filePath, readTextOptions);
  }*/
}
