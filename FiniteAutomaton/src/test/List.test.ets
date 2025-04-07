import minDFATest from './minDFA.test'
import nfaToDFATest from './nfaToDFA.test'
import takeClosureTest from './takeClosure.test'
import IsNFATest from './IsNFA.test'
import simulateTest from './simulate.test';

export default function testsuite() {
  simulateTest();
  IsNFATest()
  takeClosureTest()
  nfaToDFATest()
  minDFATest()
}