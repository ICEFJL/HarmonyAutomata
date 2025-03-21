import { Const, DrawCanvas, DrawInvoker,State, AutomatonType} from 'shared';
import {BaseTuringMachine} from '../model/BaseTuringMachine'
import {TuringTransition} from '../model/TuringTransition'
import {TuringGemLayoutAlgorithm} from '../model/TuringGemLayoutAlgorithm'
import {FileManager}from 'shared/src/main/ets/automaton/FileManager'


@Entry
@Component
struct TMComponent {
  @Provide drawInvoker: DrawInvoker = new DrawInvoker();
  @Provide update: boolean = false;
  @Provide unDoDraw: boolean = false;
  @Provide redoDraw: boolean = false;
  @Provide index: number = Const.NONE;


  private clearAll(){
    this.drawInvoker.clearAll();
    this.unDoDraw = false;
    this.redoDraw = false;
  }

  private endUpdate(){
    this.index = Const.NONE;
    this.update = !this.update;
  }

  @Builder
  TMMenu(){
    Menu() {
      MenuItem({ content: '保存文件' })
        .onClick(() => {
          //const  exampleTM = BaseTuringMachine.getTuringMachine(this.drawInvoker);
          const  exampleTM =BaseTuringMachine.createExample();
          const exampleFile= new FileManager(AutomatonType.TM);
          exampleTM.saveToFile();
          exampleTM.runTuringMachine();
          exampleFile.initFileList();
          exampleFile.deleteSelectFile('/data/storage/el2/base/haps/TuringMachine/files','test.json');
          exampleFile.initFileList();
        })
      MenuItem({ content: '仿真验证' })
        .onClick(() => {
          const exampleTM =BaseTuringMachine.loadFromFile();
          exampleTM.runTuringMachine();

        })
      MenuItem({ content: '删除文件' })
        .onClick(() => {


        })
      MenuItem({ content: '自动布局' })
        .onClick(() => {
          let gemLayoutAlgorithm = new TuringGemLayoutAlgorithm<State, TuringTransition>();
          const turingMachine = gemLayoutAlgorithm.process(BaseTuringMachine.getTuringMachine(this.drawInvoker)) as BaseTuringMachine;
          if(turingMachine.update){
            turingMachine.drawTuringMachine(this.drawInvoker);
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
      .bindMenu(this.TMMenu())
  }

  build() {
    Navigation() {
      DrawCanvas({ automatonType: AutomatonType.TM })
    }
    .title('经典图灵机')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .menus(this.NavigationMenus())
  }
}
