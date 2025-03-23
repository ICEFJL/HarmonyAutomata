import { State } from '../automaton/State';
import { Const } from '../common/Constants';
import { HelpUtil } from '../common/HelpUtil';
import { IDraw } from './IDraw';

export class DrawTransition extends IDraw {
  fromState: State;
  toState: State;
  label: string;
  needOffset: boolean;
  p1: [number, number] = [0, 0];
  p2: [number, number] = [0, 0];
  p3: [number, number] = [0, 0];
  p4: [number, number] = [0, 0];
  private selfRingLinePath: Path2D = new Path2D();
  public  baseLine: [number, number][] = [[0, 0], [0, 0]];
  private arrowEnd: [number, number][] = [[0, 0], [0, 0], [0, 0]];

  constructor(fromState: State, toState: State, label: string, needOffset: boolean = false) {
    super();
    this.fromState = fromState;
    this.toState = toState;
    this.label = label;
    this.needOffset = needOffset;
  }


  public draw(context: CanvasRenderingContext2D): void {
    if (this.fromState === this.toState) {
      this.calculateSelfRingLineInfo();
      this.drawSelfRing(context);
    } else {
      this.calculateStraightLineInfo();
      this.drawNormalTransition(context);
    }

    // Draw the labels
    context.font = Const.LABEL_FONT;
    context.fillStyle = 'Black';
    context.textAlign = 'center';
    context.textBaseline = 'middle';

    let x: number = (this.baseLine[0][0] + this.baseLine[1][0]) / 2;
    let y: number = (this.baseLine[0][1] + this.baseLine[1][1]) / 2;
    if(this.fromState !== this.toState){
      const dx = this.baseLine[1][0] - this.baseLine[0][0];
      const dy = this.baseLine[1][1] - this.baseLine[0][1];

      const length = Math.sqrt(dx * dx + dy * dy);

      const nx = dx / length;
      const ny = dy / length;

      const px = ny;
      const py = -nx;

      x += px * Const.LINE_BAND_WIDTH / 2;
      y += py * Const.LINE_BAND_WIDTH / 2;
    }
    //此处label最小长度改为5
    if(this.label.length > 5){
      context.fillText(this.label.length.toString(), x, y);
    } else {
      context.fillText(this.label.length === 0 ? Const.EMPTY_STRING : this.label, x, y);
    }

    context.beginPath();
    context.moveTo(this.arrowEnd[0][0], this.arrowEnd[0][1]);
    context.lineTo(this.arrowEnd[1][0], this.arrowEnd[1][1]);
    context.moveTo(this.arrowEnd[0][0], this.arrowEnd[0][1]);
    context.lineTo(this.arrowEnd[2][0], this.arrowEnd[2][1]);
    context.strokeStyle = Color.Black;
    context.stroke();

    // context.strokeStyle = Color.Red;
    // context.stroke(HelpUtil.getRectPath(this.p1, this.p2, this.p3, this.p4));
  }

  public drawOffset(context: CanvasRenderingContext2D, labelOffset: number): void {
    if (this.fromState === this.toState) {
      this.calculateSelfRingLineInfo();
      this.drawSelfRing(context);
    } else {
      this.calculateStraightLineInfo();
      this.drawNormalTransition(context);
    }

    // Draw the labels
    context.font = Const.LABEL_FONT;
    context.fillStyle = 'Black';
    context.textAlign = 'center';
    context.textBaseline = 'middle';

    let x: number = (this.baseLine[0][0] + this.baseLine[1][0]) / 2;
    let y: number = (this.baseLine[0][1] + this.baseLine[1][1]) / 2;
    if(this.fromState !== this.toState){
      const dx = this.baseLine[1][0] - this.baseLine[0][0];
      const dy = this.baseLine[1][1] - this.baseLine[0][1];

      const length = Math.sqrt(dx * dx + dy * dy);

      const nx = dx / length;
      const ny = dy / length;

      const px = ny;
      const py = -nx;

      x += px * Const.LINE_BAND_WIDTH / 2;
      y += py * Const.LINE_BAND_WIDTH / 2;
    }
    //此处label最小长度改为5
    if(this.label.length > 5){
      context.fillText(this.label.length.toString(), x, y);
    } else {
      context.fillText(this.label.length === 0 ? Const.EMPTY_STRING : this.label, x, y - labelOffset);
      //console.log("检查偏移", x+labelOffset)
    }

    context.beginPath();
    context.moveTo(this.arrowEnd[0][0], this.arrowEnd[0][1]);
    context.lineTo(this.arrowEnd[1][0], this.arrowEnd[1][1]);
    context.moveTo(this.arrowEnd[0][0], this.arrowEnd[0][1]);
    context.lineTo(this.arrowEnd[2][0], this.arrowEnd[2][1]);
    context.strokeStyle = Color.Black;
    context.stroke();

    // context.strokeStyle = Color.Red;
    // context.stroke(HelpUtil.getRectPath(this.p1, this.p2, this.p3, this.p4));
  }

