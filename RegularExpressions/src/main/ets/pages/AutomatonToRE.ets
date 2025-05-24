import { State, Transition,DrawCanvas, DrawInvoker,DrawState,
  DrawTransition,IDraw,FSAAutomaton,Const,GemLayoutAlgorithm,
  SavedFile,GemLayoutTest,SaveFileWindow,ConfirmWindow } from 'shared';
import {BaseAutomaton} from '../datastructure/BaseAutomaton';
import { AutomatonToRegexConverter } from '../convert/AutomatonToRegexConverter';
import { ConvertToAutomaton } from '../convert/ConvertToAutomaton';
import {getStates,getTransitions} from '../convert/InvokerGet';
import { ResultWindow } from '../view/ResultWindow';
import { GraphvizInput } from '../view/GraphvizInput';
import { GraphvizExample } from '../view/GraphvizExample';
import { ToastUtil } from '@pura/harmony-utils';

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
  @Provide saveFile: SavedFile | null = null;
  @Provide label: string = "";
  @Provide title: string = "";
  @Provide fsa: BaseAutomaton = new BaseAutomaton();
  private gemLayoutAlgorithm = new GemLayoutAlgorithm<State, Transition>();
  private saveFileWindow: CustomDialogController = new CustomDialogController({
    builder: SaveFileWindow({ save: () => this.save() }), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });
  private confirmWindow: CustomDialogController = new CustomDialogController({
    builder: ConfirmWindow({ action: () => this.delete() }), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  @Provide showInfo: boolean = false;
  @Provide stateInfo: string = '';
  @Provide transitionInfo: string = '';
  @Provide regexInfo: string = '';
  //@State loadInfo: string = '';

  @Provide showSaveDialog: boolean = false;
  @Provide showLoadDialog: boolean = false;
  @Provide saveFileName: string = ''; // 保存文件的文件名
  @Provide loadFileName: string = ''; // 读取文件的文件名

  private graphvizInput: CustomDialogController = new CustomDialogController({
    builder: GraphvizInput({ openExample: () => this.openExample(), import: () => {
      this.gemLayoutAlgorithm.process(this.fsa) as FSAAutomaton;
      this.clearAll();
    } }), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });
  private graphvizExample: CustomDialogController = new CustomDialogController({
    builder: GraphvizExample(), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });
  openExample(): void{
    this.graphvizExample.open();
  }
  clearAll(): void{
    this.drawInvoker.clearAll();
    this.endUpdate();
    this.unDoDraw = false;
    this.redoDraw = false;
  }
  endUpdate(): void{
    this.fsa.drawAutomaton(this.drawInvoker);
    this.index = Const.NONE;
    this.update = !this.update;
  }

  save(): void{
    this.fsa = BaseAutomaton.getAutomaton(this.drawInvoker);
    this.fsa.setNote(this.note);
    this.fsa.setName(this.name);
    this.fsa.saveToFile();
    if(this.saveFile){
      this.saveFile.setNote(this.note);
      this.saveFile.update();
    }else {
      this.saveFile = new SavedFile(this.name, this.note, this.fsa.type);
      this.saveFile.save();
    }

    this.clearAll();
  }

  delete(): void{
    if(this.saveFile){
      this.saveFile.delete();
      this.saveFile = null;
      this.fsa = new BaseAutomaton();
      this.clearAll();
      ToastUtil.showToast('删除成功');
    }else{
      ToastUtil.showToast('尚未保存');
    }
  }

  // 显示正则表达式
  viewAutomatonInfo() {
    //let states = this.drawInvoker.getStates();
    // let transitions = this.drawInvoker.getTransitions();
    this.stateInfo="";
    this.fsa=BaseAutomaton.getAutomaton(this.drawInvoker);
    let statess = getStates(this.drawInvoker);
    let transitionss = getTransitions(this.drawInvoker);
    let states = this.fsa.getStates();
    let initialState = this.fsa.initialState;
    let finalStates = states.filter(state => state.isFinal);
    if(initialState!=null)
      this.stateInfo+="初始状态:"+initialState.uuid+"\n";
    this.stateInfo+="终止状态:"+finalStates.map(s => s.uuid)+"\n";
    this.stateInfo+="自动机状态与转移：\n"
    this.fsa.getStates().forEach((state) => {
      this.stateInfo+="状态"+state.name +"  id:" +state.uuid+"\n"
      //result+="坐标"+state.x +" , " +state.y+"\n"
    });
    this.fsa.getTransitions().forEach((transition) => {
      let from=this.fsa.getStateWithUuid(transition.from);
      let to =this.fsa.getStateWithUuid(transition.to)
      if(from!=null&&to!=null)
      {
        this.stateInfo+=(from.name +"->"+ to.name+"输入符号: "+transition.label+"\n")
      }
    });
    //this.stateInfo = '状态:\n' + states.map(s => `UUID: ${s.state.uuid}, 状态名: ${s.state.name},是否初始状态: ${s.isInitialState}, 是否终止状态: ${s.state.isFinal}`).join('\n');
    //this.transitionInfo = '转换:\n' + transitions.map(t => `(${t.fromState.name} -> ${t.toState.name}, label: ${t.label})`).join('\n');
    const automaton = ConvertToAutomaton.convert(statess, transitionss);
    let result=AutomatonToRegexConverter.convertToRegex(this.fsa)
    this.regexInfo = '正则表达式:' + result;
    // 显示信息
    if(result!="Error")
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

  // 处理读取操作
  confirmLoad() {
    if (this.loadFileName.trim() === '') {
      return;
    }
    const automaton = BaseAutomaton.loadFromFile("AU",this.loadFileName)
    // 输出原本的自动机状态
    this.stateInfo="";
    this.transitionInfo="";
    let states = automaton.getStates();
    const transitions = automaton.getTransitions();
    let initialState = automaton.initialState;
    let finalStates = states.filter(state => state.isFinal);
    //
    let drawArray: Array<IDraw> = [];
    for (const state of states) {
      if(state.uuid == initialState?.uuid){
        this.drawInvoker.initialState = new DrawState(state, true);
        drawArray.push(this.drawInvoker.initialState);
      }else{
        drawArray.push(new DrawState(state, false));
      }
    }
    for (const transition of transitions) {
      const label = transition.label;
      const fromState = automaton.getStateWithUuid(transition.from);
      const toState = automaton.getStateWithUuid(transition.to);
      if(!fromState || !toState){
        continue;
      }
      drawArray.push(new DrawTransition(fromState, toState, label));
    }
    this.drawInvoker.update(drawArray);
    this.index = Const.NONE;
    this.update = !this.update;
    /*if(initialState!=null)
      this.stateInfo+="初始状态:"+initialState.name+"\n";
    this.stateInfo+="终止状态:"+finalStates.map(s => s.name)+"\n";
    automaton.getStates().forEach((state) => {
      this.stateInfo+="状态"+state.name +"  id:" +state.uuid+"\n"
      this.stateInfo+="坐标"+state.x +" , " +state.y+"\n"
    });
    automaton.getTransitions().forEach((transition) => {
      this.transitionInfo+="("+transition.from +"->"+ transition.to+"  label: "+transition.label+")\n"
    });
    this.loadFileName="";
    this.regexInfo="";
    this.showInfo = true;*/
    this.showLoadDialog = false;
  }

  @Builder
  FSAMenu() {
    Menu() {
      MenuItem() {
        Text('正则表达式转换') // 菜单项内容
          .onClick(() => this.viewAutomatonInfo())
          .width(160)
          .height(50)
          .fontSize(20)
          .padding(10)
      }
      MenuItem() {
        Text('保存文件')
          .onClick(() => {
            //this.showSaveDialog = true
            if(!this.drawInvoker.initialState){
              ToastUtil.showToast('缺乏初始状态，无法执行');
              return;
            }
            this.saveFileWindow.open();
          }) // 弹出保存文件弹窗
          .width(160)
          .height(50)
          .fontSize(20)
          .padding(10)
      }
      /*MenuItem() {
        Text('读取文件')
          .onClick(() => this.showLoadDialog = true) // 弹出读取文件弹窗
          .width(160)
          .height(50)
          .fontSize(20)
          .padding(10)
      }*/
      MenuItem() {
        Text('删除文件')
          .onClick(() => {
            if(!this.saveFile){
              ToastUtil.showToast('尚未保存');
            }
            this.title = '删除文件';
            this.label = '确定删除该文件吗？';
            this.confirmWindow.open();
          })
          .width(160)
          .height(50)
          .fontSize(20)
          .padding(10)
      }
      MenuItem({
        content: '导入Graphviz文件'
      })
        .onClick(() => {
          this.title = '导入Graphviz文件';
          this.graphvizInput.open();
        })
    }
  }

  @Builder
  NavigationMenus() {
    Image($r('app.media.icon_menu'))
      .width(48)
      .height(48)
      .bindMenu(this.FSAMenu())
  }

  build() {
    Stack() { // 使用 Stack 布局实现层级叠加
      // 主内容层
      Column() {
        Navigation() {
          DrawCanvas()
        }
        .title('有穷自动机->正则表达式')
        .titleMode(NavigationTitleMode.Mini)
        .hideToolBar(true)
        .width('100%')
        .height('100%')
        .menus(this.NavigationMenus())
      }

      // 转化弹窗
      if (this.showInfo) {
        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) { // 居中布局
          Column() {
            Text(this.stateInfo)
              .fontSize(16)
              .margin(10)
              .textAlign(TextAlign.Start) // 左对齐文本
              .width('100%')

            Text(this.transitionInfo)
              .fontSize(16)
              .margin(10)
              .textAlign(TextAlign.Start)
              .width('100%')

            Text(this.regexInfo)
              .fontSize(16)
              .margin(10)
              .textAlign(TextAlign.Start)
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

      //读取文件弹窗
      if (this.showLoadDialog) {
        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          Column() {
            Text('请输入文件名:')
              .fontSize(16)
              .margin(10)
              .textAlign(TextAlign.Start)
              .width('100%')

            // 输入框，用于输入文件名
            TextInput({ text: this.loadFileName, placeholder: "输入保存文件名" })
              .onChange((value: string) => {
                this.loadFileName = value;  // 更新保存文件名
              })
              .width('80%')
              .margin({ top: 20 })
              .alignSelf(ItemAlign.Center);

            Row() {
              Button('读取')
                .onClick(() => this.confirmLoad())
                .width('45%')
                .margin(5)

              Button('取消')
                .onClick(() => this.showLoadDialog = false)
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
