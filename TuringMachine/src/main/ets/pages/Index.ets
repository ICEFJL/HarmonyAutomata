import { Const, DrawCanvas, DrawInvoker, AutomatonType, SaveFileWindow, SavedFile, ConfirmWindow, State } from 'shared';
import {BaseTuringMachine} from '../model/BaseTuringMachine'
import { ToastUtil } from '@pura/harmony-utils';
import { funcAbilityWant } from '../turingmachineability/TuringMachineAbility';
import router from '@ohos.router';
import { TuringGemLayoutAlgorithm } from '../model/GemLayoutAlgorithm'
import { TuringTransition } from '../model/TuringTransition'
import { GraphvizInput } from '../view/GraphvizInput'
import { GraphvizExample } from '../view/GraphvizExample'
@Entry
@Component
struct TMComponent {
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
  private gemLayoutAlgorithm = new TuringGemLayoutAlgorithm();
  @Provide tm: BaseTuringMachine = new BaseTuringMachine();
  private graphvizInput: CustomDialogController = new CustomDialogController({
    builder: GraphvizInput({
      openExample: () => this.openExample(), import: () => {
        this.tm = this.gemLayoutAlgorithm.process(this.tm) as BaseTuringMachine;
        ToastUtil.showToast('导入成功');
        this.clearAll();
      }
    }), // 弹框的构造器
    cancel: () => {
      console.log("cancel") // 点击蒙层的回调
    },
    autoCancel: true, // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });
  private graphvizExample: CustomDialogController = new CustomDialogController({
    builder: GraphvizExample(), // 弹框的构造器
    cancel: () => {
      console.log("cancel") // 点击蒙层的回调
    },
    autoCancel: true, // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  openExample(): void {
    this.graphvizExample.open();
  }

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

  private clearAll(){
    this.drawInvoker.clearAll();
    this.endUpdate();
    this.unDoDraw = false;
    this.redoDraw = false;
  }

  private endUpdate(){
    this.tm.drawTM(this.drawInvoker);
    this.index = Const.NONE;
    this.update = !this.update;
  }

  save(): void{
    this.tm = BaseTuringMachine.getTuringMachine(this.drawInvoker);
    this.tm.setNote(this.note);
    this.tm.setName(this.name);
    this.tm.saveToFile();
    if(this.saveFile){
      this.saveFile.setNote(this.note);
      this.saveFile.update();
    }else {
      this.saveFile = new SavedFile(this.name, this.note, this.tm.type);
      this.saveFile.save();
    }
    this.clearAll();
    this.endUpdate();
  }

  delete(): void{
    if(this.saveFile){
      this.saveFile.delete();
      this.saveFile = null;
      this.tm = new BaseTuringMachine();
      this.clearAll();
      this.endUpdate();
      ToastUtil.showToast('删除成功');
    }else{
      ToastUtil.showToast('尚未保存');
    }
  }

  aboutToAppear() {
    if(funcAbilityWant?.parameters?.file){
      let fileName = funcAbilityWant?.parameters?.fileName as string;
      let note = funcAbilityWant?.parameters?.note as string;
      let fileType = funcAbilityWant?.parameters?.fileType as AutomatonType;
      let saveTime = funcAbilityWant?.parameters?.saveTime as number;
      this.saveFile = new SavedFile(fileName, note, fileType, saveTime);
      this.tm = BaseTuringMachine.loadFromFile("", fileName);
      this.name = fileName;
      this.note = note;
      this.endUpdate();
    }
  }

  @Builder
  TMMenu(){
    Menu() {
      MenuItem({ content: '保存文件' })
        .onClick(() => {
          this.saveFileWindow.open();
        })
      MenuItem({ content: '仿真验证' })
        .onClick(() => {
          if (!this.saveFile) {
            ToastUtil.showToast('尚未保存');
            return;
          }
          const tm: string =this.tm.serialize();
          router.push({
            url:'pages/SimulateTM',
            params:{ data:tm }
          })
        })
      MenuItem({ content: '删除文件' })
        .onClick(() => {
          if(!this.saveFile){
            ToastUtil.showToast('尚未保存');
            return;
          }
          this.title = '删除文件';
          this.label = '确定删除该文件吗？';
          this.confirmWindow.open();
        })
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
  NavigationMenus(){
    Image($r('app.media.icon_menu'))
      .width(48)
      .height(48)
      .bindMenu(this.TMMenu())
  }

  build() {
    Navigation() {
      DrawCanvas({ automatonType: AutomatonType.TM })
    }
    .title(this.saveFile ? 'TM文件:' + this.saveFile.fileName : '新建经典图灵机')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .menus(this.NavigationMenus())
  }
}
