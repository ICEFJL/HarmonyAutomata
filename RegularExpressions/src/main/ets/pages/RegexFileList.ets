import Regular_Expression from '../datastructure/Regular_Expression';
import { AutomatonToRegexConverter } from '../convert/AutomatonToRegexConverter';
import { FileUtil } from '../datastructure/FileUtil';
import { LogUtil } from '@pura/harmony-utils';
import router from '@ohos.router';
import { ToastUtil } from '@pura/harmony-utils';

interface RegexFile {
  fileName: string;
  content: string;
}

@Entry
@Component
export struct RegexFileList {
  @State regexFiles: RegexFile[] = [];
  @State initialized: boolean = false;
  @Provide showSaveDialog: boolean = false;
  @Provide saveFileName: string = '';
  private regularexpression: string = '';
  @State editDialogVisible: boolean = false;
  @State editFileName: string = '';
  @State editRegexContent: string = '';
  private editFileIndex: number = -1;

  aboutToAppear() {
    this.loadRegexFiles();
  }

  async loadRegexFiles(): Promise<void> {
    const dir = "EX";
    let fileNames: string[] = [];

    try {
      fileNames = FileUtil.listFiles(dir); // 无需 context
    } catch (err) {
      LogUtil.error('读取文件夹失败: ' + JSON.stringify(err));
      return;
    }

    const regexList: RegexFile[] = [];

    for (const fileName of fileNames) {
      const content = FileUtil.readFile(dir, fileName); // 无需 context
      regexList.push({ fileName, content });
      console.log('展示内容:', content);
    }

    this.regexFiles = regexList;
    this.initialized = true;
  }

  confirmSave()
  {
    const regex = new Regular_Expression(this.regularexpression);
    let result = regex.isValidRegex();
    if (!result) {
      ToastUtil.showToast("错误原因: " + regex.errorMessage);
      console.log("表达式不合法: " + regex.errorMessage);
      return;
    } else {
      console.log("正则表达式合法");
      console.log("FileName:"+this.saveFileName+".json   "+"regularexpression"+this.regularexpression);
      const saved = FileUtil.saveFile("EX", this.saveFileName+".json", this.regularexpression);
      if (saved) {
        ToastUtil.showToast("保存成功");
        console.log("保存成功");
        this.showSaveDialog = false;
        this.regularexpression="";
        this.saveFileName="";
        this.loadRegexFiles();
      } else {
        ToastUtil.showToast("保存失败：文件已存在");
        console.error("保存失败");
      }
    }
  }

  confirmEdit() {
    const regex = new Regular_Expression(this.editRegexContent);
    if (!regex.isValidRegex()) {
      ToastUtil.showToast("表达式不合法:" + regex.errorMessage);
      return;
    }
    const newFileName = this.editFileName + '.json';
    const oldFileName = this.regexFiles[this.editFileIndex].fileName;
    FileUtil.deleteFile("EX", oldFileName);

    const success = FileUtil.saveFile("EX", newFileName, this.editRegexContent);
    if (success) {
      ToastUtil.showToast("修改成功");
      this.regularexpression="";
      this.saveFileName="";
      this.editDialogVisible = false;
      this.loadRegexFiles();
    } else {
      ToastUtil.showToast("修改失败:文件已存在");
    }
  }


  @Builder
  buildRegexRow(item: RegexFile, index: number) {
    ListItem() {
      Row() {
        Column() {
          Text(item.fileName.substring(0, item.fileName.length - 5))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text(item.content)
            .fontSize(16)
            .fontColor(Color.Gray)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

        }
        .border({
          width: 1,
          color: '#d0d0d0',
          radius: 10 // 圆角
        })
        .shadow({ // 阴影效果
          color: '#aaa',
          radius: 6,
          offsetX: 2,
          offsetY: 2
        })
        .layoutWeight(1)
        .margin(5);
      }
      .height(50)
      .backgroundColor(Color.White)
      .onClick(() => {
        LogUtil.info("点击查看正则表达式: " + item.content);
        ToastUtil.showToast("正则表达式: " + item.content)
        // 可扩展跳转详情页
      });
    }
    .margin({ bottom: 6 })
    .swipeAction({
      end: this.buildActionButtons(index)
    });
  }

