import { State } from '../datastructure/State';
import {Transition} from '../datastructure/Transition';
import {Automaton} from '../datastructure/Automaton';
import {AutomatonType} from '../datastructure/Type';
import {RegexToAutomaton} from '../convert/RegexToAutomaton';

export function testRegexToAutomaton(regexInput:string): string{
  let result : string=""
  try {
    const automaton = RegexToAutomaton.convert(regexInput)
    let states = automaton.getStates();
    let initialState = automaton.initialState;
    let finalStates = states.filter(state => state.isFinal);
    if(initialState!=null)
      result+="初始状态:"+initialState.uuid+"\n";
    result+="终止状态:"+finalStates.map(s => s.uuid)+"\n";
    result+="自动机状态与转移：\n"
    automaton.getStates().forEach((state) => {
      result+="状态"+state.name +"  id:" +state.uuid+"\n"
      //result+="坐标"+state.x +" , " +state.y+"\n"
    });
    automaton.getTransitions().forEach((transition) => {
      let from=automaton.getStateWithUuid(transition.from);
      let to =automaton.getStateWithUuid(transition.to)
      if(from!=null&&to!=null)
      {
        result+=(from.name +"->"+ to.name+"输入符号: "+transition.label+"\n")
      }

    });

  } catch (e) {
    result = `转换失败: ${(e as Error).message}`
  }
  console.log(`信息：${result} `);
  return result;
}