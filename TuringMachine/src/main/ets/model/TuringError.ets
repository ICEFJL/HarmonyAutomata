export enum TuringError {
  // 状态系统错误（1xxx）
  NoInitialState = 1001, // 未定义初始状态
  UnreachableFinalState = 1002, // 终态不可达
  DuplicateState = 1003, // 状态名称重复
  EmptyStateSet = 1004, // 状态集合为空
  IsolatedState = 1005, // 孤立状态存在

  // 转移规则错误（2xxx）
  InvalidTransition = 2001, // 无效转移规则引用
  NonDeterministicConflict = 2002, // 非确定性转移冲突
  InvalidMoveDirection = 2003, // 非法移动方向

  // 符号系统错误（3xxx）
  UndefinedSymbol = 3001, // 未定义符号出现

  // 运行时错误（4xxx）
  TapeOverflow = 4001, // 纸带长度超过限制
  MaxStepExceeded = 4002, // 超过最大计算步数
  InfiniteLoopDetected = 4003 // 检测到无限循环
}