import relationalStore from '@ohos.data.relationalStore';
import { AutomatonType } from '../automaton/Type';
import { Const, SAVED_FILE } from './Constants';
import { SavedFile } from './SavedFile';

export class Database {
  static rdbStore: relationalStore.RdbStore | null = null;

  // 创建rdbStore
  static async getRdbStore() {
    try {
      if (Database.rdbStore) {
        return;
      }
      let context = getContext().getApplicationContext();
      let rdb = await relationalStore.getRdbStore(context, {
        name: Const.DATABASE_NAME, // 数据库文件名
        securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
        encrypt: false // 可选参数，是否加密，默认不加密
      });
      Database.rdbStore = rdb;
      Database.rdbStore.executeSql(Const.SQL_CREATE_TABLE);
    } catch (error) {
      console.log('RDBStoreManager', `gerRdbStore() failed, err: ${error}`);
    }
  }

  // 插入数据
  static async insertData(file: SavedFile): Promise<number | null> {
    let data: relationalStore.ValuesBucket = Database.toValuesBucket(file);
    if (Database.rdbStore) {
      try {
        let result = await Database.rdbStore.insert(Const.TABLE_NAME, data);
        return result;
      } catch (error) {
        console.log('RDBStoreManager', `insertData() failed, err: ${JSON.stringify(error)}`);
      }
    }
    return null;
  }

  // 删除数据
  static async deleteData(predicates: relationalStore.RdbPredicates): Promise<number | null> {
    if (Database.rdbStore) {
      try {
        let result = await Database.rdbStore.delete(predicates);
        return result;
      } catch (error) {
        console.log('RDBStoreManager', `deleteData() failed, err: ${error}`);
      }
    }
    return null;
  }

  // 更新数据
  static async updateData(predicates: relationalStore.RdbPredicates, file: SavedFile): Promise<number | null> {
    let data: relationalStore.ValuesBucket = Database.toValuesBucket(file);
    if (Database.rdbStore) {
      try {
        let result = await Database.rdbStore.update(data, predicates);
        return result;
      } catch (error) {
        console.log('RDBStoreManager', `updateData() failed, err: ${error}`);
      }
    }
    return null;
  }

  // 查询数据
  static async query(predicates: relationalStore.RdbPredicates): Promise<SavedFile[] | null> {
    const resultSet = await Database.rdbStore?.query(predicates);
    if (resultSet) {
      const files: SavedFile[] = [];
      while (resultSet.goToNextRow()) {
        files.push(new SavedFile(
          resultSet.getString(resultSet.getColumnIndex(SAVED_FILE.fileName)),
          resultSet.getString(resultSet.getColumnIndex(SAVED_FILE.note)),
          resultSet.getString(resultSet.getColumnIndex(SAVED_FILE.fileType)) as AutomatonType,
          resultSet.getLong(resultSet.getColumnIndex(SAVED_FILE.saveTime))
        ));
      }
      return files;
    }
    return null;
  }

  // 新增类型转换方法
  static toValuesBucket(file: SavedFile): relationalStore.ValuesBucket {
    return {
      fileName: file.fileName,
      note: file.note,
      saveTime: file.saveTime,
      fileType: file.fileType
    };
  }

  static async queryByFileName(filename: string): Promise<SavedFile[] | null> {
    try {
      // 构建查询条件
      let predicates = new relationalStore.RdbPredicates(Const.TABLE_NAME);
      predicates.equalTo(SAVED_FILE.fileName, filename);

      // 执行查询
      return await Database.query(predicates);
    } catch (error) {
      console.log('RDBStoreManager', `queryByFileName() failed, err: ${error}`);
      return null;
    }
  }

  static async deleteByFileName(filename: string): Promise<number | null> {
    try {
      // 构建查询条件
      let predicates = new relationalStore.RdbPredicates(Const.TABLE_NAME);
      predicates.equalTo(SAVED_FILE.fileName, filename);

      // 执行删除
      return await Database.deleteData(predicates);
    } catch (error) {
      console.log('RDBStoreManager', `deleteByFileName() failed, err: ${error}`);
      return null;
    }
  }

  // 获取数据库中所有数据
  static async queryAllData(): Promise<SavedFile[] | null> {
    try {
      let predicates = new relationalStore.RdbPredicates(Const.TABLE_NAME);

      // 执行查询
      return await Database.query(predicates);
    } catch (error) {
      console.log('RDBStoreManager', `queryAllData() failed, err: ${error}`);
      return null;
    }
  }

  // 根据文件名更新数据
  static async updateByFileName(filename: string, file: SavedFile): Promise<number | null> {
    try {
      // 构建查询条件
      let predicates = new relationalStore.RdbPredicates(Const.TABLE_NAME);
      predicates.equalTo(SAVED_FILE.fileName, filename);

      // 执行更新
      return await Database.updateData(predicates, file);
    } catch (error) {
      console.log('RDBStoreManager', `updateByFileName() failed, err: ${error}`);
      return null;
    }
  }
}
