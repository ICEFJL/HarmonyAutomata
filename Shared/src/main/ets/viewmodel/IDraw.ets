import { DrawTransition } from "./DrawTransition";

export abstract class IDraw {
  constructor() {}

  public abstract draw(context: CanvasRenderingContext2D): void;
}

export class DrawOperate{
  op: Array<IDraw> = [];
  type: DrawType = DrawType.UPDATE;
  preTransition: Array<DrawTransition> = [];

  constructor(op: Array<IDraw> = [], type: DrawType = DrawType.UPDATE, preTransition: Array<DrawTransition> = []) {
    this.op = op;
    this.type = type;
    this.preTransition = preTransition;
  }
}

export enum DrawType {
  UPDATE,
  DELETE,
  MOVE,
  CREATE,
  ADD
}
