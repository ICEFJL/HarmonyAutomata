import AutomatonCheckerTestTest from './AutomatonCheckerTest.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  AutomatonCheckerTestTest()
}