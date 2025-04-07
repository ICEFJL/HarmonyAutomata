import { Uuid } from './function/Uuid';

export class Transition {
  // 转移的唯一标识
  readonly uuid: number;

  // 转移的头
  from: number;

  // 转移的尾
  to: number;

  // 转移的标签
  label: string = "";

  constructor(from: number, to: number, label: string = "", uuid: number = Uuid.index) {
    this.uuid = uuid;
    this.from = from;
    this.to = to;
    this.setLabel(label);
  }

  public setLabel(label: string): void {
    this.label = label;
  }

  public static deepCopy(transition: Transition): Transition{
    return new Transition(transition.from, transition.to, transition.label, transition.uuid);
  }
}