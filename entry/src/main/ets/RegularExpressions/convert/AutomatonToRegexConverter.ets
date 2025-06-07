import { State } from '../datastructure/State';
import {BaseAutomaton} from '../datastructure/BaseAutomaton';
import {Transition} from '../datastructure/Transition';
import {Automaton} from '../datastructure/Automaton';
import { ToastUtil } from '@pura/harmony-utils';

export class AutomatonToRegexConverter {
  static convertToRegex(automaton: BaseAutomaton): string {
    const states = automaton.getStates();
    const transitions = automaton.getTransitions();
    const initialState = automaton.initialState;
    const finalStates = states.filter(s => s.isFinal);

    if (!initialState) {//||finalStates.length === 0
      ToastUtil.showToast("转换失败:自动机必须有一个初始状态");
      //throw new Error("自动机必须有一个初始状态和至少一个终止状态");
      return "Error";
    }

    // Step 1: 初始化转移图
    const transitionMap: Map<number, Map<number, string>> = new Map();
    for (const state of states) {
      transitionMap.set(state.uuid, new Map());
    }

    // 合并同一对 from -> to 的标签为正则“或”关系
    for (const transition of transitions) {
      const fromMap = transitionMap.get(transition.from)!;
      const existing = fromMap.get(transition.to);
      const labels = existing ? new Set(existing.split("+")) : new Set<string>();

      for (const char of transition.label) {
        if (char) labels.add(char);  // 避免空字符参与合并
        else labels.add("ε");
      }

      const combined = Array.from(labels).join("+");
      const labelStr = labels.size > 1 ? `(${combined})` : combined;
      fromMap.set(transition.to, labelStr);
    }


    // Step 2: 添加唯一终态 (virtualFinal)，并通过 ε 转移连接所有原终态
    const virtualFinal = new State(0, 0, "virtualFinal", true, Date.now());
    transitionMap.set(virtualFinal.uuid, new Map());
    // 👇 确保每个终态都被正确连接到 virtualFinal
    for (const final of finalStates) {
      let finalMap = transitionMap.get(final.uuid);
      if (!finalMap) {
        finalMap = new Map();
        transitionMap.set(final.uuid, finalMap);
      }

      const existing = finalMap.get(virtualFinal.uuid);
      if (existing) {
        finalMap.set(virtualFinal.uuid, existing + "+ε");
      } else {
        finalMap.set(virtualFinal.uuid, "ε");
      }
    }
    /*for (const char of transition.label) {
      if (char) labels.add(char); } // 错误：逐字符处理
}   */
    // 将 virtualFinal 加入状态集合
    const allStates = [...states, virtualFinal];

    // Step 3: 消除除 initial 和 virtualFinal 外的状态
    for (const state of allStates) {
      if (state.uuid !== initialState.uuid && state.uuid !== virtualFinal.uuid) {
        AutomatonToRegexConverter.eliminateState(state.uuid, transitionMap);
      }
    }

    // Step 4: 提取最终正则表达式
    let result = transitionMap.get(initialState.uuid)?.get(virtualFinal.uuid) || "";

    // 👇 获取初始状态的自环（loop）并补上循环结构
    const selfLoop = transitionMap.get(initialState.uuid)?.get(initialState.uuid);
    if (selfLoop) {
      const loopPart = selfLoop.length === 1 ? `${selfLoop}*` : `(${selfLoop})*`;
      result = loopPart + result;
    }

    // 如 virtualFinal 有自环，加上循环（一般不会出现，但保留）
    const finalLoop = transitionMap.get(virtualFinal.uuid)?.get(virtualFinal.uuid);
    if (finalLoop) {
      result = `(${result})(${finalLoop})*`;
    }
    // 显式区分空路径（ε）和无路径（null）
    const reachable = transitionMap.get(initialState.uuid)?.has(virtualFinal.uuid);
    if (!reachable) {
      return"<不可达>";
    } else if (result == "") {
      return"ε";
    }
    console.log(" 结果: " +result);
    result=AutomatonToRegexConverter.simplify(result);
    result=AutomatonToRegexConverter.flattenUnions(result);
    console.log(" 结果2: " +result);
    console.log("Final regex candidates from initial to virtualFinal:");
    const mapToPrint = transitionMap.get(initialState.uuid);
    if (mapToPrint) {
      console.log("Initial state's outgoing transitions:");
      for (const key of mapToPrint.keys()) {
        const value = mapToPrint.get(key);
        console.log("  to state " + key + ": " + value);
      }
    }
    //console.log(" 结果: " +result);
    return AutomatonToRegexConverter.simplify(result);
  }

