import {State} from './State'

export class Node<S extends State> {
  readonly state: S;
  readonly parent: Node<S> | null = null
  constructor (state: S, parent: Node<S> | null = null) {
    this.state = state;
    this.parent = parent;
  }
}

export enum AutomatonType {
  FSA = 'FINITE_STATE_AUTOMATON',
  TM = 'TURING_MACHINE',
  PDA = 'PUSHDOWN_AUTOMATON'
}
