import { Const, DrawCanvas, DrawInvoker,State, AutomatonType} from 'shared';
import {BaseTuringMachine} from '../model/BaseTuringMachine'
import {TuringTransition} from '../model/TuringTransition'
import {TuringGemLayoutAlgorithm} from '../model/TuringGemLayoutAlgorithm'

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
          const turingMachine =BaseTuringMachine.createExample();
          turingMachine.saveToFile();

        })
      MenuItem({ content: '仿真验证' })
        .onClick(() => {
          const exampleTM =BaseTuringMachine.loadFromFile();
          console.log("Initial Tape:", exampleTM.getCurrentTape());
          console.log("Head Position:", exampleTM.headPosition);
          console.log("CurrentSymbol:", exampleTM.getCurrentSymbol());

          let stepCount = 0;
          console.log(`Step ${++stepCount}:`);
          try {
            while (exampleTM.step()) {
              console.log(`Step ${++stepCount}:`);
              console.log("Head Position:", exampleTM.headPosition);
              console.log("Current Symbol:", exampleTM.getCurrentSymbol());
              console.log("Tape:", exampleTM.getCurrentTape());
              console.log("-------------------");
            }
          } catch (e) {
            console.error("执行异常:", e);
            throw new Error('Failed to run TuringMachine');
          }

          console.log("Final Tape:", exampleTM.getCurrentTape());


        })
      MenuItem({ content: '文件管理' })
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
