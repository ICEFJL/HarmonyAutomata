import { FSAConfig } from './AutomatonCreator';

export const nfaToDFATestFSA_RES: FSAConfig = {
  name: "nfaToDFATestFSA_RES", 
  states: ['s0', 's1', 's2', 's3'],
  alphabet: ['a', 'b'],
  transitions: {
    's0': {'a': ['s2'], 'b': ['s1']},
    's1': {'a': ['s2'], 'b': ['s1']},
    's2': {'a': ['s2'], 'b': ['s3']},
    's3': {'a': ['s2'], 'b': ['s1']},
  },
  initial_state: 's0',
  final_states: ['s3']
};

export const minimizedNormalFSA: FSAConfig = {
  name: "minimizedNormalFSA", 
  states: ['s0', 's1'],
  alphabet: ['0', '1'],
  transitions: {
    's0': { '0': ['s0'], '1': ['s1'] },
    's1': { '0': ['s1'], '1': ['s0'] }
  },
  initial_state: 's0',
  final_states: ['s0']
};

export const minDFATestFSA_RES: FSAConfig = {
  name: "minDFATestFSA_RES", 
  states: ['s0', 's1'],
  alphabet: ['a', 'b'],
  transitions: {
    's0': {'a': ['s1']},
    's1': {'a': ['s1'], 'b': ['s1']},
  },
  initial_state: 's0',
  final_states: ['s1']
};
