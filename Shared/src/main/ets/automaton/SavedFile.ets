import { AutomatonType } from "./Type";

export class SavedFile {

  headImgPath: string;

  fileName: string;

  note: string;

  saveTime: number;

  fileType: AutomatonType;

  constructor(headImgPath: string = '', fileName: string = '', note: string = '', fileType: AutomatonType = AutomatonType.UNKNOWN) {
    this.headImgPath = headImgPath;
    this.fileName = fileName;
    this.note = note;
    this.fileType = fileType;
    this.saveTime = Date.now();
  }

  getHeadImgPath(): string {
    return this.headImgPath;
  }

  setHeadImgPath(headImgPath: string): void {
    this.headImgPath = headImgPath;
  }

  getFileName(): string {
    return this.fileName;
  }

  setFileName(fileName: string): void {
    this.fileName = fileName;
  }

  getNote(): string {
    return this.note;
  }

  setNote(note: string): void {
    this.note = note;
  }

  getSaveTime(): number {
    return this.saveTime;
  }

  setSaveTime(saveTime: number): void {
    this.saveTime = saveTime;
  }

  getFileType(): AutomatonType {
    return this.fileType;
  }

  setFileType(fileType: AutomatonType): void {
    this.fileType = fileType;
  }

  getSaveTimeStr(): string {
    const dateTime = new Date(this.saveTime);
    return `${dateTime.getFullYear()}-${String(dateTime.getMonth() + 1).padStart(2, '0')}-${String(dateTime.getDate()).padStart(2, '0')} ${String(dateTime.getHours()).padStart(2, '0')}:${String(dateTime.getMinutes()).padStart(2, '0')}`;
  }

  save(): boolean {
    this.saveTime = Date.now();
    // 假设存在一个save方法来保存数据
    // return super.save(); // 需要根据实际的LitePal for ArkTS库实现
    return true; // 这里返回true作为示例
  }
}