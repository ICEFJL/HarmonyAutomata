import { Transition } from "../Transition";
import { State } from "../State";
import { Automaton } from "../Automaton";
import { globalContext } from "../../components/DrawCanvas";
import { HelpUtil } from "../../common/HelpUtil";
import { Const } from "../../../../../Index";
export class GemLayoutTest<S extends State, T extends Transition> {
  process(graph: Automaton<S, T>): Automaton<S, T> {
    const vArray = graph.getStates(); // 直接使用所有状态（无需移除初始状态）
    const n = vArray.length;

    // 1. 计算理想距离矩阵
    const distanceMatrix: number[][] = Array(n).fill(0).map(() => Array(n).fill(0));
    // 初始化邻接关系（假设无向图）
    for (let i = 0; i < n; i++) {
      for (let j = 0; j < n; j++) {
        distanceMatrix[i][j] = i === j ? 0 : Infinity;
      }
    }
    for (const t of graph.getTransitions()) {
      const fromIndex = vArray.findIndex(v => v.uuid === t.from);
      const toIndex = vArray.findIndex(v => v.uuid === t.to);
      if (fromIndex !== -1 && toIndex !== -1) {
        distanceMatrix[fromIndex][toIndex] = 1;
        distanceMatrix[toIndex][fromIndex] = 1;
      }
    }
    // Floyd-Warshall计算最短路径
    for (let k = 0; k < n; k++) {
      for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
          if (distanceMatrix[i][j] > distanceMatrix[i][k] + distanceMatrix[k][j]) {
            distanceMatrix[i][j] = distanceMatrix[i][k] + distanceMatrix[k][j];
          }
        }
      }
    }
    // 转换为实际距离（单位边长为100）
    const k = 100;
    for (let i = 0; i < n; i++) {
      for (let j = 0; j < n; j++) {
        distanceMatrix[i][j] *= k;
      }
    }

    // 2. 迭代优化位置
    const rMax = 1000; // 调整迭代次数
    for (let i = 0; i < rMax; i++) {
      vArray.forEach((vertex, index) => {
        const p: [number, number] = [0, 0];

        // 弹簧力
        for (let j = 0; j < n; j++) {
          if (index === j) continue;
          const d = distanceMatrix[index][j];
          const dx = vArray[j].x - vertex.x;
          const dy = vArray[j].y - vertex.y;
          const d_actual = Math.sqrt(dx ** 2 + dy ** 2);
          if (d_actual === 0) continue;
          const delta_d = d_actual - d;
          const k_spring = 0.1;
          p[0] += (dx / d_actual) * (delta_d * k_spring);
          p[1] += (dy / d_actual) * (delta_d * k_spring);
        }

        // 排斥力
        for (let j = 0; j < n; j++) {
          if (index === j) continue;
          const dx = vArray[j].x - vertex.x;
          const dy = vArray[j].y - vertex.y;
          const d2 = dx ** 2 + dy ** 2;
          if (d2 === 0) continue;
          const k_repulsion = 1000;
          p[0] -= (dx / d2) * (k_repulsion / Math.sqrt(d2));
          p[1] -= (dy / d2) * (k_repulsion / Math.sqrt(d2));
        }

        // 重力项
        const gravity = 0.05;
        const centerX = globalContext.width / 2;
        const centerY = globalContext.height / 2;
        p[0] += gravity * (centerX - vertex.x);
        p[1] += gravity * (centerY - vertex.y);

        // 更新坐标并限制边界
        vertex.x += p[0];
        vertex.y += p[1];
        const pos = HelpUtil.clampPosition(
          globalContext,
          vertex.x,
          vertex.y,
          Const.CIRCLE_RADIUS
        );
        vertex.x = pos[0];
        vertex.y = pos[1];
      });
    }

    return graph;
  }
}