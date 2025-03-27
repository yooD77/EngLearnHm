import CirclePageTest from './CirclePage.test'
import PracticePageTest from './PracticePage.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  PracticePageTest()
  CirclePageTest()
}