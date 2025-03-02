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

  setNeedOffset(command: DrawTransition, flag: boolean, type: DrawType = DrawType.UPDATE): void{
    if (command.toState.uuid !== command.fromState.uuid){
      const nKey = DrawInvoker.createKey(command.toState.uuid, command.fromState.uuid);
      if (this.transitionMap.has(nKey)) {
        let transitionArray = this.transitionMap.get(nKey)!;
        transitionArray[transitionArray.length - 1].needOffset = flag;
        if(type === DrawType.UPDATE){
          command.needOffset = flag;
        }
      }
    }
  }

  update(commands: Array<IDraw>): void {
    this.isDrawing = true;
    const draw = new DrawOperate(commands, DrawType.UPDATE);
    this.drawList.push(draw);
    this.push(draw);
  }

  delete(command: IDraw): void {
    this.isDrawing = true;
    let drawArray: Array<IDraw> = [];
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
        drawArray.push(...this.transitionMap.get(key)!);
      }
    }
    const draw = new DrawOperate(drawArray, DrawType.DELETE);
    this.drawList.push(draw);
    this.pop(draw);
  }

  push(draw: DrawOperate): void {
    let tempArray: Array<DrawTransition> = [];
    draw.op.forEach(command => {
      if (command instanceof DrawState) {
        const uuid = command.state.uuid;
        if (!this.stateMap.has(uuid)) {
          this.stateMap.set(uuid, []);
        }
        this.stateMap.get(uuid)!.push(command);
      } else if (command instanceof DrawTransition) {
        const key = DrawInvoker.createKey(command.fromState.uuid, command.toState.uuid);
        if (!this.transitionMap.has(key)) {
          this.transitionMap.set(key, []);
          tempArray.push(command);
        }
        this.transitionMap.get(key)!.push(command);
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
        transitionArray.pop();
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
      if (undoCommands.type === DrawType.UPDATE){
        this.pop(undoCommands);
      } else if (undoCommands.type === DrawType.DELETE){
        this.push(undoCommands);
      }
    }
  }

  redo(): void {
    if (this.redoList.length > 0) {
      let redoCommands = this.redoList.pop()!;
      this.drawList.push(redoCommands);
      if (redoCommands.type === DrawType.UPDATE){
        this.push(redoCommands);
      } else if (redoCommands.type === DrawType.DELETE){
        this.pop(redoCommands);
      }
    }
  }

  execute(context: CanvasRenderingContext2D): void {
    if (this.stateMap !== null) {
      this.stateMap.forEach((states: Array<DrawState>) => {
        states[states.length - 1].draw(context);
      });
      this.transitionMap.forEach((transitions: Array<DrawTransition>) => {
        transitions[transitions.length - 1].draw(context);
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
