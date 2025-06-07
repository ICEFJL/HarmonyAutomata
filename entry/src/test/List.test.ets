import FSATest from './FSA.test';
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  FSATest()
}