  private drawNormalTransition(context: CanvasRenderingContext2D): void {
    // Draw the arrow line
    context.beginPath();
    context.moveTo(this.baseLine[0][0], this.baseLine[0][1]);
    context.lineTo(this.baseLine[1][0], this.baseLine[1][1]);
    context.strokeStyle = Color.Black;
    context.lineWidth = Const.LINE_WIDTH;
    context.stroke();
  }

  private drawSelfRing(context: CanvasRenderingContext2D): void {
    context.strokeStyle = 'Black';
    context.lineWidth = Const.LINE_WIDTH;
    context.stroke(this.selfRingLinePath);
  }

  private calculateSelfRingLineInfo(): void {
    const x = this.fromState.x;
    const y = this.fromState.y;

    this.selfRingLinePath = new Path2D();
    this.selfRingLinePath.ellipse(x, y - Const.OVAL_A, Const.OVAL_B, Const.OVAL_A, 0, Math.PI, 2 * Math.PI, false);

    this.p1 = [x - Const.OVAL_B, y - Const.OVAL_A];
    this.p2 = [x + Const.OVAL_B, y - Const.OVAL_A];
    this.p3 = [x + Const.OVAL_B, y - 2 * Const.OVAL_A];
    this.p4 = [x - Const.OVAL_B, y - 2 * Const.OVAL_A];

    this.baseLine[0] = [x - 10, y - 1.5 * Const.OVAL_A];
    this.baseLine[1] = [x + 10, y - 1.5 * Const.OVAL_A];

    this.arrowEnd[0] = [x + Const.CONST_X_OFFSET_1, y + Const.CONST_Y_OFFSET_1 - Const.CIRCLE_RADIUS];
    this.arrowEnd[1] = [this.arrowEnd[0][0] - Const.CONST_X_OFFSET_2, this.arrowEnd[0][1] - Const.CONST_Y_OFFSET_2];
    this.arrowEnd[2] = [this.arrowEnd[0][0] + Const.CONST_X_OFFSET_2, this.arrowEnd[0][1] - Const.CONST_Y_OFFSET_2];
  }


  private calculateStraightLineInfo(): void {
    const x1 = Math.round(this.fromState.x + 0.5);
    const y1 = Math.round(this.fromState.y + 0.5);
    const x2 = Math.round(this.toState.x + 0.5);
    const y2 = Math.round(this.toState.y + 0.5);
    const r = Const.CIRCLE_RADIUS;

    if (!this.needOffset) {
      this.baseLine = HelpUtil.calculateTransitionEndPointsBetweenTwoStates(x1, y1, x2, y2, r);
      this.calculateStraightLineRectAndArrowInfo();
      return;
    }

    const argY = y2 > y1 ? 1 : -1;
    const argX = x2 > x1 ? 1 : -1;
    const sr = Const.SIN_OFFSET * r;
    const cr = Const.COS_OFFSET * r;

    if (x1 === x2) {
      this.baseLine[0] = [x1 + argY * sr, y1 + argY * cr];
      this.baseLine[1] = [x2 + argY * sr, y2 - argY * cr];
    } else if (y1 === y2) {
      this.baseLine[0] = [x1 + argX * cr, y1 - argX * sr];
      this.baseLine[1] = [x2 - argX * cr, y2 - argX * sr];
    } else {
      const k = (y1 - y2) / (x1 - x2);
      const tan = k > 0 ? k : -k;
      const cos = Math.sqrt(1 / (tan * tan + 1));
      const sin = tan * cos;
      const mx = cos * cr;
      const my = sin * cr;
      const ex = sin * sr;
      const ey = cos * sr;

      if (k > 0) {
        const mp1 = [x1 + mx * argY, y1 + my * argY];
        const mp2 = [x2 - mx * argY, y2 - my * argY];
        this.baseLine[0] = [mp1[0] + argY * ex, mp1[1] - argY * ey];
        this.baseLine[1] = [mp2[0] + argY * ex, mp2[1] - argY * ey];
      } else {
        const mp1 = [x1 - mx * argY, y1 + my * argY];
        const mp2 = [x2 + mx * argY, y2 - my * argY];
        this.baseLine[0] = [mp1[0] + argY * ex, mp1[1] + argY * ey];
        this.baseLine[1] = [mp2[0] + argY * ex, mp2[1] + argY * ey];
      }
    }
    this.calculateStraightLineRectAndArrowInfo();
  }

