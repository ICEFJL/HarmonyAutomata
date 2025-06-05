import { LogUtil, DateUtil, FileUtil } from '@pura/harmony-utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { Type as ClzTransType, instanceToPlain, plainToClass } from 'class-transformer';
import 'reflect-metadata';
import {BaseAutomaton,RegexToAutomaton} from '../datastructure/BaseAutomaton';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
export default class Regular_Expression{
  regularexpression :string;
  private pos: number = 0;
  public errorMessage: string = '';

  constructor(regularexpression :string)
  {
    this.regularexpression=regularexpression;
  }

  /*public saveToFile(jsonStr: string, dirPath: string = "", fileName: string = "test.json"): void{
    let path = FileUtil.getFilesDirPath(dirPath, fileName, false);
    let file = FileUtil.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
    let len = FileUtil.writeSync(file.fd, jsonStr);
    FileUtil.closeSync(file.fd); //关闭文件
  }*/
  public saveToFile(dirPath: string = "EX", fileName: string = "test.json"): string {
    try {
      let path = FileUtil.getFilesDirPath(dirPath, fileName);
      let file = FileUtil.openSync(path);
      let len = FileUtil.writeSync(file.fd, this.regularexpression)
      FileUtil.closeSync(file.fd); //关闭文件
      LogUtil.info("保存成功: " + this.regularexpression);
      return  "保存成功";
    } catch (err) {
      let error = err as BusinessError;
      LogUtil.error(`Regular_Expression-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      return  "保存失败";
    }
  }

  public static isEqual(RE1: Regular_Expression, RE2: Regular_Expression): boolean {
    let automaton1 = RegexToAutomaton.convert(RE1.regularexpression);
    automaton1 = BaseAutomaton.convertNFAtoDFA(automaton1);
    automaton1 = BaseAutomaton.minimizeDFA(automaton1);
    let automaton2 = RegexToAutomaton.convert(RE2.regularexpression);
    automaton2 = BaseAutomaton.convertNFAtoDFA(automaton2);
    automaton2 = BaseAutomaton.minimizeDFA(automaton2);
    return BaseAutomaton.isEqual(automaton1,automaton2);
  }

  public isValidRegex(): boolean {
    //this.regularexpression = expr.replace(/\s+/g, '');
    this.pos = 0;
    this.errorMessage = '';

    if (!/^[a-zA-Z0-9ε()+*]*$/.test(this.regularexpression)) {
      this.errorMessage = "包含非法字符，允许的字符为字母、数字、ε、+、*、()";
      return false;
    }

    const valid = this.expression();
    if (!valid) {
      if (this.errorMessage === '') {
        this.errorMessage = "正则表达式结构非法";
      }
      return false;
    }

    if (this.pos !== this.regularexpression.length) {
      this.errorMessage = `正则表达式未完整解析，出错位置：${this.pos}`;
      return false;
    }

    return true;
  }

  private expression(): boolean {
    // 开始时先检查是否是 +，防止开头是 +
    if (this.peek() === '+') {
      this.errorMessage = "表达式不能以 '+' 开头";
      return false;
    }

    if (!this.term()) return false;

    while (this.peek() === '+') {
      this.consume();
      // 检查下一个不是 +，防止连续 ++
      if (this.peek() === '+') {
        this.errorMessage = "表达式不能包含连续的 '+'";
        return false;
      }
      if (!this.term()) {
        this.errorMessage = "'+' 运算符后缺少有效的表达式";
        return false;
      }
    }
    return true;
  }


  private term(): boolean {
    while (this.peek() && this.peek() !== ')' && this.peek() !== '+') {
      if (!this.factor()) return false;
    }
    return true;
  }

  private factor(): boolean {
    if (!this.base()) return false;
    if (this.peek() === '*') {
      this.consume();
    }
    return true;
  }

  private base(): boolean {
    const char = this.peek();
    if (char === '(') {
      this.consume();
      if (!this.expression()) return false;
      if (this.peek() !== ')') {
        this.errorMessage = "括号不匹配，缺少右括号 ')'";
        return false;
      }
      this.consume();
      return true;
    } else if (/[a-zA-Z0-9ε]/.test(char)) {
      this.consume();
      return true;
    }
    this.errorMessage = `无效字符或结构 '${char}'`;
    return false;
  }

  private peek(): string {
    return this.regularexpression[this.pos];
  }

  private consume(): void {
    this.pos++;
  }
}