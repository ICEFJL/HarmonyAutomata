import { AutomatonType, Const, FunctionUrl, HelpUtil, SavedFile } from "shared"

@Component
export struct Save{
  @Consume savedFileList: SavedFile[];
  startAbility: Function = () => {}

  getAbility(type: AutomatonType): string {
    switch (type) {
      case AutomatonType.FSA:
      case AutomatonType.NFA:
      case AutomatonType.DFA:
        return FunctionUrl.FA
      default:
       return FunctionUrl.FA
    }
  }

  getRouter(type: AutomatonType): string {
    switch (type) {
      case AutomatonType.FSA:
      case AutomatonType.NFA:
      case AutomatonType.DFA:
        return 'Index'
      default:
       return 'Index'
    }
  }

  @Builder
  NavigationTitleBar(){
    Row() {
      Text('已保存')
        .fontSize(24)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .margin(10)
    }
    .backgroundColor(Color.White)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  build() {
    NavDestination() {
      Column({ space: 10 }) {
        ForEach(this.savedFileList, (item: SavedFile)=>{
          Row(){
            Image(HelpUtil.getPicture(item.fileName))
              .width(60)
              .height(60)
              .margin(5)
            Column({ space: 5}) {
              Row() {
                Text(item.fileName)
                  .textAlign(TextAlign.Start)
                  .fontSize(20)
                  .layoutWeight(1)
                Text(item.fileType)
                  .textAlign(TextAlign.End)
                  .fontSize(20)

              }
              Row() {
                Text(item.note)
                  .textAlign(TextAlign.Start)
                  .fontSize(20)
                  .layoutWeight(1)
                Text(item.getSaveTimeStr())
                  .textAlign(TextAlign.End)
                  .fontSize(20)
              }
            }
              .layoutWeight(1)
              .margin(5)
          }
          .height(70)
          .backgroundColor(Color.White)
          .onClick(() => {
            this.startAbility(this.getAbility(item.fileType),this.getRouter(item.fileType), item)
          })
        })
        Button('test')
          .onClick(() => {
            this.startAbility(FunctionUrl.FA, 'test')
          })
        Button('test1')
          .onClick(() => {
            this.startAbility(FunctionUrl.FA, 'test1')
          })
      }
      .padding(20)
    }
    .title(this.NavigationTitleBar())
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f3f5')
  }
}