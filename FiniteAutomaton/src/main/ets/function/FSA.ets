import { FSAAutomaton, State } from "shared";
import { DFA } from "./DFA";
import { NFA } from "./NFA";

export class FSA {
  public static minimize(fsa: FSAAutomaton): FSAAutomaton{
    let minFsa = fsa.deepCopy();
    if(NFA.isNFA(minFsa)){
      minFsa = NFA.toDFA(minFsa);
    }
    return DFA.minimize(minFsa);
  }

  // 在 FSAAutomaton 类中添加 isEquivalentTo 方法
  public static isEqual(fsa1: FSAAutomaton, fsa2: FSAAutomaton): boolean {
    const min1 = FSA.minimize(fsa1);
    const min2 = FSA.minimize(fsa2);

    // 1. 检查初始状态是否存在
    const initial1 = min1.initialState;
    const initial2 = min2.initialState;
    if (!initial1 || !initial2) return false;

    // 2. 构建状态映射队列
    const stateMap = new Map<number, number>();
    const visited = new Set<number>();
    const queue: number[] = [initial1.uuid];
    stateMap.set(initial1.uuid, initial2.uuid);
    visited.add(initial1.uuid);

    while (queue.length > 0) {
      const s1Uuid = queue.shift()!;
      const s2Uuid = stateMap.get(s1Uuid)!;
      const s1 = min1.getStateWithUuid(s1Uuid)!;
      const s2 = min2.getStateWithUuid(s2Uuid)!;

      // 终态必须一致
      if (s1.isFinal !== s2.isFinal) return false;

      // 遍历所有转移
      const alphabet = FSAAutomaton.getAlphabet(min1);
      for (const symbol of alphabet) {
        const trans1 = min1.getTransitionsFromState(s1Uuid).find(t => t.label.includes(symbol));
        const trans2 = min2.getTransitionsFromState(s2Uuid).find(t => t.label.includes(symbol));
        if (!trans1 && !trans2) continue;
        if (!trans1 || !trans2) return false;

        const next1Uuid = trans1.to;
        const next2Uuid = trans2.to;

        // 检查映射是否一致
        if (stateMap.has(next1Uuid)) {
          if (stateMap.get(next1Uuid) !== next2Uuid) return false;
        } else {
          stateMap.set(next1Uuid, next2Uuid);
          if (!visited.has(next1Uuid)) {
            visited.add(next1Uuid);
            queue.push(next1Uuid);
          }
        }
      }
    }

    // 3. 检查所有状态都被映射
    return stateMap.size === min1.getStates().length;
  }

}