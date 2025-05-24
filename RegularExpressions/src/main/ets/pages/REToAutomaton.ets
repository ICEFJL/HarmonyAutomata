import { DrawCanvas, DrawInvoker,DrawState,DrawTransition,IDraw,FSAAutomaton,Const, } from 'shared';
import {BaseAutomaton} from '../datastructure/BaseAutomaton';
import { AutomatonToRegexConverter } from '../convert/AutomatonToRegexConverter';
import { RegexToAutomaton } from '../datastructure/BaseAutomaton';
import {getStates,getTransitions} from '../convert/InvokerGet';
import Regular_Expression from '../datastructure/Regular_Expression';
//import { RegexToAutomaton } from '../convert/RegexToAutomaton';
import { ConvertToAutomaton } from '../convert/ConvertToAutomaton';
import { GemLayoutAlgorithm,State, Transition} from 'shared';
import { ToastUtil } from '@pura/harmony-utils';
import 'reflect-metadata';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
import router from '@ohos.router';

interface RouteParams {
  regularExpression?: string;
}

@Entry
@Component
struct ParentComponent {
  @Provide drawInvoker: DrawInvoker = new DrawInvoker();
  @Provide index: number = Const.NONE;
  @Provide update: boolean = false;
  @Provide unDoDraw: boolean = false;
  @Provide redoDraw: boolean = false;
  @Provide name: string = "";
  @Provide note: string = "";
  //@Provide saveFile: SavedFile | null = null;
  @Provide label: string = "";
  @Provide title: string = "";
  //fsa = new FSAAutomaton();
  fsa = new BaseAutomaton();
  private gemLayoutAlgorithm = new GemLayoutAlgorithm<State, Transition>();

  @Provide showInfo: boolean = false;
  @Provide stateInfo: string = '';
  @Provide transitionInfo: string = '';
  @Provide regexInfo: string = '';
  @Provide regexInput: string = '';
  //@State loadInfo: string = '';

  @Provide showSaveDialog: boolean = false;
  @Provide showLoadDialog: boolean = false;
  @Provide saveFileName: string = ''; // 保存文件的文件名
  @Provide loadFileName: string = ''; // 读取文件的文件名

  aboutToAppear() {
    const params = router.getParams() as RouteParams;

    if (params.regularExpression) {
      this.regexInput = params.regularExpression;
    }
  }

  // 显示正则表达式
  viewAutomatonInfo() {
    let states = getStates(this.drawInvoker);
    let transitions = getTransitions(this.drawInvoker);

    this.stateInfo = '状态:\n' + states.map(s => `UUID: ${s.state.uuid}, 状态名: ${s.state.name},是否初始状态: ${s.isInitialState}, 是否终止状态: ${s.state.isFinal}`).join('\n');
    this.transitionInfo = '转换:\n' + transitions.map(t => `(${t.fromState.name} -> ${t.toState.name}, label: ${t.label})`).join('\n');

    const automaton = ConvertToAutomaton.convert(states, transitions);
    //this.regexInfo = '正则表达式:' + AutomatonToRegexConverter.convertToRegex(automaton);

    // 显示信息
    this.showInfo = true;
  }

  // 处理保存操作
  confirmSave() {
    if (this.saveFileName.trim() === '') {
      return; // 如果文件名为空，则不进行保存操作
    }

    let states = getStates(this.drawInvoker);
    let transitions = getTransitions(this.drawInvoker);
    const automaton = ConvertToAutomaton.convert(states, transitions);

    automaton.saveToFile("AU", this.saveFileName); // 使用输入的文件名进行保存
    this.saveFileName="";
    this.regexInfo="保存成功";
    this.stateInfo="";
    this.transitionInfo="";
    this.showSaveDialog = false; // 关闭弹窗
    this.showInfo = true;
  }