  @Builder
  buildActionButtons(index: number) {
    Row() {
      this.simulate(index)
      this.edit(index)
      this.delete(index)
    }
    .layoutWeight(3);
  }

  @Builder
  edit(index: number) {
    Text('修改')
      .fontSize(20)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Blue)
      .height(70)
      .width(70)
      .onClick(() => {
        const file = this.regexFiles[index];
        this.editFileName = file.fileName.replace(/\.json$/, '');
        this.editRegexContent = file.content;
        this.editFileIndex = index;
        this.editDialogVisible = true;
      });
  }

  @Builder
  simulate(index: number) {
    Text('仿真')
      .fontSize(20)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Green)
      .height(70)
      .width(70)
      .onClick(() => {
        const content = this.regexFiles[index].content;
        router.pushUrl({
          url: 'pages/REToAutomaton',
          params: { regularExpression: content }
        });
      });
  }

  @Builder
  delete(index: number) {
    Text('删除')
      .fontSize(20)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Red)
      .height(70)
      .width(70)
      .onClick(() => {
        const fileName = this.regexFiles[index].fileName;
        const success = FileUtil.deleteFile("EX", fileName); // 无需 context
        if (success) {
          this.regexFiles.splice(index, 1);
        } else {
          LogUtil.error("删除文件失败：" + fileName);
        }
      });
  }

  @Builder
  SaveMenu() {
    Menu() {
      MenuItem() {
        Text('新建文件')
          .onClick(() => this.showSaveDialog = true) // 弹出保存文件弹窗
          .width(160)
          .height(50)
          .fontSize(20)
          .padding(10)
      }
    }
  }

  @Builder
  NavigationMenus() {
    Image($r('app.media.icon_menu'))
      .width(48)
      .height(48)
      .bindMenu(this.SaveMenu())
  }

  build() {
    Column() {
      Navigation()
      {}
      .title('正则表达式')
      .titleMode(NavigationTitleMode.Mini)
      .hideToolBar(true)
      .width('100%')
      .height(56)
      .menus(this.NavigationMenus())

      if (!this.initialized) {
        Text('加载中...')
          .margin(20);
      } else if (this.regexFiles.length === 0) {
        Text('暂无保存的正则表达式')
          .margin(20);
      }
      else {
        List() {
          ForEach(this.regexFiles, (item: RegexFile, index: number) => {
            this.buildRegexRow(item, index);
          });
        }
        .padding(20);
      }

      if (this.showSaveDialog) {
        Flex({ justifyContent: FlexAlign.Center}) {
          Column() {
            TextInput({ text: this.regularexpression, placeholder: "输入正则表达式" })
              .onChange((value: string) => {
                this.regularexpression = value;  // 更新保存文件名
              })
              .width('80%')
              .margin({ top: 20 })
              .alignSelf(ItemAlign.Center);

            TextInput({ text: this.saveFileName, placeholder: "输入保存文件名" })
              .onChange((value: string) => {
                this.saveFileName = value;  // 更新保存文件名
              })
              .width('80%')
              .margin({ top: 20 })
              .alignSelf(ItemAlign.Center);

            Row() {
              Button('保存')
                .onClick(() => this.confirmSave())
                .width('45%')
                .margin(5)

              Button('取消')
                .onClick(() => this.showSaveDialog = false)
                .width('45%')
                .margin(5)
            }
          }
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .width('80%')
          .margin({ top: '20%' })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)') // 半透明遮罩
      }

      if (this.editDialogVisible) {
        Flex({ justifyContent: FlexAlign.Center }) {
          Column() {
            TextInput({ text: this.editRegexContent, placeholder: "修改正则表达式" })
              .onChange((value: string) => {
                this.editRegexContent = value;
              })
              .width('80%')
              .margin({ top: 20 })
              .alignSelf(ItemAlign.Center);

            TextInput({ text: this.editFileName, placeholder: "修改文件名" })
              .onChange((value: string) => {
                this.editFileName = value;
              })
              .width('80%')
              .margin({ top: 20 })
              .alignSelf(ItemAlign.Center);

            Row() {
              Button('确认修改')
                .onClick(() => this.confirmEdit())
                .width('45%')
                .margin(5)

              Button('取消')
                .onClick(() => this.editDialogVisible = false)
                .width('45%')
                .margin(5)
            }
          }
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .width('80%')
          .margin({ top: '20%' })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f3f5');
  }
}
