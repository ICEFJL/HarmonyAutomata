import { Const, FSAAutomaton, State } from "shared";
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

  public static isEqual(fsa1: FSAAutomaton, fsa2: FSAAutomaton): boolean {
    let isNfa1 = NFA.isNFA(fsa1);
    let isNfa2 = NFA.isNFA(fsa2);
    if(isNfa1 !== isNfa2){
      return false;
    }
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
      const alphabet = FSA.getAlphabet(min1);
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

  public static getDeadStates(automaton: FSAAutomaton): State[] {
    const allStates = automaton.getStates();
    const finalStates = allStates.filter(state => state.isFinal);
    const finalIds = new Set(finalStates.map(s => s.uuid));

    if (finalIds.size === 0) {
      return allStates; // 无终态时所有状态均为死状态
    }

    const visited = new Set(finalIds);
    const queue = Array.from(finalIds);
    // 缓存前驱映射
    const predecessorMap = new Map<number, number[]>();
    automaton.getTransitions().forEach(t => {
      if (!predecessorMap.has(t.to)) {
        predecessorMap.set(t.to, []);
      }
      predecessorMap.get(t.to)!.push(t.from);
    });

    while (queue.length > 0) {
      const currentStateId = queue.shift()!;
      // 收集所有前驱状态（反向遍历）
      const predecessors = predecessorMap.get(currentStateId) || [];

      for (const predecessorId of predecessors) {
        if (!visited.has(predecessorId)) {
          visited.add(predecessorId);
          queue.push(predecessorId);
        }
      }
    }

    // 筛选出无法到达终态的状态
    return allStates.filter(state => !visited.has(state.uuid));
  }

  public static getUnreachableStates(automaton: FSAAutomaton): State[] {
    const allStates = automaton.getStates(); // 直接获取状态对象列表

    if (!automaton.initialState) {
      return allStates; // 无初始状态时返回所有状态对象
    }

    const initialId = automaton.initialState.uuid;
    const visited = new Set<number>();
    const queue = [initialId];

    while (queue.length > 0) {
      const stateId = queue.shift()!;
      if (visited.has(stateId)) continue;
      visited.add(stateId);

      const transitions = automaton.getTransitionsFromState(stateId);
      for (const trans of transitions) {
        const target = trans.to;
        if (!visited.has(target)) {
          queue.push(target);
        }
      }
    }

    return allStates.filter(state => !visited.has(state.uuid));
  }

  public static getAlphabet(automaton: FSAAutomaton): string[] {
    const transitions = automaton.getTransitions();
    const charSet = new Set<string>();
    for (const transition of transitions) {
      const label = transition.label;
      for (const char of label) {
        charSet.add(char);
      }
    }
    charSet.delete(Const.EMPTY_STRING);
    return Array.from(charSet);
  }
}