import { Automaton } from '../Automaton';
import { State } from '../State';
import { Transition } from '../Transition';
import { LogUtil, FileUtil } from '@pura/harmony-utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { AutomatonType, Node } from '../Type'
import { Type as ClzTransType, instanceToPlain, plainToClass } from 'class-transformer';
import 'reflect-metadata';
import DrawInvoker from '../../viewmodel/DrawInvoker';
import { DrawState } from '../../viewmodel/DrawState';
import { DrawTransition } from '../../viewmodel/DrawTransition';
import { IDraw } from '../../viewmodel/IDraw';
import { Const, DrawType, SavedFile } from '../../../../../Index';
import { FSAState } from './function/simulateFSA';

export class FSAAutomaton extends Automaton<State, Transition> {
  constructor() {
    super(AutomatonType.FSA);
  }

  public static getAutomaton(draw: DrawInvoker): FSAAutomaton{
    const fsa = new FSAAutomaton();
    draw.stateMap.forEach((states) => {
      const drawState = states[states.length - 1];
      const newState = State.deepCopy(drawState.state)
      fsa.addState(newState);
      if (drawState.isInitialState){
        fsa.initialState = newState;
      }
    });
    draw.transitionMap.forEach((transitions) => {
      // 合并所有 transition 的 label
      let combinedLabel = transitions.map(transition => transition.label).join('');
      combinedLabel = Array.from(new Set(combinedLabel)).join('')
      // 使用合并后的 label 创建一个新的 Transition 对象
      const transition = transitions[transitions.length - 1];
      fsa.addTransition(new Transition(transition.fromState.uuid, transition.toState.uuid, combinedLabel));
    });

    return fsa;
  }

  public removeUnconnectedStates() {
    const states = this.getStates();
    if(states.length <= 1){
      return;
    }
    const connectedStates = new Set<number>();

    // 收集所有有转移的状态
    this.getTransitions().forEach(transition => {
      connectedStates.add(transition.from);
      connectedStates.add(transition.to);
    });

    // 删除没有转移的状态
    states.forEach(state => {
      if (!connectedStates.has(state.uuid)) {
        this.removeState(state);
      }
    });
  }

  public drawAutomaton(draw: DrawInvoker){
    let drawArray: Array<IDraw> = [];
    const states = this.getStates();
    for (const state of states) {
      if(state.uuid == this.initialState?.uuid){
        draw.initialState = new DrawState(state, true);
        drawArray.push(draw.initialState);
      }else{
        drawArray.push(new DrawState(state, false));
      }
    }
    const transitions = this.getTransitions();
    for (const transition of transitions) {
      const label = transition.label;
      const fromState = this.getStateWithUuid(transition.from);
      const toState = this.getStateWithUuid(transition.to);
      if(!fromState || !toState){
        continue;
      }
      drawArray.push(new DrawTransition(fromState, toState, label));
    }
    let delArray: Array<DrawTransition> = [];
    for(let items of draw.transitionMap.values()){
      for(let item of items){
        delArray.push(item)
      }
    }
    draw.update(drawArray,DrawType.CREATE, delArray);
  }

  public getNextState(uuid: number, remaining: string): FSAState[]{
    let res : FSAState[] = [];
    const symbol = remaining[0];
    const transitions: Transition[] = this.getTransitionsFromState(uuid);
    for (const transition of transitions) {
      const label = transition.label;
      const labelEmpty = label.includes(Const.EMPTY_STRING);
      const labelSymbol = label.includes(symbol);
      const toState = this.getStateWithUuid(transition.to);
      if (!toState || (!labelEmpty && !labelSymbol)) {
        continue;
      }
      if(labelSymbol){
        res.push(new FSAState(remaining.slice(1), symbol, toState));
      }
      if(labelEmpty){
        res.push(new FSAState(remaining, Const.EMPTY_STRING, toState));
      }
    }
    return res;
  }

  public getSuccessors(node: Node<FSAState>): Node<FSAState>[]{
    const successors: Node<FSAState>[] = [];
    const res = this.getNextState(node.state.uuid, node.state.remaining);
    for (const graphState of res) {
      const newNode = new Node<FSAState>(graphState, node);
      successors.push(newNode);
    }
    return successors;
  }

