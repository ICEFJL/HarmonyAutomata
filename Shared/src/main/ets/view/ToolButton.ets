import { Const } from "../common/Constants";

@Component
export struct ToolButton {
  @Prop icon: Resource;
  @Prop activeIcon: Resource;
  @Prop text: Resource;
  @Prop isActive: boolean;

  build() {
    Column() {
      Image(this.isActive ? this.activeIcon : this.icon)
        .width($r('app.float.image_width'))
        .height($r('app.float.image_width'))
        .margin({ top: $r('app.float.top'),bottom: $r('app.float.bottom') });
      Text(this.text)
        .fontSize($r('app.float.font_size_m'))
        .fontColor(this.isActive ? $r('app.color.theme_color') : $r('sys.color.mask_secondary'));
    }
    .width($r('app.float.paint_width'))
    .height($r('app.float.paint_height'));
  }
}
