import { HelpUtil } from "../common/HelpUtil";
import { DrawState } from "./DrawState";
import { DrawTransition } from "./DrawTransition";
import { DrawOperate, DrawType, IDraw } from "./IDraw";

export default class DrawInvoker {
  // Draw list.
  drawList: Array<DrawOperate> = [];
  // Redo list.
  redoList: Array<DrawOperate> = [];

  stateMap: Map<number, DrawState[]> = new Map();

  transitionMap: Map<string, DrawTransition[]> = new Map();

  initialState: DrawState | null = null;

  flag: boolean = false;

  isDrawing: boolean = false;

  tempArray: Array<DrawTransition> = [];

  labelHeight: number = 0;

  clearAll(): void {
    this.drawList = [];            // 清空操作历史列表
    this.redoList = [];            // 清空重做列表
    this.stateMap.clear();               // 清空所有状态记录
    this.transitionMap.clear();          // 清空所有过渡记录
    this.initialState = null;            // 重置初始状态
    this.flag = false;
    this.isDrawing = false;
  }


  setNeedOffset(command: DrawTransition, flag: boolean, type: DrawType = DrawType.UPDATE): void{
    if (command.toState.uuid !== command.fromState.uuid){
      const nKey = HelpUtil.createKey(command.toState.uuid, command.fromState.uuid);
      if (this.transitionMap.has(nKey)) {
        let transitionArray = this.transitionMap.get(nKey)!;
        transitionArray.forEach((item)=>{
          item.needOffset = flag;
        })
        if(type === DrawType.ADD || type === DrawType.CREATE){
          command.needOffset = flag;
        }
      }
    }
  }

  update(commands: Array<IDraw>, type: DrawType = DrawType.UPDATE, preTransition: Array<DrawTransition> = []): void {
    this.isDrawing = true;
    let draw: DrawOperate = new DrawOperate();
    switch (type){
      case DrawType.ADD:
      case DrawType.CREATE:
      case DrawType.UPDATE:
        draw = new DrawOperate(commands, type, preTransition);
        this.drawList.push(draw);
        this.push(draw);
        break;
      case DrawType.DELETE:
        let drawArray: Array<IDraw> = [];
        for(const command of commands){
          if(command instanceof DrawState){
            let stateArray = this.stateMap.get(command.state.uuid)!;
            stateArray.forEach(state => {
              drawArray.push(state);
            })
            this.transitionMap.forEach((transitions: Array<DrawTransition>, keyStr: string) => {
              const key = HelpUtil.extractUuids(keyStr);
              if(key[0] === command.state.uuid || key[1] === command.state.uuid){
                drawArray.push(...transitions);
              }
            });
          } else if(command instanceof DrawTransition){
            const key = HelpUtil.createKey(command.fromState.uuid, command.toState.uuid);
            if (this.transitionMap.has(key)) {
              let transitions = this.transitionMap.get(key)!;
              for (let t of transitions){
                if(t.label === command.label)
                  drawArray.push(t);
              }
              //drawArray.push(...this.transitionMap.get(key)!);
            }
          }
        }

        drawArray = Array.from(new Set<IDraw>(drawArray));
        draw = new DrawOperate(drawArray, type);
        this.drawList.push(draw);
        this.pop(draw);
        this.flag = true;
        break;
      case DrawType.MOVE:
        if(commands[0] instanceof DrawState){
          this.changeMove(commands[0]);
          draw = new DrawOperate(commands, type);
          this.drawList.push(draw);
          this.push(draw);
        }
        break;
      default:
        break;
    }
  }

  changeMove(mState: DrawState): void {
    this.transitionMap.forEach((transitions: Array<DrawTransition>, keyStr: string) => {
      const key = HelpUtil.extractUuids(keyStr);
      if(key[0] === mState.state.uuid || key[1] === mState.state.uuid){
        transitions.forEach((transition:DrawTransition) => {
          if(key[0] === mState.state.uuid){
            transition.fromState = mState.state;
          }
          if(key[1] === mState.state.uuid){
            transition.toState = mState.state;
          }
        })
      }
    });
  }

  pushState(command: DrawState){
    const uuid = command.state.uuid;
    if (!this.stateMap.has(uuid)) {
      this.stateMap.set(uuid, []);
      this.flag = true;
    }else if(!this.flag){
      const stateArray = this.stateMap.get(uuid);
      if(stateArray && !stateArray[stateArray.length - 1].equals(command)){
        this.flag = true;
      }
    }
    this.stateMap.get(uuid)!.push(command);
  }

