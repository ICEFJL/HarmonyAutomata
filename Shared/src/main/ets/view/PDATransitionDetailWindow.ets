import { Const } from '../common/Constants';
import DrawInvoker from '../viewmodel/DrawInvoker';
import { DrawTransition } from '../viewmodel/DrawTransition';
import { IDraw } from '../viewmodel/IDraw';

@CustomDialog
@Component
export struct PDATransitionDetailWindow {
  @Consume mTransition: DrawTransition;
  @Consume firstCreate: boolean;
  @Consume drawInvoker: DrawInvoker;

  //为统一接口:此处保留labelName,拆分labelName为readSymbol:popSymbol;pushSymbol
  //eg.读0写1,方向R;记为0,1;R
  labelName: string = "";
  readSymbol: string = "";
  popSymbol: string = "";
  endUpdate: Function = () => {};

  private controller: CustomDialogController;

  aboutToAppear(): void {
    if(this.mTransition.label.length>1){
      this.readSymbol = this.mTransition.label[0];
      this.popSymbol = this.mTransition.label[2];
      this.labelName = this.mTransition.label[4];
    }
    else{
      this.labelName = this.mTransition.label;
    }
  }

  build() {
    Stack() {
      Column() {
        Text(this.mTransition.fromState.name+" -> "+this.mTransition.toState.name)
          .fontSize(20)
          .margin({top: 15})

        Row() {
          Text('读取：')
            .fontSize(20)
            .margin({left: 10})
          TextInput({text: $$this.readSymbol, placeholder: Const.EMPTY_STRING })
            .fontSize(20)
            .margin({right: 10})
            .width('50%')
            .maxLength(1)
        }
        .margin({top: 5})

        Row() {
          Text('取栈：')
            .fontSize(20)
            .margin({left: 10})
          TextInput({text: $$this.popSymbol, placeholder: Const.EMPTY_STRING })
            .fontSize(20)
            .margin({right: 10})
            .width('50%')
            .maxLength(1)
        }
        .margin({top: 5})

        Row() {
          Text('压栈：')
            .fontSize(20)
            .margin({left: 10})
          TextInput({text: $$this.labelName, placeholder: Const.EMPTY_STRING })
            .fontSize(20)
            .margin({right: 10})
            .width('50%')
            .maxLength(1)
        }
        .margin({top: 5})

        Text()
          .size({width: "100%", height: "2px"})
          .backgroundColor("#bebbc1")
          .margin({top: 10})

        Row() {
          Text("取消")
            .height("100%")
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .onClick(() => {
              this.controller.close(); // 关闭弹窗
            })
          Text()
            .size({width: "2px", height: "100%"})
            .backgroundColor("#bebbc1")
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
              if(this.labelName=="") this.labelName="ε";
              if(this.popSymbol=="") this.popSymbol="ε";
              this.labelName=this.readSymbol+","+this.popSymbol+";"+this.labelName;

              console.log("PDTransitionDetailWindow 已设置 labelName ：",this.labelName);

              this.mTransition.label = this.labelName;
              //去重this.mTransition.label = Array.from(new Set(this.mTransition.label)).join('')
              this.drawInvoker.update([this.mTransition]);
              this.endUpdate();
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
