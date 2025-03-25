import { State,AutomatonType, Const, SavedFile, DrawInvoker } from 'shared'
import {PDATransition} from './PDATransition'
import 'reflect-metadata';
import { Uuid } from 'shared/src/main/ets/automaton/function/Uuid'
import { instanceToPlain } from 'class-transformer';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '@pura/harmony-utils';

export interface History {
  currentState: State | null;   // 当前状态
  inputIndex: number;       // 当前输入的索引位置
  currentStack: string[];          // 栈的当前内容
}
export class PDAAutomaton<S extends State, T extends PDATransition> {
  // 唯一标识
  readonly uuid: number;
  // 自动机下所有状态
  protected states: Set<S>;
  // 自动机下所有转移
  protected transitions: Set<T>;
  //栈用于保存中间符号，支持入栈、出栈等操作。


  protected currentStack: string[] = [];
  //输入字符串
  protected input: string = "";
  //当前输入字符位置指针
  protected inputIndex: number = 0;
  protected currentState: S | null;
  // 存储所有符号（包括输入符号、栈符号和转移符号）
  protected alphabet: Set<string> = new Set();
  //protected historyStack: History[] = [];


  // 自动机的初始状态
  initialState: S | null;
  note: string;
  type: AutomatonType;
  name: string;
  update: boolean;

  constructor() {
    this.uuid =Uuid.index;
    this.note = "";
    this.type = AutomatonType.PDA;
    this.name = "PDAAutomaton";
    this.states = new Set<S>();
    this.transitions = new Set<T>();
    this.initialState = null;
    this.currentState = null;
    this.update = false;
  }

  public initializeInput(input: string): void {
    this.input = input;
    this.inputIndex = 0;
    this.currentStack = ['Z']; // 初始栈底符号
    this.currentState = this.initialState;
  }

  // 添加一个函数来初始化字母表
  private initializeAlphabet(): void {
    // 遍历所有转移并将其中的符号加入到字母表
    this.transitions.forEach(transition => {
      // 读取符号
      if (transition.readSymbol !== 'ε') {
        this.alphabet.add(transition.readSymbol);
      }
      // 弹出符号
      if (transition.popSymbol !== 'ε') {
        this.alphabet.add(transition.popSymbol);
      }
      // 推入符号
      if (transition.pushSymbol !== 'ε') {
        this.alphabet.add(transition.pushSymbol);
      }
    });
    // 将数组转成逗号分隔的字符串打印
    console.log("打印字母表", Array.from(this.alphabet).join(', '));

  }

  public getAlphabet(): Set<string> {
    return new Set(Array.from(this.alphabet));
  }

  public getCurrentSymbol(): string {
    return this.input[this.inputIndex] ?? 'ε';
  }

  public getRestSymbol(): string {
    return this.input.slice(this.inputIndex) ?? 'ε';
  }

  protected pushStack(symbols: string): void {
    if (symbols[0] !== 'ε' && symbols.length !== 0) {
      this.currentStack.push(symbols[0]);
    }
  }


  protected popStack(): string {
    return this.currentStack.pop() ?? 'ε';
  }

  // 回溯历史
  private restoreHistory(backup: History): void {
    this.currentState = backup.currentState as S;
    this.inputIndex = backup.inputIndex;
    this.currentStack = backup.currentStack;
  }

  public recursiveRun(): boolean {
    // 提前终止检查
    if (!this.currentState) return false;
    // 如果输入已读完，且当前状态是终止状态，且栈顶是初始符号 Z，则接受
    if (
      this.inputIndex >= this.input.length &&
        this.currentState?.isFinal &&
        this.currentStack.length === 1 &&
        this.currentStack[0] === 'Z'
    ) {
      return true;
    }

    const currentInput = this.getCurrentSymbol();
    const stackTop = this.currentStack[this.currentStack.length - 1] ?? 'ε';

    const transitions = this.getTransitions().filter(t =>
    t.from === this.currentState!.uuid &&
      (t.readSymbol === currentInput || t.readSymbol === 'ε') &&
      (t.popSymbol === stackTop || t.popSymbol === 'ε')
    );

    for (const transition of transitions) {
      // 1. 保存当前状态用于回溯
      const backup: History = {
        currentState: this.currentState,
        inputIndex: this.inputIndex,
        currentStack: [...this.currentStack],
      };
      // 2. 执行转移操作
      if (transition.readSymbol !== 'ε') {
        this.inputIndex++;
      }
      if (transition.popSymbol !== 'ε') {
        this.popStack();
      }
      if (transition.pushSymbol !== 'ε') {
        this.pushStack(transition.pushSymbol);
      }
      this.currentState = this.getStateWithUuid(transition.to);
      // 3. 递归尝试后续路径
      if (this.run()) {
        return true;
      }
      // 4. 回溯状态
      this.restoreHistory(backup);
    }
    return false;
  }

