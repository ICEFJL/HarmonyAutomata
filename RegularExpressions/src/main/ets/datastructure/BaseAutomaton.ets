import { Automaton,State,Transition,AutomatonType,IDraw,DrawInvoker,DrawState,DrawTransition,DrawType,Const } from 'shared';
import { LogUtil, FileUtil } from '@pura/harmony-utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
import { Type as ClzTransType, instanceToPlain, plainToClass } from 'class-transformer';
//import { FSAAutomaton} from "shared";
//import { NFA } from "./NFA";
import 'reflect-metadata';

export class BaseAutomaton extends Automaton<State, Transition> {
  constructor() {
    super(AutomatonType.FSA);
  }



  public static loadFromFile(dirPath: string = "", fileName: string = "test.json"): BaseAutomaton {
    try {
      let filePath = FileUtil.getFilesDirPath(dirPath, fileName);
      let readTextOptions: ReadTextOptions = {
        offset: 0,
        length: 0,
        encoding: 'utf-8'
      };
      let stat = fs.statSync(filePath);
      readTextOptions.length = stat.size;
      let bufferStr = fs.readTextSync(filePath, readTextOptions);
      return BaseAutomaton.deserialize(bufferStr);
    } catch (err) {
      let error =err as BusinessError;
      LogUtil.error(`BaseAutomaton-loadFromFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to load automaton from file');
    }
  }

  public static deserialize(automatonJSON: string): BaseAutomaton {
    try {
      const plainObject = plainToClass(BaseAutomaton, JSON.parse(automatonJSON), { exposeDefaultValues: true });

      if (plainObject === null) {
        throw new Error('Invalid JSON input for BaseAutomaton');
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
      LogUtil.error(`BaseAutomaton-deserialize-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to deserialize BaseAutomaton');
    }
  }

  public static getAlphabet(automaton: BaseAutomaton): string[] {
    const transitions = automaton.getTransitions();
    const charSet = new Set<string>();
    for (const transition of transitions) {
      const label = transition.label;
      for (const char of label) {
        charSet.add(char);
      }
    }
    charSet.delete("");
    return Array.from(charSet);
  }

  public static getUnreachableStates(automaton: BaseAutomaton): State[] {
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

  public static getDeadStates(automaton: BaseAutomaton): State[] {
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

  public getTransitions(): Transition[] {
    return Array.from(this.transitions);
  }

  public getStates(): State[] {
    return Array.from(this.states);
  }

  public static getAutomaton(draw: DrawInvoker): BaseAutomaton{
    const fsa = new BaseAutomaton();
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

  public static isEqual(fsa1: BaseAutomaton, fsa2: BaseAutomaton): boolean {
    let isNfa1 = BaseAutomaton.isNFA(fsa1);
    let isNfa2 = BaseAutomaton.isNFA(fsa2);
    if(isNfa1 !== isNfa2){
      return false;
    }
    const min1 = BaseAutomaton.minimizeDFA(fsa1);
    const min2 = BaseAutomaton.minimizeDFA(fsa2);

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
      const alphabet = BaseAutomaton.getAlphabet(min1);
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

  public static isNFA(automaton: BaseAutomaton): boolean {
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

  public getTransitionsFrom(stateId: number): Transition[] {
    return this.getTransitions().filter(t => t.from === stateId);
  }

  public getStateById(id: number): State | undefined {
    return this.getStates().find(s => s.uuid === id);
  }

  public static convertNFAtoDFA(nfa: BaseAutomaton): BaseAutomaton {
    const EPSILON = "";
    const dfa = new BaseAutomaton();
    let initialState=nfa.initialState;
    if (!initialState) {
      throw new Error("NFA 不存在初始状态");
    }
    const startClosure: Set<number> = BaseAutomaton.epsilonClosure(new Set([initialState.uuid]), nfa);
    const stateIdMap: Map<string, State> = new Map();
    const queue: Set<number>[] = [];
    queue.push(startClosure);

    let stateCounter = 0;
    const getStateName = () => `S${stateCounter++}`;

    const setToString = (s: Set<number>): string => [...Array.from(s)].sort().join(',');

    const dfaStartState = new State(0, 0, getStateName(), BaseAutomaton.hasFinalState(startClosure, nfa));
    dfa.setInitialState(dfaStartState);
    dfa.addState(dfaStartState);
    stateIdMap.set(setToString(startClosure), dfaStartState);

    while (queue.length > 0) {
      const currentSet = queue.shift()!;
      const currentState = stateIdMap.get(setToString(currentSet))!;

      const symbolSet = new Set<string>();
      for (const stateId of currentSet) {
        for (const t of nfa.getTransitionsFrom(stateId)) {
          if (t.label !== EPSILON) symbolSet.add(t.label);
        }
      }

      for (const symbol of symbolSet) {
        let moveSet: Set<number> = new Set();
        for (const stateId of currentSet) {
          for (const t of nfa.getTransitionsFrom(stateId)) {
            if (t.label === symbol) {
              moveSet.add(t.to);
            }
          }
        }

        const targetClosure = BaseAutomaton.epsilonClosure(moveSet, nfa);
        const targetKey = setToString(targetClosure);

        if (!stateIdMap.has(targetKey)) {
          const targetState = new State(0, 0, getStateName(), BaseAutomaton.hasFinalState(targetClosure, nfa));
          dfa.addState(targetState);
          stateIdMap.set(targetKey, targetState);
          queue.push(targetClosure);
        }

        dfa.addTransition(new Transition(currentState.uuid, stateIdMap.get(targetKey)!.uuid, symbol));
      }
    }

    return dfa;
  }

  private static epsilonClosure(states: Set<number>, nfa: BaseAutomaton): Set<number> {
    const EPSILON = "";
    const stack: number[] = [...Array.from(states)];
    const closure = new Set<number>(states);

    while (stack.length > 0) {
      const stateId = stack.pop()!;
      for (const t of nfa.getTransitionsFrom(stateId)) {
        if (t.label === EPSILON && !closure.has(t.to)) {
          closure.add(t.to);
          stack.push(t.to);
        }
      }
    }

    return closure;
  }

  private static hasFinalState(states: Set<number>, nfa: BaseAutomaton): boolean {
    for (const id of states) {
      const state = nfa.getStateById(id);
      if (state && state.isFinal) return true;
    }
    return false;
  }

  public static minimizeDFA(dfa: BaseAutomaton): BaseAutomaton {
    const states = dfa.getStates();
    const transitions = dfa.getTransitions();
    const symbols = new Set<string>();

    // 收集所有符号（排除空串）
    for (const t of transitions) {
      if (t.label !== "") {
        symbols.add(t.label);
      }
    }

    // 初始分组：终态 和 非终态
    const finalStates = states.filter(s => s.isFinal).map(s => s.uuid);
    const nonFinalStates = states.filter(s => !s.isFinal).map(s => s.uuid);
    let partitions: number[][] = [];
    if (finalStates.length > 0) partitions.push(finalStates);
    if (nonFinalStates.length > 0) partitions.push(nonFinalStates);

    const getGroupIndex = (stateId: number, groups: number[][]): number => {
      for (let i = 0; i < groups.length; i++) {
        if (groups[i].includes(stateId)) return i;
      }
      return -1;
    };

    let changed = true;
    while (changed) {
      changed = false;
      const newPartitions: number[][] = [];

      for (const group of partitions) {
        const subGroups: Map<string, number[]> = new Map();

        for (const stateId of group) {
          const signature: string[] = [];
          for (const symbol of symbols) {
            const trans = dfa.getTransitionsFrom(stateId).find(t => t.label === symbol);
            const targetGroup = trans ? getGroupIndex(trans.to, partitions) : -1;
            signature.push(symbol + ':' + targetGroup);
          }
          const sigKey = signature.join('|');
          if (!subGroups.has(sigKey)) {
            subGroups.set(sigKey, []);
          }
          subGroups.get(sigKey)?.push(stateId);
        }

        if (subGroups.size === 1) {
          newPartitions.push(group);
        } else {
          changed = true;
          for (const subgroup of subGroups.values()) {
            newPartitions.push(subgroup);
          }
        }
      }

      partitions = newPartitions;
    }

    // 构造新的最小化 DFA
    const minimizedDFA = new BaseAutomaton();
    const stateMap = new Map<string, State>();

    const getGroupKey = (group: number[]): string =>
    Array.from(group).sort((a, b) => a - b).join(',');

    for (const group of partitions) {
      const origState = dfa.getStateById(group[0]);
      if (!origState) continue;
      const key = getGroupKey(group);
      const newState = new State(0, 0, `Q${stateMap.size}`, group.some(id => dfa.getStateById(id)?.isFinal ?? false));
      stateMap.set(key, newState);
      minimizedDFA.addState(newState);

      if (dfa.initialState && group.includes(dfa.initialState.uuid)) {
        minimizedDFA.setInitialState(newState);
      }
    }

    for (const group of partitions) {
      const fromKey = getGroupKey(group);
      const fromState = stateMap.get(fromKey);
      if (!fromState) continue;

      const origStateId = group[0];
      const fromTransitions = dfa.getTransitionsFrom(origStateId);

      for (const symbol of symbols) {
        const t = fromTransitions.find(tr => tr.label === symbol);
        if (!t) continue;

        const toStateId = t.to;
        const toGroup = partitions.find(g => g.includes(toStateId));
        if (!toGroup) continue;

        const toKey = getGroupKey(toGroup);
        const toState = stateMap.get(toKey);
        if (!toState) continue;

        minimizedDFA.addTransition(new Transition(fromState.uuid, toState.uuid, symbol));
      }
    }

    return minimizedDFA;
  }
}

// 工具类：插入连接符
class RegexConcatInserter {

  private static isLiteral(c: string): boolean {
    return /^[a-zA-Z0-9]$/.test(c);
  }

  public static insertConcatOperators(regex: string): string {
    let result = '';
    for (let i = 0; i < regex.length; i++) {
      const curr = regex[i];
      const next = regex[i + 1];

      result += curr;

      if (!next) continue;

      const needConcat =
        (RegexConcatInserter.isLiteral(curr) || curr === '*' || curr === ')') &&
          (RegexConcatInserter.isLiteral(next) || next === '(' || next === 'ε');

      if (needConcat) {
        result += '.';
      }
    }

    return result;
  }
}

// 正则表达式转自动机
export class RegexToAutomaton {
  static convert(regex: string): BaseAutomaton {
    const preprocessedRegex = RegexConcatInserter.insertConcatOperators(regex);
    const postfix = RegexToAutomaton.infixToPostfix(preprocessedRegex);
    return RegexToAutomaton.postfixToNFA(postfix);
  }

  private static infixToPostfix(regex: string): string {
    class OperatorPrecedence {
      static readonly STAR = 3;
      static readonly CONCAT = 2;
      static readonly UNION = 1;

      static getPrecedence(op: string): number {
        switch (op) {
          case '*': return OperatorPrecedence.STAR;
          case '.': return OperatorPrecedence.CONCAT;
          case '+': return OperatorPrecedence.UNION;
          default: return -1;
        }
      }
    }
    const output: string[] = [];
    const stack: string[] = [];

    for (const token of regex) {
      if (/^[a-zA-Z0-9]$/.test(token)|| token === 'ε') {
        output.push(token);
      } else if (token === '(') {
        stack.push(token);
      } else if (token === ')') {
        while (stack.length && stack[stack.length - 1] !== '(') {
          output.push(stack.pop()!);
        }
        stack.pop(); // 移除 (
      } else { // 操作符
        while (stack.length &&
          OperatorPrecedence.getPrecedence(stack[stack.length - 1]) >= OperatorPrecedence.getPrecedence(token)) {
          output.push(stack.pop()!);
        }
        stack.push(token);
      }
    }

    while (stack.length) {
      output.push(stack.pop()!);
    }

    return output.join('');
  }

  private static postfixToNFA(postfix: string): BaseAutomaton {
    class Fragment {
      start: State;
      end: State;
      transitions: Transition[];

      constructor(start: State, end: State, transitions: Transition[]) {
        this.start = start;
        this.end = end;
        this.transitions = transitions;
      }
    }

    let stateId = 0;
    const newState = (namePrefix = 'q') => new State(0, 0, namePrefix + (stateId++));
    const EPSILON = "";//'ε';
    const stack: Fragment[] = [];

    for (const token of postfix) {
      if (/^[a-zA-Z0-9]$/.test(token) || token === 'ε') {
        const s1 = newState();
        const s2 = newState();
        const t = new Transition(s1.uuid, s2.uuid, token === 'ε' ? EPSILON : token);
        stack.push(new Fragment(s1, s2, [t]));
      }
      else if (token === '*') {
        const frag = stack.pop()!;
        const start = newState();
        const end = newState();
        const t1 = new Transition(start.uuid, frag.start.uuid, EPSILON);
        const t2 = new Transition(frag.end.uuid, frag.start.uuid, EPSILON);
        const t3 = new Transition(start.uuid, end.uuid, EPSILON);
        const t4 = new Transition(frag.end.uuid, end.uuid, EPSILON);
        stack.push(new Fragment(start, end, [t1, t2, t3, t4, ...frag.transitions]));
      } else if (token === '.') {
        const frag2 = stack.pop()!;
        const frag1 = stack.pop()!;
        const t = new Transition(frag1.end.uuid, frag2.start.uuid, EPSILON);
        stack.push(new Fragment(frag1.start, frag2.end, [t, ...frag1.transitions, ...frag2.transitions]));
      } else if (token === '+') {
        const frag2 = stack.pop()!;
        const frag1 = stack.pop()!;
        const start = newState();
        const end = newState();
        const t1 = new Transition(start.uuid, frag1.start.uuid, EPSILON);
        const t2 = new Transition(start.uuid, frag2.start.uuid, EPSILON);
        const t3 = new Transition(frag1.end.uuid, end.uuid, EPSILON);
        const t4 = new Transition(frag2.end.uuid, end.uuid, EPSILON);
        stack.push(new Fragment(start, end, [t1, t2, t3, t4, ...frag1.transitions, ...frag2.transitions]));
      }
    }

    const result = stack.pop()!;
    result.end.isFinal = true;

    const automaton = new BaseAutomaton();
    automaton.setInitialState(result.start);

    // 1. 收集所有参与转移的状态 ID
    const usedStateIds = new Set<number>();
    result.transitions.forEach(t => {
      usedStateIds.add(t.from);
      usedStateIds.add(t.to);
    });
    usedStateIds.add(result.start.uuid);
    usedStateIds.add(result.end.uuid);

    // 2. 为每个唯一 ID 分配状态并命名：q0, q1, ...
    const idToStateMap = new Map<number, State>();
    let stateCounter = 0;
    usedStateIds.forEach(id => {
      const name = `q${stateCounter++}`;
      const isFinal = id === result.end.uuid;
      const state = new State(0, 0, name, isFinal, id);
      idToStateMap.set(id, state);
      automaton.addState(state);
    });

    // 3. 添加转移
    result.transitions.forEach(t => {
      automaton.addTransition(new Transition(t.from, t.to, t.label));
    });
    return automaton;
  }
}

export function compareAutomatons(automaton1: BaseAutomaton, automaton2: BaseAutomaton): boolean {
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