import {DrawCanvas, DrawInvoker} from 'shared';
import {BaseTuringMachine} from '../model/BaseTuringMachine'
const exampleTM=BaseTuringMachine.createExample();
//const exampleTM = BaseTuringMachine.loadFromFile();
exampleTM.saveToFile();//如何支持相对路径
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

@Entry
@Component

struct ParentComponent {

  @Builder
  FSAMenu() {
    Menu() {
      MenuItem({ content: '保存文件' })

      MenuItem({ content: '文件管理' })

      MenuItem({ content: '仿真验证' })

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
      //DrawCanvas()
    }
    .title('经典图灵机')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .menus(this.NavigationMenus())
  }
}
