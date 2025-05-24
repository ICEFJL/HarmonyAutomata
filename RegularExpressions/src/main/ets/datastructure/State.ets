import { Uuid } from './Uuid';

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

  constructor(x: number = 0, y: number = 0, name: string = "", isFinal: boolean = false, uuid: number = Uuid.index) {
    this.setName(name);
    this.uuid = uuid;
    this.setPosition(x, y);
    this.isFinal = isFinal;
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
      return this.uuid === obj.uuid &&
        this.name === obj.name &&
        this.isFinal === obj.isFinal &&
        this.x === obj.x &&
        this.y === obj.y;
    } else {
      return false;
    }
  }

  public static deepCopy(state: State): State {
    return new State(state.x, state.y, state.name, state.isFinal, state.uuid);
  }
}