  private static eliminateState(stateId: number, transitionMap: Map<number, Map<number, string>>): void {
    let fromStates = Array.from(transitionMap.keys()).filter(from => transitionMap.get(from)?.has(stateId));
    let toStates = Array.from(transitionMap.get(stateId)?.keys() || []);
    let loop = transitionMap.get(stateId)?.get(stateId) || "";
    console.log(`消除状态 ${stateId}`);
    for (const from of fromStates) {
      for (const to of toStates) {
        if (from === stateId || to === stateId) continue;

        let fromToState = transitionMap.get(from)?.get(stateId) || "";
        let stateToTo = transitionMap.get(stateId)?.get(to) || "";
        let fromTo = transitionMap.get(from)?.get(to) || "";

        let newRegex = fromTo;
        if (fromToState && stateToTo) {
          let middle = loop ? `(${loop})*` : "";
          newRegex = fromTo ? `${fromTo}+(${fromToState}${middle}${stateToTo})` : `(${fromToState}${middle}${stateToTo})`;
        }

        // 确保 `to` 状态有自环时，保留它
        let loopTo = transitionMap.get(to)?.get(to) || "";
        if (loopTo) {
          newRegex = `(${newRegex})(${loopTo})*`;
        }

        if (newRegex) {
          transitionMap.get(from)?.set(to, newRegex);
        }

      }
    }

    // 删除该状态的所有记录
    transitionMap.delete(stateId);
    for (const map of transitionMap.values()) {
      map.delete(stateId);
    }
  }

  public static simplify(regex: string): string {
    let simplified = regex;

    simplified = AutomatonToRegexConverter.removeRedundantParentheses(simplified);
    simplified = AutomatonToRegexConverter.simplifyEmptyStrings(simplified);
    simplified = AutomatonToRegexConverter.simplifyUnions(simplified);
    simplified = AutomatonToRegexConverter.factorizeUnionGroups(simplified);
    simplified = AutomatonToRegexConverter.simplifyConcatenations(simplified);
    //simplified = AutomatonToRegexConverter.removeRedundantParentheses(simplified);
    if (simplified.startsWith('(') && simplified.endsWith(')')) {
      simplified = simplified.slice(1, -1);
    }
    return simplified;
  }

  private static removeRedundantParentheses(regex: string): string {
    // 只去除“非操作符包裹且不影响量词”的冗余括号
    return regex.replace(/\(([^()+*?]+)\)(?![*+?])/g, '$1');
  }

  private static simplifyEmptyStrings(regex: string): string {
    // εa -> a, aε -> a，但保留 ε+ 或 +ε 形式
    return regex
      .replace(/ε+/g, 'ε')
      .replace(/ε([a-zA-Z0-9(])/g, '$1')   // εa -> a
      .replace(/([a-zA-Z0-9)*])ε/g, '$1');   // aε -> a
  }


  private static simplifyUnions(regex: string): string {
    // 逐字符扫描，避免处理连接形式（例如 a+(a+b)c）
    let result = '';
    let buffer = '';
    let depth = 0;
    let i = 0;

    while (i < regex.length) {
      const char = regex[i];

      if (char === '(') {
        depth++;
        buffer += char;
      } else if (char === ')') {
        depth--;
        buffer += char;
      } else if (char === '+' && depth === 0) {
        // 顶层并集发现，结束当前项
        buffer += '|||'; // 用临时分隔符标记并集拆分点
      } else {
        buffer += char;
      }

      i++;
    }

    // 按我们插入的 ||| 拆分并去重
    const terms = buffer.split('|||').map(t => t.trim());
    const unique = Array.from(new Set(terms));
    result = unique.join('+');

    // 若多项，用括号包裹
    if (unique.length > 1) {
      result = `(${result})`;
    }

    return result;
  }

  private static simplifyConcatenations(regex: string): string {
    // 删除仅包围单个字符的括号： (a) → a
    regex = regex.replace(/\(([a-zA-Z0-9])\)/g, '$1');

    // 删除重复括号： ((a)) → (a)
    regex = regex.replace(/\(\((.*?)\)\)/g, '($1)');

    // 合并显式拼接：a(b) → ab, (a)b → ab, (a)(b) → ab
    regex = regex.replace(/([a-zA-Z0-9])\(([^+()]+)\)/g, '$1$2'); // a(b) → ab
    regex = regex.replace(/\(([^+()]+)\)([a-zA-Z0-9])/g, '$1$2'); // (a)b → ab
    regex = regex.replace(/\(([^+()]+)\)\(([^+()]+)\)/g, '$1$2'); // (a)(b) → ab

    return regex;
  }

  private static factorizeUnionGroups(regex: string): string {
    // 匹配形如 xa+ya → (x+y)a
    return regex.replace(/([a-zA-Z]+)a\+([a-zA-Z]+)a/g, (match:string, p1:string, p2:string) => {
      if (p1 !== p2) {
        return `(${p1}+${p2})a`;
      }
      return match;
    }).replace(/a([a-zA-Z]+)\+a([a-zA-Z]+)/g, (match:string, s1:string, s2:string) => {
      if (s1 !== s2) {
        return `a(${s1}+${s2})`;
      }
      return match;
    });
  }

  // 处理 a+(a+b) => a+b、(a+b)+a => a+b、(a+b)+(b+c) => a+b+c
  private static flattenUnions(regex: string): string {
    const unionGroups = regex.split('+');
    const terms = new Set<string>();

    for (let term of unionGroups) {
      // 去除括号，例如 (a+b) → a+b
      if (term.startsWith('(') && term.endsWith(')')) {
        term = term.slice(1, -1);
      }
      // 再次分割可能存在的子 +
      for (const sub of term.split('+')) {
        terms.add(sub);
      }
    }

    return Array.from(terms).sort().join('+');
  }

}
