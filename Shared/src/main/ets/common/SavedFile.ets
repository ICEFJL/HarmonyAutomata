import { AutomatonType } from "../automaton/Type";
import relationalStore from '@ohos.data.relationalStore';
import { Database } from "./Database";
import { FileUtil } from "@pura/harmony-utils";
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
import { Const, HelpUtil } from "../../../../Index";

export class SavedFile {
  fileName: string;

  note: string;

  fileType: AutomatonType;

  saveTime: number;

  constructor(fileName: string = '', note: string = '', fileType: AutomatonType = AutomatonType.UNKNOWN, saveTime: number = Date.now()) {
    this.fileName = fileName;
    this.note = note;
    this.fileType = fileType;
    this.saveTime = saveTime;
  }

  setFileName(fileName: string): void {
    this.fileName = fileName;
  }

  setNote(note: string): void {
    this.note = note;
  }

  setSaveTime(saveTime: number): void {
    this.saveTime = saveTime;
  }

  setFileType(fileType: AutomatonType): void {
    this.fileType = fileType;
  }

  getSaveTimeStr(): string {
    const dateTime = new Date(this.saveTime);
    return `${dateTime.getFullYear()}-${String(dateTime.getMonth() + 1).padStart(2, '0')}-${String(dateTime.getDate()).padStart(2, '0')} ${String(dateTime.getHours()).padStart(2, '0')}:${String(dateTime.getMinutes()).padStart(2, '0')}`;
  }

  update(): boolean {
    this.saveTime = Date.now();
    Database.updateByFileName(this.fileName, this);
    HelpUtil.savePicture(this.fileName);
    return true;
  }

  save(): boolean {
    this.saveTime = Date.now();
    HelpUtil.savePicture(this.fileName);
    Database.insertData(this);
    return true;
  }

  delete(): boolean {
    Database.deleteByFileName(this.fileName);
    SavedFile.deleteFile("",this.fileName + Const.FILE_POSTFIX);
    HelpUtil.deletePicture(this.fileName);
    return true;
  }

  static deleteFile(dirPath: string = "", fileName: string = ""): void{
    let filePath = FileUtil.getFilesDirPath(dirPath, fileName, false);
    let isExisted = FileUtil.access(filePath);
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

  static saveToFile(jsonStr: string, dirPath: string = "", fileName: string = "test.json"): void{
    let path = FileUtil.getFilesDirPath(dirPath, fileName, false);
    let file = FileUtil.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
    let len = FileUtil.writeSync(file.fd, jsonStr);
    FileUtil.closeSync(file.fd); //关闭文件
  }

  static loadFromFile(dirPath: string = "", fileName: string = "test.json"): string {
    let filePath = FileUtil.getFilesDirPath(dirPath, fileName, false);
    let readTextOptions: ReadTextOptions = {
      offset: 0,
      length: 0,
      encoding: 'utf-8'
    };
    let stat = fs.statSync(filePath);
    readTextOptions.length = stat.size;
    return fs.readTextSync(filePath, readTextOptions);
  }

  /**
   * 判断 filename 是否是一个合法的文件名称
   * 在此要求，一个合法的文件名称只能包含以下字符：
   * 各种字符的unicode编码的范围：
   * 特定符号：'-', '_', '.'
   * 汉字：[0x4e00,0x9fa5]（或十进制[19968,40869]）
   * 数字：[0x30,0x39]（或十进制[48, 57]）
   * 小写字母：[0x61,0x7a]（或十进制[97, 122]）
   * 大写字母：[0x41,0x5a]（或十进制[65, 90]）
   *
   * @param filename 待检测的文件名称
   * @return filename是否合法
   */
  static isFileNameLegal(filename: string): boolean {
    if (!filename || filename.trim().length === 0) {
      return false;
    }

    const regex = /^[-._0-9a-zA-Z\u4e00-\u9fa5]+$/;
    return regex.test(filename);
  }
}