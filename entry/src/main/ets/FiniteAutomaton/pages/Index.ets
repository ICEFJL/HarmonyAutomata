import { ToastUtil } from '@pura/harmony-utils';
import {
  AutomatonType,
  ConfirmWindow,
  Const, DrawCanvas, DrawInvoker, FSAAutomaton, GemLayoutAlgorithm,GemLayoutTest,
  AutomatonCreator,
  SavedFile,
  SaveFileWindow,
  simulateFSA, DFA, NFA,
  SimulateWindow,
  State, Transition,
  DFATest,
  NFAToDFATest} from 'shared';
import { ResultWindow } from '../view/ResultWindow';
import { easyFSA, minDFATestFSA, nfaToDFATestFSA, normalFSA } from '../test/TestAutomaton';
import { GraphvizInput } from '../view/GraphvizInput';
import { GraphvizExample } from '../view/GraphvizExample';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct FSAComponent {
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
  @Provide fsa: FSAAutomaton = new FSAAutomaton();
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

  private simulateWindow: CustomDialogController = new CustomDialogController({
    builder: SimulateWindow({ action: (input: string) => this.simulate(input) }), // 弹框的构造器
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
      this.fsa = this.gemLayoutAlgorithm.process(this.fsa) as FSAAutomaton;
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
    const params = router.getParams() as Record<string, Object>;
    if(params){
      let fileName = params['fileName'] as string;
      let note = params['note'] as string;
      let fileType = params['fileType'] as AutomatonType;
      let saveTime = params['saveTime'] as number;
      this.saveFile = new SavedFile(fileName, note, fileType, saveTime);
      this.fsa = FSAAutomaton.loadFromFile("", fileName);
      this.name = fileName;
      this.note = note;
      this.endUpdate();
    }
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
    this.fsa = FSAAutomaton.getAutomaton(this.drawInvoker);
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
      this.fsa = new FSAAutomaton();
      this.clearAll();
      ToastUtil.showToast('删除成功');
    }else{
      ToastUtil.showToast('尚未保存');
    }
  }

  simulate(input: string): void{
    const result = simulateFSA(this.fsa, input);
    if(result.accepted){
      this.label = '字符串'+input+'被接受';
    }else{
      this.label = '该字符串'+input+'被拒绝';
    }
    this.title = '结果';
    this.resultWindow.open();
  }

  @Builder
  FSAMenu(){
    Menu() {
      MenuItem({
        content: '保存文件'
      })
        .onClick(() => {
          if(!this.drawInvoker.initialState){
            ToastUtil.showToast('缺乏初始状态，无法执行');
            return;
          }
          this.saveFileWindow.open();
        })
      MenuItem({
        content: '仿真验证'
      })
        .onClick(() => {
          if(!this.drawInvoker.initialState){
            ToastUtil.showToast('缺乏初始状态，无法执行');
            return;
          }
          this.simulateWindow.open();
        })
      MenuItem({
        content: 'NFA->DFA'
      })
        .onClick(() => {
          if(!this.drawInvoker.initialState || !NFA.isNFA(this.fsa)){
            ToastUtil.showToast('该自动机不是 NFA');
            return;
          }
          this.fsa = NFA.toDFA(FSAAutomaton.getAutomaton(this.drawInvoker));
          this.fsa = this.gemLayoutAlgorithm.process(this.fsa) as FSAAutomaton;
          this.clearAll()
        })
      MenuItem({
        content: '最小化DFA'
      })
        .onClick(() => {
          if(!this.drawInvoker.initialState || NFA.isNFA(this.fsa)){
            ToastUtil.showToast('该自动机不是 DFA');
            return;
          }
          const preFsa = FSAAutomaton.getAutomaton(this.drawInvoker);
          this.fsa = DFA.minimize(preFsa);
          this.fsa = this.gemLayoutAlgorithm.process(this.fsa) as FSAAutomaton;
          this.clearAll();
        })
      MenuItem({
        content: '删除文件'
      })
        .onClick(() => {
          if(!this.saveFile){
            ToastUtil.showToast('尚未保存');
          }
          this.title = '删除文件';
          this.label = '确定删除该文件吗？';
          this.confirmWindow.open();
        })
      MenuItem({
        content: '自动布局',
      })
        .onClick(() => {
          this.fsa = FSAAutomaton.getAutomaton(this.drawInvoker);
          this.fsa = this.gemLayoutAlgorithm.process(this.fsa) as FSAAutomaton;
          if(this.fsa.update){
            this.endUpdate();
          }
        })
      MenuItem({
        content: '导入Graphviz文件'
      })
        .onClick(() => {
          this.title = '导入Graphviz文件';
          this.graphvizInput.open();
        })
      MenuItem({
        content: '创建测试文件'
      })
        .onClick(() => {
          AutomatonCreator.save(easyFSA);
          AutomatonCreator.save(normalFSA);
          AutomatonCreator.save(nfaToDFATestFSA);
          AutomatonCreator.save(minDFATestFSA);
          AutomatonCreator.save(NFAToDFATest.nfa[1]);
          ToastUtil.showToast('创建成功');
        })
    }
  }

  @Builder
  NavigationMenus(){
    Image($r('app.media.icon_menu'))
      .width(48)
      .height(48)
      .bindMenu(this.FSAMenu())
      .margin({top: 5})
  }

  build() {
    Navigation() {
      DrawCanvas({automatonType: AutomatonType.FSA})
    }
    .title(this.saveFile ? '修改' + this.saveFile.fileName : '新建有穷自动机')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .menus(this.NavigationMenus())
  }
}
