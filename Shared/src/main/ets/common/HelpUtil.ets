import { SavedFile } from "../../../../Index";
import { globalContext } from "../components/DrawCanvas";
import { Const } from "./Constants";

export class HelpUtil {
  static calculateTransitionEndPointsBetweenTwoStates(x1: number, y1: number, x2: number, y2: number, r: number): [number, number][] {
    // case 1: x1 == x2, 可快速求出 transition-line 的起点和终点
    if (x1 === x2) {
      if (y1 > y2) {
        return [[x1, y1 - r], [x1, y2 + r]];
      } else {
        return [[x1, y1 + r], [x1, y2 - r]];
      }
    }

    // case 2: x1 != x2, 需要按步骤计算交点
    const k = (y1 - y2) / (x1 - x2);
    const s = y1 - k * x1;

    // 计算 L 与 O1，O2 的交点
    const pfs1 = HelpUtil.getIntersectionPointsOfLineAndCircle(k, s, x1, y1, r);
    const pfs2 = HelpUtil.getIntersectionPointsOfLineAndCircle(k, s, x2, y2, r);

    // 选择第1个点
    const ps0 = Math.abs(pfs1[0][0] - x2) < Math.abs(pfs1[1][0] - x2) ? pfs1[0] : pfs1[1];

    // 选择第2个点
    const ps1 = Math.abs(pfs2[0][0] - x1) < Math.abs(pfs2[1][0] - x1) ? pfs2[0] : pfs2[1];

    return [ps0, ps1];
  }

  static getIntersectionPointsOfLineAndCircle(k: number, s: number, ccx: number, ccy: number, cr: number): [number, number][] {
    const m = s - ccy;

    const a = k * k + 1;
    const b = 2 * k * m - 2 * ccx;
    const c = ccx * ccx + m * m - cr * cr;

    const delta = Math.sqrt(b * b - 4 * a * c);
    const px1 = (-b + delta) / (2 * a);
    const px2 = (-b - delta) / (2 * a);
    const py1 = k * px1 + s;
    const py2 = k * px2 + s;

    return [[px1, py1], [px2, py2]];
  }

  static getRectPath(p1: [number, number], p2: [number, number], p3: [number, number], p4: [number, number]): Path2D {
    const path = new Path2D();
    path.moveTo(p1[0], p1[1]);
    path.lineTo(p2[0], p2[1]);
    path.lineTo(p3[0], p3[1]);
    path.lineTo(p4[0], p4[1]);
    path.closePath();
    return path;
  }

  static getCross(p1: [number, number], p2: [number, number], p: [number, number]): number{
    return (p2[0] - p1[0]) * (p[1] - p1[1]) - (p[0] - p1[0]) * (p2[1] - p1[1]);
  }

  static isInRectPath(p: [number, number], p1: [number, number], p2: [number, number], p3: [number, number], p4: [number, number]): boolean{
    return HelpUtil.getCross(p1, p2, p) * HelpUtil.getCross(p3, p4, p) >= 0 &&
      HelpUtil.getCross(p2, p3, p) * HelpUtil.getCross(p4, p1, p) >= 0 ;
  }
  
  static drawGrid(context: CanvasRenderingContext2D): void {
    const gridSize = Const.CIRCLE_RADIUS; // 网格大小
    const gridColor = Color.Gray; // 网格颜色

    context.save();
    context.strokeStyle = gridColor;
    context.lineWidth = Const.LINE_WIDTH / 2;

    // 绘制垂直线
    for (let x = 0; x < context.width; x += gridSize) {
      context.beginPath();
      context.moveTo(x, 0);
      context.lineTo(x, context.height);
      context.stroke();
    }

    // 绘制水平线
    for (let y = 0; y < context.height; y += gridSize) {
      context.beginPath();
      context.moveTo(0, y);
      context.lineTo(context.width, y);
      context.stroke();
    }

    context.restore();
  }

  static clampPosition(context: CanvasRenderingContext2D, x: number, y: number, radius: number): number[] {
    const maxX = context.width - radius;
    const maxY = context.height - radius;
    const clampedX = Math.max(radius, Math.min(x, maxX));
    const clampedY = Math.max(radius, Math.min(y, maxY));
    return [ clampedX, clampedY ];
  }

  static savePicture(name: string): void{
    let picture = globalContext.toDataURL();
    SavedFile.saveToFile(picture, "", name + Const.PIC_POSTFIX);
  }

  static getPicture(name: string): string{
    return SavedFile.loadFromFile("", name + Const.PIC_POSTFIX);
  }

  static deletePicture(name: string): void{
    SavedFile.deleteFile("", name + Const.PIC_POSTFIX);
  }
}