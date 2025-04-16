// 定义单次转移操作的类型
interface Transition {
  currentState: string; //当前状态
  readSymbol: string;
  nextState: string; // 必须 ∈ states
  writeSymbol: string; // 必须 ∈ tapeAlphabet
  moveDirection: 'L' | 'R' | 'S'; // 允许值：'L'（左移）或 'R'（右移）或'S'不动
}

// 优化后的图灵机配置接口
export interface TMConfig {
  // 基础信息
  name?: string; // 可选机器名称
  note?: string; // 可选备注说明

  // 核心七元组参数
  states: string[]; // 有限状态集合（至少包含initialState和finalStates）
  inputAlphabet: string[]; // 输入符号集合（合法输入字符）
  tapeAlphabet: string[]; // 纸带符号集合（必须包含inputAlphabet和blankSymbol）
  blankSymbol: string; // 空白符号（必须 ∈ tapeAlphabet）
  transitions: Transition[]; //转移函数列表
  initialState: string; // 初始状态（必须 ∈ states）
  finalStates: string[]; // 接受状态集合（必须 ⊆ states）
}

//以下为《形式语言与自动机理论（第四版）》蒋宗礼 第九章图灵机部分例题
export const exercise1: TMConfig = {
  name: "第九章习题1",
  states: ['q0', 'q1', 'q2'],
  inputAlphabet: ['0', '1'],
  tapeAlphabet: ['0', '1', 'B'],
  blankSymbol: 'ε',

  // 转移函数配置
  transitions: [
    {
      currentState: "q0",
      readSymbol: "0",
      nextState: "q0",
      writeSymbol: "0",
      moveDirection: "R"
    },
    {
      currentState: "q0",
      readSymbol: "1",
      nextState: "q1",
      writeSymbol: "1",
      moveDirection: "R"
    },
    {
      currentState: "q1",
      readSymbol: "0",
      nextState: "q1",
      writeSymbol: "0",
      moveDirection: "R"
    },
    {
      currentState: "q1",
      readSymbol: "ε",
      nextState: "q2",
      writeSymbol: "ε",
      moveDirection: "R"
    }
  ],

  // 状态配置
  initialState: "q0",
  finalStates: ["q2"]

};

