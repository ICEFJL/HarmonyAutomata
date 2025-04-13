import { FSAAutomaton, GemLayoutAlgorithm, SavedFile, State, Transition } from 'shared';

export interface FSAConfig {
    name?: string;
    note?: string;
    states: string[];          // 状态列表
    alphabet: string[];        // 输入符号集合
    transitions: Record<string, Record<string, string[]>>; // 状态转移表
    initial_state: string;     // 初始状态名称
    final_states: string[];    // 终止状态列表
}

export class AutomatonCreator {
    static gemLayoutAlgorithm = new GemLayoutAlgorithm<State, Transition>();
    public static save(nfa: FSAConfig): void {
        let fsa = AutomatonCreator.createFromDFA(nfa);
        fsa = AutomatonCreator.gemLayoutAlgorithm.process(fsa) as FSAAutomaton;
        fsa.saveToFile();
        let savedFile = new SavedFile(fsa.name, '测试文件', fsa.type);
        savedFile.save();
    }

    public static createFromDFA(dfa: FSAConfig): FSAAutomaton {
        const automaton = new FSAAutomaton();
        const stateMap = new Map<string, State>(); // 状态名称到State对象的映射

        // 1. 设置 DFA 名称
        if (dfa.name) {
            automaton.setName(dfa.name); // 设置自动机名称
        }

        // 2. 创建所有状态
        dfa.states.forEach(stateName => {
            const state = new State();
            state.setName(stateName); // 设置状态名称
            stateMap.set(stateName, state);
            automaton.addState(state); // 单个添加状态
        });

        // 3. 设置初始状态
        const initialState = stateMap.get(dfa.initial_state);
        if (!initialState) throw new Error(`初始状态 ${dfa.initial_state} 不存在`);
        automaton.setInitialState(initialState);

        // 4. 创建转移
        const transitions: Transition[] = [];
        for (const entry of Object.entries(dfa.transitions)) {
            const fromState = entry[0]; // 获取状态名称
            const transitionsMap = entry[1]; // 获取对应的状态转移映射
            for (const transitionEntry of Object.entries(transitionsMap)) {
                const symbol = transitionEntry[0]; // 输入符号
                const toStates = transitionEntry[1]; // 目标状态名称
                const fromStateObj = stateMap.get(fromState);
                for (const toState of toStates) {
                    const toStateObj = stateMap.get(toState);
                    if (!fromStateObj || !toStateObj) {
                        throw new Error(`状态 ${fromState} 或 ${toState} 不存在`);
                    }
                    const transition = new Transition(fromStateObj.uuid, toStateObj.uuid);
                    transition.setLabel(symbol);
                    transitions.push(transition);
                }
            }
        }
        automaton.addTransitions(transitions); // 批量添加转移

        // 5. 设置终止状态
        dfa.final_states.forEach(finalStateName => {
            const state = stateMap.get(finalStateName);
            if (state) state.isFinal = true;
        });

        return automaton;
    }
}
