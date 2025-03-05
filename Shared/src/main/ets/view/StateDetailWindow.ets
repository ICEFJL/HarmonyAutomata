import DrawInvoker from '../viewmodel/DrawInvoker';
import { DrawState } from '../viewmodel/DrawState';

@CustomDialog
@Component
export struct StateDetailWindow {
  @Consume drawInvoker: DrawInvoker;
  @Consume mState: DrawState;
  mStateName: string = "";
  isInitialState: boolean = false;
  isFinalState: boolean = false;
  endUpdate: Function = () => {};

  private controller: CustomDialogController;

  aboutToAppear(): void {
    this.mStateName = this.mState.state.name;
    this.isInitialState = this.mState.isInitialState;
    this.isFinalState = this.mState.state.isFinal;
  }

  build() {
    Stack() {
      Column() {
        Row({space: 5}) {
          Text('状态名称：')
            .fontSize(20)
            .margin({left: 10})
          TextInput({text: $$this.mStateName, placeholder: '请输入状态名称' })
            .fontSize(20)
            .margin({right: 10})
            .width('50%')
            .maxLength(5)
        }
        .margin({top: 15})

        Row() {
          Row(){
            Text('初始状态')
              .fontSize(20)
              .margin(10)
            Checkbox() // 添加复选框
              .select($$this.isInitialState)
              .margin(10)
          }
          Row() {
            Text('最终状态')
              .fontSize(20)
              .margin(10)
            Checkbox() // 添加复选框
              .select($$this.isFinalState)
              .margin(10)
          }
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
              this.mState = DrawState.deepCopy(this.mState)
              this.mState.state.name = this.mStateName;
              this.mState.isInitialState = this.isInitialState;
              this.mState.state.isFinal = this.isFinalState;
              this.drawInvoker.update([this.mState])
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
