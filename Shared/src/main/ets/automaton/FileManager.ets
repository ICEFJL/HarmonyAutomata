import { FileUtil } from '@pura/harmony-utils';
import {SavedFile} from '../automaton/SavedFile'
import { AutomatonType } from "./Type";

export class FileManager {
  protected fileList : Set<SavedFile>;
  protected fileCount: number;
  protected FolderPath: string='';
  fileType: AutomatonType=AutomatonType.UNKNOWN;
  //protected dirCount: number;
  readonly  tmFolderPath: string='/data/storage/el2/base/haps/TuringMachine/files';//沙箱规则下tm默认存储文件夹路径

  constructor(type:AutomatonType) {
    this.fileList=new Set<SavedFile>();
    this.fileCount=0;
    this.fileType=type;
    switch (this.fileType){
      case AutomatonType.TM:
        this.FolderPath=this.tmFolderPath;
        break;
      default :
        break;
    }
  }

  /** 路径合法性校验（沙箱规则）*/
  private validatePath(path: string): void {
    if (!/^\/data\/storage\/\w+(\/\w+)*$/.test(path)) {
      throw new Error('路径必须符合沙箱规范');
    }
  }

  public addFile(file:SavedFile): void {
    this.fileList.add(file);
  }

  //基于FileUtil.listFile()方法显示目录下所有文件,并初始化set<F>
  async initFileList(path:string=this.FolderPath){
    this.validatePath(path);
    try {
      const files:string[]=await FileUtil.listFile(path,{recursion:false});
      this.fileCount=files.length;
      console.log(path,'文件夹下文件数：',this.fileCount);
      if(this.fileCount=0){
        console.log(path,'空文件夹！');
        return;
      }
      for (let i = 0; i < files.length; i++) {
        let tempFile=new SavedFile();
        tempFile.setFileName(files[i]);
        //其他配置
        this.addFile(tempFile);
        console.log(`第${i+1}个文件：${files[i]}`);
      }
    } catch (error) {
      console.error("数据获取失败:", error);
    }
  }

  //path：文件夹
  //name:该文件夹下要删除的文件名
  async deleteSelectFile(path:string=this.FolderPath,name:string){
    this.validatePath(path);
    let filePath=path+'/'+name;
    let isExisted=FileUtil.access(filePath);
    if(!isExisted){
      console.log('文件不存在：',filePath);
    }
    else{
      console.log('找到文件：',filePath);
    }
    FileUtil.unlink(filePath);
    let isDeleted=FileUtil.access(filePath);
    if(!isDeleted){
      console.log('删除失败：',filePath);
    }
    else{
      console.log('已删除：',filePath);
    }
  }


}