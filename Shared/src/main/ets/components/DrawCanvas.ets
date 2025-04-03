import DrawInvoker from '../viewmodel/DrawInvoker';
import { DrawType, IDraw } from '../viewmodel/IDraw';
import { Const } from '../common/Constants';
import { State as AutomatonState } from '../automaton/State';
import { StateDetailWindow } from '../view/StateDetailWindow';
import { DrawState } from '../viewmodel/DrawState';
import { DrawTransition } from '../viewmodel/DrawTransition';
import { TransitionDetailWindow } from '../view/TransitionDetailWindow';
import { HelpUtil } from '../common/HelpUtil';
import { ToolButton } from '../view/ToolButton';
//添加
import { TuringTransitionDetailWindow } from '../view/TuringTransitionDetailWindow';
import { PDATransitionDetailWindow } from '../view/PDATransitionDetailWindow';
import { AutomatonType } from '../automaton/Type';

const setting: RenderingContextSettings = new RenderingContextSettings(true);
export const globalContext = new CanvasRenderingContext2D(setting);

@Component
export struct DrawCanvas {
  @State scaleValueX: number = Const.SCALE;
  @State scaleValueY: number = Const.SCALE;
  @State pinchValueX: number = Const.SCALE;
  @State pinchValueY: number = Const.SCALE;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  private dragStartX: number = 0;
  private dragStartY: number = 0;

  @Consume drawInvoker: DrawInvoker;
  @Consume index: number;
  @Consume unDoDraw: boolean;
  @Consume redoDraw: boolean;
  @Consume @Watch('endUpdate') update: boolean;
  @Provide mState: DrawState = new DrawState(new AutomatonState(), false);
  @Provide mTransition: DrawTransition = new DrawTransition(new AutomatonState(), new AutomatonState(), "");
  @Provide firstCreate: boolean = false;
  @Provide alterflag: boolean = false;
  premState: DrawState = new DrawState(new AutomatonState(), false);

