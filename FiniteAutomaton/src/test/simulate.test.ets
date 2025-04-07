import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { simulateFSA } from 'shared/src/main/ets/automaton/fsa/simulateFSA';
import { AutomatonCreator } from '../main/ets/test/AutomatonCreator';
import { easyFSA, minDFATestFSA, nfaToDFATestFSA, normalFSA } from '../main/ets/test/TestAutomaton';
import { nfaToDFATestFSA_RES, minimizedNormalFSA, minDFATestFSA_RES } from '../main/ets/test/TestResultAutomaton';

export default function simulateTest() {
  describe('simulateTest', () => {
    it('simulate', 0, () => {
      let a = simulateFSA(AutomatonCreator.createFromDFA(easyFSA), 'b');
      expect(a.accepted).assertEqual(false);
    });
    it('simulate2', 0, () => {
      let a = simulateFSA(AutomatonCreator.createFromDFA(easyFSA), '');
      expect(a.accepted).assertEqual(true);
    });
    it('simulate3', 0, () => {
      let a = simulateFSA(AutomatonCreator.createFromDFA(easyFSA), '01');
      expect(a.accepted).assertEqual(false);
    });
    it('simulate4', 0, () => {
      let a = simulateFSA(AutomatonCreator.createFromDFA(normalFSA), '000000000101');
      expect(a.accepted).assertEqual(true);
    });
    it('simulate5', 0, () => {
      let a = simulateFSA(AutomatonCreator.createFromDFA(nfaToDFATestFSA), 'aaab');
      expect(a.accepted).assertEqual(true);
    });
    it('simulate6', 0, () => {
      let a = simulateFSA(AutomatonCreator.createFromDFA(minDFATestFSA), 'baba');
      expect(a.accepted).assertEqual(false);
    });
  });
}