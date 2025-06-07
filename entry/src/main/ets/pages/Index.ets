// Index.ets
import router from '@ohos.router';
import { Home } from './Home';
import { LogUtil } from '@pura/harmony-utils';
import { SavedFile } from 'shared/src/main/ets/common/SavedFile';
import { Const, Database } from 'shared';
import { Save } from './Save';

@Entry
@Component
struct Index {
  private controller: TabsController = new TabsController();
  @State index: number = 0; // 选项卡下标，默认为第一个
  @Provide savedFileList: SavedFile[] = [];
  async onPageShow(){
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

  startAbility(name: string = '', route: string = '', savedFile: SavedFile | null = null): void {
    if (savedFile) {
      router.pushUrl({
        url: name+"/"+"pages/"+route,
        params: savedFile
      })
    } else {
      router.pushUrl({
        url: name+"/"+"pages/"+route
      })
    }
  }

  @Builder tabHome() {   // 自定义消息标签
    Column() {
      Column() {
        Blank()
        Image(this.index == 0 ? $r("app.media.home_active") : $r("app.media.home"))
          .size({ width: 25, height: 25 })
        Text('功能')
          .fontSize(16)
          .fontColor(this.index == 0 ? "#0A59F7" : "#6b6b6b")
        Blank()
      }
      .height('100%')
      .width("100%")
      .onClick(() => {
        this.index = 0;
      })
    }
  }

  @Builder tabSave() {  // 自定义联系人标签
    Column() {
      Blank()
      Image(this.index == 1 ? $r("app.media.save_active") : $r("app.media.save"))
        .size({ width: 25, height: 25 })
      Text('已保存')
        .fontSize(16)
        .fontColor(this.index == 1 ? "#0A59F7" : "#6b6b6b")
      Blank()
    }
    .height('100%')
    .width("100%")
    .onClick(() => {
      this.index = 1;
    })
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End, // TabBar排列在下方
        controller: this.controller,   // 绑定控制器
        index: this.index
      }) {
        TabContent() {
          Home({ startAbility: (name: string, router: string) => this.startAbility(name, router) })
        }
        .tabBar(this.tabHome)      // 使用自定义TabBar

        TabContent() {
          Save({ startAbility: (name: string, router: string, savedFile: SavedFile | null) => this.startAbility(name, router, savedFile) })
        }
        .tabBar(this.tabSave)     // 使用自定义TabBar
      }
      .width('100%')
      .height('100%')
      .barHeight(60)
      .barMode(BarMode.Fixed)         // TabBar均分
      .scrollable(false)
    }
    .width('100%')
    .height('100%')
  }
}
