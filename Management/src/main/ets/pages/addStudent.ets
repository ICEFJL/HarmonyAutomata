import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
import { promptAction, router } from '@kit.ArkUI';
import { preferenceUtil } from '../utils/PreferencesUtil';

//教师端，添加学生

interface RequestQuery {
  userId: string;
}

interface RequestBody {
  id: string;
}

interface ResponseErrorType {
  status: boolean
  message: string
  errors: string[]
}

@Entry
@Component

struct AddStudent {

  @State studentId:string  = ''
  build() {
    Column({space: 100}) {
      //顶部
      Row(){
        Image($r('app.media.ic_arrow_left'))
          .width(30)
          .onClick(()=> {
            router.back()
          })
      }
      .width('100%')
      .height(30)

      //请输入学生ID
      TextInput({
        placeholder: '请输入学生ID'
      })
        .margin({left: 10, right: 10})
        .onChange((value: string) => {
          this.studentId = value
        })

      Button()  {
        Text('添加')
      }
      .width(100)
      .height(50)
      .onClick(async () => {
        const params: RequestQuery = {
          //userId: '272'
          userId:  preferenceUtil.readData('userId')
        }
        const body: RequestBody = {
          id: this.studentId
        }
        await axios.post('http://192.168.88.1:3001/teacher/users/ts', body, { params })
          .then((res: AxiosResponse) => {
            console.log('添加学生成功', JSON.stringify(res.data.data))
            promptAction.showToast({
              message: '添加成功',
              duration: 2000,
            });
          })
          .catch((error: AxiosError<ResponseErrorType>) => {
            console.error('添加学生失败', JSON.stringify(error.response?.data.errors[0]))
            if(error.response?.data.errors[0] === 'Cannot read properties of undefined (reading \'query\')'){
              promptAction.showToast({
                message: '添加成功',
                duration: 2000,
              });
            }else {
              promptAction.showToast({
                message: error.response?.data.errors[0],
                duration: 2000,
              })
            }
          })
      })
    }
    .justifyContent(FlexAlign.Start)
  }


}