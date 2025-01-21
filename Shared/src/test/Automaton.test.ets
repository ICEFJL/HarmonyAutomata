import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { State } from '../main/ets/automaton/State'
import { Transition } from '../main/ets/automaton/Transition'
import { LogUtil, DateUtil } from '@pura/harmony-utils';
import { BaseAutomaton, compareAutomatons, createTestAutomaton } from '../main/ets/automaton/Example/BaseAutomaton'

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
      const deserializedAutomaton = BaseAutomaton.deserialize(automatonJSON);

      // 验证反序列化后的自动机是否与原始自动机一致
      expect(compareAutomatons(automaton, deserializedAutomaton)).assertTrue();
    })
  })
}
