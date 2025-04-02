
export  interface StepLog {
  step: number;
  head: number;
  currentState:string;
  transition: string;
  tape: string;
}

export interface TuringResult {
  logs: StepLog[];
  error?: string;
  finalTape: string;
  finalStep:number;
}