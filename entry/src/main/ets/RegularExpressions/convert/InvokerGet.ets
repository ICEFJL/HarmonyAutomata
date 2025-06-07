import { DrawState,DrawTransition,DrawInvoker,DrawOperate, DrawType, IDraw } from "shared";

export function getStates(drawinvoker:DrawInvoker): DrawState[] {
  let states: DrawState[] = [];
  drawinvoker.stateMap.forEach((stateArray) => {
    if (stateArray.length > 0) {
      states.push(stateArray[stateArray.length - 1]); // 获取最新的状态
    }
  });
  return states;
}

export function getTransitions(drawinvoker:DrawInvoker): DrawTransition[] {
  let transitions: DrawTransition[] = [];
  drawinvoker.transitionMap.forEach((transitionArray) => {
    if (transitionArray.length > 0) {
      transitions.push(transitionArray[transitionArray.length - 1]); // 获取最新的转换
    }
  });
  return transitions;
}
