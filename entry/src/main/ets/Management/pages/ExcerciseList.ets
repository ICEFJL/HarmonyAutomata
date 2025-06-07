// import { promptAction, router } from '@kit.ArkUI';
// import { BusinessError } from '@kit.BasicServicesKit';
// import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
//
// @Entry
// @Component
// struct Auto {
//
//   build() {
//     Column() {
//       Row() {
//         Text('返回')
//           .onClick(()=> {
//             router.back()
//           })
//         //刷新
//         Image($r('app.media.ic_refresh'))
//           .width(30)
//           .onClick(()=> {
//
//           })
//       }
//       .width('100%')
//       .height(50)
//       .padding({left:10,right:10})
//       .backgroundColor('#00E5EE')
//       .justifyContent(FlexAlign.SpaceBetween)
//       //题目列表
//       List({space:10}){
//         //当数据库中没有该学生提交的答案时，进入答题页面，否则显示已完成
//         //访问http://localhost:3001/student/excercises/接口
//       }
//       .scrollBar(BarState.Auto)
//
//       //分情况判断正确性（语法）和等价性
//       //主要是判断有限自动机和正则表达式
//     }
//     .width('100%')
//     .height('100%')
//     .padding(0)
//
//   }
// }
import { promptAction, router } from '@kit.ArkUI';
import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
import {preferenceUtil} from "../utils/PreferencesUtil";
import json from '@ohos.util.json';
import { ExcerciseItemType } from '../data/excerciseList'
import { ExcerciseResponseDataType,PageType } from '../data/index'

//学生端，习题列表页面

interface ParamsObj {
  excerciseType: string;
}

interface AxiosRequestQuery {
  'currentPage': string;
  'pageSize': string;
  'excerciseType': string;
  'userId': string;
}

interface ResponseType {
  status: boolean;
  message: string;
  data: ExcerciseResponseDataType<ExcerciseItemType>;
}

@Entry
@Component
struct Auto {
  @State excerciseType:string = '';//习题类型

  // 当前选中的分类，默认全部
  @State selectedCategory: string = '全部';
  // 存储习题数据的列表
  @State excercises :ExcerciseItemType[] = [];
  // 当前页码
  @State currentPage: number = 1;
  // 每页数量
  @State pageSize: number = 5;
  // 总页数
  @State totalPages: number = 0;
  // 是否正在加载中
  @State isLoading: boolean = false;

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(30)
          .onClick(() => {
            router.back()
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(40)
      .backgroundColor('#F8F8F8')
      .shadow({
        color: '#C0C0C0',
        radius: 5
      })

      // 顶部导航栏
      Row() {
        Button('全部')
          .backgroundColor(this.selectedCategory === '全部' ? '#1890FF' : '#F0F0F0')
          .onClick(() => {
            this.selectedCategory = '全部';
            this.currentPage = 1;
            this.excercises = [];
            this.totalPages = 0;
            this.loadExcercises('http://192.168.88.1:3001/student/excercises');
          });
        Button('未完成')
          .backgroundColor(this.selectedCategory === '未完成' ? '#1890FF' : '#F0F0F0')
          .onClick(() => {
            this.currentPage = 1;
            this.excercises = [];
            this.totalPages = 0;
            this.selectedCategory = '未完成';
            this.loadExcercises('http://192.168.88.1:3001/student/excercises/uncompleted');
          });
        Button('已完成')
          .backgroundColor(this.selectedCategory === '已完成' ? '#1890FF' : '#F0F0F0')
          .onClick(() => {
            this.currentPage = 1;
            this.excercises = [];
            this.totalPages = 0;
            this.selectedCategory = '已完成';
            this.loadExcercises('http://192.168.88.1:3001/student/excercises/completed');
          });
      }
      .padding({ top: 10, bottom: 10 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 习题列表
      Refresh({refreshing:false}) {
        List() {
          ForEach(this.excercises, (item: ExcerciseItemType, index: number) => {
            ListItem() {
              Column() {
                //习题标题
                Row() {
                  Text(item.title)
                    .margin({ left: 10, right: 10,top:10,bottom:10})
                }
                //.padding({left:40,top:5})
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                //习题发布者、发布时间
                Row() {
                  Text(item.publisherName)
                    .margin({ left: 10, right: 10})
                  Text(item.publishTime)
                    .margin({ left: 10, right: 10})
                }
                .padding({left:40,top:5})
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
            .onClick(() => {
              router.pushUrl({
                url: 'Management/pages/ExcerciseDetail',
                params: {
                  excerciseId:item.id,
                  excercisePublisher:item.publisherName,
                }
              })
            })

          })
          //默认不显示加载更多
          // if(this.isLoading){
          //   ListItem()  {
          //     Column() {
          //       Image($r('app.media.ic_loading'))
          //         .width(100)
          //         .margin({top:10})
          //     }
          //     .justifyContent(FlexAlign.Center)
          //     .alignItems(HorizontalAlign.Center)
          //     .width('100%')
          //     .height(100)
          //     .backgroundColor(Color.White)
          //   }
          // }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Color.White)
        .padding({ bottom: 10 })
        .onReachEnd(() => {
          //改变isloading效果
          this.isLoading = true;
        })
        .parallelGesture(PanGesture({direction: PanDirection.Up,distance:60})
          .onActionStart(()=>{
            if(this.isLoading) {
              if(this.currentPage<this.totalPages){
                this.currentPage = this.currentPage + 1;
                if(this.selectedCategory === '全部') {
                  this.loadExcercises('http://192.168.88.1:3001/student/excercises');
                } else if(this.selectedCategory === '未完成') {
                  this.loadExcercises('http://192.168.88.1:3001/student/excercises/uncompleted');
                } else if(this.selectedCategory === '已完成') {
                  this.loadExcercises('http://192.168.88.1:3001/student/excercises/completed');
                }
              }
            }
            this.isLoading = false;
          }))
      }

    }
    .width('100%')
    .padding(20);
  }

  //获取传入的习题类型参数
  async aboutToAppear() {
    //获取习题类型
    const params = router.getParams() as ParamsObj;
    this.excerciseType = params.excerciseType;
    console.log('传入的习题类型为：', this.excerciseType)
    //执行函数
    if(this.selectedCategory === '全部') {
      await this.loadExcercises('http://192.168.88.1:3001/student/excercises');
    }else if(this.selectedCategory === '未完成') {
      await this.loadExcercises('http://192.168.88.1:3001/student/excercises/uncompleted');
    }else if(this.selectedCategory === '已完成') {
      await this.loadExcercises('http://192.168.88.1:3001/student/excercises/completed');
    }
  }

  async loadExcercises(url: string) {
    // 获取本地存储的token
    try {
      // const token = preferenceUtil.readData('token');
      // console.log('token为：',generalToken.getToken())
      const params: AxiosRequestQuery = {
        'currentPage': this.currentPage.toString(),
        'pageSize': this.pageSize.toString(),
        'excerciseType': this.excerciseType,
        //'userId': generalUserId.getUserId(),
        'userId':preferenceUtil.readData('userId').toString()
        //userId:'271'
      };
      const res: AxiosResponse<ResponseType> = await axios.get<ResponseType>(url,{ params: params });
      if(res.data.status) {
        this.excercises = [...this.excercises,...res.data.data.excercises]
        //console.log('获取习题数据成功:', JSON.stringify());
        //将totalPages转化为number类型
        this.totalPages = Number(res.data.data.pagination.total)/this.pageSize;
      }
    } catch (error) {
      console.error('获取本地存储的token失败：', error);
    }
  }


}
