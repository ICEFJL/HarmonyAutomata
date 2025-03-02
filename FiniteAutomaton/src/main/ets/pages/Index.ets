import {DrawCanvas, DrawInvoker} from 'shared';

@Entry
@Component
struct ParentComponent {
  @Provide drawInvoker: DrawInvoker = new DrawInvoker();

  @Builder
  FSAMenu(){
    Menu() {
      MenuItem({
        content: '保存文件'
      })
      MenuItem({
        content: '仿真验证'
      })
      MenuItem({
        content: 'NFA->DFA'
      })
      MenuItem({
        content: '最小化DFA'
      })
      MenuItem({
        content: '删除文件'
      })
    }
  }

  @Builder
  NavigationMenus(){
    Image($r('app.media.icon_menu'))
      .width(48)
      .height(48)
      .bindMenu(this.FSAMenu())
  }

  build() {
    Navigation() {
      DrawCanvas()
    }
    .title('有限自动机')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .menus(this.NavigationMenus())
  }
}
