import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { FSA } from '../main/ets/function/FSA'
import { NFA } from '../main/ets/function/NFA'
import { AutomatonCreator } from '../main/ets/test/AutomatonCreator'
import { easyFSA, minDFATestFSA, nfaToDFATestFSA, normalFSA } from '../main/ets/test/TestAutomaton';
import { nfaToDFATestFSA_RES, minimizedNormalFSA, minDFATestFSA_RES } from '../main/ets/test/TestResultAutomaton';

export default function nfaToDFATest() {
  describe('nfaToDFATest', () => {
    it('assertEqual', 0, () => {
      let a = NFA.toDFA(AutomatonCreator.createFromDFA(nfaToDFATestFSA));
      let b = AutomatonCreator.createFromDFA(nfaToDFATestFSA_RES);
      expect(FSA.isEqual(a, b)).assertEqual(true);
    })
  })
}