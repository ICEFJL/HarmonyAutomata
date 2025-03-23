@CustomDialog
@Component
export struct SimulateWindow {
  input: string = "";
  action: Function = () => {};

  private controller: CustomDialogController;

  build() {
    Stack() {
      Column() {
        Row({space: 5}) {
          Text('目标字符串：')
            .fontSize(20)
            .margin({left: 10})
          TextInput({text: $$this.input})
            .fontSize(20)
            .margin({right: 10})
            .width('50%')
            .maxLength(5)
        }
        .margin(15)

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
              this.action(this.input);
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
