import { FSAAutomaton, State, Transition  } from "shared";

@CustomDialog
@Component
export struct GraphvizInput {
  @Consume title: string;
  @Consume fsa: FSAAutomaton;
  info:string = '';
  openExample: Function = () => {};
  import: Function = () => {};
  automaton = new FSAAutomaton();
  statesMap = new Map<string, State>();

  private controller: CustomDialogController;

  ensureStateExists(name: string): State {
    if (!this.statesMap.has(name)) {
      const newState = new State();
      newState.name = name;
      this.automaton.addState(newState);
      this.statesMap.set(name, newState);
    }
    return this.statesMap.get(name)!;
  }

  parseGraphvizInput(input: string): FSAAutomaton {
    this.automaton = new FSAAutomaton();
    const lines = input.split('\n');
    this.statesMap = new Map<string, State>();
    let initialStates: string[] = [];

    // 定义正则表达式（需要根据实际需求调整）
    const IS_INIT_EX = RegExp(/\s*q -> (q\d*)/);
    const IS_FINAL_EX = RegExp(/\s*(q\d*) \[shape=doublecircle\]/);
    const TRANS_EX = RegExp(/\s*(q\d*) -> (q\d*)( \[label= "(.*)"\];)/);

    lines.forEach(line => {
      line = line.trim();
      if (!line || line.startsWith("//")) return;

      // 处理初始状态
      const initMatch = line.match(IS_INIT_EX);
      if (initMatch) {
        initialStates.push(initMatch[1]);
        return;
      }

      // 处理终态
      const finalMatch = line.match(IS_FINAL_EX);
      if (finalMatch) {
        const name = finalMatch[1];
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

        const transition = new Transition(fromState.uuid, toState.uuid, label);
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

        TextArea({placeholder:'请输入内容',text:$$this.info})
          .height(300)
          .margin({left: 10, right: 10})

        Text()
          .size({width: "100%", height: "2px"})
          .backgroundColor("#bebbc1")
          .margin({top: 10})

        Row() {
          Text("导入")
            .height("100%")
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .onClick(() => {
              this.fsa = this.parseGraphvizInput(this.info);
              this.import();
              this.controller.close(); // 关闭弹窗
            })
          Text()
            .size({width: "2px", height: "100%"})
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
    .padding({left: 40, right: 40})
    .width("100%")
  }
}
