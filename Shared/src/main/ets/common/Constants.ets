export enum SAVED_FILE {
  fileName = 'fileName',
  note = 'note',
  fileType = 'fileType',
  saveTime = 'saveTime'
}

export enum FunctionUrl {
  FA = 'FiniteAutomatonAbility',
  PA = 'PushdownAutomatonAbility',
  RE = 'RegularExpressionsAbility',
  TM = 'TuringMachineAbility',
  MG = 'ManagementAbility'
}

export class Const {
  // 画布相关
  static readonly NONE: number = -1;
  static readonly STATE: number = 0;
  static readonly TRANSITION: number = 1;
  static readonly DELETE: number = 2;
  static readonly TEN: number = 10;
  static readonly CANVAS_WIDTH: number = 750;
  static readonly ONE_HUNDRED_PERCENT: string = '100%';
  static readonly SCALE: number = 2;
  static readonly LABEL_FONT_NUMBER = 16 / this.SCALE;
  static readonly LABEL_FONT: string = this.LABEL_FONT_NUMBER + 'vp';
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

  // 数据库相关
  static readonly TABLE_NAME: string = 'Automaton';
  static readonly SQL_CREATE_TABLE: string = `CREATE TABLE IF NOT EXISTS ${this.TABLE_NAME} (
    fileName TEXT PRIMARY KEY,
    note TEXT,
    saveTime INTEGER,
    fileType TEXT
  )`;
  static readonly DATABASE_NAME: string = '__Database.db';

  // 文件相关
  static readonly FILE_POSTFIX: string = '.json';
  static readonly PIC_POSTFIX: string = '.txt';

  // 路由相关
  static readonly BUNDLE_NAME = 'com.example.bishe'
  static readonly FUNCTION: string[] = ['有穷自动机','下推自动机','正则','图灵机','管理']
  static readonly FUNCTION_URL_MAP: Map<string, string> = new Map([
    [this.FUNCTION[0], FunctionUrl.FA],
    [this.FUNCTION[1], FunctionUrl.PA],
    [this.FUNCTION[2], FunctionUrl.RE],
    [this.FUNCTION[3], FunctionUrl.TM],
    [this.FUNCTION[4], FunctionUrl.MG]
  ]);
}

