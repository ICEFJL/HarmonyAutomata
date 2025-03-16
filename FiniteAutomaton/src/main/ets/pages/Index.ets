import { Const, DrawCanvas, DrawInvoker, FSAAutomaton, GemLayoutAlgorithm, State, Transition} from 'shared';

@Entry
@Component
struct FSAComponent {
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
  FSAMenu(){
    Menu() {
      MenuItem({
        content: '保存文件'
      })
        .onClick(() => {

        })
      MenuItem({
        content: '仿真验证'
      })
      MenuItem({
        content: 'NFA->DFA'
      })
      MenuItem({
        content: '最小化DFA'
      })
      MenuItem({
        content: '删除文件'
      })
      MenuItem({
        content: '自动布局',
      })
        .onClick(() => {
          let gemLayoutAlgorithm = new GemLayoutAlgorithm<State, Transition>();
          const automaton = gemLayoutAlgorithm.process(FSAAutomaton.getAutomaton(this.drawInvoker)) as FSAAutomaton;
          if(automaton.update){
            automaton.drawAutomaton(this.drawInvoker);
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
      .bindMenu(this.FSAMenu())
  }

  build() {
    Navigation() {
      DrawCanvas()
    }
    .title('有限自动机')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .menus(this.NavigationMenus())
  }
}
