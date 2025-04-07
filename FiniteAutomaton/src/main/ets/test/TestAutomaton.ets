import { FSAConfig } from './AutomatonCreator';

export const easyFSA: FSAConfig = {
  name: "easyFSA", 
  states: ['s0', 's1'],
  alphabet: [],
  transitions: {
    's0': {'ε': ['s1']}
  },
  initial_state: 's0',
  final_states: ['s1']
};

export const normalFSA: FSAConfig = {
  name: "normalFSA", 
  states: ['s0', 's1', 's2'],
  alphabet: ['0', '1'],
  transitions: {
    's0': {'0': ['s0'], '1': ['s1']},
    's1': {'0': ['s2'], '1': ['s0']},
    's2': {'0': ['s2'], '1': ['s0']}
  },
  initial_state: 's0',
  final_states: ['s0']
};

export const nfaToDFATestFSA: FSAConfig = {
  name: "nfaToDFATestFSA", 
  states: ['s0', 's1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9'],
  alphabet: ['a', 'b'],
  transitions: {
    's0': {'ε': ['s1', 's7']},
    's1': {'ε': ['s2', 's4']},
    's2': {'a': ['s3']},
    's3': {'ε': ['s6']},
    's4': {'b': ['s5']},
    's5': {'ε': ['s6']},
    's6': {'ε': ['s7', 's1']},
    's7': {'a': ['s8']},
    's8': {'b': ['s9']}
  },
  initial_state: 's0',
  final_states: ['s9']
};

export const minDFATestFSA: FSAConfig = {
  name: "minDFATestFSA", 
  states: ['s0', 's1', 's2', 's3', 's4'],
  alphabet: ['a', 'b'],
  transitions: {
    's0': {'a': ['s1'], 'b': ['s3']},
    's1': {'a': ['s2'], 'b': ['s1']},
    's2': {'a': ['s2'], 'b': ['s1']},
    's3': {'a': ['s4'], 'b': ['s3']},
    's4': {'a': ['s4'], 'b': ['s3']}
  },
  initial_state: 's0',
  final_states: ['s1', 's2']
};
