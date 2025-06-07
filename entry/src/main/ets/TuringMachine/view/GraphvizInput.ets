import { State } from "shared";
import { BaseTuringMachine } from '../model/BaseTuringMachine'
import { TuringTransition } from '../model/TuringTransition'

@CustomDialog
@Component
export struct GraphvizInput {
  @Consume title: string;
  @Consume tm: BaseTuringMachine;
  info: string = '';
  openExample: Function = () => {
  };
  import: Function = () => {
  };
  automaton = new BaseTuringMachine();
  statesMap = new Map<string, State>();
  private controller: CustomDialogController;

  parseGraphvizInput(input: string): BaseTuringMachine {
    // 创建一个新的图灵机实例
    this.automaton = new BaseTuringMachine();
    // 将输入按行分割
    const lines = input.split('\n');
    // 创建一个映射来存储状态
    this.statesMap = new Map<string, State>();
    // 存储初始状态的名称
    let initialStates: string[] = [];

    // 定义表达式（需要根据实际需求调整）
    const IS_INIT_EX = RegExp(/\s*q->(q\d*)/);
    const IS_FINAL_EX = RegExp(/\s*(q\d*)\[shape=doublecircle\]/);
    const TRANS_EX = RegExp(/\s*(q\d*)->(q\d*)(\[label="(.*)"\])/);

    lines.forEach(line => {
      line = line.trim();
      line = line.replace(/\s+/g, ''); // 去掉所有空白字符
      if (!line || line.startsWith("//")) {
        return;
      }

      // 处理初始状态
      const initMatch = line.match(IS_INIT_EX);
      if (initMatch) {
        console.log("初始状态" + initMatch[1]);
        initialStates.push(initMatch[1]);
        return;
      }

      // 处理终态
      const finalMatch = line.match(IS_FINAL_EX);
      if (finalMatch) {
        console.log("最终状态" + finalMatch[1]);
        const name = finalMatch[1];
        // 确保状态存在，如果不存在则创建
        this.ensureStateExists(name).isFinal = true;
        return;
      }

      // 处理转移
      const transMatch = line.match(TRANS_EX);
      if (transMatch) {
        const fromName = transMatch[1];
        const toName = transMatch[2];
        const label = transMatch[4] || "";
        const fromState = this.ensureStateExists(fromName);
        const toState = this.ensureStateExists(toName);
        if (label[4] != 'R' && label[4] != 'S' && label[4] != 'L') {
          throw new Error("Wrong direction");
        }
        const transition = new TuringTransition(fromState.uuid, toState.uuid, label[0], label[2], label[4]);
        this.automaton.addTransition(transition);
      }

    });

    // 设置初始状态
    if (initialStates.length > 0) {
      const initialState = this.statesMap.get(initialStates[0]);
      if (initialState) {
        this.automaton.setInitialState(initialState);
      }
    }

    return this.automaton;
  }

  ensureStateExists(name: string): State {
    if (!this.statesMap.has(name)) {
      const newState = new State();
      newState.name = name;
      this.automaton.addState(newState);
      this.statesMap.set(name, newState);
    }
    return this.statesMap.get(name)!;
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(this.title)
            .textAlign(TextAlign.Start)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin(10)
          Button("格式样例")
            .fontSize(15)
            .margin(10)
            .onClick(() => {
              this.openExample();
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width("100%")

        TextArea({ placeholder: '请输入内容', text: $$this.info })
          .height(300)
          .margin({ left: 10, right: 10 })

        Text()
          .size({ width: "100%", height: "2px" })
          .backgroundColor("#bebbc1")
          .margin({ top: 10 })

        Row() {
          Text("导入")
            .height("100%")
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .onClick(() => {
              this.tm = this.parseGraphvizInput(this.info);
              this.import();
              this.controller.close(); // 关闭弹窗
            })
          Text()
            .size({ width: "2px", height: "100%" })
            .backgroundColor("#bebbc1")
          Text("关闭")
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .height("100%")
            .layoutWeight(1)
            .onClick(() => {
              this.controller.close(); // 关闭弹窗
            })
        }
        .height(45)
        .width('100%')
      }
      .backgroundColor("#e6ffffff")
      .borderRadius(10)
    }
    .padding({ left: 40, right: 40 })
    .width("100%")
  }
}
