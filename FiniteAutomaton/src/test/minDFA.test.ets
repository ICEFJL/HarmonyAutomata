import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { DFA } from '../main/ets/function/DFA'
import { FSA } from '../main/ets/function/FSA'
import { AutomatonCreator } from '../main/ets/test/AutomatonCreator'
import { easyFSA, minDFATestFSA, nfaToDFATestFSA, normalFSA } from '../main/ets/test/TestAutomaton';
import { nfaToDFATestFSA_RES, minimizedNormalFSA, minDFATestFSA_RES } from '../main/ets/test/TestResultAutomaton';

export default function minDFATest() {
  describe('minDFATest', () => {
    it('assertEqual', 0, () => {
      let a = DFA.minimize(AutomatonCreator.createFromDFA(normalFSA))
      let b = AutomatonCreator.createFromDFA(minimizedNormalFSA);
      expect(FSA.isEqual(a, b)).assertEqual(true);
    })
    it('assertEqual2', 0, () => {
      let a = DFA.minimize(AutomatonCreator.createFromDFA(minDFATestFSA))
      let b = AutomatonCreator.createFromDFA(minDFATestFSA_RES);
      expect(FSA.isEqual(a, b)).assertEqual(true);
    })
  })
}