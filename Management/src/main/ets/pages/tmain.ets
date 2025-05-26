import { promptAction, router } from '@kit.ArkUI';
import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { TabTitleBar } from '@kit.ArkUI'
import { preferenceUtil, PreferenceUtil } from '../utils/PreferencesUtil';
import { ExcerciseResponseDataType ,StudentResponseDataType } from '../data/index';
import { StudentItemType } from '../data/userList';
import { ExcerciseItemType } from '../data/excerciseList'
import { it } from '@ohos/hypium';

//教师端主页

interface AxiosRequestQuery {
  'currentPage': string;
  'pageSize': string;
  'userId': string;
}

interface ExcerciseResponseType {
  status: boolean;
  message: string;
  data: ExcerciseResponseDataType<ExcerciseItemType>;
}

interface UserResponseType {
  status: boolean;
  message: string;
  data: StudentResponseDataType<StudentItemType>;
}

interface  DelResponseType {
  status: boolean;
  message: string;
  data: string[];
}

@Entry
@Component
struct Tmain {
  //@State isShowSheet: boolean = false;
  @State isShowMenu: boolean = false;
  @State select: boolean = true;//true为学生，false为习题
  @State url: string = '';
  @State currentPage: number = 1;
  @State totalPages: number = 1;
  @State pageSize: number = 10;
  @State isListReachEnd: boolean = false;

  @State users: StudentItemType[] = [];
  @State excercises: ExcerciseItemType[] = [];

  //半模态页面
  // @Builder
  // SheetBuilder() {
  //   Column() {
  //     Button('修改密码')
  //       .fontSize(20)
  //       .fontColor(Color.White)
  //       .position({x:'40%',y:'30%'})
  //   }
  //   .alignItems(HorizontalAlign.Center)
  //   .justifyContent(FlexAlign.SpaceAround)
  //   .onAppear(() => {
  //     console.log('半模态页面即将显示')
  //   })
  //   .onDisAppear(() => {
  //     console.log('半模态页面即将隐藏')
  //   })
  // }
  @Builder
  MyMenu() {
    Menu() {
      MenuItem({content: '个人中心'})
        .onClick(() => {
          router.pushUrl({
            url:'pages/personal',
            params: {
              role: 'teacher',
              //userId: preferenceUtil.readData('userId')
              userId: '272'
            }
          })
        })
      MenuItem({content: '添加学生'})
        .onClick(() => {
          router.pushUrl({
            url:'pages/addStudent',
          })
        })

      MenuItem({content: '添加习题'})
        .onClick(() => {
          router.pushUrl({
            url:'pages/addExercise'
          })
        })
    }
    .onAppear(() => {
      console.log('菜单即将显示')
    })
    .onDisAppear(() => {
      console.log('菜单即将隐藏')
    })
  }

