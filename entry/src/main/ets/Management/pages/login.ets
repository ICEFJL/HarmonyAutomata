import { promptAction, router } from '@kit.ArkUI';
import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
import {preferenceUtil} from "../utils/PreferencesUtil";
import json from '@ohos.util.json';


//定义接口类型
interface LoginRequest {
  login: string;
  upassword: string;
}
interface LoginData {
  userId: string;
}
interface LoginResponse<LoginData> {
  status: boolean;
  message:  string;
  data: LoginData;
}
//let style_isChecked: boolean = false;
let pwd_ischecked: boolean = false;
let input_username: string = "";
let input_password: string = "";
let index_style: number = 0;//0为学生，1为教师，2为管理员

@Entry
@Component
struct login {
  @State message: string = '自动机理论学习平台';
  @State selectedRole: string = '学生端';

  aboutToAppear(): void {
    if(preferenceUtil.readData("username")!="default"){
      input_username = preferenceUtil.readData("username")
    }
    if(preferenceUtil.readData("password")!="default"){
      input_password = preferenceUtil.readData("password")
    }
  }


  build() {
    Scroll(){
      Column({space:30}){
        Image($r("app.media.ic_huawei"))
          .width(50)
        Flex({ justifyContent: FlexAlign.SpaceAround }) {
          Button('学生端')
            .backgroundColor(this.selectedRole === '学生端' ? '#1890FF' : '#F0F0F0')
            .fontColor(this.selectedRole === '学生端' ? '#FFFFFF' : '#000000')
            .width(120)
            .onClick(() => {
              this.selectedRole = '学生端'
              index_style = 0;
            })
          Button('教师端')
            .backgroundColor(this.selectedRole === '教师端' ? '#1890FF' : '#F0F0F0')
            .fontColor(this.selectedRole === '教师端' ? '#FFFFFF' : '#000000')
            .width(120)
            .onClick(() => {
              this.selectedRole = '教师端'
              index_style = 1;
            })
        }
        .padding({ bottom: 20 })
        TextInput({
          placeholder:'请输入邮箱',
          text:input_username
        })
          .onChange((value:string)=>{
            input_username = value;
          })
        TextInput({
          placeholder:'请输入密码',
          text:input_password
        }).type(InputType.Password).onChange((value:string)=>{
          input_password = value;
        })
        Row(){
          Checkbox()
            .select(false)
            .onChange((checked)=>{pwd_ischecked = !pwd_ischecked})
          Text('记住密码')
        }
        .width('100%')
        .height(30)
        //页面切换-》main.ets
        Button('登录')
          .width('100%')
          .onClick(async ()=>{
            if (input_username===''||input_password==='') {
              promptAction.showToast({
                message: '请输入邮箱或密码',
                duration: 2000
              });
              return;
            }
            else {
              //记住密码
              if(pwd_ischecked){
                preferenceUtil.set("username",input_username)
                preferenceUtil.set("password",input_password)
                preferenceUtil.save()
              }
              else{
                //不记住密码
                preferenceUtil.delete("username")
                preferenceUtil.delete("password")
                preferenceUtil.save()
              }
              const requestData: LoginRequest = {
                login: input_username,
                upassword: input_password
              };
              //访问接口
              if (index_style===0) {
                //访问学生端登录接口
                await axios.post('http://192.168.88.1:3001/student/auth/sign_in',requestData)
                  .then(async (res: AxiosResponse<LoginResponse<LoginData>>) => {
                    //单独取出res中的token
                    //const token = JSON.stringify(res.data.data.token);
                    //preferenceUtil.set("token",token);
                    await preferenceUtil.delete('userId')
                    await preferenceUtil.set("userId",JSON.stringify(res.data.data.userId))
                    await preferenceUtil.save()
                    console.log('用户请求成功',JSON.stringify(res.data.data.userId))
                    console.log('用户首选项',JSON.stringify(preferenceUtil.readData("userId")))
                    console.log('用户id',JSON.stringify(input_username))
                    //generalToken.setToken(token);
                    //generalUserId.setUserId(JSON.stringify(res.data.data.userId));
                    router.replaceUrl({
                      url: 'Management/pages/main',

                    },(err)=>{
                      if (err) {
                        console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                        promptAction.showToast({
                          message: '登录失败'+err.message,
                          duration: 2000
                        });
                        return;
                      }
                      console.info('Invoke replaceUrl succeeded.');
                    })
                  })
                  .catch((err: AxiosError) => {
                    console.log('请求失败', err)
                  })
              }
              else if (index_style===1) {
                //教师
                await axios.post('http://192.168.88.1:3001/teacher/auth/sign_in',requestData)
                  .then((res: AxiosResponse) => {
                    preferenceUtil.set("userId",JSON.stringify(res.data.data.userId))
                    console.log('请求成功',JSON.stringify(res.data))
                    router.replaceUrl({
                      url:'Management/pages/tmain'
                    },(err)=>{
                      if (err) {
                        console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                        return;
                      }
                      console.info('Invoke replaceUrl succeeded.');
                    })
                  })
                  .catch((err: AxiosError) => {
                    console.log('请求失败', err)
                  })
              }
              // else if (index_style===2) {
              //   //管理员
              //   await axios.post('http://192.168.88.1:3001/admin/auth/sign_in',requestData)
              //     .then((res: AxiosResponse) => {
              //       preferenceUtil.set("userId",JSON.stringify(res.data.data.userId))
              //       console.log('请求成功',JSON.stringify(res.data))
              //       router.replaceUrl({
              //         url:'Management/pages/tmain'
              //       },(err)=>{
              //         if (err) {
              //           console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
              //           return;
              //         }
              //         console.info('Invoke replaceUrl succeeded.');
              //       })
              //     })
              //     .catch((err: AxiosError) => {
              //       console.log('请求失败', err)
              //     })
              // }

            }

          })
        Row({space:15}){
          //页面切换
          Text('前往注册')
            .onClick(()=> {
              router.pushUrl({
                url: 'Management/pages/register'
              }, (err) => {
                if (err) {
                  console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                  return;
                }
                console.info('Invoke pushUrl succeeded.');
              })
            })
        }
      }
      .width('100%')
      .padding(40)
    }
    .width('100%')
    .height('100%')
  }
}