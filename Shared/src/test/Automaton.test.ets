import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { State } from '../main/ets/automaton/State'
import { Transition } from '../main/ets/automaton/Transition'
import { LogUtil, DateUtil } from '@pura/harmony-utils';
import { FSAAutomaton, compareAutomatons, createTestAutomaton } from '../main/ets/automaton/example/FSAAutomaton'

export default function AutomatonTest() {
  describe('AutomatonTest', () => {
    it('assertEqual', 0, () => {
      let time = DateUtil.getTodayTime()
      console.info("time:", time);

      // 序列化自动机
      const automaton = createTestAutomaton()
      const automatonJSON = automaton.serialize()
      console.info("Serialized Automaton:", automatonJSON);

      // 反序列化自动机
      const deserializedAutomaton = FSAAutomaton.deserialize(automatonJSON);

      // 验证反序列化后的自动机是否与原始自动机一致
      expect(compareAutomatons(automaton, deserializedAutomaton)).assertTrue();
    })
    it('testUniqueUUIDGeneration', 0, () => {
      let states: State[] = [];
      for (let i = 0; i < 10000; i++) {
        const state = new State();
        states.push(state);
        // console.info("UUID:", state.uuid);
      }

      // 收集所有UUID
      const uuids = states.map(state => state.uuid);

      // 检查是否有重复UUID（Set去重后的长度应等于原始数组长度）
      expect(uuids.length === new Set(uuids).size).assertTrue();
    });
  })
}
