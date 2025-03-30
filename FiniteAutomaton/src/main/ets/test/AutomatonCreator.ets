import {FSAAutomaton, State, Transition} from 'shared';

export class AutomatonCreator {

    static easyFSA: FSAAutomaton | null = null;

    static normalFSA: FSAAutomaton | null = null;

    static nfaToDFATestFSA: FSAAutomaton | null = null;

    public static getEasyFSA(): FSAAutomaton {
        if (!AutomatonCreator.easyFSA) {
            AutomatonCreator.easyFSA = new FSAAutomaton();
            const state1 = new State();
            const state2 = new State();
            const transition1 = new Transition(state1.uuid, state2.uuid);
            transition1.setLabel('');
            AutomatonCreator.easyFSA.addStates([state1, state2]);
            AutomatonCreator.easyFSA.addTransition(transition1);
            AutomatonCreator.easyFSA.setInitialState(state1);
            state2.isFinal = true;
        }
        return AutomatonCreator.easyFSA;
    }

    public static getNormalFSA(): FSAAutomaton {
        if (!AutomatonCreator.normalFSA) {
            AutomatonCreator.normalFSA = new FSAAutomaton();
            const state1 = new State();
            const state2 = new State();
            const state3 = new State();
            const transition1 = new Transition(state1.uuid, state1.uuid);
            transition1.setLabel('0');
            const transition2 = new Transition(state1.uuid, state2.uuid);
            transition2.setLabel('1');
            const transition3 = new Transition(state2.uuid, state1.uuid);
            transition3.setLabel('1');
            const transition4 = new Transition(state2.uuid, state2.uuid);
            transition4.setLabel('0');
            const transition5 = new Transition(state3.uuid, state3.uuid);
            transition5.setLabel('0');
            const transition6 = new Transition(state3.uuid, state1.uuid);
            transition6.setLabel('1');
            AutomatonCreator.normalFSA.addStates([state1, state2, state3]);
            AutomatonCreator.normalFSA.addTransitions([transition1, transition2, transition3, transition4, transition5, transition6]);
            AutomatonCreator.normalFSA.setInitialState(state1);
            state1.isFinal = true;
        }
        return AutomatonCreator.normalFSA;
    }

    public static getNfaToDFATestFSA(): FSAAutomaton {
        if (!AutomatonCreator.nfaToDFATestFSA) {
            AutomatonCreator.nfaToDFATestFSA = new FSAAutomaton();
            const statesList: State[] = [];
            for (let i = 0; i < 10; i++) {
                const state = new State();
                statesList.push(state);
                state.setName(`s${i}`);
                AutomatonCreator.nfaToDFATestFSA.addState(state);
            }
            const transition1 = new Transition(statesList[0].uuid, statesList[1].uuid);
            transition1.setLabel('');
            const transition2 = new Transition(statesList[0].uuid, statesList[7].uuid);
            transition2.setLabel('');
            const transition3 = new Transition(statesList[1].uuid, statesList[2].uuid);
            transition3.setLabel('');
            const transition4 = new Transition(statesList[1].uuid, statesList[4].uuid);
            transition4.setLabel('');
            const transition5 = new Transition(statesList[2].uuid, statesList[3].uuid);
            transition5.setLabel('a');
            const transition6 = new Transition(statesList[3].uuid, statesList[6].uuid);
            transition6.setLabel('');
            const transition7 = new Transition(statesList[4].uuid, statesList[5].uuid);
            transition7.setLabel('b');
            const transition8 = new Transition(statesList[5].uuid, statesList[6].uuid);
            transition8.setLabel('');
            const transition9 = new Transition(statesList[6].uuid, statesList[7].uuid);
            transition9.setLabel('');
            const transition10 = new Transition(statesList[6].uuid, statesList[1].uuid);
            transition10.setLabel('');
            const transition11 = new Transition(statesList[7].uuid, statesList[8].uuid);
            transition11.setLabel('a');
            const transition12 = new Transition(statesList[8].uuid, statesList[9].uuid);
            transition12.setLabel('b');
            AutomatonCreator.nfaToDFATestFSA.addTransitions([
                transition1, transition2, transition3, transition4, transition5,
                transition6, transition7, transition8, transition9, transition10,
                transition11, transition12
            ]);
            AutomatonCreator.nfaToDFATestFSA.setInitialState(statesList[0]);
            statesList[9].isFinal = true;
        }
        return AutomatonCreator.nfaToDFATestFSA;
    }
}