  public run(): boolean {
    // 提前终止检查
    if (!this.currentState) return false;

    // 使用栈来存储需要探索的状态
    const stateStack: History[] = [];

    // 开始探索
    while (true) {
      // 检查是否达到接受状态
      if (
        this.inputIndex >= this.input.length &&
          this.currentState?.isFinal &&
          this.currentStack.length === 1 &&
          this.currentStack[0] === 'Z'
      ) {
        return true;
      }

      const currentInput = this.getCurrentSymbol();
      const stackTop = this.currentStack[this.currentStack.length - 1] ?? 'ε';

      // 获取所有可能的转移
      const transitions = this.getTransitions().filter(t =>
      t.from === this.currentState!.uuid &&
        (t.readSymbol === currentInput || t.readSymbol === 'ε') &&
        (t.popSymbol === stackTop || t.popSymbol === 'ε')
      );

      // 如果没有可用的转移，回溯到上一个状态
      if (transitions.length === 0) {
        if (stateStack.length === 0) {
          // 没有更多状态可以回溯，拒绝输入
          return false;
        }

        // 回溯到上一个状态
        const lastState = stateStack.pop()!;
        this.currentState = lastState.currentState as S;
        this.inputIndex = lastState.inputIndex;
        this.currentStack = lastState.currentStack;
        continue;
      }

      // 取出第一个转移进行尝试，其余转移保存到栈中以备后续回溯
      const currentTransition = transitions[0];

      // 对于其余转移，保存当前状态到栈中
      for (let i = 1; i < transitions.length; i++) {
        stateStack.push({
          currentState: this.currentState,
          inputIndex: this.inputIndex,
          currentStack: [...this.currentStack]
        });
      }

      // 执行当前转移
      if (currentTransition.readSymbol !== 'ε') {
        this.inputIndex++;
      }
      if (currentTransition.popSymbol !== 'ε') {
        this.popStack();
      }
      if (currentTransition.pushSymbol !== 'ε') {
        this.pushStack(currentTransition.pushSymbol);
      }
      this.currentState = this.getStateWithUuid(currentTransition.to);
    }
  }


  public checkPDAEquivalence(automaton: PDAAutomaton<State, PDATransition>): boolean {
    // 1. 检查字母表是否等价
    const thisAlphabet = this.getAlphabet();
    const otherAlphabet = automaton.getAlphabet();

    console.log("当前自动机字母表:", thisAlphabet);
    console.log("对比自动机字母表:", otherAlphabet);

    // 检查字母表长度
    if (thisAlphabet.size !== otherAlphabet.size) {
      console.log("字母表长度不同，不等价");
      return false;
    }

    // 检查字母表内容
    for (const item of thisAlphabet) {
      if (!otherAlphabet.has(item)) {
        return false;
      }
    }

    // 2. 生成测试用例
    const testCases = this.generateTestCases(Array.from(this.alphabet));
    console.log("生成的测试用例:", testCases);

    // 3. 对每个测试用例，检查两个自动机是否给出相同的接受/拒绝结果
    for (const testCase of testCases) {
      // 重置并初始化当前自动机
      this.initializeInput(testCase);
      const thisResult = this.run();

      // 重置并初始化另一个自动机
      automaton.initializeInput(testCase);
      const otherResult = automaton.run();

      // 如果结果不同，则不等价
      if (thisResult !== otherResult) {
        console.log(`测试用例 "${testCase}" 结果不同：${thisResult} vs ${otherResult}`);
        return false;
      }
    }

    // 4. 如果所有测试都通过，则认为两个自动机是等价的
    console.log("所有测试用例都通过，自动机等价");
    return true;
  }

