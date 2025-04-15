import { Transition } from 'shared';

export class PDATransition extends Transition {
  readonly readSymbol: string;   // 当前扫描符号（如 '0', '1'）
  readonly popSymbol: string;  // 要从栈取出的符号
  readonly pushSymbol: string; // 要压入栈的符号

  constructor(
    from: number,
    to: number,
    readSymbol: string,
    popSymbol: string,
    pushSymbol: string
  ) {
    // 生成标签
    const label = `${readSymbol},${popSymbol};${pushSymbol}`;
    super(from, to,label);
    this.readSymbol = readSymbol;
    this.popSymbol = popSymbol;
    this.pushSymbol = pushSymbol;
  }
}
