export class Const {
  static readonly NONE: number = -1;
  static readonly STATE: number = 0;
  static readonly TRANSITION: number = 1;
  static readonly DELETE: number = 2;
  static readonly TEN: number = 10;
  static readonly CANVAS_WIDTH: number = 750;
  static readonly ONE_HUNDRED_PERCENT: string = '100%';
  static readonly DETENTS: [number, number] = [550, 600];
  static readonly SCALE: number = 2;
  static readonly LABEL_FONT: string = 16 / this.SCALE+'vp';
  static readonly LINE_WIDTH: number = 2 / this.SCALE;
  static readonly CIRCLE_RADIUS: number = vp2px(10) / this.SCALE;
  static readonly OVAL_A: number = this.CIRCLE_RADIUS;
  static readonly OVAL_B: number = Math.floor(this.CIRCLE_RADIUS / 3 * 2);
  static readonly CONST_X_OFFSET_1: number = vp2px(6.5) / this.SCALE;
  static readonly CONST_X_OFFSET_2: number = vp2px(2.5) / this.SCALE;
  static readonly CONST_Y_OFFSET_1: number = vp2px(2.5) / this.SCALE;
  static readonly CONST_Y_OFFSET_2: number = vp2px(4.5) / this.SCALE;
  static readonly SIN_OFFSET: number = 0.3;
  static readonly COS_OFFSET: number = Math.sqrt(1 - this.SIN_OFFSET * this.SIN_OFFSET);
  static readonly ARROW_EDGE: number = vp2px(7) / this.SCALE;
  static readonly LINE_BAND_WIDTH: number = this.ARROW_EDGE / 2;
  static readonly EMPTY_STRING: string = 'ε';
}
