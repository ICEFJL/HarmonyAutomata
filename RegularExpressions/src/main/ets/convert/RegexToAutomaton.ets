import { State } from '../datastructure/State';
import {Transition} from '../datastructure/Transition';
import {Automaton} from '../datastructure/Automaton';
import {AutomatonType} from '../datastructure/Type';
import 'reflect-metadata';

export class BaseAutomaton extends Automaton<State, Transition> {
  constructor() {
    super(AutomatonType.FSA);
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
