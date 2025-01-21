import { DateUtil } from '@pura/harmony-utils';

export class State {
  // 状态的唯一标识
  readonly uuid: number;

  // 该状态的状态名
  name: string = "";

  // 该状态是否为终态
  isFinal: boolean = false;

  // 该状态在绘图时的坐标
  x: number = 0;
  y: number = 0;

  constructor(x: number = 0, y: number = 0) {
    this.uuid = DateUtil.getTodayTime();
    this.setPosition(x, y);
  }

  public getName(): string {
    return this.name;
  }

  public setName(name: string): void {
    this.name = name;
  }

  public setPosition(x: number, y: number): void {
    this.x = x;
    this.y = y;
  }

  public equals(obj: State): boolean {
    if (obj instanceof State) {
      return this.uuid === obj.uuid;
    } else {
      return false;
    }
  }
}