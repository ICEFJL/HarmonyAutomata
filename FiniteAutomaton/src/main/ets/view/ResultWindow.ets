@CustomDialog
@Component
export struct ResultWindow {
  @Consume label: string;
  @Consume title: string;

  private controller: CustomDialogController;

  build() {
    Stack() {
      Column() {
        Text(this.title)
          .textAlign(TextAlign.Center)
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
          Text("确认")
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .height("100%")
            .layoutWeight(1)
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
