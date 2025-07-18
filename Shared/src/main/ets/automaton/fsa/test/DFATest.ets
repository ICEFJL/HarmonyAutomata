import { AutomatonCreator, FSAConfig } from "./AutomatonCreator";

export class DFATest {
  public static test(): void {
    DFATest.ans.forEach(dfa => {
      AutomatonCreator.save(dfa);
    });
  }

  static readonly ans: FSAConfig[] = [
    {
      name: "构造DFA(字母表{0,1})问题1",
      note: "(1)所有以00或11结尾的字符串的集合。",
      states: [
        "S0",    // 初始状态（未输入任何字符）
        "S1_0",  // 最后一个字符是0
        "S1_1",  // 最后一个字符是1
        "S2_00", // 最后两个字符是00（接受状态）
        "S2_11", // 最后两个字符是11（接受状态）
        "D"     // 死状态（非接受）
      ],
      alphabet: ["0", "1"],
      transitions: {
        "S0": { "0": ["S1_0"], "1": ["S1_1"] },
        "S1_0": { "0": ["S2_00"], "1": ["S1_1"] },
        "S1_1": { "0": ["S1_0"], "1": ["S2_11"] },
        "S2_00": { "0": ["S2_00"], "1": ["S1_1"] },
        "S2_11": { "0": ["S1_0"], "1": ["S2_11"] },
        "D": { "0": ["D"], "1": ["D"] }
      },
      initial_state: "S0",
      final_states: ["S2_00", "S2_11"] // 接受条件：以00或11结尾
    },
    {
      name: "构造DFA(字母表{0,1})问题2",
      note: "(2)所有以00开头、以11结尾的字符串的集合。",
      states: [
        "S0",        // 初始状态
        "S1_0",      // 输入了第一个0
        "S2_00",     // 输入了前两个0（开头满足）
        "S3_0", "S3_1", // 中间状态（跟踪最后一位）
        "S4_11",     // 最后两位是11（接受状态）
        "D"          // 死状态（非接受）
      ],
      alphabet: ["0", "1"],
      transitions: {
        "S0": { "0": ["S1_0"], "1": ["D"] },
        "S1_0": { "0": ["S2_00"], "1": ["D"] },
        "S2_00": { "0": ["S3_0"], "1": ["S3_1"] },
        "S3_0": { "0": ["S3_0"], "1": ["S3_1"] },
        "S3_1": { "0": ["S3_0"], "1": ["S4_11"] },
        "S4_11": { "0": ["S3_0"], "1": ["S4_11"] },
        "D": { "0": ["D"], "1": ["D"] }
      },
      initial_state: "S0",
      final_states: ["S4_11"] // 接受条件：以11结尾且开头为00
    },
    {
      name: "构造DFA(字母表{0,1})问题3",
      note: "(3)所有不包含00的字符串的集合。",
      states: ["S0", "S1", "D"],
      alphabet: ["0", "1"],
      transitions: {
        "S0": { "0": ["S1"], "1": ["S0"] },
        "S1": { "0": ["D"], "1": ["S0"] },
        "D": { "0": ["D"], "1": ["D"] }
      },
      initial_state: "S0",
      final_states: ["S0", "S1"]
    },
    {
      name: "构造DFA(字母表{0,1})问题4",
      note: "(4)所有包含三个连续的0的字符串的集合。",
      states: ["S0", "S1", "S2", "S3"],
      alphabet: ["0", "1"],
      transitions: {
        "S0": { "0": ["S1"], "1": ["S0"] },
        "S1": { "0": ["S2"], "1": ["S0"] },
        "S2": { "0": ["S3"], "1": ["S0"] },
        "S3": { "0": ["S3"], "1": ["S3"] }
      },
      initial_state: "S0",
      final_states: ["S3"]
    },
    {
      name: "构造DFA(字母表{0,1})问题5",
      note: "(5)所有满足下面条件的字符串的集合：每个由五个连续符号组成的子串都至少包含两个0(长度小于5的字符串作为不接受来处理)。",
      states: [
        "S0", // Initial state (no input)
        // 1-character states
        "S1_0", "S1_1",
        // 2-character states
        "S2_00", "S2_01", "S2_10", "S2_11",
        // 3-character states
        "S3_000", "S3_001", "S3_010", "S3_011", "S3_100", "S3_101", "S3_110", "S3_111",
        // 4-character states (accepting if reached)
        "S4_0000", "S4_0001", "S4_0010", "S4_0011", "S4_0100", "S4_0101", "S4_0110", "S4_0111",
        "S4_1000", "S4_1001", "S4_1010", "S4_1011", "S4_1100", "S4_1101", "S4_1110", "S4_1111",
        "D" // Dead state (reject)
      ],
      alphabet: ["0", "1"],
      transitions: {
        "S0": { "0": ["S1_0"], "1": ["S1_1"] },
        "S1_0": { "0": ["S2_00"], "1": ["S2_01"] },
        "S1_1": { "0": ["S2_10"], "1": ["S2_11"] },
        "S2_00": { "0": ["S3_000"], "1": ["S3_001"] },
        "S2_01": { "0": ["S3_010"], "1": ["S3_011"] },
        "S2_10": { "0": ["S3_100"], "1": ["S3_101"] },
        "S2_11": { "0": ["S3_110"], "1": ["S3_111"] },
        "S3_000": { "0": ["S4_0000"], "1": ["S4_0001"] },
        "S3_001": { "0": ["S4_0010"], "1": ["S4_0011"] },
        "S3_010": { "0": ["S4_0100"], "1": ["S4_0101"] },
        "S3_011": { "0": ["S4_0110"], "1": ["S4_0111"] },
        "S3_100": { "0": ["S4_1000"], "1": ["S4_1001"] },
        "S3_101": { "0": ["S4_1010"], "1": ["S4_1011"] },
        "S3_110": { "0": ["S4_1100"], "1": ["S4_1101"] },
        "S3_111": { "0": ["S4_1110"], "1": ["S4_1111"] },
        "S4_0000": { "0": ["S4_0000"], "1": ["S4_0001"] },
        "S4_0001": { "0": ["S4_0010"], "1": ["S4_0011"] },
        "S4_0010": { "0": ["S4_0100"], "1": ["S4_0101"] },
        "S4_0011": { "0": ["S4_0110"], "1": ["S4_0111"] },
        "S4_0100": { "0": ["S4_1000"], "1": ["S4_1001"] },
        "S4_0101": { "0": ["S4_1010"], "1": ["S4_1011"] },
        "S4_0110": { "0": ["S4_1100"], "1": ["S4_1101"] },
        "S4_0111": { "0": ["S4_1110"], "1": ["D"] },
        "S4_1000": { "0": ["S4_0000"], "1": ["S4_0001"] },
        "S4_1001": { "0": ["S4_0010"], "1": ["S4_0011"] },
        "S4_1010": { "0": ["S4_0100"], "1": ["S4_0101"] },
        "S4_1011": { "0": ["S4_0110"], "1": ["D"] },
        "S4_1100": { "0": ["S4_1000"], "1": ["S4_1001"] },
        "S4_1101": { "0": ["S4_1010"], "1": ["D"] },
        "S4_1110": { "0": ["S4_1100"], "1": ["D"] },
        "S4_1111": { "0": ["D"], "1": ["D"] },
        "D": { "0": ["D"], "1": ["D"] }
      },
      initial_state: "S0",
      final_states: [
        "S4_0000", "S4_0001", "S4_0010", "S4_0011", "S4_0100", "S4_0101", "S4_0110", "S4_0111",
        "S4_1000", "S4_1001", "S4_1010", "S4_1011", "S4_1100", "S4_1101", "S4_1110", "S4_1111"
      ]
    },
    {
      name: "构造DFA(字母表{0,1})问题6",
      note: "(6)所有0的个数能被5整除、1的个数能被3整除的字符串的集合。",
      states: [
      // 状态命名格式：S_0mod5_1mod3
        "S_0_0", "S_0_1", "S_0_2",
        "S_1_0", "S_1_1", "S_1_2",
        "S_2_0", "S_2_1", "S_2_2",
        "S_3_0", "S_3_1", "S_3_2",
        "S_4_0", "S_4_1", "S_4_2",
      ],
      alphabet: ["0", "1"],
      transitions: {
        "S_0_0": { "0": ["S_1_0"], "1": ["S_0_1"] },
        "S_0_1": { "0": ["S_1_1"], "1": ["S_0_2"] },
        "S_0_2": { "0": ["S_1_2"], "1": ["S_0_0"] },
        "S_1_0": { "0": ["S_2_0"], "1": ["S_1_1"] },
        "S_1_1": { "0": ["S_2_1"], "1": ["S_1_2"] },
        "S_1_2": { "0": ["S_2_2"], "1": ["S_1_0"] },
        "S_2_0": { "0": ["S_3_0"], "1": ["S_2_1"] },
        "S_2_1": { "0": ["S_3_1"], "1": ["S_2_2"] },
        "S_2_2": { "0": ["S_3_2"], "1": ["S_2_0"] },
        "S_3_0": { "0": ["S_4_0"], "1": ["S_3_1"] },
        "S_3_1": { "0": ["S_4_1"], "1": ["S_3_2"] },
        "S_3_2": { "0": ["S_4_2"], "1": ["S_3_0"] },
        "S_4_0": { "0": ["S_0_0"], "1": ["S_4_1"] },
        "S_4_1": { "0": ["S_0_1"], "1": ["S_4_2"] },
        "S_4_2": { "0": ["S_0_2"], "1": ["S_4_0"] }
      },
      initial_state: "S_0_0",
      final_states: ["S_0_0"] // 仅当0和1的计数均满足条件时接受
    }
  ];
}
