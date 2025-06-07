import { FSAAutomaton, compareAutomatons, createTestAutomaton } from 'shared'

@Entry
@Component
struct TestFile {
  @State result: string = 'Click the button to test'

  // 定义一个测试函数
  testFunction(): void {
    const automaton1 = createTestAutomaton()
    automaton1.saveToFile()

    const automaton2 = FSAAutomaton.loadFromFile()

    const comparisonResult = compareAutomatons(automaton1, automaton2)
    this.result = comparisonResult ? 'Automatons are equal' : 'Automatons are not equal'
  }

  build() {
    Column() {
      Text('This is the TestFile Page')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Center)

      // 显示测试结果
      Text(this.result)
        .fontSize(30)
        .alignSelf(ItemAlign.Center)
        .margin({ top: 20 })

      // 添加一个按钮用于测试
      Button('Run Test')
        .onClick(() => {
          this.testFunction()  // 调用测试函数并更新结果
        })
        .margin({ top: 20 })
        .alignSelf(ItemAlign.Center)
    }
    .height('100%')
    .width('100%')
  }
}
