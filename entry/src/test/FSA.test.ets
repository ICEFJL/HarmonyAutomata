import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { DFA, NFA, FSA, simulateFSA, AutomatonCreator, NFAToDFATest} from 'shared'
import { easyFSA, minDFATestFSA, nfaToDFATestFSA, normalFSA } from '../main/ets/FiniteAutomaton/test/TestAutomaton';
import { nfaToDFATestFSA_RES, minimizedNormalFSA, minDFATestFSA_RES } from '../main/ets/FiniteAutomaton/test/TestResultAutomaton';
function areSetsEqual(set1: Set<number>, set2: Set<number>): boolean {
  if (set1.size !== set2.size) {
    return false;
  }
  for (let item of set1) {
    if (!set2.has(item)) {
      return false;
    }
  }
  return true;
}

export default function FSATest() {
  describe('nfaToDFATest', () => {
    it('convertNFAtoDFA', 0, () => {
      let a = NFA.toDFA(AutomatonCreator.createFromDFA(nfaToDFATestFSA));
      let b = AutomatonCreator.createFromDFA(nfaToDFATestFSA_RES);
      expect(FSA.isEqual(a, b)).assertEqual(true);
    })
    it('convertFirstSampleNFAtoDFA', 0, () => {
      let a = NFA.toDFA(AutomatonCreator.createFromDFA(NFAToDFATest.nfa[0]));
      let b = AutomatonCreator.createFromDFA(NFAToDFATest.dfa[0]);
      expect(FSA.isEqual(a, b)).assertEqual(true);
    })
    it('convertSecondSampleNFAtoDFA', 0, () => {
      let a = NFA.toDFA(AutomatonCreator.createFromDFA(NFAToDFATest.nfa[1]));
      let b = AutomatonCreator.createFromDFA(NFAToDFATest.dfa[1]);
      expect(FSA.isEqual(a, b)).assertEqual(true);
    })
  })
  describe('IsNFATest', () => {
    it('easyFiniteStateAutomatonIsNFA', 0, () => {
      let a = NFA.isNFA(AutomatonCreator.createFromDFA(easyFSA))
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

  describe('minDFATest', () => {
    it('minimizeNormalDFA', 0, () => {
      let a = DFA.minimize(AutomatonCreator.createFromDFA(normalFSA))
      let b = AutomatonCreator.createFromDFA(minimizedNormalFSA);
      expect(FSA.isEqual(a, b)).assertEqual(true);
    })
    it('minimizeSampleDFA', 0, () => {
      let a = DFA.minimize(AutomatonCreator.createFromDFA(minDFATestFSA))
      let b = AutomatonCreator.createFromDFA(minDFATestFSA_RES);
      expect(FSA.isEqual(a, b)).assertEqual(true);
    })
  })

  describe('takeClosureTest', () => {
    it('testClosure_s0', 0, () => {
      let a = AutomatonCreator.createFromDFA(easyFSA);
      let res: string[] = ['s0', 's1'];
      let resSet: Set<number> = new Set<number>();
      for (const s of res) {
        resSet.add(a.getStateWithName(s)!.uuid);
      }
      let input = NFA.getClosure(a.getStateWithName('s0')!.uuid, a);
      expect(areSetsEqual(resSet, input)).assertTrue();
    })
    it('testClosure_s1', 0, () => {
      let a = AutomatonCreator.createFromDFA(nfaToDFATestFSA);
      let res: string[] = ['s0', 's1', 's2', 's4', 's7'];
      let resSet: Set<number> = new Set<number>();
      for (const s of res) {
        resSet.add(a.getStateWithName(s)!.uuid);
      }
      let input = NFA.getClosure(a.getStateWithName('s0')!.uuid, a);
      expect(areSetsEqual(input, resSet)).assertEqual(true);
    })
    it('testClosure_s3', 0, () => {
      let a = AutomatonCreator.createFromDFA(nfaToDFATestFSA);
      let res: string[] = ['s3', 's6', 's7', 's1', 's2', 's4'];
      let resSet: Set<number> = new Set<number>();
      for (const s of res) {
        resSet.add(a.getStateWithName(s)!.uuid);
      }
      let input = NFA.getClosure(a.getStateWithName('s3')!.uuid, a);
      expect(areSetsEqual(input, resSet)).assertEqual(true);
    })
  })
}