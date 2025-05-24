import { Automaton,State,Transition,AutomatonType } from 'shared';
import { LogUtil, FileUtil } from '@pura/harmony-utils';
import {BaseAutomaton} from '../datastructure/BaseAutomaton';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
import { Type as ClzTransType, instanceToPlain, plainToClass } from 'class-transformer';
import 'reflect-metadata';

export function InitAutomaton(): BaseAutomaton {
  // 创建自动机实例
  const automaton = new BaseAutomaton();

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
    new Transition(q1.uuid, q1.uuid, "a"),
  ]);

  return automaton;
}