  pushTransition(command: DrawTransition){
    const key = HelpUtil.createKey(command.fromState.uuid, command.toState.uuid);
    if (!this.transitionMap.has(key)) {
      this.transitionMap.set(key, []);
      this.flag = true;
    }else if(!this.flag){
      const transitionArray = this.transitionMap.get(key)!;
      if(transitionArray &&  !transitionArray.some(transition => transition.label === command.label)){
        this.flag = true;
      }
    }
    this.transitionMap.get(key)!.push(command);
    this.tempArray.push(command);
  }

  push(draw: DrawOperate): void {
    if (draw.type === DrawType.CREATE) {
      let temp = new DrawOperate(draw.preTransition, DrawType.DELETE);
      this.pop(temp);
    }
    if(draw.type === DrawType.UPDATE){
      for(const transition of draw.preTransition){
        this.popTransition(transition)
      }
    }
    this.tempArray = [];
    this.flag = false;
    draw.op.forEach(command => {
      if (command instanceof DrawState) {
        this.pushState(command);
      } else if (command instanceof DrawTransition) {
        this.pushTransition(command);
      }
    });
    if(draw.type !== DrawType.UPDATE){
      this.tempArray.forEach(command => {
        this.setNeedOffset(command, true, draw.type);
      });
    }
  }

  popState(command: DrawState){
    const uuid = command.state.uuid;
    const stateArray = this.stateMap.get(uuid)!;
    stateArray.pop();
    if (stateArray.length === 0) {
      this.stateMap.delete(uuid);
    }
  }

  popTransition(command: DrawTransition): void {
    const key = HelpUtil.createKey(command.fromState.uuid, command.toState.uuid);
    const transitionArray = this.transitionMap.get(key)!;
    // 查找符合条件的转换
    const transitionToRemove = transitionArray.find(t => t.uuid === command.uuid);
    // 如果找到了转换，则执行删除操作
    if (transitionToRemove) {
      // 从数组中删除这个转换
      const index = transitionArray.indexOf(transitionToRemove);
      if (index !== -1) {
        transitionArray.splice(index, 1); // 删除该转换
      }
    }
    //transitionArray.pop();
    if (transitionArray.length === 0) {
      this.transitionMap.delete(key);
      this.tempArray.push(command);
    }
  }

  pop(draw: DrawOperate): void {
    this.tempArray = [];
    draw.op.forEach(command => {
      if (command instanceof DrawState) {
        this.popState(command);
      } else if (command instanceof DrawTransition) {
        this.popTransition(command);
      }
    });
    if(draw.type === DrawType.UPDATE){
      for(const transition of draw.preTransition){
        this.pushTransition(transition)
      }
    } else {
      this.tempArray.forEach(command => {
        this.setNeedOffset(command, false, draw.type);
      });
    }
    if(draw.type === DrawType.CREATE){
      let temp = new DrawOperate(draw.preTransition, DrawType.UPDATE);
      this.push(temp);
    }
  }

  undo(): void {
    if (this.drawList.length > 0) {
      let undoCommands = this.drawList.pop()!;
      this.redoList.push(undoCommands);
      switch (undoCommands.type){
        case DrawType.ADD:
        case DrawType.UPDATE:
          this.pop(undoCommands);
          break;
        case DrawType.DELETE:
          this.push(undoCommands);
          break;
        case DrawType.MOVE:
          const command = undoCommands.op[0] as DrawState;
          const uuid = command.state.uuid;
          const stateArray = this.stateMap.get(uuid)!;
          stateArray.pop();
          const state = stateArray[stateArray.length - 1];
          this.changeMove(state);
          break;
        case DrawType.CREATE:
          this.pop(undoCommands);
          break;
      }
    }
  }

  redo(): void {
    if (this.redoList.length > 0) {
      let redoCommands = this.redoList.pop()!;
      this.drawList.push(redoCommands);
      switch (redoCommands.type){
        case DrawType.ADD:
        case DrawType.UPDATE:
          this.push(redoCommands);
          break;
        case DrawType.DELETE:
          this.pop(redoCommands);
          break;
        case DrawType.MOVE:
          this.push(redoCommands);
          this.changeMove(redoCommands.op[0] as DrawState);
          break;
        case DrawType.CREATE:
          this.push(redoCommands);
          break;
      }
    }
  }

  execute(context: CanvasRenderingContext2D): void {
    if (this.stateMap !== null) {
      this.stateMap.forEach((states) => {
        states[states.length - 1].draw(context);
      });
      this.transitionMap.forEach((transitions) => {
        transitions.forEach((transition, index) => {
          transition.draw(context, this.labelHeight * 2 * index);  // 绘制每条转移
          //console.log("调用了drawOffset", 50*index)
        });
      });
    }
  }

  canRedo(): boolean {
    return this.redoList.length > 0;
  }

  canUndo(): boolean {
    return this.drawList.length > 0;
  }
}
