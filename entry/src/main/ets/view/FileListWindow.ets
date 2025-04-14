//import { PDAAutomaton } from 'PushdownAutomaton';
import { BusinessError } from '@kit.BasicServicesKit';
import { Environment } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { AutomatonType, Const, HelpUtil, SavedFile } from 'shared';
import { FileUtil } from '@pura/harmony-utils';

@Component
export struct FileListWindow {

  @Provide targetFolderPath: string = ""
  @Provide saveFile: SavedFile | null = null;
  @Provide fileNameList: string[] = [];
  @Provide FileList: SavedFile[] = [];
  // 定义关闭回调函数参数（非装饰器）
  public  onClose?: () => void;


  public import(){
    // 检查是否具有 READ_WRITE_DOWNLOAD_DIRECTORY 权限，无权限则需要向用户申请授予权限。
    try {
      // 获取目录
      // const documentsPath = Environment.getUserDocumentDir();
      // console.info(`success to getUserDocumentDir: ${documentsPath}`);
      // this.targetFolderPath = `${documentsPath}/Automaton`;
      const downloadPath = Environment.getUserDownloadDir();
      this.targetFolderPath = `${downloadPath}/Automaton`;
      // 确保目标文件夹存在，如果不存在则创建它
      if (!FileUtil.accessSync(this.targetFolderPath)) {
        FileUtil.mkdirSync(this.targetFolderPath);  // 创建文件夹
        console.log(`创建文件夹：${this.targetFolderPath}`);
      }

      this.fileNameList= fs.listFileSync(this.targetFolderPath);
      this.fileNameList.forEach((file, index) => {
        const content=fs.readTextSync(`${this.targetFolderPath}/${file}`);
        this.saveFile = new SavedFile(JSON.parse(content).name, JSON.parse(content).note, JSON.parse(content).type);
        this.FileList.push(this.saveFile)
      });

      // this.fileNameList.forEach((file, index) => {
      //   console.info('文件目录',`${this.targetFolderPath} ${index}: ${file}`);
      //   const content=fs.readTextSync(`${this.targetFolderPath}/${file}`);
      //   console.log('测试文件读入类型', JSON.parse(content).type);
      //   SavedFile.saveToFile(content, "", JSON.parse(content).name + Const.FILE_POSTFIX);
      //   this.saveFile = new SavedFile(JSON.parse(content).name, JSON.parse(content).note, JSON.parse(content).type);
      //   this.saveFile.save();
      // });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Error code: ${err.code}, message: ${err.message}`);
    }
  }
  aboutToAppear(): void {
    this.import();
  }

  build() {
    Column() {
      List({ space: 10 }) {
        ForEach(this.FileList, (item: SavedFile, index: number)=>{
          ListItem(){
            Row(){
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
                .layoutWeight(2)
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
              .layoutWeight(4)
              .margin(5)

              Text('导入')
                .fontSize(20) // 设置字体大小
                .fontColor(Color.White) // 设置字体颜色为白色
                .textAlign(TextAlign.Center) // 设置文本居中对齐
                .backgroundColor(Color.Green) // 设置背景颜色为红色
                .height(70)
                .width(70)
                .onClick(() => {
                  const content=fs.readTextSync(`${this.targetFolderPath}/${this.fileNameList[index]}`);
                  SavedFile.saveToFile(content, "", JSON.parse(content).name + Const.FILE_POSTFIX);
                  this.saveFile = new SavedFile(JSON.parse(content).name, JSON.parse(content).note, JSON.parse(content).type);
                  this.saveFile.save();
                })
                .layoutWeight(1)
            }
            .height(75)
            .backgroundColor(Color.White)
          }
        })
      }
      .width("100%")
      .padding(20)
      .layoutWeight(1)

      Button('关闭')
        .onClick(() => {
          this.onClose?.(); // 安全调用回调
        })
        .width(160)
        .margin({ top: 5, right: 10,bottom: 20})
        .backgroundColor(0x666666)
    }
    .backgroundColor('#f2f3f5')
    .width("100%")
    .height("100%")

  }
}