  private calculateStraightLineRectAndArrowInfo(): void {
    const x1 = Math.round(this.baseLine[0][0] + 0.5);
    const y1 = Math.round(this.baseLine[0][1] + 0.5);
    const x2 = Math.round(this.baseLine[1][0] + 0.5);
    const y2 = Math.round(this.baseLine[1][1] + 0.5);
    const halfArrow = Const.ARROW_EDGE / 2;
    const argY = y2 > y1 ? 1 : -1;
    const argX = x2 > x1 ? 1 : -1;

    if (x1 === x2) {
      // 线条矩形区域
      this.p1 = [x1 - Const.LINE_BAND_WIDTH, y1];
      this.p2 = [x1 + Const.LINE_BAND_WIDTH, y1];
      this.p3 = [x1 + Const.LINE_BAND_WIDTH, y2];
      this.p4 = [x1 - Const.LINE_BAND_WIDTH, y2];

      // 箭头端点坐标
      const tmpY = y2 - halfArrow * 1.732 * argY;
      this.arrowEnd[0] = [x2, y2];
      this.arrowEnd[1] = [x2 - halfArrow, tmpY];
      this.arrowEnd[2] = [x2 + halfArrow, tmpY];
    } else if (y1 === y2) {
      this.p1 = [x1, y1 - Const.LINE_BAND_WIDTH];
      this.p2 = [x1, y1 + Const.LINE_BAND_WIDTH];
      this.p3 = [x2, y1 + Const.LINE_BAND_WIDTH];
      this.p4 = [x2, y1 - Const.LINE_BAND_WIDTH];

      const tmpX = x2 - halfArrow * 1.732 * argX;
      this.arrowEnd[0] = [x2, y2];
      this.arrowEnd[1] = [tmpX, y2 - halfArrow];
      this.arrowEnd[2] = [tmpX, y2 + halfArrow];
    } else {
      const k = (y1 - y2) / (x1 - x2);
      const tan = k > 0 ? k : -k;
      const cos = Math.sqrt(1 / (tan * tan + 1));
      const sin = tan * cos;
      const x = sin * Const.LINE_BAND_WIDTH;
      const y = cos * Const.LINE_BAND_WIDTH;
      const len = 1.732 * halfArrow;
      const amx = cos * len;
      const amy = sin * len;
      const ax = sin * halfArrow;
      const ay = cos * halfArrow;

      if (k > 0) {
        this.p1 = [x1 + x, y1 - y];
        this.p2 = [x1 - x, y1 + y];
        this.p3 = [x2 - x, y2 + y];
        this.p4 = [x2 + x, y2 - y];

        const arrowMidP = [x2 - argY * amx, y2 - argY * amy];
        this.arrowEnd[0] = [x2, y2];
        this.arrowEnd[1] = [arrowMidP[0] + ax, arrowMidP[1] - ay];
        this.arrowEnd[2] = [arrowMidP[0] - ax, arrowMidP[1] + ay];
      } else {
        this.p1 = [x1 - x, y1 - y];
        this.p2 = [x1 + x, y1 + y];
        this.p3 = [x2 + x, y2 + y];
        this.p4 = [x2 - x, y2 - y];

        const tmp = [x2 + argY * amx, y2 - argY * amy];
        this.arrowEnd[0] = [x2, y2];
        this.arrowEnd[1] = [tmp[0] + ax, tmp[1] + ay];
        this.arrowEnd[2] = [tmp[0] - ax, tmp[1] - ay];
      }
    }
  }


  public static deepCopy(drawTransition: DrawTransition){
    return new DrawTransition(drawTransition.fromState, drawTransition.toState, drawTransition.label, drawTransition.needOffset);
  }
}
