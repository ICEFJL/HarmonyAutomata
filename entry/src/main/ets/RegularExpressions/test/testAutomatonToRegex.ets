/*import { Transition, Automaton, State, AutomatonType } from 'shared';
import { AutomatonToRegexConverter } from '../convert/AutomatonToRegexConverter';
import {BaseAutomaton} from '../datastructure/BaseAutomaton';

export function testAutomatonToRegex(): string {
  // 创建自动机实例
  const automaton = new BaseAutomaton();
  let result : string=""
  // 创建状态
  let q0 = new State(0, 0, "q0", false, 0);
  let q1 = new State(0, 0, "q1", false, 1);
  let q2 = new State(0, 0, "q2", true, 2); // 终态
  let q3 = new State(0, 0, "q3", false, 3);
  // 设置初始状态
  automaton.setInitialState(q0);
  // 添加状态到自动机
  automaton.addStates([q0, q1, q2, q3]);
  // 添加转移
  automaton.addTransitions([
    new Transition(q0.uuid, q3.uuid, "c"),
    new Transition(q3.uuid, q1.uuid, "a"),
    new Transition(q0.uuid, q1.uuid, "a"),
    new Transition(q1.uuid, q2.uuid, "b"),
    new Transition(q1.uuid, q1.uuid, "a"), // 自环 a*
  ]);

  // 输出原本的自动机状态
  console.log("原本的自动机状态与转移：");

  automaton.getStates().forEach((state) => {
    console.log(`状态 ${state.name} (id: ${state.uuid})`);
  });
  automaton.getTransitions().forEach((transition) => {
    console.log(` ${transition.from} -> ${transition.to} , 输入符号: ${transition.label}`);
  });

  // 运行转换
  try {
    let regex = AutomatonToRegexConverter.convertToRegex(automaton);
    let states = automaton.getStates();
    let initialState = automaton.initialState;
    let finalStates = states.filter(state => state.isFinal);
    if(initialState!=null)
      result+="初始状态:"+initialState.uuid+"\n";
    result+="终止状态:"+finalStates.map(s => s.uuid)+"\n";
    result+="原本的自动机状态与转移：\n"
    automaton.getStates().forEach((state) => {
      result+="状态"+state.name +"  id:" +state.uuid+"\n"
    });
    automaton.getTransitions().forEach((transition) => {
      result+=transition.from +"->"+ transition.to+"输入符号: "+transition.label+"\n"
    });
    console.log("转换得到的正则表达式:", regex);
    return result+"转换得到的正则表达式:\n"+regex;
  } catch (error) {
    console.error("正则表达式转换失败:", error);
    return "";
  }
}*/
