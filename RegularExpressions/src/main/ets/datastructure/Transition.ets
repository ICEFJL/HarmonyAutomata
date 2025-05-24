import { DateUtil } from '@pura/harmony-utils';

export class Transition {
  // 转移的唯一标识
  readonly uuid: number;

  // 转移的头
  from: number;

  // 转移的尾
  to: number;

  // 转移的标签
  label: string = "";

  constructor(from: number, to: number, label: string = "") {
    this.uuid = DateUtil.getTodayTime();
    this.from = from;
    this.to = to;
    this.setLabel(label);
  }

  public setLabel(label: string): void {
    this.label = label;
  }
}