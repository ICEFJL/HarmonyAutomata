import { FSAAutomaton, Transition, State, Const } from "shared";

export class NFA {
  public static isNFA(automaton: FSAAutomaton): boolean {
    const states = automaton.getStates();
    for (const state of states) {
      const transitions = automaton.getTransitionsFromState(state.uuid);
      const labels = transitions.map(transition => transition.label);

      // 检查是否存在空字符串
      if (labels.includes(Const.EMPTY_STRING)) {
        return true;
      }

      // 检查是否存在相同字符
      const charSet = new Set<string>();
      for (const label of labels) {
        for (const char of label) {
          if (charSet.has(char)) {
            return true;
          }
          charSet.add(char);
        }
      }
    }
    return false;
  }

  public static toDFA(nfa: FSAAutomaton): FSAAutomaton {
    const initialState = nfa.initialState;
    if (!initialState || !NFA.isNFA(nfa)) return nfa;

    const closureCache = new Map<number, Set<number>>();
    nfa.getStates().forEach(state => {
      closureCache.set(state.uuid, NFA.getClosure(state.uuid, nfa));
    });

    const initialStateClosure = closureCache.get(initialState.uuid)!;
    const initialStateKey = NFA.getStringForStates(initialStateClosure);
    const frontier: string[] = [initialStateKey];
    const visitedStates = new Map<string, Set<number>>(); // 已访问状态集合的缓存
    const transitionMap = new Map<string, string>();
    const alphabet = FSAAutomaton.getAlphabet(nfa);
    const accept = new Set(nfa.getStates().filter(s => s.isFinal).map(s => s.uuid));
    const dfaMap = new Map<string, number>();

    const dfa = new FSAAutomaton();
    dfa.setName(nfa.name);
    dfa.setNote(nfa.note);

    visitedStates.set(initialStateKey, initialStateClosure);

    while (frontier.length > 0) {
      const currentStateKey = frontier.shift()!;
      const currentStates = visitedStates.get(currentStateKey)!;

      for (const symbol of alphabet) {
        const nextStates = NFA.getStatesOnTerminal(symbol, currentStates, nfa, closureCache);
        if (nextStates.size === 0) continue;

        const nextStatesKey = NFA.getStringForStates(nextStates);
        if (!visitedStates.has(nextStatesKey)) {
          visitedStates.set(nextStatesKey, nextStates);
          frontier.push(nextStatesKey);
        }
        const transitionKey = currentStateKey + "-" + nextStatesKey;
        if(!transitionMap.has(transitionKey)){
          transitionMap.set(transitionKey, symbol);
        } else {
          transitionMap.set(transitionKey, transitionMap.get(transitionKey)! + symbol);
        }
      }
    }

    visitedStates.forEach((states, currentStateKey) => {
      const newState = new State();
      newState.setName(NFA.getNameForStates(states, nfa))
      for(const state of states){
        if(accept.has(state)){
          newState.isFinal = true;
          break;
        }
      }
      dfaMap.set(currentStateKey, newState.uuid);
      dfa.addState(newState);
      if(currentStateKey === initialStateKey){
        newState.setPosition(initialState.x, initialState.y);
        dfa.setInitialState(newState);
      }
    });

    transitionMap.forEach((value, key) => {
      const parts = key.split('-');
      const fromState = dfaMap.get(parts[0]);
      const toState = dfaMap.get(parts[1]);
      if(fromState && toState){
        dfa.addTransition(new Transition(fromState, toState, value));
      }
    });

    return dfa;
  }
  private static getSortStates(states: Set<number>): number[]{
    return Array.from(states).sort((a, b) => a - b);
  }

  private static getStringForStates(states: Set<number>): string {
    return NFA.getSortStates(states).join(',');
  }

  private static getNameForStates(states: Set<number>, automaton: FSAAutomaton): string {
    return NFA.getSortStates(states)
      .map(uuid => automaton.getStateWithUuid(uuid)?.name)
      .join(',');
  }

  private static getStatesOnTerminal(
    symbol: string,
    states: Set<number>,
    automaton: FSAAutomaton,
    closureCache: Map<number, Set<number>>
  ): Set<number> {
    const result = new Set<number>();
    for (const state of states) {
      const transitions = automaton.getTransitionsFromState(state);
      for (const transition of transitions) {
        if (transition.label.includes(symbol)) {
          const closure = closureCache.get(transition.to);
          if(closure){
            closure.forEach(uuid => result.add(uuid));
          }
        }
      }
    }
    // 转换为State对象数组
    return result;
  }

  public  static getClosure(state: number, automaton: FSAAutomaton): Set<number> {
    const closure = new Set<number>();
    const queue = [state]; // 使用队列实现BFS遍历

    closure.add(state);

    while (queue.length > 0) {
      const currentState = queue.shift()!;
      const transitions = automaton.getTransitionsFromState(currentState);
      for (const transition of transitions) {
        if (transition.label.includes(Const.EMPTY_STRING)) {
          const toState = automaton.getStateWithUuid(transition.to);
          if (toState && !closure.has(toState.uuid)) {
            closure.add(toState.uuid);
            queue.push(toState.uuid);
          }
        }
      }
    }
    return closure;
  }

}
