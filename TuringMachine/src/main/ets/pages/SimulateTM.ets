import router from '@ohos.router';
import {BaseTuringMachine} from '../model/BaseTuringMachine'
import {TuringResult,StepLog} from '../model/runResultLog'
import { autoFillManager } from '@kit.AbilityKit';

@Entry
@Component
struct SimulateTM {
  @State params:object=router.getParams();
  @State initialTape:string="";
  @State stepCount:number=0;
  @State ifFinal:boolean=false;
  @State result:TuringResult={
    logs:[],
    finalTape:"",
    finalStep:0
  }
  @State stepLog:StepLog={
    step: 0,
    head: 0,
    currentState:"",
    transition:"",
    tape: ""
  }
  @State showStates: string = "";
  @State showInitialState: string = "";
  @State showFinalStates: string = "";
  @State showSymbols: string = "";
  @State showBlankSymbol: string = "";
  @State showEnterSymbols: string = "";
  @State showTransitions: string[] = [];

  tm=new BaseTuringMachine();
  //设最大步数为五十步
  maxStep:number=50;

  onPageShow() {
    const data: string = this.params['data'];
    this.tm = BaseTuringMachine.deserialize(data);
    //this.tm = this.tm.createExample();
    this.showStates = this.tm.showStates();
    this.showInitialState = this.tm.showInitialState();
    this.showFinalStates = this.tm.showFinalStates();
    this.showSymbols = this.tm.showSymbols();
    this.showBlankSymbol = this.tm.showBlankSymbol();
    this.showEnterSymbols = this.tm.showEnterSymbols();
    this.showTransitions = this.tm.showTransitions();
  }

  build() {
    Navigation() {
      Text()
        .size({width: "100%", height: "2px"})
        .backgroundColor($r('sys.color.black'))
      Row(){
        Text("初始纸带")
          .fontSize(20)
          .margin({left: 10})
        TextInput({
          text:$$this.initialTape,
          placeholder:"请输入初始纸带内容"
        })
          .fontSize(20)
          .margin({right: 10})
          .width("75%")
      }
      .margin({top:10})
      Button("开始仿真")
        .align(Alignment.Center)
        .fontSize(20)
        .onClick(() => {
          //重置图灵机状态
          this.tm.reset();
          this.ifFinal=false;
          this.stepCount=0;
          this.tm.initializeTape(this.initialTape);
          this.result=this.tm.runResultLog();
          const specificLog = this.result.logs.find(log => log.step === this.stepCount);
          if (specificLog) {
            this.stepLog=specificLog;
          }
          else console.error("错误步数");
        })
        .margin({top:10})
      Column() {
        Text("状态集 " + `${this.showStates}`)
          .fontSize(20)
          .margin({ top: 10, left: 10 })
        Text("初始状态 " + `${this.showInitialState}`)
          .fontSize(20)
          .margin({ top: 10, left: 10 })
        Text("终止状态集 " + `${this.showFinalStates}`)
          .fontSize(20)
          .margin({ top: 10, left: 10 })
        Text("带符号表 " + `${this.showSymbols}`)
          .fontSize(20)
          .margin({ top: 10, left: 10 })
        Text("空白符 " + `${this.showBlankSymbol}`)
          .fontSize(20)
          .margin({ top: 10, left: 10 })
        Text("输入字母表 " + `${this.showEnterSymbols}`)
          .fontSize(20)
          .margin({ top: 10, left: 10 })
        Row() {
          Text("移动函数 ")
            .fontSize(20)
          List({ space: 10, initialIndex: 0 }) {
            ForEach(this.showTransitions, (item: string) => {
              ListItem() {
                Text(item)
                  .fontSize(20)
                  .margin({ left: 10 })
              }.editable(false)
            }, (item: string) => item)
          }
          .height("40%")
          .width("100%")
          .listDirection(Axis.Vertical)
          .edgeEffect(EdgeEffect.None)
          .layoutWeight(1)
          .alignListItem(ListItemAlign.Start) // 列表项顶部对齐
          .margin({ left: 10, bottom: 10, right: 10 })
          .border({
            radius: 8                  // 圆角半径
          })
        }
        .alignItems(VerticalAlign.Top) // Row 内顶部对齐
        .margin({ top: 10, left: 10, right: 10 })
        .width('75%')
      }
      .border({
        width: 1, // 边框宽度
        color: Color.Gray, // 边框颜色
        radius: 8, // 圆角半径
        style: BorderStyle.Solid      // 边框样式（实线）
      })
      .alignItems(HorizontalAlign.Start)
      .width("95%")
      .layoutWeight(1)
      .margin({ top: 10 })
      Column(){
        Text(this.ifFinal ? "最终状态 " + `${this.stepLog.currentState}` : "当前状态 " + `${this.stepLog.currentState}`)
          .margin({ top: 10, left: 10 })
          .fontSize(20)
        Text("进行的读写操作 "+`${this.stepLog.transition}`)
          .margin({ top: 10, left: 10 })
          .fontSize(20)
        Text(this.ifFinal ? "最终读写头位置 " + `${this.stepLog.head + 1}` :
          "当前读写头位置 " + `${this.stepLog.head + 1}`)
          .margin({ top: 10, left: 10 })
          .fontSize(20)
        Text(this.ifFinal ? "最终纸带 " + `${this.stepLog.tape}` : "当前纸带 " + `${this.stepLog.tape}`)
          .margin({ top: 10, left: 10 })
          .fontSize(20)
        Row(){
          Text("步数")
            .fontSize(20)
            .margin({left:10})
          Text(`${this.stepCount}/${this.result.finalStep}`)
            .fontSize(20)
            .margin({ left: 5 })
          Button("上一步")
            .fontSize(20)
            .margin({left:10})
            .onClick(() => {
              this.ifFinal=false;
              if(this.stepCount==0){
                console.log("当前为初始状态");
                return;
              }
              else this.stepCount--;
              const specificLog = this.result.logs.find(log => log.step === this.stepCount);
              if (specificLog) {
                this.stepLog=specificLog;
              }
              else console.error("错误步数");
            })
          Button("下一步")
            .fontSize(20)
            .margin({left:10})
            .onClick(() => {
              if(this.ifFinal) return;
              if(this.stepCount>=this.result.finalStep||this.stepCount>=this.maxStep){
                console.log("已达到最大步数");
                return;
              }
              else{
                this.stepCount++;
                if(this.stepCount==this.result.finalStep) this.ifFinal=true;
              }
              const specificLog = this.result.logs.find(log => log.step === this.stepCount);
              if (specificLog) {
                this.stepLog=specificLog;
              }
              else console.error("错误步数");
            })
        }
        .margin({ top: 10, bottom: 10 })
      }
      .alignItems(HorizontalAlign.Start)
      .border({
        width: 1, // 边框宽度
        color: Color.Gray, // 边框颜色
        radius: 8, // 圆角半径
        style: BorderStyle.Solid      // 边框样式（实线）
      })
      .width("95%")
      .margin({ top: 10 })
      Row(){
        Text("仿真结果")
          .fontSize(20)
          .margin({left: 10})
        TextInput({
          text:`${this.result.finalTape}`,
        })
          .fontSize(20)
          .margin({right: 10})
          .width("75%")
          .enabled(false) // 关键属性控制只读
          .backgroundColor('#f5f5f5') // 视觉提示
      }
      .margin({top:10})
    }
    .title('经典图灵机仿真')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
  }
}