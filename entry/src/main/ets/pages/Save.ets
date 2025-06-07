import { LogUtil } from "@pura/harmony-utils";
import { AutomatonType, Const, Database, FunctionUrl, HelpUtil, SavedFile } from "shared"
import { FileListWindow } from "../view/FileListWindow";

@Component
export struct Save{
  @Consume savedFileList: SavedFile[];
  @State showFileList: boolean = false;
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

  @Builder
  export(index: number) {
    Text('导出')
      .fontSize(20) // 设置字体大小
      .fontColor(Color.White) // 设置字体颜色为白色
      .textAlign(TextAlign.Center) // 设置文本居中对齐
      .backgroundColor(Color.Blue) // 设置背景颜色为红色
      .height(70)
      .width(70)
      .onClick(() => {
        const name = this.savedFileList[index].fileName;
        SavedFile.export(name);
      })
  }

  @Builder
  buildActionButtons(index: number) {
    Row() {
      this.export(index)   // 导出按钮
      this.delete(index)   // 删除按钮
    }
    .layoutWeight(3) // 控制按钮区域宽度
  }

  @Builder
  Menu(){
    MenuItem({ content: '导入文件' })
      .onClick(() => {
        this.showFileList=true;

      })
  }

  @Builder
  NavigationMenus(){
    Image($r('app.media.icon_menu'))
      .width(48)
      .height(48)
      .bindMenu(this.Menu())
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }){
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
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(item.fileType)
                      .textAlign(TextAlign.End)
                      .fontSize(18)
                  }
                  .layoutWeight(1)
                  Row() {
                    Text(item.note)
                      .textAlign(TextAlign.Start)
                      .fontSize(18)
                      .fontColor(Color.Gray)
                      .layoutWeight(10)
                      .maxLines(2)          // 限制最多显示2行
                      .textOverflow({ overflow: TextOverflow.Ellipsis }) // 超出部分显示...
                    Text(item.getSaveTimeStr())
                      .textAlign(TextAlign.End)
                      .fontColor(Color.Gray)
                      .fontSize(18)
                      .layoutWeight(6)
                  }
                }
                .layoutWeight(2)
                .margin(5)
              }
              .height(75)
              .backgroundColor(Color.White)
              .onClick(() => {
                this.startAbility(this.getAbility(item.fileType),this.getRouter(item.fileType), item)
              })
            }
            .swipeAction({end: this.buildActionButtons(index)})
          })
        }
        .padding(20)
        .layoutWeight(1)

        if (this.showFileList) {
          FileListWindow({
            onClose: async () => {
              this.showFileList = false;
              await Database.getRdbStore(); // 确保数据库初始化完成
              try {
                const data = await Database.queryAllData(); // 异步获取数据
                if(!data){
                  return;
                }
                this.savedFileList = data; // 更新状态
                this.savedFileList.sort((a, b) => {
                  return b.saveTime - a.saveTime;
                })
              } catch (error) {
                LogUtil.error('Failed to load saved files: ' + JSON.stringify(error));
              }
            }
          })
            .width('100%')
            .height('100%')
        }
      }
    }
    .title(this.NavigationTitleBar())
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f3f5')
    .menus(this.NavigationMenus())

  }
}