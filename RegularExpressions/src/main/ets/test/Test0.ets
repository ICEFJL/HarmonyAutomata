import { compareAutomatons } from 'shared'
import {BaseAutomaton} from '../datastructure/BaseAutomaton';
import {InitAutomaton} from './InitAutomaton'
import router from '@ohos.router';  // 引入 HarmonyOS 路由
import 'reflect-metadata';
import { FileUtil, LogUtil } from '@pura/harmony-utils';
@Entry
@Component
struct TestFile {
  @State result: string = ''
  private saveFileName: string = '';  // 保存文件名
  private loadFileName: string = '';  // 读取文件名

  build() {
    Column() {
      Row() {
        // **返回图标**
        Image($r('app.media.back_icon'))
          .width(32)
          .height(32)
          .margin({ left: 16, right: 8  })
          .onClick(() => {
            router.back(); // 返回上一个界面
          });
        Text('自动机保存与读取')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center);
      }
      .width('100%')
      .height(50)
      .alignItems(VerticalAlign.Center)
      .margin({ top: 16 });
      // **保存文件名输入框**
      TextInput({ text: this.saveFileName, placeholder: "输入保存文件名" })
        .onChange((value: string) => {
          this.saveFileName = value;  // 更新保存文件名
        })
        .width('80%')
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center);

      // 添加一个按钮用于测试
      Button('保存')
        .onClick(() => {
          const automaton1 = InitAutomaton()
          //automaton1.saveToFile("AU",this.saveFileName)
          this.result="保存成功"
        })
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center)

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
          const automaton2 = BaseAutomaton.loadFromFile("AU",this.loadFileName)
          // 输出原本的自动机状态
          this.result="";
          let states = automaton2.getStates();
          let initialState = automaton2.initialState;
          let finalStates = states.filter(state => state.isFinal);
          if(initialState!=null)
            this.result+="初始状态:"+initialState.uuid+"\n";
          this.result+="终止状态:"+finalStates.map(s => s.uuid)+"\n";
          this.result+="原本的自动机状态与转移：\n"
          automaton2.getStates().forEach((state) => {
            this.result+="状态"+state.name +"  id:" +state.uuid+"\n"
          });
          automaton2.getTransitions().forEach((transition) => {
            this.result+=transition.from +"->"+ transition.to+"输入符号: "+transition.label+"\n"
          });
        })
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center);

      // 显示测试结果
      Text(this.result)
        .fontSize(25)
        .alignSelf(ItemAlign.Center)
        .margin({ top: 20 })
    }
    .height('100%')
    .width('100%')
  }
}