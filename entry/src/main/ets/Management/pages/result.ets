import { promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

//待使用，待完善

@Entry
@Component
struct Result {


  build() {
    Column({space:10}){
      //顶部
      Row(){
        Text('返回')
          .onClick(()=> {
            router.replaceUrl({
              url:'Management/pages/auto'
            },(err)=> {
              if (err) {
                console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke replaceUrl succeeded.');
            })
          })
          .padding(10)
      }
      .width('100%')
      .height(40)
      .backgroundColor('#00E5EE')
      .justifyContent(FlexAlign.Start)
      //评测结果
      Row(){}
      .width('100%')
      .padding(10)

      Row({space:20}){
        //是否导出
        Button('导出文件')
          .align(Alignment.BottomStart)
        //返回习题页面
        Button('返回主页')
          .align(Alignment.BottomEnd)
          .onClick(()=> {
            router.replaceUrl({
              url:'Management/pages/main'
            },(err)=> {
              if (err) {
                console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke replaceUrl succeeded.');
            })
          })
      }
      .justifyContent(FlexAlign.Center)
      .padding(10)
      .width('100%')
      .height(40)
      .position({x:'0%',y:'95%'})
    }

  }
}