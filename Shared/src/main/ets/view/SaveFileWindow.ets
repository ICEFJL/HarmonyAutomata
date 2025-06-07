import { ToastUtil } from '@pura/harmony-utils';
import { Database } from '../common/Database';
import { SavedFile } from '../common/SavedFile';

@CustomDialog
@Component
export struct SaveFileWindow {
  @Consume name: string;
  @Consume note: string;
  @Consume saveFile: SavedFile;
  @State isShow: boolean = true;
  save: Function = () => {};

  private controller: CustomDialogController;

  aboutToAppear(): void {
    if(this.saveFile){
      this.isShow = false;
    }
  }

  build() {
    Stack() {
      Column() {
        Row({space: 5}) {
          Text('名称：')
            .fontSize(20)
            .margin({left: 10})
          TextInput({text: $$this.name, placeholder: '请输入名称'})
            .fontSize(20)
            .margin({right: 10})
            .width('50%')
            .maxLength(20)
            .focusable(this.isShow)
        }
        .margin({top: 15})

        Row() {
          Text('备注：')
            .fontSize(20)
            .margin({left: 10})
          TextInput({text: $$this.note})
            .fontSize(20)
            .margin({right: 10})
            .width('50%')
            .maxLength(50)
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
            .onClick(async () => {
              if(!SavedFile.isFileNameLegal(this.name)){
                ToastUtil.showToast("文件名不能为空，且只能包含汉字、英文字母、数字、'.'、'-'、'_'");
                return;
              }
              if(!this.saveFile){
                let result = await Database.queryByFileName(this.name);
                if(result && result.length > 0){
                  ToastUtil.showToast("文件名重复");
                  return;
                }
              }
              this.save();
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
