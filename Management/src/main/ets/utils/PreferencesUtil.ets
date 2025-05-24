import { preferences } from '@kit.ArkData'
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

export class PreferenceUtil {
  private dataPreferences: preferences.Preferences | null = null;

  init(context:Context,storeName:string) {
    let options:preferences.Options = { name:storeName };
    this.dataPreferences = preferences.getPreferencesSync(context,options);
  }

  set(key:string,value:string){
    if(this.dataPreferences){
      if (this.dataPreferences.hasSync(key)) {
        console.info('已经存在key: ' + key);
      } else {
        // 此处以此键值对不存在时写入数据为例
        this.dataPreferences.putSync(key, value);
        this.save();
        console.info("添加成功");
      }
    }

  }

  readData(key:string,value?:string){
    let val: string = "";
    if(this.dataPreferences){
      val = this.dataPreferences.getSync(key, value?value:"default") as string;
    }
    return val;
  }

  delete(key:string){
    if(this.dataPreferences){
      this.dataPreferences.deleteSync(key);
    }
  }

  save(){
    if(this.dataPreferences){
      this.dataPreferences.flush((err: BusinessError) => {
        if (err) {
          console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
          return;
        }
        console.info('Succeeded in flushing.');
      })
    }
  }
}

const preferenceUtil = new PreferenceUtil()
export { preferenceUtil}