  // 辅助函数：生成测试用例
  private generateTestCases(alphabet: string[]): string[] {
    const testCases: string[] = [''];  // 空字符串

    // 如果字母表为空，只返回空字符串
    if (alphabet.length === 0) {
      return testCases;
    }

    // 1. 单个字符
    for (const symbol of alphabet) {
      testCases.push(symbol);
    }

    // 2. 两个字符的组合
    for (const symbol1 of alphabet) {
      for (const symbol2 of alphabet) {
        testCases.push(symbol1 + symbol2);
      }
    }

    // 3. 三个字符的组合（抽样）
    // 避免生成所有组合，只选择一部分
    const maxSamples = 20;  // 最多生成20个三字符样本
    const totalCombinations = Math.pow(alphabet.length, 3);
    const sampleInterval = Math.max(1, Math.floor(totalCombinations / maxSamples));

    for (let i = 0; i < totalCombinations; i += sampleInterval) {
      const index1 = Math.floor(i / (alphabet.length * alphabet.length)) % alphabet.length;
      const index2 = Math.floor(i / alphabet.length) % alphabet.length;
      const index3 = i % alphabet.length;

      testCases.push(alphabet[index1] + alphabet[index2] + alphabet[index3]);
    }

    // 4. 特殊模式
    // 重复
    if (alphabet.length > 0) {
      testCases.push(alphabet[0] + alphabet[0]);
      testCases.push(alphabet[0] + alphabet[0] + alphabet[0]);
    }

    // 如果字母表有多个字符
    if (alphabet.length > 1) {
      // 交替
      testCases.push(alphabet[0] + alphabet[1] + alphabet[0] + alphabet[1]);
      // 回文
      testCases.push(alphabet[0] + alphabet[1] + alphabet[1] + alphabet[0]);
      // 嵌套
      testCases.push(alphabet[0] + alphabet[1] + alphabet[0]);
    }

    // 随机生成一些更长的字符串
    for (let i = 0; i < 5; i++) {
      let str = '';
      const length = 4 + i;  // 长度从4到8

      for (let j = 0; j < length; j++) {
        const randomIndex = Math.floor(Math.random() * alphabet.length);
        str += alphabet[randomIndex];
      }

      testCases.push(str);
    }

    return testCases;
  }


//----------------------------------------------------------------------

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
    if (this.transitions.has(transition)) {
      return;
    }
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

  public getStateWithUuid(uuid: number): S | null {
    for (const state of this.states) {
      if (state.uuid === uuid) {
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

  public getTransitionsFromState(uuid: number): T[] {
    return this.getTransitions().filter((transition) => transition.from === uuid);
  }

  /** 验证状态是否有效 */
  private validateState(state: S): void {
    if (!this.states.has(state)) {
      throw new Error(`状态 ${state.name} 不属于当前图灵机`);
    }
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

  public setNote(note: string): void {
    this.note = note;
  }

  public setType(type: AutomatonType): void {
    this.type = type;
  }

  public setName(name: string): void {
    this.name = name;
  }
  //将对象序列化为 JSON 字符串
  public serialize(): string {
    try {
      return JSON.stringify(instanceToPlain(this));
    } catch (err) {
      let error = err as BusinessError;
      console.error(`BaseTuringMachine-beanToJsonStr-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return "";
    }
  }

  public saveToFile(dirPath: string = ""): void {
    try {
      let jsonStr = this.serialize();
      SavedFile.saveToFile(jsonStr, dirPath, this.name + Const.FILE_POSTFIX);
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`BaseAutomaton-saveToFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }

  //----------------------------------------------------------------------

  public static getAutomaton(draw: DrawInvoker): PDAAutomaton<State, PDATransition>{
    const pda = new PDAAutomaton();
    draw.stateMap.forEach((states) => {
      const drawState = states[states.length - 1];
      const newState = State.deepCopy(drawState.state)
      pda.addState(newState);
      if (drawState.isInitialState){
        pda.initialState = newState;
      }
    });
    draw.transitionMap.forEach((transitions) => {
      transitions.forEach((transition) => {
        pda.addTransition(new PDATransition(transition.fromState.uuid, transition.toState.uuid, transition.label[0],transition.label[2],transition.label[4]));
      })
    });
    pda.initializeAlphabet();
    return pda;
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




}
