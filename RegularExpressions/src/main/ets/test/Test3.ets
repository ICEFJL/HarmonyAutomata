import {Transition} from '../datastructure/Transition';
import {Automaton} from '../datastructure/Automaton';
import {AutomatonType} from '../datastructure/Type';
import router from '@ohos.router';
import {testRegexToAutomaton} from '../test/testRegexToAutomaton';
@Entry
@Component
struct RegexTestPage {
  @State regexInput: string = ''
  @State result: string = '';

  build() {
    Column({ space: 20 }) {
      Row() {
        Image($r('app.media.back_icon'))
          .width(32)
          .height(32)
          .margin({ left: 16, right: 8 })
          .onClick(() => {
            router.back();
          });
        Text('正则转自动机测试')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin(10)
      }
      .width('100%')
      .height(50)
      //.alignItems(VerticalAlign.Center)
      .margin({ top: 16 });

      TextInput({ text: this.regexInput, placeholder: "输入正则表达式" })
        .onChange((value: string) => {
          this.regexInput = value; // 更新输入值
        })
        .width('80%')
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center);

      Button('转换为自动机')
        .margin(10)
        .onClick(() => {
          this.result=testRegexToAutomaton(this.regexInput);
        })

      Scroll() {
        Text(this.result)
          .fontSize(16)
          .fontFamily('monospace')
          .padding(10)
      }.height('60%')
    }
    .padding(20)
    .align(Alignment.TopStart)
  }
}
