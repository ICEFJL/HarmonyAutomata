import { State, AutomatonType, Const } from 'shared'
import {TuringTransition} from './TuringTransition'
import 'reflect-metadata';
import { Uuid } from 'shared/src/main/ets/automaton/function/Uuid'
import { TuringError } from './TuringError'

export abstract class TuringMachine<S extends State, T extends TuringTransition> {
  // 唯一标识
  readonly uuid: number;
  // 自动机下所有状态
  protected states: Set<S>;
  // 自动机下所有转移
  protected transitions: Set<T>;
  // 稀疏存储纸带
  protected tape: Map<number, string> = new Map();
  // 读写头位置
  headPosition: number = 0;
  initialTape: string = "";
  // 空白符号
  protected blank: string = 'ε';
  protected currentTape: string = "";
  protected currentState: S | null;
  private currentTransition: T | null = null;
  //最大步数与simulateTM界面保持一致
  readonly maxStep: number = 1000;
  //纸带最大长度设为10000
  readonly maxTape: number = 10000;
  // 自动机的初始状态
  initialState: S | null;
  note: string;
  type: AutomatonType;
  name: string;
  update: boolean;

  constructor(type: AutomatonType.TM) {
    this.uuid =Uuid.index;
    this.note = "";
    this.type = type;
    this.name = "TuringMachine";
    this.states = new Set<S>();
    this.transitions = new Set<T>();
    this.initialState = null;
    this.blank = Const.EMPTY_STRING;
    this.tape = new Map<number, string>(); // 纸带Σ* (稀疏存储)
    this.headPosition = 0;
    this.initialTape = "";
    this.currentState = null;
    this.currentTape = "";
    this.update = false;
  }

  /** 验证状态是否有效 */
  private validateState(state: S): void {
    if (!this.states.has(state)) {
      throw new Error(`状态 ${state.name} 不属于当前图灵机`);
    }
  }

  private updateTapeString(): void {
    // 获取所有已存储的非空白符号位置
    const positions = Array.from(this.tape.keys());

    // 最小位置需包含当前读写头位置
    let minPos = Math.min(...positions, this.headPosition);
    let maxPos = Math.max(...positions, this.headPosition);

    // 判断右侧是否有非空白符号
    const hasRightSymbol = positions.some(pos => pos > this.headPosition);

    // 若右侧全为空白符，截断显示到当前头位置
    if (!hasRightSymbol) {
      maxPos = this.headPosition;
    }

    // 构建可视化字符串（状态名嵌入磁头位置，保留符号）
    let tapeStr = "";
    for (let pos = minPos; pos <= maxPos; pos++) {
      const symbol = this.tape.get(pos) || this.blank;

      if (pos === this.headPosition) {
        // 磁头位置显示状态名和符号
        const stateName = this.currentState?.name || "";
        tapeStr += `[${stateName}]`; // 状态名用方括号标记
        tapeStr += symbol; // 符号紧跟状态名显示
      } else {
        tapeStr += symbol;
      }
    }

    this.currentTape = tapeStr;
  }

  //tm七元组基本信息展示
  //状态集
  public showStates(): string {
    let showStr = "";
    for (const state of this.states) {
      if (state.name != "") {
        showStr = showStr + state.name + " ";
      }
    }
    return showStr;
  }

  //开始状态
  public showInitialState(): string {
    if (this.initialState != null) {
      return this.initialState.name;
    } else {
      return "NULL";
    }
  }

  //终止状态集
  public showFinalStates(): string {
    let showStr = "";
    for (const state of this.states) {
      if (state.isFinal) {
        showStr = showStr + state.name + " ";
      }
    }
    return showStr;
  }

  //带符号表
  public showSymbols(): string {
    const symbols = new Set<string>();
    for (const transition of this.transitions) {
      symbols.add(transition.readSymbol);
      symbols.add(transition.writeSymbol);
    }
    symbols.add(Const.EMPTY_STRING);
    const showStr = Array.from(symbols);
    return showStr.join(' ');
  }

  //空白符
  public showBlankSymbol(): string {
    return Const.EMPTY_STRING;
  }

  //输入字母表
  public showEnterSymbols(): string {
    const charArray = this.initialTape.split('');
    const uniqueCharSet = new Set<string>();
    for (const char of charArray) {
      uniqueCharSet.add(char);
    }
    const result = Array.from(uniqueCharSet);
    return result.join(' ');
  }

  //移动函数
  public showTransitions(): string[] {
    const strs = new Set<string>();
    for (const transition of this.transitions) {
      let str = "";
      const fromState = this.getStateWithUuid(transition.from);
      const toState = this.getStateWithUuid(transition.to);
      if (fromState != null && toState != null) {
        str =
          `δ(${fromState.name},${transition.readSymbol})=(${toState.name},${transition.writeSymbol},${transition.moveDirection})`;
        strs.add(str);
      }
    }
    return Array.from(strs);
  }


  public setNote(note: string): void {
    this.note = note;
  }

  public setType(type: AutomatonType): void {
    this.type = type;
  }

  public setName(name: string): void {
    this.name = name;
  }

  public getCurrentTransition(): T | null {
    return this.currentTransition;
  }

  public  getCurrentStateName():string{
    if(this.currentState==null){
      return "NULL";
    }
    else return this.currentState.name;
  }

  public  getCurrentTransitionName():string{
    if(this.currentTransition==null){
      return "NULL";
    }
    else{
      switch (this.currentTransition.moveDirection) {
        case 'L': // 左移逻辑
          return '读'+this.currentTransition.label[0]+'写'+this.currentTransition.label[2]+'左移'
        case 'R': // 右移逻辑
          return '读'+this.currentTransition.label[0]+'写'+this.currentTransition.label[2]+'右移'
        case 'S': // 不动
          return '读'+this.currentTransition.label[0]+'写'+this.currentTransition.label[2]+'不动'
        default:  // 处理其他方向（如不移动或无效输入）
          console.error("wrong moveDirection!");
          return "undefined";
      }
    }
  }

