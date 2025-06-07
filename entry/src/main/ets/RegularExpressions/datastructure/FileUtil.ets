import fileio from '@ohos.fileio';
import util from '@ohos.util';
import { BusinessError } from '@ohos.base';
import { ToastUtil } from '@pura/harmony-utils';
export class FileUtil {
  // 默认沙箱路径（适用于数据持久化）
  static readonly basePath: string = '/data/storage/el2/base/files';

  static getFilesDirPath(dir: string, fileName: string): string {
    return `${FileUtil.basePath}/${dir}/${fileName}`;
  }

  static ensureDirExists(dirPath: string): void {
    const fullPath: string = `${FileUtil.basePath}/${dirPath}`;
    try {
      fileio.mkdirSync(fullPath);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      if (error.code !== -4011) {
        console.error("创建目录失败:", JSON.stringify(err));
      }
    }
  }

  static listFiles(dir: string): string[] {
    const fullPath: string = `${FileUtil.basePath}/${dir}`;
    const files: string[] = [];
    try {
      const dirHandle = fileio.opendirSync(fullPath);
      let entry: fileio.Dirent | null;
      while ((entry = dirHandle.readSync()) !== null) {
        if (entry.name.endsWith('.json') && !entry.isDirectory()) {
          files.push(entry.name);
        }
      }
      dirHandle.closeSync();
    } catch (err) {
      console.error("读取文件列表失败:", JSON.stringify(err));
    }
    return files;
  }

  static readFile(dir: string, fileName: string): string {
    const filePath = FileUtil.getFilesDirPath(dir, fileName);
    try {
      const fd = fileio.openSync(filePath, 0o0); // 只读模式
      const stat = fileio.fstatSync(fd);
      const buffer = new ArrayBuffer(stat.size);
      fileio.readSync(fd, buffer);
      fileio.closeSync(fd);

      const decoder = new util.TextDecoder('utf-8');
      const uint8Array = new Uint8Array(buffer);  // ✅ 正确包装
      console.log("读取文件"+decoder.decode(uint8Array));
      return decoder.decode(uint8Array);          // ✅ 解码字符串
    } catch (err) {
      console.error('读取文件失败:', JSON.stringify(err));
      return '';
    }
  }

  static writeFile(dir: string, fileName: string, content: string): boolean {
    FileUtil.ensureDirExists(dir);
    const filePath = FileUtil.getFilesDirPath(dir, fileName);

    try {
      // 打开文件：O_CREAT | O_RDWR
      const fd = fileio.openSync(filePath, 0o102, 0o666);

      // 把字符串编码为 UTF-8 二进制数据
      const encoder = new util.TextEncoder(); // 通过 util 模块引入（见说明）
      const encoded = encoder.encode(content);

      const decoder = new util.TextDecoder('utf-8');
      const decoded = decoder.decode(encoded);
      console.log("decoded:"+decoded); // 应该输出 "ε"

      fileio.writeSync(fd, encoded.buffer);
      fileio.closeSync(fd);
      return true;
    } catch (err) {
      console.error("写入文件失败:", JSON.stringify(err));
      return false;
    }
  }


  static deleteFile(dir: string, fileName: string): boolean {
    const filePath = FileUtil.getFilesDirPath(dir, fileName);
    try {
      fileio.unlinkSync(filePath);
      return true;
    } catch (err) {
      console.error("删除文件失败:", JSON.stringify(err));
      return false;
    }
  }

  static exportFile(dir: string, fileName: string): boolean {
    const sourcePath = FileUtil.getFilesDirPath(dir, fileName);
    const destPath = `/storage/media/100/local/files/${fileName}`;
    try {
      const srcFd = fileio.openSync(sourcePath, 0o0);
      const dstFd = fileio.openSync(destPath, 0o102, 0o666);
      const buffer = new ArrayBuffer(1024);
      let bytesRead = 0;
      while ((bytesRead = fileio.readSync(srcFd, buffer)) > 0) {
        const writeBuffer = buffer.slice(0, bytesRead);
        fileio.writeSync(dstFd, writeBuffer);
      }
      fileio.closeSync(srcFd);
      fileio.closeSync(dstFd);
      return true;
    } catch (err) {
      console.error("导出文件失败:", JSON.stringify(err));
      return false;
    }
  }

  static saveFile(dir: string, fileName: string, content: string): boolean {
    const filePath = FileUtil.getFilesDirPath(dir, fileName);
    try {
      fileio.accessSync(filePath); // 如果文件存在，不会抛异常
      // 文件存在
      console.error("文件已存在:", filePath);
      return false;
    } catch (e) {
      // 文件不存在，可以继续写入
      return FileUtil.writeFile(dir, fileName, content);
    }
  }

}
