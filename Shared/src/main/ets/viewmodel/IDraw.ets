export abstract class IDraw {
  constructor() {}

  public abstract draw(context: CanvasRenderingContext2D): void;
}

export class DrawOperate{
  op: Array<IDraw> = [];
  type: DrawType = DrawType.UPDATE;

  constructor(op: Array<IDraw>, type: DrawType) {
    this.op = op;
    this.type = type;
  }
}

export enum DrawType {
  UPDATE,
  DELETE,
}