  /** 获取当前纸带可视化字符串 */
  public getCurrentTape(): string {
    return this.currentTape;
  }

  public getStateWithUuid(uuid: number): S | null {
    for (const state of this.states) {
      if (state.uuid === uuid) {
        return state;
      }
    }
    return null;
  }

  public getTransitionsFromState(uuid: number): T[] {
    return this.getTransitions().filter((transition) => transition.from === uuid);
  }

  public addStates(states: S[]): void {
    for (const state of states) {
      this.addState(state);
    }
  }

  public addState(state: S): void {
    this.states.add(state);
  }

  public removeState(state: S): void {
    // 清理关联转移
    this.transitions.forEach(t => {
      if (t.from === state.uuid || t.to === state.uuid) {
        this.transitions.delete(t);
      }
    });

    // 更新当前状态
    if (this.currentState?.equals(state)) {
      this.currentState = null;
    }

    if (this.isInitialState(state)) {
      this.initialState = null;
    }
    this.states.delete(state);
  }

  public addTransition(transition: T): void {
    const fromExists = Array.from(this.states).some(s => s.uuid === transition.from);
    const toExists = Array.from(this.states).some(s => s.uuid === transition.to);

    if (!fromExists || !toExists) {
      throw new Error(`无效转移规则：状态 ${transition.from} → ${transition.to} 不存在`);
    }
    console.log(transition.label);
    this.transitions.add(transition);
  }

  public getStateWithName(name: string): S | null {
    for (const state of this.states) {
      if (state.name === name) {
        return state;
      }
    }
    return null;
  }

  public addTransitions(transitions: T[]): void {
    for (const transition of transitions) {
      this.addTransition(transition);
    }
  }

  public removeTransition(transition: T): void {
    this.transitions.delete(transition);
  }

  public getTransitions(): T[] {
    return Array.from(this.transitions);
  }

  public getStates(): S[] {
    return Array.from(this.states);
  }

  public setInitialState(state: S | null): void {
    if (state) {
      this.validateState(state);
      this.initialState = state;
      this.currentState = state; // 重置时自动恢复
    } else {
      this.initialState = null;
      this.currentState = null;
    }
  }

  private isInitialState(state: S): boolean {
    return this.initialState !== null && this.initialState.equals(state);
  }

  /** 初始化纸带内容 */
  public initializeTape(input: string, startPosition: number = 0): void {
    this.initialTape = input;
    // 仅写入非空白符号
    input.split('').forEach((char, index) => {
      if (char !== this.blank) {
        this.tape.set(startPosition + index, char);
      }
    });
    this.updateTapeString();

  }

  /** 获取当前读写头位置的符号 */
  public getCurrentSymbol(): string {
    return this.tape.get(this.headPosition) || this.blank;
  }

  /** 执行单步计算 */
  public step(): boolean {

    console.log(`[Step Debug] 当前状态: ${this.currentState?.name}, 符号: ${this.getCurrentSymbol()}`);
    // 检查是否处于终止状态
    if (this.currentState?.isFinal) {
      console.log("find Final state:",this.currentState.name);
      return false;
    }

    // 初始化当前状态
    if (!this.currentState && this.initialState) {
      this.currentState = this.initialState;
    }

    if (!this.currentState) {
      console.log("当前状态为空，尝试初始化");
      return false;
    }

    const currentSymbol = this.getCurrentSymbol();
    const validTransitions = Array.from(this.transitions).filter(t =>
    t.from === this.currentState!.uuid &&
      t.readSymbol === currentSymbol
    );

    console.log(`[Step Debug] 找到有效转移规则: ${validTransitions.length} 条`);
    console.log("转移规则列表:");
    validTransitions.forEach(t => {
      console.log(`从 ${t.from} 读 ${t.readSymbol} → 到 ${t.to} 写 ${t.writeSymbol} 方向 ${t.moveDirection}`);
    });
    // 确定型检查：必须恰好一个转移
    if (validTransitions.length == 0) {
      console.log('当前状态无转移函数');
      throw new Error(TuringError.MissingTransition);
    }
    if (validTransitions.length != 1) {
      console.log('不符合转移函数确定性要求，图灵机终止');
      throw new Error(TuringError.NonDeterministicConflict);
    }

    const transition = validTransitions[0];
    this.currentTransition = transition; // 记录当前转移规则

    // 执行转移操作
    // 写入逻辑
    if (transition.writeSymbol !== this.blank) {
      this.tape.set(this.headPosition, transition.writeSymbol);
    } else {
      // 写入空白符号时删除存储项（恢复默认）
      this.tape.delete(this.headPosition);
    }
    switch (transition.moveDirection) {
      case 'L': // 左移逻辑
        this.headPosition -= 1;
        break;
      case 'R': // 右移逻辑
        this.headPosition += 1;
        break;
      case 'S': // 不动
        break;
      default:  // 处理其他方向（如不移动或无效输入）
        throw new Error(TuringError.InvalidMoveDirection);
    }
    const newState = Array.from(this.states).find(s => s.uuid === transition.to);
    this.currentState = newState || null;

    this.updateTapeString();

    return true;
  }


  /** 完全重置计算状态 */
  public reset(): void {
    this.currentTransition = null;
    this.currentState = this.initialState;
    this.headPosition = 0;
    this.tape.clear();
    this.initialTape = "";
  }

}