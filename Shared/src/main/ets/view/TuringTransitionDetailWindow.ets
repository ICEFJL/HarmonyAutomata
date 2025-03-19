import { Const } from '../common/Constants';
import DrawInvoker from '../viewmodel/DrawInvoker';
import { DrawTransition } from '../viewmodel/DrawTransition';
import { IDraw } from '../viewmodel/IDraw';

@CustomDialog
@Component
export struct TuringTransitionDetailWindow {
  @Consume mTransition: DrawTransition;
  @Consume firstCreate: boolean;
  @Consume drawInvoker: DrawInvoker;

  //为统一接口:此处保留labelName,拆分labelName为readSymbol:writeSymbol;moveDirection
  //eg.读0写1,方向R;记为0,1;R
  labelName: string = "";
  readSymbol: string = "";
  writeSymbol: string = "";
  endUpdate: Function = () => {};
  private controller: CustomDialogController;

  // Step 1: 定义互斥状态变量
  @State isR: boolean = true;//默认选择右移
  @State isL: boolean = false;
  @State isS: boolean = false;

  // Step 2: 创建互斥状态更新函数
  private updateSelection(selected: string) {
    this.isR = (selected === 'right');
    this.isL = (selected === 'left');
    this.isS = (selected === 'stay');
  }

  aboutToAppear(): void {
    this.labelName = this.mTransition.label;
  }

  build() {
    Stack() {
      Column() {
        Text(this.mTransition.fromState.name+" -> "+this.mTransition.toState.name)
          .fontSize(20)
          .margin({top: 15})

        Text()
          .size({width: "100%", height: "2px"})
          .backgroundColor("#bebbc1")
          .margin({top: 10})

        Text('当前读写头操作：')
          .fontSize(20)
          .width('100%')  // 显式声明宽度
          .padding({left:10})  // 替代子组件边距
          .margin({top: 10})

        Row() {
          Row() {
            Text("读")
              .fontSize(20)
              .margin({ left: 10 })
            TextInput({ text: $$this.readSymbol, placeholder: Const.EMPTY_STRING })
              .fontSize(20)
              .margin({ right: 10 })
              .width('30%')
              .maxLength(1)
          }
          Row() {
            Text("写")
              .fontSize(20)
              .margin({left: 10})
            TextInput({text: $$this.writeSymbol, placeholder: Const.EMPTY_STRING })
              .fontSize(20)
              .margin({right: 10})
              .width('30%')
              .maxLength(1)
          }
        }
        .margin({top: 5})

        Text('移动方向：')
          .fontSize(20)
          .width('100%')  // 显式声明宽度
          .padding({left:10})  // 替代子组件边距
          .margin({top: 10})

        // Step 3: 绑定状态与事件
        Row() {
          Row() {
            Text('右移').fontSize(20)
            Checkbox()
              .select($$this.isR)
              .onChange((checked) => {
                if (checked) this.updateSelection('right')
              })
          }
          Row() {
            Text('左移').fontSize(20).margin({left:10})
            Checkbox()
              .select($$this.isL)
              .onChange((checked) => {
                if (checked) this.updateSelection('left')
              })
          }
          Row() {
            Text('不动').fontSize(20).margin({left:10})
            Checkbox()
              .select($$this.isS)
              .onChange((checked) => {
                if (checked) this.updateSelection('stay')
              })
          }
        }
        .margin({top: 5})

        Text()
          .size({width: "100%", height: "2px"})
          .backgroundColor("#bebbc1")
          .margin({top: 10})

        Row() {
          Text("确认")
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .height("100%")
            .layoutWeight(1)
            .onClick(() => {
              if(!this.firstCreate){
                this.mTransition = DrawTransition.deepCopy(this.mTransition);
              }
              //合并为labelName
              if(this.readSymbol=="") this.readSymbol="ε";
              if(this.writeSymbol=="") this.writeSymbol="ε";
              if(this.isR){
                this.labelName=this.readSymbol+","+this.writeSymbol+";"+"R";
              }
              else if(this.isL){
                this.labelName=this.readSymbol+","+this.writeSymbol+";"+"L";
              }
              else if(this.isS){
                this.labelName=this.readSymbol+","+this.writeSymbol+";"+"S";
              }
              else {
                console.error("未选择移动方向！");
              }
              console.log("TuringTransitionDetailWindow 已设置 labelName ：",this.labelName);
              this.mTransition.label = this.labelName;
              //this.mTransition.label = Array.from(new Set(this.mTransition.label)).join('')
              this.drawInvoker.update([this.mTransition]);
              this.endUpdate();
              this.controller.close(); // 关闭弹窗
            })
          Text()
            .size({width: "2px", height: "100%"})
            .backgroundColor("#bebbc1")
          Text("取消")
            .height("100%")
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .onClick(() => {
              this.controller.close(); // 关闭弹窗
            })
        }
        .height(45)
        .width('100%')
      }
      .backgroundColor("#e6ffffff")
      .borderRadius(20)
    }
    .padding({left: 40, right: 40})
    .width("100%")
  }
}
