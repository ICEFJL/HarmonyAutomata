import { State,AutomatonType,DrawInvoker,DrawState,DrawTransition,IDraw,SavedFile,Const, DrawType} from 'shared'
import {TuringTransition} from './TuringTransition'
import {LogUtil} from '@pura/harmony-utils';
import {TuringMachine} from './TuringMachine'
import 'reflect-metadata';
import { Type as ClzTransType, instanceToPlain, plainToClass } from 'class-transformer';
import { BusinessError } from '@kit.BasicServicesKit';
import {StepLog,TuringResult} from './runResultLog'
import { TuringError } from './TuringError'

export class BaseTuringMachine extends TuringMachine<State, TuringTransition> {
  constructor() {
    super(AutomatonType.TM);
  }

  public drawTM(draw: DrawInvoker) {
    let drawArray: Array<IDraw> = [];
    const states = this.getStates();
    for (const state of states) {
      if (state.uuid == this.initialState?.uuid) {
        draw.initialState = new DrawState(state, true);
        drawArray.push(draw.initialState);
      } else {
        drawArray.push(new DrawState(state, false));
      }
    }
    const transitions = this.getTransitions();
    for (const transition of transitions) {
      const label = transition.label;
      const fromState = this.getStateWithUuid(transition.from);
      const toState = this.getStateWithUuid(transition.to);
      if (!fromState || !toState) {
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

  public static getTuringMachine(draw: DrawInvoker): BaseTuringMachine{
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
      for(let i=0;i < transitions.length;i++){
        const transition = transitions[i];
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

  public createExample(): BaseTuringMachine {
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
    tm.initialState=q0;
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

  public runTuringMachine(): void {
    console.log("Initial Tape:", this.getCurrentTape());
    console.log("Head Position:", this.headPosition);
    console.log("CurrentSymbol:", this.getCurrentSymbol());

    let stepCount = 0;
    console.log(`Step ${++stepCount}:`);
    try {
      while (this.step()) {
        console.log(`Step ${++stepCount}:`);
        console.log("Head Position:", this.headPosition);
        console.log("Current Symbol:", this.getCurrentSymbol());
        console.log("Tape:", this.getCurrentTape());
        console.log("-------------------");
      }
    } catch (e) {
      console.error("执行异常:", e);
      throw new Error('Failed to run TuringMachine');
    }

    console.log("Final Tape:", this.getCurrentTape());
  }

  public serialize(): string {
    try {
      return JSON.stringify(instanceToPlain(this));
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`BaseTuringMachine-beanToJsonStr-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return "";
    }
  }

  public saveToFile(dirPath: string = ""): void {
    try {
      let jsonStr = this.serialize();
      console.log("json文件内容：" + jsonStr);
      SavedFile.saveToFile(jsonStr, dirPath, this.name + Const.FILE_POSTFIX);
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`BaseTuringMachine-saveToFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }


  public static loadFromFile(dirPath: string = "", fileName: string = "test"): BaseTuringMachine {
    try {
      let bufferStr = SavedFile.loadFromFile(dirPath, fileName + Const.FILE_POSTFIX);
      return BaseTuringMachine.deserialize(bufferStr);
    } catch (err) {
      let error =err as BusinessError;
      LogUtil.error(`BaseTuringMachine-loadFromFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
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

  //去除字符串尾部连续ε和[]
  public getFinalTape(str: string): string {
    // 删除所有 [...] 块（包括括号）
    // 使用正则表达式匹配非贪婪模式的 [...] 内容
    str = str.replace(/\[.*?\]/g, '');

    // 去除尾部连续 ε
    let end = str.length - 1;
    while (end >= 0 && str.charAt(end) === 'ε') {
      end--;
    }
    return str.substring(0, end + 1);
  }

  //图灵机错误检测
  private _validateStateSystem(): void {
    // 1. 空状态集合检测
    if (this.states.size === 0) {
      throw new Error(TuringError.EmptyStateSet); // EmptyStateSet
    }

    // 2. 初始状态检测
    if (!this.initialState) {
      throw new Error(TuringError.NoInitialState); // NoInitialState
    }

    // 3. 状态名称唯一性
    const nameSet = new Set<string>();
    this.states.forEach(state => {
      if (nameSet.has(state.name)) {
        throw new Error(TuringError.DuplicateState + " " + state.name); // DuplicateState
      }
      nameSet.add(state.name);
    });

    // 4. 终态可达性（BFS实现）
    this._validateFinalStatesReachable();


  }

  private _validateFinalStatesReachable(): void {
    // 获取所有终态集合（需至少存在一个终态）
    const finalStates = Array.from(this.states).filter(s => s.isFinal);
    if (finalStates.length === 0) {
      throw new Error(TuringError.NoFinalState); // 终态集合为空错误
    }

    // BFS遍历初始化（使用状态UUID作为唯一标识）
    const visited = new Set<number>();
    const queue: number[] = [this.initialState!.uuid];

    // 广度优先搜索路径探测
    while (queue.length > 0) {
      const currentId = queue.shift()!;
      if (visited.has(currentId)) {
        continue;
      }
      visited.add(currentId);

      // 发现可达终态立即终止验证
      if (finalStates.some(fs => fs.uuid === currentId)) {
        return;
      }

      // 收集当前状态所有出边目标状态
      this.getTransitionsFromState(currentId).forEach(t => {
        if (!visited.has(t.to)) {
          queue.push(t.to);
        }
      });
    }

    // 遍历完成仍未发现可达终态
    throw new Error(TuringError.UnreachableFinalState);
  }

  private _validateSymbolSystem(): void {
    // 1. 收集合法符号集（含转移规则中的读写符号和空白符）
    const validSymbols = new Set<string>();
    this.transitions.forEach(t => {
      validSymbols.add(t.readSymbol);
      validSymbols.add(t.writeSymbol);
    });
    validSymbols.add(this.blank);

    // 2. 验证纸带符号是否合法
    this.tape.forEach((symbol, pos) => {
      if (!validSymbols.has(symbol)) {
        throw new Error("纸带" + TuringError.UndefinedSymbol + `"${symbol}"`);
      }
    });

    // 3. 验证转移规则中的符号合法性（防御性编程）
    this.transitions.forEach(t => {
      if (!validSymbols.has(t.readSymbol)) {
        throw new Error(`转移规则 ${t.label} 读取符号 "${t.readSymbol}" 未定义`);
      }
      if (!validSymbols.has(t.writeSymbol)) {
        throw new Error(`转移规则 ${t.label} 写入符号 "${t.writeSymbol}" 未定义`);
      }
    });
  }


  //存储单带图灵机仿真过程
  public runResultLog(): TuringResult {
    const logEntries: StepLog[] = []; // 显式声明数组类型[3](@ref)
    let stepCount = 0;

    try {
      //状态预检测
      this._validateStateSystem();
      this._validateSymbolSystem();
      // 记录初始状态（step 0）
      logEntries.push({
        step: stepCount,
        currentState:this.getCurrentStateName(),
        transition:this.getCurrentTransitionName(),
        head: this.headPosition,
        tape: this.getCurrentTape()
      });

      console.log(`Step ${stepCount}:`);
      console.log("Initial Tape:", this.getCurrentTape());
      console.log("Head Position:", this.headPosition);
      console.log("CurrentSymbol:", this.getCurrentSymbol());

      // 执行状态转换
      while (this.step()) {
        stepCount++;
        logEntries.push({
          step: stepCount,
          head: this.headPosition,
          currentState:this.getCurrentStateName(),
          transition: this.getCurrentTransitionName(),
          tape: this.getCurrentTape()
        });
        if (stepCount > this.maxStep) {
          throw new Error(TuringError.MaxStepExceeded);
        }
        if (this.tape.size > this.maxTape) {
          throw new Error(TuringError.TapeOverflow);
        }
        console.log(`Step ${stepCount}:`);
        console.log("Head Position:", this.headPosition+1);
        console.log("Current Symbol:", this.getCurrentSymbol());
        console.log("Tape:", this.getCurrentTape());
        console.log("-------------------");
      }
    } catch (e) {
      const err = e as Error;
      return {
        logs: logEntries,
        error: ` ${err}`, // 错误信息格式化
        finalTape: this.getFinalTape(this.getCurrentTape()),
        finalStep:stepCount
      };
    }

    return {
      logs: logEntries,
      finalTape: this.getFinalTape(this.getCurrentTape()),
      finalStep:stepCount
    };

  }

}

