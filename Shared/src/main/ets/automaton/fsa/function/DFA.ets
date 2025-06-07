import { FSA, FSAAutomaton, State, Transition } from "shared";
import { NFA } from "./NFA";

export class DFA{

  public static minimize(dfa: FSAAutomaton): FSAAutomaton {
    // 1. 检查是否是确定性有限自动机（可选前置校验）
    if (NFA.isNFA(dfa)) throw new Error("必须传入DFA");
    if (!dfa.initialState) throw new Error("DFA必须包含初始状态");

    const unreachableStates = FSA.getUnreachableStates(dfa);
    for(const state of unreachableStates){
      dfa.removeState(state);
    }

    const deadStates = FSA.getDeadStates(dfa);
    for(const state of deadStates){
      dfa.removeState(state);
    }

    // 2. 初始化分区（接受态与非接受态）
    const alphabet = FSA.getAlphabet(dfa);
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
    const represents: number[] = [];
    for (const partition of partitions) {
      const p = Array.from(partition);
      const representative = p[0];
      const newState = State.deepCopy(dfa.getStateWithUuid(representative)!);
      minimized.addState(newState);
      for(const stateId of p){
        newStates.set(stateId, representative);
        if(stateId == dfa.initialState.uuid){
          minimized.initialState = newState;
        }
      }
      represents.push(representative);
    }

    for(const represent of represents){
      for (const symbol of alphabet) {
        const trans = dfa.getTransitionsFromState(represent).find(t => t.label.includes(symbol));
        if (trans) {
          minimized.addTransition(new Transition(represent, newStates.get(trans.to)!, symbol));
        }
      }
    }

    return minimized;
  }
}