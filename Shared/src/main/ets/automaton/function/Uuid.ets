export class Uuid {
  constructor() {}

  static get index(): number {
    // 取当前时间戳的末尾7位
    const timestamp = Date.now().toString(16).slice(-7);

    // 生成6位随机十六进制数
    const randomPart = Array.from<string, string>(
      { length: 6 },
      () => Math.floor(Math.random() * 16).toString(16)
    ).join('');

    const uuidStr = timestamp + randomPart;
    const uuidNumber = parseInt(uuidStr, 16); // 转换为十进制 number

    return uuidNumber;
  }
}
