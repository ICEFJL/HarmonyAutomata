import DrawInvoker from '../viewmodel/DrawInvoker';
import { IDraw } from '../viewmodel/IDraw';
import { Const } from '../common/Constants';
import { State as AutomatonState } from '../automaton/State';
import { StateDetailWindow } from '../view/StateDetailWindow';
import { DrawState } from '../viewmodel/DrawState';
import { DrawTransition } from '../viewmodel/DrawTransition';
import { TransitionDetailWindow } from '../view/TransitionDetailWindow';
import { HelpUtil } from '../common/HelpUtil';
import { ToolButton } from '../view/ToolButton';

@Component
export struct DrawCanvas {
  @State unDoDraw: boolean = false;
  @State redoDraw: boolean = false;
  @State index: number = Const.NONE;
  @State scaleValueX: number = Const.SCALE;
  @State scaleValueY: number = Const.SCALE;
  @State pinchValueX: number = Const.SCALE;
  @State pinchValueY: number = Const.SCALE;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  private dragStartX: number = 0;
  private dragStartY: number = 0;

  @Consume drawInvoker: DrawInvoker;
  @Provide mState: DrawState = new DrawState(new AutomatonState(), false);
  @Provide mTransition: DrawTransition = new DrawTransition(new AutomatonState(), new AutomatonState(), "");
  @Provide firstCreate: boolean = false;
  premState: DrawState = new DrawState(new AutomatonState(), false);
  preLabel: string = "";

  private setting: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting);
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
  private transitionWindow: CustomDialogController = new CustomDialogController({
    builder: TransitionDetailWindow({ endUpdate: () => this.endUpdate() }), // 弹框的构造器
    cancel: () => {
      console.log("cancel")         // 点击蒙层的回调
    },
    autoCancel: true,               // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

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
    this.mState.radius = Const.CIRCLE_RADIUS;
    this.drawInvoker.isDrawing = false;

    if(this.checkUpdated()){
      let commands = this.drawInvoker.drawList.pop()!;
      this.drawInvoker.pop(commands);
      this.updateDraw();
      return;
    }
    this.drawInvoker.redoList = [];
    this.redoDraw = false;
    this.unDoDraw = true;
    this.updateDraw();
  }

  checkUpdated(): boolean {
    if(this.firstCreate){
      this.firstCreate = false;
      return false;
    }
    switch (this.index) {
      case Const.STATE:
        return this.premState.equals(this.mState);
      case Const.TRANSITION:
        return this.preLabel === this.mTransition.label;
      case Const.DELETE:
        return false;
    }
    return true;
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
        const e = eArray[eArray.length - 1];
        if(HelpUtil.isInRectPath([x,y],e.p1 , e.p2, e.p3, e.p4)){
          this.mTransition = e;
          this.preLabel = e.label;
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
        this.mState.draw(this.context);
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
          this.drawInvoker.delete(this.mState);
        }else{
          this.drawInvoker.delete(this.mTransition);
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
        this.transitionWindow.open();
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
    this.drawInvoker.transitionMap.forEach((transitions: Array<DrawTransition>, keyStr: string) => {
      const key = DrawInvoker.extractUuids(keyStr);
      if(key[0] === this.mState.state.uuid || key[1] === this.mState.state.uuid){
        this.mTransition = DrawTransition.deepCopy(transitions[transitions.length - 1]);
        if(key[0] === this.mState.state.uuid){
          this.mTransition.fromState = this.mState.state;
        }
        if(key[1] === this.mState.state.uuid){
          this.mTransition.toState = this.mState.state;
        }
        drawArray.push(this.mTransition);
      }
    });
    this.drawInvoker.update(drawArray);
    this.updateDraw();
  }

  handleTouchMove(touch: TouchObject): void {
    if(!this.isSelected){
      return;
    }

    switch (this.index) {
      case Const.STATE:

        const newStateX = touch.x;
        const newStateY = touch.y;

        // 计算状态的中心点是否会移出画布
        const maxX = this.context.width - this.mState.radius;
        const maxY = this.context.height - this.mState.radius;

        const clampedX = Math.max(this.mState.radius, Math.min(newStateX, maxX));
        const clampedY = Math.max(this.mState.radius, Math.min(newStateY, maxY));

        this.mState.state.x = clampedX;
        this.mState.state.y = clampedY;
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
          this.firstCreate = true;
        }else{
          const transitionArray = this.drawInvoker.transitionMap.get(key)!;
          this.mTransition = transitionArray[transitionArray.length - 1];
          this.preLabel = this.mTransition.label;
        }
        this.transitionWindow.open();
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
          HelpUtil.drawGrid(this.context);
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
      .backgroundColor(Color.White);
    }
    .backgroundColor($r('sys.color.comp_background_focus'))
    .width(Const.ONE_HUNDRED_PERCENT)
    .height(Const.ONE_HUNDRED_PERCENT);
  }

}