  public static loadFromFile(dirPath: string = "", fileName: string = "test"): FSAAutomaton {
    try {
      let bufferStr = SavedFile.loadFromFile(dirPath, fileName + Const.FILE_POSTFIX);
      return FSAAutomaton.deserialize(bufferStr);
    } catch (err) {
      let error =err as BusinessError;
      LogUtil.error(`FSAAutomaton-loadFromFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to load automaton from file');
    }
  }

  public static deserialize(automatonJSON: string): FSAAutomaton {
    try {
      const plainObject = plainToClass(FSAAutomaton, JSON.parse(automatonJSON), { exposeDefaultValues: true });

      if (plainObject === null) {
        throw new Error('Invalid JSON input for FSAAutomaton');
      }

      // 嵌套对象从Object转为具体对象
      plainObject.initialState = plainToClass(State, plainObject.initialState, { exposeDefaultValues: true });

      // 手动将 Array 转换为 Set
      let states = new Set(plainObject.states);
      let transitions = new Set(plainObject.transitions);
      plainObject.states = new Set<State>();
      plainObject.transitions = new Set<Transition>();
      for (const state of states) {
        plainObject.states.add(plainToClass(State, state, { exposeDefaultValues: true } ));
      }
      for (const transition of transitions) {
        plainObject.transitions.add(plainToClass(Transition, transition, { exposeDefaultValues: true }));
      }

      return plainObject;
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`FSAAutomaton-deserialize-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to deserialize FSAAutomaton');
    }
  }

  public deepCopy(): FSAAutomaton {
    const newAutomaton = new FSAAutomaton();

    // 1. 复制所有状态并建立映射
    this.getStates().forEach(oldState => {
      const newState = State.deepCopy(oldState);
      newAutomaton.addState(newState);
      if(this.isInitialState(oldState)){
        newAutomaton.setInitialState(newState);
      }
    });

    // 2. 复制转移，更新from/to为新状态的UUID
    this.getTransitions().forEach(oldTransition => {
      const newTransition = Transition.deepCopy(oldTransition)
      newAutomaton.addTransition(newTransition);
    });

    // 3. 复制其他属性
    newAutomaton.name = this.name;
    newAutomaton.note = this.note;
    newAutomaton.type = this.type;

    return newAutomaton;
  }

}

export function createTestAutomaton(): FSAAutomaton {
  // 创建一个自动机实例
  const automaton = new FSAAutomaton()

  // 创建并添加状态
  const state1 = new State();
  const state2 = new State();
  const state3 = new State();
  state1.setName("State 1");
  state2.setName("State 2");
  state3.setName("State 3");
  state1.setPosition(0, 0);
  state2.setPosition(100, 100);
  state3.setPosition(200, 200);
  automaton.addStates([state1, state2, state3]);

  // 设置初始状态
  automaton.setInitialState(state1);

  // 创建并添加转移
  const transition1 = new Transition(state1.uuid, state2.uuid);
  transition1.setLabel("a");
  automaton.addTransition(transition1);

  const transition2 = new Transition(state2.uuid, state3.uuid);
  transition2.setLabel("b");
  automaton.addTransition(transition2);

  return automaton;
}

export function compareAutomatons(automaton1: FSAAutomaton, automaton2: FSAAutomaton): boolean {
  // 比较 UUID
  if (automaton1.uuid !== automaton2.uuid || automaton1.name !== automaton2.name || automaton1.type !== automaton2.type) {
    LogUtil.error("UUID mismatch.");
    return false;
  }

  // 比较初始状态
  if (automaton1.initialState?.uuid !== automaton2.initialState?.uuid) {
    LogUtil.error("Initial state mismatch.");
    return false;
  }

  // 比较状态
  const states1 = automaton1.getStates();
  const states2 = automaton2.getStates();
  if (states1.length !== states2.length) {
    LogUtil.error("States count mismatch.");
    return false;
  }
  for (let i = 0; i < states1.length; i++) {
    if (states1[i].uuid !== states2[i].uuid ||
      states1[i].name !== states2[i].name ||
      states1[i].x !== states2[i].x ||
      states1[i].y !== states2[i].y ) {
      LogUtil.error(`State mismatch at index ${i}`);
      return false;
    }
  }

  // 比较转移
  const transitions1 = automaton1.getTransitions();
  const transitions2 = automaton2.getTransitions();
  if (transitions1.length !== transitions2.length) {
    LogUtil.error("Transitions count mismatch.");
    return false;
  }
  for (let i = 0; i < transitions1.length; i++) {
    if (transitions1[i].from !== transitions2[i].from ||
      transitions1[i].to !== transitions2[i].to ||
      transitions1[i].label !== transitions2[i].label) {
      LogUtil.error(`Transition mismatch at index ${i}`);
      return false;
    }
  }

  return true;
}