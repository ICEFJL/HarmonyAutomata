import takeClosureTest from './takeClosure.test'
import IsNFATest from './IsNFA.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  IsNFATest()
  takeClosureTest()
}