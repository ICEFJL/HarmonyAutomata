import { pasteboard } from "@kit.BasicServicesKit";
import { promptAction } from "@kit.ArkUI";

@CustomDialog
@Component
export struct GraphvizExample {
  info: string = '基本结构\n' +
    'digraph 图名 {\n' +
    '    // 初始状态定义\n' +
    '    q -> q0\n' +
    '    \n' +
    '    // 状态转移定义\n' +
    '    q0 -> q0 [label= "0,1;R"]\n' +
    '    q0 -> q0 [label= "1,0;R"]\n' +
    '    q0 -> q1 [label= "ε,ε;S"]\n' +
    '    \n' +
    '    // 初始状态标记点\n' +
    '    q [shape=point]\n' +
    '    \n' +
    '    // 终止状态定义\n' +
    '    q1 [shape=doublecircle]\n' +
    '}\n' +
    '格式规范\n' +
    '1.点状态：\n' +
    '   文件中必须包含 q [shape=point] 语句，用于绘制初始状态的指针\n' +
    '2.状态命名：\n' +
    '   除了点状态之外的所有状态,包括接受状态和拒绝状态命名时必须以q+数字的形式命名，如 q0, q1, q2 等\n' +
    '3.初始状态：\n' +
    '   使用 q -> q状态名 格式定义，例如 q -> q0 表示 q0 是初始状态\n' +
    '4.终止状态：\n' +
    '   使用 q状态名 [shape=doublecircle] 格式定义终止状态\n' +
    '5.转移关系：\n' +
    '   基本格式：q起始状态 -> q目标状态 [label= "readSymbol,writeSymbol;moveDirection"]\n' +
    '   移动方向：仅限R,S,L三种情况\n' +
    '   读写符号：为空时，用ε表示\n' +
    '   例如：q0 -> q1 [label= "0,1;R"]';
  exmp: string = '基本结构\n' +
    'digraph 图名 {\n' +
    '    // 初始状态定义\n' +
    '    q -> q0\n' +
    '    \n' +
    '    // 状态转移定义\n' +
    '    q0 -> q0 [label= "0,1;R"];\n' +
    '    q0 -> q0 [label= "1,0;R"];\n' +
    '    q0 -> q1 [label= "ε,ε;S"];\n' +
    '    \n' +
    '    // 初始状态标记点\n' +
    '    q [shape=point]\n' +
    '    \n' +
    '    // 终止状态定义\n' +
    '    q1 [shape=doublecircle]\n' +
    '}\n';
  private controller: CustomDialogController;

  copyText(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    systemPasteboard.getData().then((data) => {
      if (data) {
        promptAction.showToast({ message: '复制成功' });
      } else {
        promptAction.showToast({ message: '复制失败' });
      }
    })
  }

  build() {
    Stack() {
      Column() {
        Text("格式样例")
          .textAlign(TextAlign.Center)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin(10)

        TextArea({ text: $$this.info })
          .height(500)
          .margin({ left: 10, right: 10 })
          .focusable(false)

        Text()
          .size({ width: "100%", height: "2px" })
          .backgroundColor("#bebbc1")
          .margin({ top: 10 })

        Row() {
          Text("复制格式")
            .height("100%")
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .onClick(() => {
              this.copyText(this.exmp);
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
      .borderRadius(20)
    }
    .padding({ left: 40, right: 40 })
    .width("100%")
  }
}