  private context: CanvasRenderingContext2D = globalContext;
  private isSelected: boolean = false;
  private counter: number = 0;
  private stateWindow: CustomDialogController = new CustomDialogController({
    builder: StateDetailWindow({ endUpdate: () => this.endUpdate() }), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });
  private transitionWindow: CustomDialogController= new CustomDialogController({
    builder: TransitionDetailWindow({ endUpdate: () => this.endUpdate() }), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });
  private turingTransitionWindow: CustomDialogController= new CustomDialogController({
    builder: TuringTransitionDetailWindow({ endUpdate: () => this.endUpdate() }), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });
  private PDATransitionWindow: CustomDialogController= new CustomDialogController({
    builder: PDATransitionDetailWindow({ endUpdate: () => this.endUpdate() }), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  //根据automatonType绘制窗口
  //step 1: 设置@Prop automatonType,从父组件获取automatonType值
  @Prop  readonly automatonType:AutomatonType;

  //step 2: 设置函数，根据automatonType使用对应open函数
  selectTransitionWindow():void{
    switch(this.automatonType) {
      case AutomatonType.TM:
        console.log("已选择TuringTransitionDetailWindow");
        this.turingTransitionWindow.open();
        return;
      case AutomatonType.PDA:
        console.log("已选择PDTransitionDetailWindow");
        this.PDATransitionWindow.open();
        return;
      default:
        console.log("默认选择TransitionDetailWindow");
        this.transitionWindow.open();
        return;
    }
  }

  updateDraw(): void {
    this.context.clearRect(0, 0, this.context.width, this.context.height);
    HelpUtil.drawGrid(this.context);
    this.drawInvoker.execute(this.context); // 重新绘制
  }

  // 回调函数，用于更新状态
  endUpdate(): void {
    this.isSelected = false;
    if(!this.drawInvoker.isDrawing){
      this.updateDraw();
      return;
    }

    if(!this.drawInvoker.flag){
      let commands = this.drawInvoker.drawList.pop()!;
      this.drawInvoker.pop(commands);
      this.updateDraw();
      return;
    }
    this.drawInvoker.flag = false;
    this.firstCreate = false;
    this.drawInvoker.redoList = [];
    this.redoDraw = false;
    this.unDoDraw = true;
    this.updateDraw();
  }

  drawOperateUndo(): void {
    this.drawInvoker.undo();
    if (!this.drawInvoker.canUndo()) {
      this.unDoDraw = false;
    }
    this.redoDraw = true;
    this.updateDraw();
  }

  drawOperateRedo(): void {
    this.drawInvoker.redo();
    if (!this.drawInvoker.canRedo()) {
      this.redoDraw = false;
    }
    this.unDoDraw = true;
    this.updateDraw();
  }

  isExist(x: number, y: number, index: number = 0): number {
    if(index === Const.DELETE || index === Const.STATE){
      for (const e of this.drawInvoker.stateMap.values()) {
        const element = e[e.length - 1];
        const dx = x - element.state.x;
        const dy = y - element.state.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        if (distance <= Const.CIRCLE_RADIUS) {
          this.mState = element;
          this.premState = element;
          return Const.STATE;
        }
      }
    }
    if(index === Const.DELETE || index === Const.TRANSITION){
      for (const eArray of this.drawInvoker.transitionMap.values()) {
        for(let i = 0; i < eArray.length;i++){
          const e = eArray[i];
          // 判断标签区域：可以根据标签的坐标和大小判断
          const labelX = (e.baseLine[0][0] + e.baseLine[1][0]) / 2;
          const labelY = (e.baseLine[0][1] + e.baseLine[1][1]) / 2 - 8 * i;

          const dx = x - labelX;
          const dy = y - labelY;
          const distance = Math.sqrt(dx * dx + dy * dy);

          // 假设标签区域的点击范围是一个固定的半径（例如 20）
          if (distance <= 4) {
            this.mTransition = e;
            return Const.TRANSITION;
          }
        }
        const e = eArray[eArray.length - 1];
        if(HelpUtil.isInRectPath([x,y],e.p1 , e.p2, e.p3, e.p4)){
          this.mTransition = e;
          return Const.TRANSITION;
        }
      }
    }

    return Const.NONE;
  }

  handleTouchDown(touch: TouchObject): void {
    switch (this.index) {
      case Const.STATE:
        if(this.isExist(touch.x, touch.y) === Const.STATE){
          return;
        }
        this.firstCreate = true;
        this.mState = new DrawState(new AutomatonState(touch.x, touch.y, "s" + this.counter), false);
        this.counter++;
        this.drawInvoker.update([this.mState]);
        this.updateDraw();
        break;
      case Const.TRANSITION:
        if(this.isExist(touch.x, touch.y) !== Const.STATE){
          return;
        }
        break;
      case Const.DELETE:
        const select = this.isExist(touch.x, touch.y, Const.DELETE);
        if(select === Const.NONE){
          return;
        }else if(select === Const.STATE){
          this.drawInvoker.update([this.mState], DrawType.DELETE);
        }else{
          this.drawInvoker.update([this.mTransition], DrawType.DELETE);
        }
        break;
      case Const.NONE :
        this.dragStartX = touch.x;
        this.dragStartY = touch.y;
        break;
       default :
        return;
    }
    this.isSelected = true;
  }

  handleDoubleClick(touch: FingerInfo): void {
    switch (this.index) {
      case Const.STATE:
        if (this.isExist(touch.localX, touch.localY) !== Const.STATE) {
          return;
        }
        this.stateWindow.open();
        break;
      case Const.TRANSITION:
        if (this.isExist(touch.localX, touch.localY, Const.TRANSITION) !== Const.TRANSITION) {
          return;
        }
        //替换
        this.alterflag = true;
        this.selectTransitionWindow();
        break;
    }
  }

  handleLongPress(touch: FingerInfo): void {
    if (this.index !== Const.STATE || this.firstCreate || this.isExist(touch.localX, touch.localY) !== Const.STATE) {
      return;
    }
    this.isSelected = true;
    this.mState = DrawState.deepCopy(this.mState);
    this.mState.radius = Const.CIRCLE_RADIUS + 5 / Const.SCALE;
    let drawArray: Array<IDraw> = [this.mState];
    let delArray: Array<IDraw> = [];
    this.drawInvoker.transitionMap.forEach((transitions: Array<DrawTransition>, keyStr: string) => {
      const key = DrawInvoker.extractUuids(keyStr);
      if(key[0] === this.mState.state.uuid || key[1] === this.mState.state.uuid){
        transitions.forEach((transition:DrawTransition) => {
          this.mTransition = DrawTransition.deepCopy(transition);
          if(key[0] === this.mState.state.uuid){
            this.mTransition.fromState = this.mState.state;
          }
          if(key[1] === this.mState.state.uuid){
            this.mTransition.toState = this.mState.state;
          }
          drawArray.push(this.mTransition);
          delArray.push(transition);
        })
      }
    });
    this.drawInvoker.update(delArray, DrawType.DELETE);
    console.log("进行了删除")
    this.drawInvoker.update(drawArray);
    console.log("进行了添加")
    this.updateDraw();
  }

  handleTouchMove(touch: TouchObject): void {
    if(!this.isSelected){
      return;
    }

    switch (this.index) {
      case Const.STATE:
        const clamped = HelpUtil.clampPosition(this.context, touch.x, touch.y, Const.CIRCLE_RADIUS);

        this.mState.state.x = clamped[0];
        this.mState.state.y = clamped[1];
        this.updateDraw();
        break;
      case Const.TRANSITION:
        this.updateDraw();
        this.context.beginPath();
        this.context.moveTo(this.mState.state.x, this.mState.state.y);
        this.context.lineTo(touch.x, touch.y);
        this.context.strokeStyle = 'gray';
        this.context.lineWidth = Const.LINE_WIDTH;
        this.context.stroke();
        break;
      case Const.NONE:
        const dx = touch.x - this.dragStartX;
        const dy = touch.y - this.dragStartY;

        this.offsetX += dx;
        this.offsetY += dy;

        this.dragStartX = touch.x;
        this.dragStartY = touch.y;
    }
  }

  handleTouchUp(touch: TouchObject): void {
    if(!this.isSelected){
      return;
    }
    switch (this.index){
      case Const.STATE:
        this.mState.radius = Const.CIRCLE_RADIUS;
        this.drawInvoker.flag = !this.premState.equals(this.mState);
        this.endUpdate();
        break;
      case Const.TRANSITION:
        this.updateDraw();
        const start = this.mState;
        if (this.isExist(touch.x, touch.y) !== Const.STATE) {
          return;
        }
        const key = DrawInvoker.createKey(start.state.uuid, this.mState.state.uuid);
        if (!this.drawInvoker.transitionMap.has(key)) {
          this.mTransition = new DrawTransition(start.state, this.mState.state,"");
        }else{
          const transitionArray = this.drawInvoker.transitionMap.get(key)!;
          this.mTransition = transitionArray[transitionArray.length - 1];
        }
        //替换
        this.selectTransitionWindow();
        break;
      case Const.DELETE:
        this.endUpdate();
        break;
      case Const.NONE:
        this.isSelected = false;
        break;
    }

  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Canvas(this.context)
        .width(Const.ONE_HUNDRED_PERCENT)
        .height(Const.ONE_HUNDRED_PERCENT)
        .backgroundColor($r('sys.color.white'))
        .onReady(() => {
          this.endUpdate();
        })
        .onTouch((event: TouchEvent) => {
          if (event.touches.length !== 1 || event.touches[0].id !== 0) {
            return;
          }
          const touch = event.touches[0];

          switch (event.type) {
            case TouchType.Down:
              this.handleTouchDown(touch);
              break;
            case TouchType.Move:
              this.handleTouchMove(touch);
              break;
            case TouchType.Up:
              this.handleTouchUp(touch);
              break;
          }
        })
        .translate({
          x: this.offsetX,
          y: this.offsetY
        })
        .scale({
          x: this.scaleValueX,
          y: this.scaleValueY
        })
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            TapGesture({ count: 2 })
              .onAction((event: GestureEvent) => {
                if (event) {
                  this.handleDoubleClick(event.fingerList[0]);
                }
              }),
            LongPressGesture()
              .onAction((event: GestureEvent) => {
                if (event) {
                  this.handleLongPress(event.fingerList[0]);
                }
              }),
            PinchGesture()
              .onActionUpdate((event: GestureEvent) => {
                this.updateDraw();
                if (event) {
                  const newScaleX = this.pinchValueX * event.scale;
                  const newScaleY = this.pinchValueY * event.scale;
                  this.scaleValueX = Math.max(1, newScaleX);
                  this.scaleValueY = Math.max(1, newScaleY);
                }
              })
              .onActionEnd(() => {
                this.pinchValueX = this.scaleValueX;
                this.pinchValueY = this.scaleValueY;
                this.updateDraw();
              })
          )
        );

      Row() {
        ToolButton({
          icon: $r("app.media.state"),
          activeIcon: $r("app.media.state_active"),
          text: $r('app.string.state'),
          isActive: this.index === Const.STATE,
        })
          .onClick(() => {
            if (this.index === Const.STATE) {
              this.index = Const.NONE;
            } else {
              this.index = Const.STATE;
            }
          });

        ToolButton({
          icon: $r("app.media.transition"),
          activeIcon: $r("app.media.transition_active"),
          text: $r('app.string.transition'),
          isActive: this.index === Const.TRANSITION,
        })
          .onClick(() => {
            if (this.index === Const.TRANSITION) {
              this.index = Const.NONE;
            } else {
              this.index = Const.TRANSITION;
            }
          });

        ToolButton({
          icon: $r('app.media.rubbers'),
          activeIcon: $r('app.media.rubbers_active'),
          text: $r('app.string.delete'),
          isActive: this.index === Const.DELETE,
        })
          .onClick(() => {
            if (this.index === Const.DELETE) {
              this.index = Const.NONE;
            } else {
              this.index = Const.DELETE;
            }
          });

        ToolButton({
          icon: $r('app.media.recall'),
          activeIcon: $r('app.media.recall_active'),
          text: $r('app.string.redo'),
          isActive: this.unDoDraw,
        })
          .onClick(() => {
            this.drawOperateUndo();
          });

        ToolButton({
          icon: $r('app.media.redo'),
          activeIcon: $r('app.media.redo_active'),
          text: $r('app.string.undo'),
          isActive: this.redoDraw,
        })
          .onClick(() => {
            this.drawOperateRedo();
          });
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width(Const.ONE_HUNDRED_PERCENT)
      .backgroundColor(Color.White)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .backgroundColor($r('sys.color.comp_background_focus'))
    .width(Const.ONE_HUNDRED_PERCENT)
    .height(Const.ONE_HUNDRED_PERCENT);
  }

}
