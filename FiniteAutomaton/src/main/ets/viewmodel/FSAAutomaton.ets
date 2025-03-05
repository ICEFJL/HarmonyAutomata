import { Automaton, State, Transition, AutomatonType } from "shared";
import { LogUtil, FileUtil } from '@pura/harmony-utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
import { plainToClass } from "class-transformer";

export class FSAAutomaton extends Automaton<State, Transition> {
  constructor() {
    super(AutomatonType.FSA);
  }

  public static loadFromFile(dirPath: string = "", fileName: string = "test.json"): FSAAutomaton {
    try {
      let filePath = FileUtil.getFilesDirPath(dirPath, fileName);
      let readTextOptions: ReadTextOptions = {
        offset: 0,
        length: 0,
        encoding: 'utf-8'
      };
      let stat = fs.statSync(filePath);
      readTextOptions.length = stat.size;
      let bufferStr = fs.readTextSync(filePath, readTextOptions);
      return FSAAutomaton.deserialize(bufferStr);
    } catch (err) {
      let error =err as BusinessError;
      LogUtil.error(`FSAAutomaton-loadFromFile-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to load automaton from file');
    }
  }

  public static deserialize(automatonJSON: string): FSAAutomaton {
    try {
      const plainObject = plainToClass(FSAAutomaton, JSON.parse(automatonJSON), { exposeDefaultValues: true });

      if (plainObject === null) {
        throw new Error('Invalid JSON input for FSAAutomaton');
      }

      // 嵌套对象从Object转为具体对象
      plainObject.initialState = plainToClass(State, plainObject.initialState, { exposeDefaultValues: true });

      // 手动将 Array 转换为 Set
      let states = new Set(plainObject.states);
      let transitions = new Set(plainObject.transitions);
      plainObject.states = new Set<State>();
      plainObject.transitions = new Set<Transition>();
      for (const state of states) {
        plainObject.states.add(plainToClass(State, state, { exposeDefaultValues: true } ));
      }
      for (const transition of transitions) {
        plainObject.transitions.add(plainToClass(Transition, transition, { exposeDefaultValues: true }));
      }

      return plainObject;
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`FSAAutomaton-deserialize-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error('Failed to deserialize FSAAutomaton');
    }
  }
}