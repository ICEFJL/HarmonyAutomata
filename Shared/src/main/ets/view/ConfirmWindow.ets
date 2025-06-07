@CustomDialog
@Component
export struct ConfirmWindow {
  @Consume label: string;
  @Consume title: string;
  action: Function = () => {};

  private controller: CustomDialogController;

  build() {
    Stack() {
      Column() {
        Text(this.title)
          .textAlign(TextAlign.Start)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .margin({top: 10})

        Text(this.label)
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .margin({top: 5})

        Text()
          .size({width: "100%", height: "2px"})
          .backgroundColor("#bebbc1")
          .margin({top: 10})

        Row() {
          Text("关闭")
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
              this.action();
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
