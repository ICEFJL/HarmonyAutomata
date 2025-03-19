import { State,AutomatonType,DrawInvoker,DrawState,DrawTransition,IDraw } from 'shared'
import {TuringTransition} from './TuringTransition'
import {FileUtil} from '@pura/harmony-utils';
import {TuringMachine} from './TuringMachine'
import 'reflect-metadata';
import { Type as ClzTransType, instanceToPlain, plainToClass } from 'class-transformer';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';

export class BaseTuringMachine extends TuringMachine<State, TuringTransition> {
  constructor() {
    super(AutomatonType.TM);
  }

  public static getAutomaton(draw: DrawInvoker): BaseTuringMachine{
    const tm = new BaseTuringMachine();
    draw.stateMap.forEach((states) => {
      const drawState = states[states.length - 1];
      const newState = State.deepCopy(drawState.state)
      tm.addState(newState);
      if (drawState.isInitialState){
        tm.initialState = newState;
      }
    });
    draw.transitionMap.forEach((transitions) => {
      const transition = transitions[transitions.length - 1];
      //为统一接口:此处保留labelName,拆分labelName为readSymbol:writeSymbol;moveDirection
      //eg.读0写1,方向R;记为0,1;R
      switch (transition.label[4]) {
        case 'L': // 左移逻辑
          tm.addTransition(new TuringTransition(transition.fromState.uuid, transition.toState.uuid, transition.label[0],transition.label[2],'L'));
          break;
        case 'R': // 右移逻辑
          tm.addTransition(new TuringTransition(transition.fromState.uuid, transition.toState.uuid, transition.label[0],transition.label[2],'R'));
          break;
        case 'S': // 不动
          tm.addTransition(new TuringTransition(transition.fromState.uuid, transition.toState.uuid, transition.label[0],transition.label[2],'S'));
          break;
        default:  // 处理其他方向（无效输入）
          console.error("wrong moveDirection!");
          break;
      }
    });

    tm.removeUnconnectedStates();

    return tm;
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
      if(state === this.initialState){
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
    draw.update(drawArray);
  }

  public static getAlphabet(automaton: BaseTuringMachine): string[] {
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

  public static getUnreachableStates(automaton: BaseTuringMachine): State[] {
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

  public static getDeadStates(automaton: BaseTuringMachine): State[] {
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


  public static createExample(): BaseTuringMachine {
    const tm = new BaseTuringMachine();
    tm.setName("BitFlipTM");
    tm.setNote("Inverts binary digits (0↔1, e.g. '101' → '010')");

    // 创建带唯一UUID的状态
    const q0 = new State();
    q0.setName("q0");q0.setPosition(0, 0);
    const q1 = new State();
    q1.setName("q1");q1.setPosition(100, 0);
    q1.isFinal = true; // 终止状态
    tm.addStates([q0, q1]);

    // 定义转换规则
    try {
      tm.addTransitions([
      // 核心逻辑：翻转符号并右移
        new TuringTransition(q0.uuid, q0.uuid, '0', '1', 'R'), // 0→1
        new TuringTransition(q0.uuid, q0.uuid, '1', '0', 'R'), // 1→0

        // 终止条件：遇到空白时停止
        new TuringTransition(q0.uuid, q1.uuid, 'ε', 'ε', 'S') // 保持空白不动
      ]);
    } catch (e) {
      console.error("转移规则添加失败:", e.message);
    }

    // 初始化纸带（示例输入"101"）
    tm.initializeTape("101");
    return tm;
  }


  public serialize(): string {
    try {
      return JSON.stringify(instanceToPlain(this));
    } catch (err) {
      let error = err as BusinessError;
      console.error(`BaseTuringMachine-beanToJsonStr-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return "";
    }
  }

  public saveToFile(dirPath: string = "", fileName: string = "test.json"): void {
    try {
      let path = FileUtil.getFilesDirPath(dirPath, fileName);

      let file = FileUtil.openSync(path);
      let len = FileUtil.writeSync(file.fd, this.serialize())
      FileUtil.closeSync(file.fd); //关闭文件
    } catch (err) {
      let error = err as BusinessError;
      console.error(`BaseTuringMachine-saveToFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to save TuringMachine to file');
    }
  }


  public static loadFromFile(dirPath: string = "", fileName: string = "test.json"): BaseTuringMachine {
    try {
      let filePath = FileUtil.getFilesDirPath(dirPath, fileName);
      console.log('filePath:',filePath);
      let readTextOptions: ReadTextOptions = {
        offset: 0,
        length: 0,
        encoding: 'utf-8'
      };
      let stat = fs.statSync(filePath);
      readTextOptions.length = stat.size;
      let bufferStr = fs.readTextSync(filePath, readTextOptions);
      return BaseTuringMachine.deserialize(bufferStr);
    } catch (err) {
      let error =err as BusinessError;
      console.error(`BaseTuringMachine-loadFromFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to load TuringMachine from file');
    }
  }

  public static deserialize(TuringMachineJSON: string): BaseTuringMachine {
    try {
      const plainObject = plainToClass(BaseTuringMachine, JSON.parse(TuringMachineJSON), { exposeDefaultValues: true });

      if (plainObject === null) {
        console.error('Invalid JSON input for BaseTuringMachine');
      }

      // 嵌套对象从Object转为具体对象
      plainObject.initialState = plainToClass(State, plainObject.initialState, { exposeDefaultValues: true });
      plainObject.currentState=plainToClass(State, plainObject.currentState, { exposeDefaultValues: true });

      // 手动将 Array 转换为 Set
      let states = new Set(plainObject.states);
      let transitions = new Set(plainObject.transitions);
      plainObject.states = new Set<State>();
      plainObject.transitions = new Set<TuringTransition>();
      for (const state of states) {
        plainObject.states.add(plainToClass(State, state, { exposeDefaultValues: true } ));
      }
      for (const transition of transitions) {
        plainObject.transitions.add(plainToClass(TuringTransition, transition, { exposeDefaultValues: true }));
      }

      // 手动将Array 转换为 Map
      // Step 1: 将普通对象转为临时Map（键仍为string类型）
      const tempMap = new Map<string, string>(Object.entries(plainObject.tape));

      // Step 2: 创建目标Map（键为number）
      plainObject.tape = new Map<number, string>();

      // Step 3: 遍历临时Map并转换键类型（避免参数解构）
      tempMap.forEach((value, keyStr) => {
        const keyNum = Number(keyStr);
        if (!isNaN(keyNum)) { // 过滤无效键
          plainObject.tape.set(keyNum, value);
        }
      });
      return plainObject;
    } catch (err) {
      let error = err as BusinessError;
      console.error(`BaseTuringMachine-deserialize-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to deserialize BaseTuringMachine');
    }
  }


}