  convertRegexToAutomaton() {
    let result : string=""
    if (this.regexInput === '') {
      ToastUtil.showToast("请输入");
      return; // 空输入直接返回
    }
    else {
      const regex = new Regular_Expression(this.regexInput);
      // 使用保存文件名作为第二个参数
      let result2 = regex.isValidRegex();
      if (!result2) {
        ToastUtil.showToast("错误原因: " + regex.errorMessage);
        console.log("错误原因: " + regex.errorMessage);
        return;
      }
      try {
        let automaton = RegexToAutomaton.convert(this.regexInput);
        let initialState = automaton.initialState;
        automaton = BaseAutomaton.convertNFAtoDFA(automaton);
        //automaton=BaseAutomaton.minimize(automaton);
        this.gemLayoutAlgorithm.process(automaton) as FSAAutomaton;
        //clear
        this.drawInvoker.clearAll();
        this.unDoDraw = false;
        this.redoDraw = false;
        this.regexInput = '';
        //draw
        automaton.drawAutomaton(this.drawInvoker);
        this.index = Const.NONE;
        this.update = !this.update;

      } catch (e) {
        console.log("转换失败: " + e.message);
        ToastUtil.showToast("转换失败: " + e.message);
      }
    }
  }


  @Builder
  FSAMenu() {
    Menu() {
      MenuItem() {
        Text('自动机转换') // 新名称
          .onClick(() => this.convertRegexToAutomaton())
          .width(160)
          .height(50)
          .fontSize(20)
          .padding(10)
      }
      MenuItem() {
        Text('保存文件')
          .onClick(() => this.showSaveDialog = true) // 弹出保存文件弹窗
          .width(160)
          .height(50)
          .fontSize(20)
          .padding(10)
      }
    }
  }

  @Builder
  NavigationMenus() {
    Column() {
      Image($r('app.media.icon_menu'))
        .width(48)
        .height(48)
        .bindMenu(this.FSAMenu())
    }
  }

  build() {
    Stack() { // 使用 Stack 布局实现层级叠加
      // 主内容层
      Column() {
        // 固定标题栏
        Navigation() {
          // 可为空内容
        }
        .title('正则表达式->有穷自动机')
        .titleMode(NavigationTitleMode.Mini)
        .hideToolBar(true)
        .width('100%')
        .height(56)
        .menus(this.NavigationMenus())

        // 固定输入框
        TextInput({ text: this.regexInput, placeholder: "输入正则表达式" })
          .onChange((value: string) => {
            this.regexInput = value;
          })
          .width('90%')
          .margin({ top: 8, bottom: 8 })
          .alignSelf(ItemAlign.Start)

        // 可滚动区域：画布
        Scroll() {
          DrawCanvas()
            .width('100%')
            .height('100%') // 确保画布本身有高度
        }
        .layoutWeight(1) // 占据剩余空间
        .width('100%')
      }
      .width('100%')
      .height('100%')

      // 转化弹窗
      if (this.showInfo) {
        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) { // 居中布局
          Column() {
            Text(this.stateInfo)
              .fontSize(16)
              .margin(10)
              .textAlign(TextAlign.Start) // 左对齐文本
              .width('100%')

            Button('关闭')
              .onClick(() => this.showInfo = false)
              .width('60%')
              .margin(10)
          }
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .width('80%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)') // 半透明遮罩
      }

      // 保存文件弹窗
      if (this.showSaveDialog) {
        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          Column() {
            Text('请输入文件名:')
              .fontSize(16)
              .margin(10)
              .textAlign(TextAlign.Start)
              .width('100%')

            // 输入框，用于输入文件名
            TextInput({ text: this.saveFileName, placeholder: "输入保存文件名" })
              .onChange((value: string) => {
                this.saveFileName = value;  // 更新保存文件名
              })
              .width('80%')
              .margin({ top: 20 })
              .alignSelf(ItemAlign.Center);

            Row() {
              Button('保存')
                .onClick(() => this.confirmSave())
                .width('45%')
                .margin(5)

              Button('取消')
                .onClick(() => this.showSaveDialog = false)
                .width('45%')
                .margin(5)
            }
          }
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .width('80%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)') // 半透明遮罩
      }

    }
    .width('100%')
    .height('100%')
  }
}
