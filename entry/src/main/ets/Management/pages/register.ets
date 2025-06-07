import { promptAction, router } from '@kit.ArkUI';
import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
import {preferenceUtil} from "../utils/PreferencesUtil";
import json from '@ohos.util.json';


interface RegisterRequest {
  email: string;
  uname: string;
  upassword: string;
}
@Entry
@Component
struct Register {
  @State message: string = 'register';
  @State input_email: string = "";
  @State input_username: string = "";
  @State input_password: string = "";
  @State input_two_password: string = "";

  build() {
    RelativeContainer() {

      Column({space:30}){
        Image($r('app.media.ic_huawei')).width(50)
        TextInput({
          placeholder:'请输入邮箱'
        }).onChange((value:string)=>{this.input_email = value})
        TextInput({
          placeholder:'请输入用户名'
        }).onChange((value:string)=>{this.input_username = value})
        TextInput({
          placeholder:'请输入密码'
        })
          .onChange((value:string)=>{this.input_password = value})
        TextInput({
          placeholder:'请再次输入密码'
        })
          .onChange((value:string)=>{this.input_two_password = value})
        //点击事件，在数据库中添加该用户信息，添加成功后弹出提示框，返回登录界面
        //用户名唯一
        Button('注册')
          .width('100%')
          .onClick(async ()=>{
            if(this.input_email==""||this.input_username==""||this.input_password==""||this.input_two_password=="") {
              //提示用户输入信息
              promptAction.showToast({
                message: '请输入完整信息',
                duration: 2000
              });
            }
            else if(this.input_password!=this.input_two_password) {
              promptAction.showToast({
                message: '请输入相同密码',
                duration: 2000
              });
            }
            else{
              const requestData: RegisterRequest = {
                email: this.input_email,
                uname: this.input_username,
                upassword: this.input_password
              };
              await axios.post('http://localhost:3001/student/auth/sign_up',requestData)
                .then((res: AxiosResponse) => {
                  console.log('注册成功', JSON.stringify(res.data))
                  router.back()
                })
                .catch((err: AxiosError) => {
                  console.log('注册失败',err)
                  promptAction.showToast({
                    message: '邮箱已被注册',
                    duration: 2000
                  });
                })
            }
          })
      }
      .width('100%')
      .padding(40)
    }
    .height('100%')
    .width('100%')
  }
}