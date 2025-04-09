export enum TuringError {
  // 状态系统错误（1xxx）
  NoInitialState = "未定义初始状态", // 未定义初始状态
  UnreachableFinalState = "终态不可达", // 终态不可达
  DuplicateState = "状态名称重复", // 状态名称重复
  EmptyStateSet = "状态集合为空", // 状态集合为空
  NoFinalState = "未定义最终状态",

  // 转移规则错误（2xxx）
  MissingTransition = "当前状态无转移函数", // 无效转移规则引用
  NonDeterministicConflict = "非确定性转移冲突", // 非确定性转移冲突
  InvalidMoveDirection = "非法移动方向", // 非法移动方向

  // 符号系统错误（3xxx）
  UndefinedSymbol = "出现未定义符号", // 未定义符号出现

  // 运行时错误（4xxx）
  TapeOverflow = "纸带长度超过限制", // 纸带长度超过限制
  MaxStepExceeded = "超过最大计算步数", // 超过最大计算步数
  InfiniteLoopDetected = "检测到无限循环" // 检测到无限循环
}