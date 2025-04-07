import { AutomatonType, Const, FunctionUrl, HelpUtil, SavedFile } from "shared"

@Component
export struct Save{
  @Consume savedFileList: SavedFile[];
  startAbility: Function = () => {}

  getAbility(type: AutomatonType): string {
    switch (type) {
      case AutomatonType.PDA:
        return FunctionUrl.PA
      case AutomatonType.TM:
        return FunctionUrl.TM
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
      case AutomatonType.TM:
        return 'Index'
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

  @Builder
  delete(index: number) {
    Text('删除')
      .fontSize(20) // 设置字体大小
      .fontColor(Color.White) // 设置字体颜色为白色
      .textAlign(TextAlign.Center) // 设置文本居中对齐
      .backgroundColor(Color.Red) // 设置背景颜色为红色
      .height(70)
      .width(70)
      .onClick(() => {
        const name = this.savedFileList[index].fileName;
        this.savedFileList.splice(index, 1);
        SavedFile.delete(name);
      })
  }


  build() {
    NavDestination() {
      List({ space: 10 }) {
        ForEach(this.savedFileList, (item: SavedFile, index: number)=>{
          ListItem(){
            Row(){
              Image(HelpUtil.getPicture(item.fileName))
                .width(60)
                .height(60)
                .margin(5)
              Column({ space: 10}) {
                Row() {
                  Text(item.fileName)
                    .textAlign(TextAlign.Start)
                    .fontSize(18)
                    .layoutWeight(1)
                  Text(item.fileType)
                    .textAlign(TextAlign.End)
                    .fontSize(18)
                }
                Row() {
                  Text(item.note)
                    .textAlign(TextAlign.Start)
                    .fontSize(18)
                    .fontColor(Color.Gray)
                    .layoutWeight(1)
                  Text(item.getSaveTimeStr())
                    .textAlign(TextAlign.End)
                    .fontColor(Color.Gray)
                    .fontSize(18)
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
          }
          .swipeAction({end: this.delete(index)})
        })
      }
      .padding(20)
      .layoutWeight(1)
    }
    .title(this.NavigationTitleBar())
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f3f5')
  }
}