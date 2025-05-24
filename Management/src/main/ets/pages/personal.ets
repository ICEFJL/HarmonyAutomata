import { promptAction, router } from '@kit.ArkUI';
import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
import {preferenceUtil} from "../utils/PreferencesUtil";
import json from '@ohos.util.json';
import { generalUserId } from '../general/userId';

//个人中心

interface RequestQuery {
  userId: string;
}

interface RequestBody {
  current_upassword: string;
  upassword: string;
  upasswordConfirmation: string;
}

interface ParamsObj {
  role: string;
  //userId:  string;
}

interface UserResponseType {
  id:  string;
  uname: string;
  role: string;
  email:  string;
  createdAt: string;
  updatedAt: string;
}

interface ResponseType {
  status: boolean
  message: string
  data: UserResponseType
}

@Entry
@Component
struct Personal {
  @State message: string = '个人中心';
  @State uname: string = '';
  @State isShowSheet: boolean = false;
  @State inputCurrentPwd: string = '';
  @State inputNewPwdOne: string = '';
  @State inputNewPwdTwo: string = '';

  @State userRole: string = '';
  //半模态页面
  @Builder
  SheetBuilder() {
    Column() {
      Button('修改密码')
        .fontSize(20)
        .fontColor(Color.White)
        .position({x:'40%',y:'30%'})
        .onClick(async () => {
          if (this.inputCurrentPwd === '' || this.inputNewPwdOne === '' || this.inputNewPwdTwo === '') {
            promptAction.showToast({
              message: '请输入完整信息',
              duration: 2000,
            });
          }
          else if(this.inputNewPwdOne !== this.inputNewPwdTwo) {
            promptAction.showToast({
              message: '两次密码不一致',
              duration: 2000,
            });
          }
          else {
            const query: RequestQuery = {
              //userId: preferenceUtil.readData('userId'),
              userId: '272'
            };
            const body: RequestBody = {
              current_upassword: this.inputCurrentPwd,
              upassword: this.inputNewPwdOne,
              upasswordConfirmation: this.inputNewPwdTwo,
            };
            let url:string = '';
            if(this.userRole === 'student') {
              url = 'http://localhost:3001/student/users/account';
            } else if(this.userRole === 'teacher') {
              url = 'http://localhost:3001/teacher/users/account';
            } else {
              url = 'http://localhost:3001/admin/users/account';
            }
            await axios.put(url, body, {
              params: query,
            })
              .then((res: AxiosResponse) => {
                console.log('修改密码成功', JSON.stringify(res.data.data))
                // 提示修改成功
                promptAction.showToast({
                  message: '修改成功',
                  duration: 2000,
                });
              })
              .catch((error: AxiosError) => {
                console.error('修改密码失败', error)
                promptAction.showToast({
                  message: error.message,
                  duration: 2000,
                });
              })
          }
        })
      //输入框
      Column() {
        TextInput({
          placeholder: '请输入原密码',
        })
          .margin(10)
          .padding(10)
          .onChange((value: string) => {
            this.inputCurrentPwd = value;
          })
        TextInput({
          placeholder: '请输入新密码',
        })
          .margin(10)
          .padding(10)
          .onChange((value: string) => {
            this.inputNewPwdOne = value;
          })
        TextInput({
          placeholder: '请再次输入新密码',
        })
          .margin(10)
          .padding(10)
          .onChange((value: string) => {
            this.inputNewPwdTwo = value;
          })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceAround)
  }

  build() {
    Column(){
      //顶部
      Row(){
        Image($r('app.media.ic_arrow_left'))
          .width(30)
          .onClick(()=>{
            router.back()
          })
        Text('编辑资料')
          .fontSize(20)
          .fontColor(Color.Gray)
          .position({x:'40%',y:'30%'})
        // Image($r('app.media.ic_more'))
        //   .width(25)
      }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height(40)
        .backgroundColor('#00E5EE')
        .padding({left:10,right:10})
      //中间
      Column(){
        Row(){}.height(10).backgroundColor(Color.Grey)
        Column(){
          //姓名
          Row(){
            Text(this.uname)
              .fontSize(20)
            //从数据库获取对应name
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .height(40)
          .padding({left:10,right:10})

          Row(){}.height(10).backgroundColor(Color.Grey)
          //修改密码
          Row(){
            Text('修改密码')
              .fontSize(20)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({left:10,right:10})
          .onClick(()=>{
            this.isShowSheet = !this.isShowSheet
          })
          .bindSheet($$this.isShowSheet, this.SheetBuilder(),{
            detents: [SheetSize.MEDIUM, SheetSize.LARGE, 600],
            preferType: SheetType.BOTTOM,
            title: { title: '修改密码' },
          })

        }
        .justifyContent(FlexAlign.SpaceAround)
        .width('100%')
        //退出登录
        Button('退出登录')
          .onClick(()=>{
            generalUserId.setUserId('');
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(10)

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Start)
  }

  // 生命周期函数，在页面即将显示时调用
  async aboutToAppear() {
    const params = router.getParams() as ParamsObj;
    this.userRole = params.role;
    console.log('传入的用户类型为：', this.userRole)
    this.fetchUserInfo()

  }

  // 获取用户信息的方法
  async fetchUserInfo() {
    //const userId = generalUserId.getUserId();
    let url:string = '';
    if(this.userRole === 'student') {
       url = 'http://192.168.88.1:3001/student/users/me';
    } else if(this.userRole === 'teacher') {
       url = 'http://192.168.88.1:3001/teacher/users/me';
    } else if(this.userRole === 'admin') {
       url = 'http://192.168.88.1:3001/admin/users/me';
    }
    console.log('获取用户信息url为：', url)
    await axios.get(url,{
      params: {
        //userId: '272'
        userId: preferenceUtil.readData('userId')
      }
    })
      .then((res: AxiosResponse<ResponseType>) => {
        console.log('获取用户信息成功', JSON.stringify(res.data.data))
        this.uname = res.data.data.uname
        console.log('获取用户信息成功',this.uname)
      })
      .catch((error: AxiosError) => {
        console.error('获取用户信息失败', url)
      })

  }
}




