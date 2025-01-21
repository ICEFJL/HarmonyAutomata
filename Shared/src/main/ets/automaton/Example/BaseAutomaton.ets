import { Automaton } from '../Automaton';
import { State } from '../State';
import { Transition } from '../Transition';
import { LogUtil, FileUtil } from '@pura/harmony-utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
import { AutomatonType } from '../Type'
import { Type as ClzTransType, instanceToPlain, plainToClass } from 'class-transformer';
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
}

export function createTestAutomaton(): BaseAutomaton {
  // 创建一个自动机实例
  const automaton = new BaseAutomaton()

  // 创建并添加状态
  const state1 = new State();
  const state2 = new State();
  const state3 = new State();
  state1.setName("State 1");
  state2.setName("State 2");
  state3.setName("State 3");
  state1.setPosition(0, 0);
  state2.setPosition(100, 100);
  state3.setPosition(200, 200);
  automaton.addStates([state1, state2, state3]);

  // 设置初始状态
  automaton.setInitialState(state1);

  // 创建并添加转移
  const transition1 = new Transition(state1.uuid, state2.uuid);
  transition1.setLabel("a");
  automaton.addTransition(transition1);

  const transition2 = new Transition(state2.uuid, state3.uuid);
  transition2.setLabel("b");
  automaton.addTransition(transition2);

  return automaton;
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