import { Const } from '../common/Constants';
import DrawInvoker from '../viewmodel/DrawInvoker';
import { DrawTransition } from '../viewmodel/DrawTransition';
import { DrawType, IDraw } from '../viewmodel/IDraw';

@CustomDialog
@Component
export struct TransitionDetailWindow {
  @Consume mTransition: DrawTransition;
  @Consume firstCreate: boolean;
  @Consume drawInvoker: DrawInvoker;
  @Consume premTransition: DrawTransition;
  labelName: string = "";
  endUpdate: Function = () => {};

  private controller: CustomDialogController;

  aboutToAppear(): void {
    this.labelName = this.mTransition.label;
  }

  build() {
    Stack() {
      Column() {
        Text(this.mTransition.fromState.name+" -> "+this.mTransition.toState.name)
          .fontSize(20)
          .margin({top: 15})

        Row() {
          Text('输入字符：')
            .fontSize(20)
            .margin({left: 10})
          TextInput({text: $$this.labelName, placeholder: Const.EMPTY_STRING })
            .fontSize(20)
            .margin({right: 10})
            .width('50%')
            .maxLength(5)
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
              this.endUpdate();
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
              this.labelName = Array.from(new Set(this.labelName)).join('');
              if (this.firstCreate){
                this.mTransition.label = this.labelName;
                this.drawInvoker.update([this.mTransition],DrawType.ADD);
              } else if(this.mTransition.label != this.labelName) {
                this.mTransition = DrawTransition.deepCopy(this.mTransition);
                this.mTransition.label = this.labelName;
                this.drawInvoker.update([this.mTransition],DrawType.UPDATE,[this.premTransition]);
              }
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
