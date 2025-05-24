import { State } from '../datastructure/State';
import {Transition} from '../datastructure/Transition';
import {Automaton} from '../datastructure/Automaton';
import {AutomatonType} from '../datastructure/Type';
import { DrawState,DrawTransition } from 'shared';
export class BaseAutomaton extends Automaton<State, Transition> {
  constructor() {
    super(AutomatonType.FSA);
  }
}

export class ConvertToAutomaton {
  // 将绘制的状态和转移信息转化为自动机
  static convert(states: DrawState[], transitions: DrawTransition[]): Automaton<State, Transition> {
    // 创建一个新的自动机实例
    const automaton = new BaseAutomaton();

    //创建状态并将其添加到自动机中
    const stateObjects: State[] = states.map(state => {
      return new State(
        state.state.x,
        state.state.y,
        state.state.name, // 节点名称
        state.state.isFinal, // 是否为终态
        state.state.uuid // 节点ID
      );
    });

    // 设置初始状态
    const initialState = stateObjects.find(state => state.uuid === states.find(s => s.isInitialState)?.state.uuid);
    if (initialState) {
      automaton.setInitialState(initialState);
    } else {
      console.error("未找到初始状态");
    }

    // 添加状态到自动机
    automaton.addStates(stateObjects);

    //创建转移并将其添加到自动机中
    const transitionObjects: Transition[] = transitions.map(transition => {
      return new Transition(
        transition.fromState.uuid, // 从状态的 uuid
        transition.toState.uuid,   // 到状态的 uuid
        transition.label // 转移标签（输入符号）
      );
    });

    // 添加转移到自动机
    automaton.addTransitions(transitionObjects);

    // 返回生成的自动机
    return automaton;
  }
}
