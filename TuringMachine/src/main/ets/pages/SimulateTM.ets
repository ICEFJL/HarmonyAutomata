import router from '@ohos.router';
import {BaseTuringMachine} from '../model/BaseTuringMachine'

@Entry
@Component
struct SimulateTM {
  @State message: string = 'Hello World';
  @State params:object=router.getParams();
  tm=new BaseTuringMachine();

  onPageShow() {
    const data: string = this.params['data'];
    this.tm=BaseTuringMachine.deserialize(data);
    //this.tm.initializeTape("101");
    //this.tm.runTuringMachine();
  }

  build() {
    Navigation() {

    }
    .title('经典图灵机仿真')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
  }
}