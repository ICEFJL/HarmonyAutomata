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

  static createKey(fromStateUuid: number, toStateUuid: number): string {
    return `${fromStateUuid}-${toStateUuid}`;
  }

  static extractUuids(key: string): [number, number] {
    const parts = key.split('-');
    if (parts.length !== 2) {
      throw new Error('Invalid key format');
    }
    const fromStateUuid = parseInt(parts[0], 10);
    const toStateUuid = parseInt(parts[1], 10);
    return [fromStateUuid, toStateUuid];
  }

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
      const nKey = DrawInvoker.createKey(command.toState.uuid, command.fromState.uuid);
      if (this.transitionMap.has(nKey)) {
        let transitionArray = this.transitionMap.get(nKey)!;
        transitionArray.forEach((item)=>{
          item.needOffset = flag;
        })
        //transitionArray[transitionArray.length - 1].needOffset = flag;
        if(type === DrawType.UPDATE){
          command.needOffset = flag;
        }
      }
    }
  }

  update(commands: Array<IDraw>, type: DrawType = DrawType.UPDATE): void {
    this.isDrawing = true;
    let draw: DrawOperate = new DrawOperate();
    switch (type){
      case DrawType.UPDATE:
        draw = new DrawOperate(commands, type);
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
              const key = DrawInvoker.extractUuids(keyStr);
              if(key[0] === command.state.uuid || key[1] === command.state.uuid){
                drawArray.push(...transitions);
              }
            });
          } else if(command instanceof DrawTransition){
            const key = DrawInvoker.createKey(command.fromState.uuid, command.toState.uuid);
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
    }
  }

  changeMove(mState: DrawState): void {
    this.transitionMap.forEach((transitions: Array<DrawTransition>, keyStr: string) => {
      const key = DrawInvoker.extractUuids(keyStr);
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

  push(draw: DrawOperate): void {
    let tempArray: Array<DrawTransition> = [];
    this.flag = false;
    draw.op.forEach(command => {
      if (command instanceof DrawState) {
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
      } else if (command instanceof DrawTransition) {
        const key = DrawInvoker.createKey(command.fromState.uuid, command.toState.uuid);
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
        //console.log('查看有多少个转移', JSON.stringify(this.transitionMap.get(key)));
        tempArray.push(command);
      }
    });
    tempArray.forEach(command => {
      this.setNeedOffset(command, true, draw.type);
    });
  }

  pop(draw: DrawOperate): void {
    let tempArray: Array<DrawTransition> = [];
    draw.op.forEach(command => {
      if (command instanceof DrawState) {
        const uuid = command.state.uuid;
        const stateArray = this.stateMap.get(uuid)!;
        stateArray.pop();
        if (stateArray.length === 0) {
          this.stateMap.delete(uuid);
        }
      } else if (command instanceof DrawTransition) {
        const key = DrawInvoker.createKey(command.fromState.uuid, command.toState.uuid);
        const transitionArray = this.transitionMap.get(key)!;
        // 查找符合条件的转换
        const transitionToRemove = transitionArray.find(t => t.label === command.label);
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
          tempArray.push(command);
        }
      }
    });
    tempArray.forEach(command => {
      this.setNeedOffset(command, false, draw.type);
    });
  }

  undo(): void {
    if (this.drawList.length > 0) {
      let undoCommands = this.drawList.pop()!;
      this.redoList.push(undoCommands);
      switch (undoCommands.type){
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
      }
    }
  }

  redo(): void {
    if (this.redoList.length > 0) {
      let redoCommands = this.redoList.pop()!;
      this.drawList.push(redoCommands);
      switch (redoCommands.type){
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
          transition.draw(context, 8 * index);  // 绘制每条转移
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
