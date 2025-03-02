import { LogUtil, DateUtil, FileUtil } from '@pura/harmony-utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { State } from './State'
import { Transition } from './Transition'
import { AutomatonType } from './Type'
import { Type as ClzTransType, instanceToPlain, plainToClass } from 'class-transformer';
import 'reflect-metadata';

export abstract class Automaton<S extends State, T extends Transition> {
  // 唯一标识
  readonly uuid: number;

  // 自动机下所有状态
  protected states: Set<S>;

  // 自动机下所有转移
  protected transitions: Set<T>;

  // 自动机的初始状态
  initialState: S | null;

  note: string;

  type: AutomatonType;

  name: string;

  constructor(type: AutomatonType) {
    this.uuid = DateUtil.getTodayTime();
    this.note = "";
    this.type = type;
    this.name = "Automaton";
    this.states = new Set<S>();
    this.transitions = new Set<T>();
    this.initialState = null;
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
    if (this.isInitialState(state)) {
      this.initialState = null;
    }
    this.states.delete(state);
  }

  public addTransition(transition: T): void {
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

  public setInitialState(initialState: S | null): void {
    this.initialState = initialState;
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

  public serialize(): string {
    try {
      return JSON.stringify(instanceToPlain(this));
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`BaseAutomaton-beanToJsonStr-异常 ~ code: ${error.code} -·- message: ${error.message}`);
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
      LogUtil.error(`BaseAutomaton-saveToFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    }
  }
}
