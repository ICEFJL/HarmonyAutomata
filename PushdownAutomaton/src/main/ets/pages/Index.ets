import { Const, DrawCanvas, DrawInvoker,State, AutomatonType} from 'shared';
import { PDAAutomaton } from '../model/PDAAutomaton';
import { PDAGemLayoutAlgorithm } from '../model/PDAGemLayoutAlgorithm';
import { PDATransition } from '../model/PDATransition';

// import {BaseTuringMachine} from '../model/BaseTuringMachine'
// import {TuringTransition} from '../model/TuringTransition'
// import {TuringGemLayoutAlgorithm} from '../model/TuringGemLayoutAlgorithm'
// import {FileManager}from 'shared/src/main/ets/automaton/FileManager'


@Entry
@Component
struct TMComponent {
  @Provide drawInvoker: DrawInvoker = new DrawInvoker();
  @Provide update: boolean = false;
  @Provide unDoDraw: boolean = false;
  @Provide redoDraw: boolean = false;
  @Provide index: number = Const.NONE;

  pda = new PDAAutomaton();
  private gemLayoutAlgorithm = new PDAGemLayoutAlgorithm();


  private clearAll(){
    this.drawInvoker.clearAll();
    this.unDoDraw = false;
    this.redoDraw = false;
  }

  private endUpdate(){
    this.drawInvoker.clearAll(); // 清空旧的绘制内容
    this.pda.drawPDAAutomaton(this.drawInvoker);
    this.index = Const.NONE;
    this.update = !this.update;
  }

  @Builder
  TMMenu(){
    Menu() {
      MenuItem({ content: '保存文件' })
        .onClick(() => {

        })
      MenuItem({ content: '仿真验证' })
        .onClick(() => {

        })
      MenuItem({ content: '删除文件' })
        .onClick(() => {

        })
      MenuItem({ content: '自动布局' })
        .onClick(() => {
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
      .bindMenu(this.TMMenu())
  }

  build() {
    Navigation() {
      DrawCanvas({ automatonType: AutomatonType.PDA })
    }
    .title('下推自动机')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .menus(this.NavigationMenus())
  }
}
