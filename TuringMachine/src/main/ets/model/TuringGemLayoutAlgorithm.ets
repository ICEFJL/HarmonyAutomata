import {Transition,State,HelpUtil,Const } from 'shared'
import {globalContext } from 'shared/src/main/ets/components/DrawCanvas'
import {TuringTransition} from '../model/TuringTransition'
import {TuringMachine} from '../model/TuringMachine'

export class TuringGemLayoutAlgorithm<S extends State, T extends TuringTransition> {
  process(graph: TuringMachine<S, T>): TuringMachine<S, T> {
    const vArray = graph.getStates(); // 直接使用所有状态（无需移除初始状态）
    const n = vArray.length;

    if (n <= 1) {
      // 节点数太少，直接返回
      if (n === 1) {
        vArray[0].x = globalContext.width / 2;
        vArray[0].y = globalContext.height / 2;
      }
      return graph;
    }

    // 1. 计算理想距离矩阵 - 使用BFS优化
    const distanceMatrix: number[][] = Array(n).fill(0).map(() => Array(n).fill(Infinity));

    // 构建邻接表
    const adjacencyList: number[][] = Array(n).fill(0).map(() => []);
    for (const t of graph.getTransitions()) {
      const fromIndex = vArray.findIndex(v => v.uuid === t.from);
      const toIndex = vArray.findIndex(v => v.uuid === t.to);
      if (fromIndex !== -1 && toIndex !== -1) {
        adjacencyList[fromIndex].push(toIndex);
        adjacencyList[toIndex].push(fromIndex); // 视为无向图
      }
    }

    // 对每个节点使用BFS计算最短路径
    for (let i = 0; i < n; i++) {
      distanceMatrix[i][i] = 0; // 自己到自己的距离为0

      const queue: number[] = [i];
      const visited = new Set<number>([i]);
      let distance = 1;

      while (queue.length > 0) {
        const size = queue.length;

        for (let s = 0; s < size; s++) {
          const current = queue.shift()!;

          for (const neighbor of adjacencyList[current]) {
            if (!visited.has(neighbor)) {
              distanceMatrix[i][neighbor] = distance;
              visited.add(neighbor);
              queue.push(neighbor);
            }
          }
        }

        distance++;
      }
    }

    // 转换为实际距离（单位边长为100）
    const k = n > 30 ? 80 : 100; // 对于大图使用更小的理想距离
    for (let i = 0; i < n; i++) {
      for (let j = 0; j < n; j++) {
        distanceMatrix[i][j] *= k;
      }
    }

    // 2. 迭代优化位置
    const rMax = Math.max(1000, n * 100); // 节点数量相关的迭代次数
    const convergenceThreshold = Math.max(0.5, n * 0.05); // 收敛阈值

    // 动态调整参数
    let k_spring = n <= 10 ? 0.1 : 0.05; // 较大图形使用较小弹簧常数
    let k_repulsion = n <= 10 ? 1000 : 2000; // 较大图形增加排斥力
    let gravity = n <= 10 ? 0.05 : 0.02; // 较大图形减小重力

    // 确保节点初始位置分布合理
    const centerX = globalContext.width / 2;
    const centerY = globalContext.height / 2;
    for (let i = 0; i < n; i++) {
      if (vArray[i].x === 0 && vArray[i].y === 0) {
        // 如果节点在默认位置，将其分散到一个圆形区域
        const angle = 2 * Math.PI * i / n;
        const radius = Math.min(globalContext.width, globalContext.height) * 0.3;
        vArray[i].x = centerX + radius * Math.cos(angle);
        vArray[i].y = centerY + radius * Math.sin(angle);
      }
    }

    let testMovement = Infinity;
    let testMovementThreshold = convergenceThreshold * 0.1;
    let lastMovementCheck = 0;
    const movementCheckInterval = 10;
    let totalMovement = 0;

    // 主迭代循环
    for (let iter = 0; iter < rMax && (iter - lastMovementCheck < movementCheckInterval || testMovement > testMovementThreshold); iter++) {
      // 每10次迭代检查一次收敛情况
      if (iter % movementCheckInterval === 0) {
        testMovement = 0;
        lastMovementCheck = iter;
      }

      // 是否使用网格优化
      const useGridOptimization = n > 50 && iter > 20;
      const gridSize = k * 2;
      const gridWidth = Math.ceil(globalContext.width / gridSize) + 1;
      const gridHeight = Math.ceil(globalContext.height / gridSize) + 1;
      const grid: number[][][] = Array(gridWidth).fill(0).map(() =>
      Array(gridHeight).fill(0).map(() => [])
      );

      // 如果使用网格优化，将节点分配到网格
      if (useGridOptimization) {
        vArray.forEach((vertex, idx) => {
          const gx = Math.floor(vertex.x / gridSize);
          const gy = Math.floor(vertex.y / gridSize);
          if (gx >= 0 && gx < gridWidth && gy >= 0 && gy < gridHeight) {
            grid[gx][gy].push(idx);
          }
        });
      }

      // 对每个节点计算力并更新位置
      vArray.forEach((vertex, index) => {
        const p: [number, number] = [0, 0];
        const oldX = vertex.x;
        const oldY = vertex.y;

        // 弹簧力 - 根据理想距离计算
        for (let j = 0; j < n; j++) {
          if (index === j) continue;
          const d = distanceMatrix[index][j];
          const dx = vArray[j].x - vertex.x;
          const dy = vArray[j].y - vertex.y;
          const d_actual = Math.sqrt(dx * dx + dy * dy);
          if (d_actual < 1) continue; // 避免除零
          const delta_d = d_actual - d;
          p[0] += (dx / d_actual) * (delta_d * k_spring);
          p[1] += (dy / d_actual) * (delta_d * k_spring);
        }

        // 排斥力计算 - 可选网格优化
        if (useGridOptimization) {
          // 网格优化的排斥力计算
          const gx = Math.floor(vertex.x / gridSize);
          const gy = Math.floor(vertex.y / gridSize);

          // 检查当前网格和周围8个网格
          for (let i = Math.max(0, gx - 1); i <= Math.min(gridWidth - 1, gx + 1); i++) {
            for (let j = Math.max(0, gy - 1); j <= Math.min(gridHeight - 1, gy + 1); j++) {
              for (const j_idx of grid[i][j]) {
                if (index === j_idx) continue;
                const dx = vArray[j_idx].x - vertex.x;
                const dy = vArray[j_idx].y - vertex.y;
                const d2 = dx * dx + dy * dy;
                if (d2 < 1) continue; // 避免除零
                const force = k_repulsion / d2;
                p[0] -= (dx / Math.sqrt(d2)) * force;
                p[1] -= (dy / Math.sqrt(d2)) * force;
              }
            }
          }
        } else {
          // 常规排斥力计算
          for (let j = 0; j < n; j++) {
            if (index === j) continue;
            const dx = vArray[j].x - vertex.x;
            const dy = vArray[j].y - vertex.y;
            const d2 = dx * dx + dy * dy;
            if (d2 < 1) continue; // 避免除零
            const force = k_repulsion / d2;
            p[0] -= (dx / Math.sqrt(d2)) * force;
            p[1] -= (dy / Math.sqrt(d2)) * force;
          }
        }

        // 中心引力
        p[0] += gravity * (centerX - vertex.x);
        p[1] += gravity * (centerY - vertex.y);

        // 限制每次移动的最大距离
        const maxMove = 50;
        const moveDistance = Math.sqrt(p[0] * p[0] + p[1] * p[1]);
        if (moveDistance > maxMove) {
          p[0] = (p[0] / moveDistance) * maxMove;
          p[1] = (p[1] / moveDistance) * maxMove;
        }

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

        // 计算总移动距离（用于收敛检测）
        const distance = Math.sqrt((pos[0] - oldX) * (pos[0] - oldX) + (pos[1] - oldY) * (pos[1] - oldY));
        totalMovement += distance;
        if (iter % movementCheckInterval === 0) {
          testMovement += distance;
        }
      });

      // 迭代过程中动态调整参数
      if (iter > 0 && iter % 100 === 0) {
        k_spring *= 0.9;
        k_repulsion *= 0.9;
        gravity *= 0.9;
      }
    }

    if(totalMovement <= convergenceThreshold){
      graph.update = false;
    } else {
      graph.update = true;
    }

    return graph;
  }
}