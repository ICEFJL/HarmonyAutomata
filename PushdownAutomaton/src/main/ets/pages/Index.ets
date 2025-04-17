import { ToastUtil } from '@pura/harmony-utils';
import {
  AutomatonType,
  ConfirmWindow,
  Const, DrawCanvas, DrawInvoker,
  HelpUtil,
  SavedFile,
  SaveFileWindow,
  SimulateWindow,
  State, Transition} from 'shared';
import { PDAAutomaton } from 'shared/src/main/ets/automaton/pda/PDAAutomaton';
import { PDAGemLayoutAlgorithm } from 'shared/src/main/ets/automaton/pda/PDAGemLayoutAlgorithm';
import { PDATransition } from 'shared/src/main/ets/automaton/pda/PDATransition';
import { funcAbilityWant } from '../pushdownautomatonability/PushdownAutomatonAbility';
import { GraphvizExample } from '../view/GraphvizExample';
import { GraphvizInput } from '../view/GraphvizInput';
import { ResultWindow } from '../view/ResultWindow';




@Entry
@Component
struct PDAComponent {
  @Provide drawInvoker: DrawInvoker = new DrawInvoker();
  @Provide update: boolean = false;
  @Provide unDoDraw: boolean = false;
  @Provide redoDraw: boolean = false;
  @Provide index: number = Const.NONE;
  @Provide name: string = "";
  @Provide note: string = "";
  @Provide saveFile: SavedFile | null = null;
  @Provide label: string = "";
  @Provide title: string = "";
  @Provide pda: PDAAutomaton<State, PDATransition> = new PDAAutomaton();
  private gemLayoutAlgorithm = new PDAGemLayoutAlgorithm();
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

  private simulateWindow: CustomDialogController = new CustomDialogController({
    builder: SimulateWindow({ action: (input: string) => this.simulate(input) }), //
    // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  private resultWindow: CustomDialogController = new CustomDialogController({
    builder: ResultWindow(), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  private graphvizInput: CustomDialogController = new CustomDialogController({
    builder: GraphvizInput({ openExample: () => this.openExample(), import: () => {
      this.pda = this.gemLayoutAlgorithm.process(this.pda) as PDAAutomaton<State, PDATransition>;
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

  aboutToAppear() {
    if(funcAbilityWant?.parameters?.file){
      let fileName = funcAbilityWant?.parameters?.fileName as string;
      let note = funcAbilityWant?.parameters?.note as string;
      let fileType = funcAbilityWant?.parameters?.fileType as AutomatonType;
      let saveTime = funcAbilityWant?.parameters?.saveTime as number;
      this.saveFile = new SavedFile(fileName, note, fileType, saveTime);
      this.pda = PDAAutomaton.loadFromFile("", fileName);
      this.name = fileName;
      this.note = note;
      this.endUpdate();
    }
  }

  clearAll(){
    this.drawInvoker.clearAll();
    this.endUpdate();
    this.unDoDraw = false;
    this.redoDraw = false;
  }

  endUpdate(){
    //this.drawInvoker.clearAll(); // 清空旧的绘制内容
    this.pda.drawPDAAutomaton(this.drawInvoker);
    this.index = Const.NONE;
    this.update = !this.update;
  }

  save(): void{
    this.pda = PDAAutomaton.getAutomaton(this.drawInvoker);
    this.pda.setNote(this.note);
    this.pda.setName(this.name);
    this.pda.saveToFile();
    if(this.saveFile){
      this.saveFile.setNote(this.note);
      this.saveFile.update();
    }else {
      this.saveFile = new SavedFile(this.name, this.note, this.pda.type);
      this.saveFile.save();
    }
    this.clearAll();
    this.endUpdate();
  }

  delete(): void{
    if(this.saveFile){
      this.saveFile.delete();
      this.saveFile = null;
      this.pda = new PDAAutomaton();
      this.clearAll();
      this.endUpdate();
      ToastUtil.showToast('删除成功');
    }else{
      ToastUtil.showToast('尚未保存');
    }
  }
  simulate(input: string): void{
    this.pda = PDAAutomaton.getAutomaton(this.drawInvoker);
    this.pda.initializeInput(input);
    const result = this.pda.run();
    if(result){
      this.label = '该字符串被接受';
    }else{
      this.label = '该字符串被拒绝';
    }
    this.title = '结果';
    this.resultWindow.open();
  }

  @Builder
  PDAMenu(){
    Menu() {
      MenuItem({ content: '保存文件' })
        .onClick(() => {
          if(!this.drawInvoker.initialState){
            ToastUtil.showToast('缺乏初始状态，无法执行');
            return;
          }
          if(!Array.from(this.drawInvoker.stateMap.values()).some(
            item => item[item.length - 1].state.isFinal === true
          )){
            ToastUtil.showToast('缺乏接受状态，无法执行');
            return;
          }
          this.saveFileWindow.open();
        })
      MenuItem({ content: '创建实例' })
        .onClick(() => {
          this.pda = PDAAutomaton.createExample();
          this.pda.drawPDAAutomaton(this.drawInvoker);
          this.endUpdate();
        })
      MenuItem({
        content: '导入Graphviz文件'
      })
        .onClick(() => {
          this.title = '导入Graphviz文件';
          this.graphvizInput.open();
        })
      MenuItem({ content: '仿真验证' })
        .onClick(() => {
          if(!this.drawInvoker.initialState){
            ToastUtil.showToast('缺乏初始状态，无法执行');
            return;
          }
          if(!Array.from(this.drawInvoker.stateMap.values()).some(
            item => item[item.length - 1].state.isFinal === true
          )){
            ToastUtil.showToast('缺乏接受状态，无法执行');
            return;
          }
          this.simulateWindow.open();
        })
      MenuItem({ content: '删除文件' })
        .onClick(() => {
          if(!this.saveFile){
            ToastUtil.showToast('尚未保存');
          }
          this.title = '删除文件';
          this.label = '确定删除该文件吗？';
          this.confirmWindow.open();
        })
      MenuItem({ content: '自动布局' })
        .onClick(() => {
          console.log("自动布局")
          this.pda = PDAAutomaton.getAutomaton(this.drawInvoker);
          this.pda = this.gemLayoutAlgorithm.process(this.pda) as PDAAutomaton<State, PDATransition>;
          if(this.pda.update){
            this.endUpdate();
          }
        })
    }
  }

  @Builder
  NavigationMenus(){
    Image($r('app.media.icon_menu'))
      .width(48)
      .height(48)
      .bindMenu(this.PDAMenu())
  }

  build() {
    Navigation() {
      DrawCanvas({ automatonType: AutomatonType.PDA })
    }
    .title(this.saveFile ? '修改' + this.saveFile.fileName : '新建下推自动机')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .menus(this.NavigationMenus())
  }
}
