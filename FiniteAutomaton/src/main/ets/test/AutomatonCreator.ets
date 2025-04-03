import {FSAAutomaton, State, Transition} from 'shared';

interface FSAConfig {
    states: string[];          // 状态列表
    alphabet: string[];        // 输入符号集合
    transitions: Record<string, Record<string, string[]>>; // 状态转移表
    initial_state: string;     // 初始状态名称
    final_states: string[];    // 终止状态列表
}

const easyFSA: FSAConfig = {
    states: ['s0', 's1'],
    alphabet: [''],
    transitions: {
        's0': {'': ['s1']}
    },
    initial_state: 's0',
    final_states: ['s1']
};

const normalFSA: FSAConfig = {
    states: ['s0', 's1', 's2'],
    alphabet: ['0', '1'],
    transitions: {
        's0': {'0': ['s0'], '1': ['s1']},
        's1': {'0': ['s2'], '1': ['s0']},
        's2': {'0': ['s2'], '1': ['s0']}
    },
    initial_state: 's0',
    final_states: ['s0']
};

const nfaToDFATestFSA: FSAConfig = {
    states: ['s0', 's1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9'],
    alphabet: ['a', 'b'],
    transitions: {
        's0': {'': ['s1', 's7']},
        's1': {'': ['s2', 's4']},
        's2': {'a': ['s3']},
        's3': {'': ['s6']},
        's4': {'b': ['s5']},
        's5': {'': ['s6']},
        's6': {'': ['s7', 's1']},
        's7': {'a': ['s8']},
        's8': {'b': ['s9']}
    },
    initial_state: 's0',
    final_states: ['s9']
};

const minDFATestFSA: FSAConfig = {
    states: ['s0', 's1', 's2', 's3', 's4'],
    alphabet: ['a', 'b'],
    transitions: {
        's0': {'a': ['s1'], 'b': ['s3']},
        's1': {'a': ['s2'], 'b': ['s1']},
        's2': {'a': ['s2'], 'b': ['s1']},
        's3': {'a': ['s4'], 'b': ['s3']},
        's4': {'a': ['s4'], 'b': ['s3']}
    },
    initial_state: 's0',
    final_states: ['s1', 's2']
};

export class AutomatonCreator {

    static easyFSA: FSAAutomaton | null = null;

    static normalFSA: FSAAutomaton | null = null;

    static nfaToDFATestFSA: FSAAutomaton | null = null;

    static minDFATestFSA: FSAAutomaton | null = null;

    public static createFromDFA(dfa: FSAConfig): FSAAutomaton {
        const automaton = new FSAAutomaton();
        const stateMap = new Map<string, State>(); // 状态名称到State对象的映射

        // 1. 创建所有状态
        dfa.states.forEach(stateName => {
            const state = new State();
            state.setName(stateName); // 设置状态名称
            stateMap.set(stateName, state);
            automaton.addState(state); // 单个添加状态
        });

        // 2. 设置初始状态
        const initialState = stateMap.get(dfa.initial_state);
        if (!initialState) throw new Error(`初始状态 ${dfa.initial_state} 不存在`);
        automaton.setInitialState(initialState);

        // 3. 创建转移
        const transitions: Transition[] = [];
        for (const entry of Object.entries(dfa.transitions)) {
            const fromState = entry[0]; // 获取状态名称
            const transitionsMap = entry[1]; // 获取对应的状态转移映射
            for (const transitionEntry of Object.entries(transitionsMap)) {
                const symbol = transitionEntry[0]; // 输入符号
                const toStates = transitionEntry[1]; // 目标状态名称
                const fromStateObj = stateMap.get(fromState);
                for(const toState of toStates){
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

        // 4. 设置终止状态
        dfa.final_states.forEach(finalStateName => {
            const state = stateMap.get(finalStateName);
            if (state) state.isFinal = true;
        });

        return automaton;
    }

    public static getEasyFSA(): FSAAutomaton {
        if (!AutomatonCreator.easyFSA) {
            AutomatonCreator.easyFSA = AutomatonCreator.createFromDFA(easyFSA);
        }
        return AutomatonCreator.easyFSA;
    }

    public static getNormalFSA(): FSAAutomaton {
        if (!AutomatonCreator.normalFSA) {
            AutomatonCreator.normalFSA = AutomatonCreator.createFromDFA(normalFSA);
        }
        return AutomatonCreator.normalFSA;
    }

    public static getNfaToDFATestFSA(): FSAAutomaton {
        if (!AutomatonCreator.nfaToDFATestFSA) {
            AutomatonCreator.nfaToDFATestFSA = AutomatonCreator.createFromDFA(nfaToDFATestFSA);
        }
        return AutomatonCreator.nfaToDFATestFSA;
    }

    public static getMinDFATestFSA(): FSAAutomaton {
        if (!AutomatonCreator.minDFATestFSA) {
            AutomatonCreator.minDFATestFSA = AutomatonCreator.createFromDFA(minDFATestFSA);
        }
        return AutomatonCreator.minDFATestFSA;
    }
}
