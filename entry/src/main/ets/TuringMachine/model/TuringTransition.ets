import { Transition } from 'shared'

export class TuringTransition extends Transition {
  readonly readSymbol: string;   // 当前扫描符号（如 '0', '1'）
  readonly writeSymbol: string;  // 要写入的符号
  readonly moveDirection: 'L' | 'R'| 'S'; // 读写头移动方向

  constructor(
    from: number,
    to: number,
    readSymbol: string,
    writeSymbol: string,
    moveDirection: 'L' | 'R' | 'S'
  ) {
    // 生成标签
    const label = `${readSymbol},${writeSymbol};${moveDirection}`;
    super(from, to,label);
    this.readSymbol = readSymbol;
    this.writeSymbol = writeSymbol;
    this.moveDirection = moveDirection;
  }
}
