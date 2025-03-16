import { FSAAutomaton, State, Transition } from "shared";
import { NFA } from "./NFA";

export class DFA{

  public static minimize(dfa: FSAAutomaton): FSAAutomaton {
    // 1. 检查是否是确定性有限自动机（可选前置校验）
    if (NFA.isNFA(dfa)) throw new Error("必须传入DFA");
    if (!dfa.initialState) throw new Error("DFA必须包含初始状态");

    const unreachableStates = FSAAutomaton.getUnreachableStates(dfa);
    for(const state of unreachableStates){
      dfa.removeState(state);
    }

    const deadStates = FSAAutomaton.getDeadStates(dfa);
    for(const state of deadStates){
      dfa.removeState(state);
    }

    // 2. 初始化分区（接受态与非接受态）
    const alphabet = FSAAutomaton.getAlphabet(dfa);
    const initialAccept = new Set(dfa.getStates().filter(s => s.isFinal).map(s => s.uuid));
    const initialNonAccept = new Set(dfa.getStates().filter(s => !s.isFinal).map(s => s.uuid));
    let partitions = [initialAccept, initialNonAccept];

    // 3. 迭代分割分区
    let changed = true;
    while (changed) {
      changed = false;
      const newPartitions: Set<number>[] = [];
      for (const partition of partitions) {
        if (partition.size <= 1) {
          newPartitions.push(partition);
          continue;
        }
        // 创建分割映射
        const splitPartitions: Set<number>[] = [];
        let splitFound = false;
        for (const symbol of alphabet) {
          const groups = new Map<number, Set<number>>();
          for (const stateId of partition) {
            const trans = dfa.getTransitionsFromState(stateId).find(t => t.label.includes(symbol));
            const targetPartitionIndex = partitions.findIndex(p => p.has(trans?.to || -1));
            if (!groups.has(targetPartitionIndex)) {
              groups.set(targetPartitionIndex, new Set());
            }
            groups.get(targetPartitionIndex)!.add(stateId);
          }
          if(groups.size > 1){
            splitFound = true;
            for(const t of groups.values()){
              splitPartitions.push(t);
            }
            break;
          }
        }
        if(splitFound){
          changed = true;
          newPartitions.push(...splitPartitions);
        }else{
          newPartitions.push(partition);
        }
      }
      partitions = newPartitions;
    }


    // 4. 构建最小化DFA
    const newStates = new Map<number, number>();
    const minimized = new FSAAutomaton();
    for (const partition of partitions) {
      const p = Array.from(partition);
      const t = p[0];
      for(const stateId of p){
        newStates.set(stateId, t);
        minimized.addState(State.deepCopy(dfa.getStateWithUuid(stateId)!));
      }
    }

    for (const fromState of newStates.values()) {
      const transitions = dfa.getTransitionsFromState(fromState);
      for (const transition of transitions) {
        const toState = newStates.get(transition.to);
        if(toState){
          minimized.addTransition(new Transition(fromState, toState, transition.label));
        }
      }
    }

    return minimized;
  }
}