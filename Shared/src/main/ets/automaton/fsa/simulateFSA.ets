import {State} from '../State'
import { ExecutionResult, ExecutionTrace, Node } from '../Type';
import { FSAAutomaton } from './FSAAutomaton';

export class FSAState extends State{
  readonly remaining: string = '';
  readonly read: string | null = '';
  constructor(remaining: string, read: string, parent: State) {
    super(parent.x, parent.y, parent.name, parent.isFinal, parent.uuid)
    this.remaining = remaining;
    this.read = read;
  }

  key () {
    return String(this.uuid + this.remaining)
  }

  isFinalState(): boolean{
    return this.isFinal && this.remaining.length === 0
  }
}

export class FSAExecutionTrace extends ExecutionTrace{
  constructor(read: string | null, to: number) {
    super(read, to);
  }
}

export class FSAExecutionResult extends ExecutionResult{
  remaining: string;
  trace: FSAExecutionTrace[] = []
  constructor(accepted: boolean, remaining: string, trace: FSAExecutionTrace[]) {
    super(accepted);
    this.remaining = remaining;
    this.trace = trace;
  }
}

export const generateTrace = (node: Node<FSAState>): FSAExecutionTrace[] => {
  const trace: FSAExecutionTrace[] = [];
  while (node.parent) {
    trace.push(new FSAExecutionTrace(node.state.read, node.state.uuid));
    node = node.parent;
  }
  // 处理根节点
  trace.push(new FSAExecutionTrace(null, node.state.uuid));
  return trace.reverse();
};

export const simulateFSA = (
  graph: FSAAutomaton,
  input: string
): FSAExecutionResult => {

  let result = new FSAExecutionResult(false, input, [])
  if (!graph.initialState) {
    return result;
  }
  const frontier: Node<FSAState>[] = []
  const reached: Map<string, Node<FSAState>> = new Map()

  const initialState = new FSAState(input, '', graph.initialState)
  let node = new Node<FSAState>(initialState, null)

  frontier.push(node)
  reached.set(node.state.key(), node)

  while (frontier.length > 0) {
    node = frontier.shift()!
    if (node.state.isFinalState()) {
      break;
    }
    for (const successor of graph.getSuccessors(node)) {
      if (!reached.has(successor.state.key())) {
        frontier.push(successor)
        reached.set(successor.state.key(), successor)
      }
    }
  }

  if (node) {
    result = new FSAExecutionResult(
      node.state.isFinal && node.state.remaining === '',
      node.state.remaining,
      generateTrace(node)
    )
  }

  return result;
}
