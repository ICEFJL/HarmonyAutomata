import { FSAConfig } from "./AutomatonCreator";

export class NFAToDFATest {
  static readonly nfa: FSAConfig[] = [
    {
      note: "原始NFA1",
      states: ["p", "q", "r", "s"],
      alphabet: ["0", "1"],
      transitions: {
        "p": { "0": ["p", "q"], "1": ["p"] },
        "q": { "0": ["r"], "1": ["r"] },
        "r": { "0": ["s"] }
      },
      initial_state: "p",
      final_states: ["s"]
    },
    {
      note: "原始NFA2",
      states: ["p", "q", "r", "s"],
      alphabet: ["0", "1"],
      transitions: {
        "p": { "0": ["q", "s"], "1": ["q"] },
        "q": { "0": ["r"], "1": ["q", "r"] },
        "r": { "0": ["s"], "1": ["p"] }
      },
      initial_state: "p",
      final_states: ["q", "s"]
    }
  ];

  static readonly dfa: FSAConfig[] = [
    {
      note: "原始NFA1的DFA",
      states: ["A", "B", "C", "D", "E", "F"],
      alphabet: ["0", "1"],
      transitions: {
        "A": { "0": ["B"], "1": ["A"] },    // {p}
        "B": { "0": ["C"], "1": ["D"] },    // {p,q}
        "C": { "0": ["E"], "1": ["D"] },    // {p,q,r}
        "D": { "0": ["F"], "1": ["A"] },    // {p,r}
        "E": { "0": ["E"], "1": ["D"] },    // {p,q,r,s} (接受)
        "F": { "0": ["C"], "1": ["D"] },    // {p,q,s} (接受)
      },
      initial_state: "A",
      final_states: ["E", "F"]
    },
    {
      note: "原始NFA2的DFA",
      states: ["A", "B", "C", "D", "E", "F", "G", "H", "S"],
      alphabet: ["0", "1"],
      transitions: {
        "A": { "0": ["D"], "1": ["B"] },    // {p}
        "B": { "0": ["C"], "1": ["E"] },    // {q} (接受)
        "C": { "0": ["S"], "1": ["A"] },    // {r}
        "D": { "0": ["C"], "1": ["E"] },    // {q,s} (接受)
        "E": { "0": ["F"], "1": ["G"] },    // {q,r} (接受)
        "F": { "0": ["S"], "1": ["A"] },    // {r,s} (接受)
        "G": { "0": ["H"], "1": ["G"] },    // {p,q,r} (接受)
        "H": { "0": ["F"], "1": ["G"] },    // {q,r,s} (接受)
        "S": { }                            // {s} (接受)
      },
      initial_state: "A",
      final_states: ["B", "D", "E", "F", "G", "H", "S"]
    }
  ]
}
