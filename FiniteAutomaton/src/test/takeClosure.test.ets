import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { NFA } from '../main/ets/function/NFA';
import { AutomatonCreator } from '../main/ets/test/AutomatonCreator';
import { easyFSA, minDFATestFSA, nfaToDFATestFSA, normalFSA } from '../main/ets/test/TestAutomaton';
import { nfaToDFATestFSA_RES, minimizedNormalFSA, minDFATestFSA_RES } from '../main/ets/test/TestResultAutomaton';

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

export default function takeClosureTest() {
  describe('takeClosureTest', () => {
    it('assertEqual', 0, () => {
      let a = AutomatonCreator.createFromDFA(easyFSA);
      let res: string[] = ['s0', 's1'];
      let resSet: Set<number> = new Set<number>();
      for (const s of res) {
        resSet.add(a.getStateWithName(s)!.uuid);
      }
      let input = NFA.getClosure(a.getStateWithName('s0')!.uuid, a);
      expect(areSetsEqual(resSet, input)).assertTrue();
    })
    it('testClosure_s0', 0, () => {
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
