import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import {NFA} from '../main/ets/function/NFA'
import { AutomatonCreator } from '../main/ets/test/AutomatonCreator'
import { easyFSA, minDFATestFSA, nfaToDFATestFSA, normalFSA } from '../main/ets/test/TestAutomaton';

export default function IsNFATest() {
  describe('IsNFATest', () => {
    it('easyFiniteStateAutomatonIsNFA', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = NFA.isNFA(AutomatonCreator.createFromDFA(easyFSA))
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertTrue()
    })
    it('normalFiniteStateAutomatonIsNotNFA', 0, () => {
      let a = NFA.isNFA(AutomatonCreator.createFromDFA(normalFSA))
      expect(a).assertFalse()
    })
    it('nfaToDfaTestAutomatonIsNFA', 0, () => {
      let a = NFA.isNFA(AutomatonCreator.createFromDFA(nfaToDFATestFSA))
      expect(a).assertTrue()
    })
    it('minDfaTestAutomatonIsNFA', 0, () => {
      let a = NFA.isNFA(AutomatonCreator.createFromDFA(minDFATestFSA))
      expect(a).assertFalse()
    })
  })
}