  build() {
    Column(){
      //头部
      //搜索学生、习题
      //增加学生、习题
      Row(){
        // Search()
        //   .width('60%')
        Image($r('app.media.ic_more'))
          .width(30)
          .onClick(() => {
            this.isShowMenu = !this.isShowMenu
          })
          .bindMenu(this.isShowMenu,this.MyMenu())
      }
      .height(60)
      .width('100%')
      .backgroundColor(Color.Pink)
      .padding(16)
      .justifyContent(FlexAlign.End)

      Divider().color('#ffe9f0f0')
      //中间
      //点击题目，进入答题情况页面
      //长按学生，删除
      Refresh({refreshing:false}){
        List() {
          //学生列表
          if(this.select === true) {
            ForEach(this.users, (item: StudentItemType, index: number) => {
              ListItem() {
                Column() {
                  Row(){
                    Text(item.id)
                      .fontSize(20)
                      .fontColor(Color.Black)
                      .margin(5)
                      .padding({left: 5, right: 5})
                    Text(item.uname)
                      .fontSize(20)
                      .fontColor(Color.Black)
                      .margin(5)
                      .padding({left: 5, right: 5})
                    Text(item.email)
                      .fontSize(20)
                      .fontColor(Color.Black)
                      .margin(5)
                      .padding({left: 5, right: 5})
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .width('100%')
                .padding({ left: 10, right: 10})
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .padding({ left: 10, right: 10})
              .height(100)
              .layoutWeight(1)
              .backgroundColor('#EEE9E9')
              .margin(10)
              .width('100%')
              .border({ radius: { topLeft: 5, topRight: 5, bottomLeft: 5, bottomRight: 5 },
                style: {
                  left: BorderStyle.Dotted,
                  right: BorderStyle.Dotted,
                  top: BorderStyle.Solid,
                  bottom: BorderStyle.Dashed
                }})

            })
          }
          else if(this.select === false) {
            //习题列表
            ForEach(this.excercises, (item: ExcerciseItemType, index: number) => {
              ListItem() {
                Row() {
                  // Row() {
                  //   Text(item.title)
                  //   Text(item.publishTime)
                  //   Text(item.type)
                  // }
                  Column(){
                    Row() {
                      Text(item.id)
                      //Text(item.title)
                      Text(item.type)
                    }
                    Row(){
                      Text(item.publishTime)
                    }
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  // Column(){
                  //   Image($r('app.media.ic_topmore'))
                  //     .width(20)
                  // }
                }
                .justifyContent(FlexAlign.End)
                .padding({ left: 5, right: 5})
                //长按删除
                .gesture(
                  LongPressGesture({repeat: true})
                    .onAction( () => {
                      //确认是否删除，是则调用接口
                      AlertDialog.show({
                        title:"提示",
                        message:"是否删除该习题？",
                        autoCancel:true,//点击遮障层时，是否关闭弹窗。默认值：true
                        alignment: DialogAlignment.Center,//弹窗在竖直方向上的对齐方式。默认值：DialogAlignment.Default
                        primaryButton: {
                          value: "取消",
                          fontColor: '#181818',
                          action: () => {
                          }
                        },
                        secondaryButton: {
                          value: "确定",
                          fontColor: '#181818',
                          action: async () => {
                            //删除该条习题,并刷新列表
                            await this.deleteExcerciseItem(item.id)
                          }
                        },
                        cornerRadius:12,//弹窗边框弧度
                        width:'80%', //弹窗宽度
                        cancel:()=>{

                        }
                      })
                    })
                    .onActionEnd(() => {
                      //长按结束后刷新列表
                    })
                )
              }
              .padding({ left: 5, right: 5})
              .height(100)
              .layoutWeight(1)
              .backgroundColor('#EEE9E9')
              .margin(10)
              .width('100%')
              .border({ radius: { topLeft: 5, topRight: 5, bottomLeft: 5, bottomRight: 5 },
                style: {
                  left: BorderStyle.Dotted,
                  right: BorderStyle.Dotted,
                  top: BorderStyle.Solid,
                  bottom: BorderStyle.Dashed
                }})
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/TExcerciseDetail',
                  params: {
                    excerciseId: item.id,
                    //excercisePublisher: item.publisher,
                  }
                })
              })
            })
            //默认不显示加载更多
            if(this.isListReachEnd){
              ListItem()  {
                Column() {
                  Image($r('app.media.ic_loading'))
                    .width(100)
                    .margin({top:10})
                }
                .padding({ left: 5, right: 5})
                .layoutWeight(1)
                .margin(10)
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .border({ style: BorderStyle.Solid})
              }
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .padding({ bottom: 10 })
        .onReachEnd(() => {
          //改变isloading效果
          this.isListReachEnd = true;
         })
        .parallelGesture(PanGesture({direction: PanDirection.Up,distance:60})
          .onActionStart(()=>{
            if(this.isListReachEnd) {
              if(this.currentPage<this.totalPages){
                this.currentPage = this.currentPage + 1;
                if(this.select === true) {
                   this.loadingUserList()
                } else if(this.select === false) {
                   this.loadingExcerciseList()
                }
              }
            }
            this.isListReachEnd = false;
          }))
      }
      .width('100%')
      .layoutWeight(1) //高度自适应


      //底部导航栏
      Row(){
        Tabs({barPosition:BarPosition.End}){
          TabContent(){
          }
          .tabBar('学生')
          TabContent(){
          }
          .tabBar('习题')
        }
        .onChange(async () => {
          this.select = !this.select
          this.totalPages = 1;
          this.currentPage = 1;
          if(this.select === true) {
            this.excercises = []
            await this.loadingUserList()
          } else if(this.select === false) {
            this.users = []
            await this.loadingExcerciseList()
          }
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor(Color.Pink)

    }
    .width('100%')
    .height('100%')
  }

  async aboutToAppear() {
    this.select = true
    await this.loadingUserList()
    //await this.loadingExcerciseList()
    promptAction.showToast({
      message: preferenceUtil.readData('userId'),
      duration: 2000,
    })
  }

  async loadingUserList() {
    try {
      const params: AxiosRequestQuery = {
        'currentPage': this.currentPage.toString(),
        'pageSize': this.pageSize.toString(),
        //'userId': '272'
        'userId': preferenceUtil.readData('userId')
        //'userId': generalUserId.getUserId()
      }
      this.url = 'http://192.168.88.1:3001/teacher/users/students';
      const res: AxiosResponse<UserResponseType> = await axios.get<UserResponseType>(this.url, {params:  params});
      if(res.data.status) {
        //this.users = res.data.data.users
        this.users = [...this.users, ...res.data.data.users]
        this.totalPages = res.data.data.pagination.totalPage
      }

    } catch (error) {
      console.error('获取失败：', error);
    }
  }

  async loadingExcerciseList() {
    try {
      const params: AxiosRequestQuery = {
        'currentPage': this.currentPage.toString(),
        'pageSize': this.pageSize.toString(),
        //'userId': '272'
        'userId': preferenceUtil.readData('userId')
        //'userId': generalUserId.getUserId()
      }
      this.url = 'http://192.168.88.1:3001/teacher/excercises/';
      const res: AxiosResponse<ExcerciseResponseType> = await axios.get<ExcerciseResponseType>(this.url, {params:params});
      if(res.data.status) {
        //this.excercises = res.data.data.excercises
        this.excercises = [...this.excercises, ...res.data.data.excercises]
        console.log('获取成功：', JSON.stringify(this.excercises[0].id))
        this.totalPages = res.data.data.pagination.totalPage;
      }
    } catch (error) {
      //console.error('获取失败：', error);
      promptAction.showToast({
        message: '获取失败',
        duration: 2000,
      });
    }
  }

  async deleteExcerciseItem(excerciseId:string) {
    try {
      //const userId:string = preferenceUtil.readData('userId')
      const userId:string = '272'
      await axios.delete('http://192.168.88.1:3001/teacher/excercises/'+excerciseId,{params:{userId:userId}})
        .then((res: AxiosResponse<DelResponseType>) => {
          console.log('删除成功：', JSON.stringify(res.data.message))
          promptAction.showToast({
            message: res.data.message,
            duration: 2000,
          });
        })
        .catch((error: AxiosError<DelResponseType>) => {
          console.error('删除失败：', JSON.stringify(error.response?.data.message))
          promptAction.showToast({
            message: error.response?.data.message,
            duration: 2000,
          });
        })

      //删除后刷新列表
      this.excercises = []
      this.currentPage = 1
      this.totalPages = 1
      await this.loadingExcerciseList()

    } catch (error) {
      console.error('删除失败失败：', error);
    }
  }
}
