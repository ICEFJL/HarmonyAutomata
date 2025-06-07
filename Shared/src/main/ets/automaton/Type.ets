import {State} from './State'

export class Node<S extends State> {
  readonly state: S;
  readonly parent: Node<S> | null = null
  constructor (state: S, parent: Node<S> | null = null) {
    this.state = state;
    this.parent = parent;
  }
}

export class ExecutionTrace{
  read: string | null;
  to: number;
  constructor(read: string | null, to: number){
    this.read = read;
    this.to = to;
  }
}

export class ExecutionResult{
  accepted: boolean;
  constructor(accepted: boolean) {
    this.accepted = accepted;
  }
}

export enum AutomatonType {
  UNKNOWN = "UNKNOWN", // 未知类型
  FSA = "FSA",         // 有限状态机（Finite State Automaton）
  DFA = "DFA",         // 确定性有限状态机（Deterministic Finite Automaton）
  NFA = "NFA",         // 非确定性有限状态机（Non-deterministic Finite Automaton）
  PDA = "PDA",         // 下推自动机（Pushdown Automaton）
  TM = "TM",           // 图灵机（Turing Machine）
  MTM = "MTM",         // 多带图灵机（Multi-track Turing Machine）
  TMBB = "TMBB",       // 带构建块的图灵机（Turing Machine with Build Blocks）
  RG = "RG",           // 正则文法（Regular Grammar）
  CFG = "CFG",         // 上下文无关文法（Context-Free Grammar）
  CSG = "CSG",         // 上下文有关文法（Context-Sensitive Grammar）
  PSG = "PSG",         // 递归可枚举文法（Phrase Structure Grammar）
  Regex = "REGEX"      // 正则表达式（Regular Expression）
}
