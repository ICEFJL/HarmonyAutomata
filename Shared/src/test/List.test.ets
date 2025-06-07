import AutomatonTest from './Automaton.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  AutomatonTest()
}