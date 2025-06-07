import { FSAConfig } from "./AutomatonCreator";

export class NFATest {
  static readonly ans: FSAConfig[] = [
    {
      name: "构造NFA(字母表{0,1})问题1",
      note: "(1)所有不包含00的字符串的集合。",
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
      name: "构造NFA(字母表{0,1})问题2",
      note: "(2)所有包含形如10100子串的字符串的集合。",
      states: ["S0", "S1", "S2", "S3", "S4", "S5"],
      alphabet: ["0", "1"],
      transitions: {
        "S0": { "0": ["S0"], "1": ["S1"] },
        "S1": { "0": ["S2"], "1": ["S1"] },
        "S2": { "1": ["S3"], "0": ["S0"] },
        "S3": { "0": ["S4"], "1": ["S1"] },
        "S4": { "0": ["S5"], "1": ["S3"] },
        "S5": { "0": ["S5"], "1": ["S5"] }
      },
      initial_state: "S0",
      final_states: ["S5"]
    },
    {
      name: "构造NFA(字母表{0,1})问题3",
      note: "(3)所有不包含形如10100子串的字符串的集合。",
      states: ["S0", "S1", "S2", "S3", "S4", "S5", "S_accept"],
      alphabet: ["0", "1"],
      transitions: {
        "S0": { "0": ["S0", "S_accept"], "1": ["S0", "S1"] },
        "S1": { "0": ["S2"], "1": ["S1", "S_accept"] },
        "S2": { "1": ["S3"], "0": ["S0", "S_accept"] },
        "S3": { "0": ["S4"], "1": ["S1", "S_accept"] },
        "S4": { "0": ["S5"], "1": ["S3", "S_accept"] },
        "S5": { "0": ["S5"], "1": ["S5"] },
        "S_accept": { "0": ["S_accept", "S0"], "1": ["S_accept", "S1"] }
      },
      initial_state: "S0",
      final_states: ["S_accept"]
    },
    {
      name: "构造NFA(字母表{0,1})问题4",
      note: "(4)所有首字符和尾字符相同的字符串的集合。",
      states: ["S0", "S0_0", "S0_1", "S_accept"],
      alphabet: ["0", "1"],
      transitions: {
        "S0": { "0": ["S0_0", "S_accept"], "1": ["S0_1", "S_accept"] },
        "S0_0": { "0": ["S0_0", "S_accept"], "1": ["S0_0"] },
        "S0_1": { "1": ["S0_1", "S_accept"], "0": ["S0_1"] }
      },
      initial_state: "S0",
      final_states: ["S_accept"]
    }
  ]
}
