import { DividerModifier, router } from '@kit.ArkUI';
import axios, { AxiosResponse,AxiosError } from '@ohos/axios';
import { ExcerciseItemType } from '../data/excerciseList'
import { ExcerciseResponseDataType,PageType,ResponseType,ExcerciseDetailResponseType } from '../data/index'
import { ExcerciseDetailType } from '../data/excerciseDetal'

//学生端，习题详情页面

interface ParamsObj {
  excerciseId: string;
  excercisePublisher: string;
}
interface ExcerciseInfo {
  id: string;
  title: string;
  content: string;
  //image_url: string;
  publisher: string;
  answer: string;
  type: string;
  createdAt: string;
  updatedAt: string;
}

class DividerTmp {
  strokeWidth: Length = 1
  startMargin: Length = 60
  endMargin: Length = 10
  color: ResourceColor = '#ffe9f0f0'

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth
    this.startMargin = startMargin
    this.endMargin = endMargin
    this.color = color
  }
}

@Entry
@Component
struct ExcerciseDetail {
  @State excerciseId: string = '';
  @State excercisePublisherName: string = '';
  @State excerciseTitle: string = '';
  @State excerciseContent: string = '';
  @State excerciseImageUrl: string = '';
  @State excercisePublisher: string = '';
  @State excerciseAnswer: string = '';
  @State excerciseType: string = '';
  @State excercisePTime: string = '';

  @State egDivider: DividerTmp = new DividerTmp(1, 60, 10, '#ffe9f0f0')

  @State isShowSheet: boolean = false;
  //半模态页面
  @Builder
  SheetBuilder() {
    Column() {
      Button('作图')
        .fontSize(20)
        .fontColor(Color.White)
      Divider().color('#ffe9f0f0').height(10)
      Button('上传文件')
        .fontSize(20)
        .fontColor(Color.White)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceAround)
  }

  build() {
    Column() {
      //头部
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(30)
          .onClick(() => {
            router.back()
          })
        Text('标题:'+this.excerciseTitle)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height(40)
      .backgroundColor(Color.Gray)

      //正体
      Column() {
        List({space:10}) {
          ListItemGroup({space:10}) {
            ListItem() {
              Text('发布者:'+this.excercisePublisherName)
            }
            ListItem() {
              Text('发布时间:'+this.excercisePTime)
            }
            ListItem() {
              Text('类型:'+this.excerciseType)
            }
            ListItem() {
              Column(){
                Text('题目:')
                Text(this.excerciseContent)
              }
              .alignItems(HorizontalAlign.Start)
            }
            // if(this.excerciseImageUrl!=='') {
            //   ListItem() {
            //     Image($r('app.media.ic_auto'))
            //       .width(100)
            //   }
            // }
          }
          .divider(this.egDivider)
          .padding({left:10,right:10,top:10,bottom:10})
        }
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceAround)

      Button() {
        Text('上传答案')
      }
      .width(100)
      .height(40)
      .onClick(() => {
        this.isShowSheet = !this.isShowSheet
      })
      .bindSheet($$this.isShowSheet, this.SheetBuilder(),{
        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 600],
        preferType: SheetType.BOTTOM,
        title: { title: '回答题目' },
      })
    }
    .justifyContent(FlexAlign.SpaceAround)
  }

  aboutToAppear(): void {
    const param = router.getParams() as ParamsObj;
    this.excerciseId = param.excerciseId;
    this.excercisePublisherName = param.excercisePublisher;
    this.loadingExcerciseInfo()
  }

  async loadingExcerciseInfo() {
    try {
      await axios.get('http://192.168.88.1:3001/student/excercises/'+this.excerciseId)
        .then((res:AxiosResponse<ResponseType<ExcerciseDetailResponseType<ExcerciseDetailType>>>) => {
          console.log('获取习题详情成功',JSON.stringify(res.data.data))
          this.excerciseTitle = res.data.data.excercise.title
          this.excerciseContent = res.data.data.excercise.content
          //this.excerciseImageUrl = res.data.data.image_url
          this.excercisePublisher = res.data.data.excercise.publisher
          this.excercisePublisherName = res.data.data.excercise.publisherName
          this.excerciseAnswer = res.data.data.excercise.answer
          this.excerciseType = res.data.data.excercise.type
          this.excercisePTime = res.data.data.excercise.publishTime
        })
        .catch((error:AxiosError) =>{
          console.log('获取习题详情失败',error.message)
        })
    } catch (error) {
      console.log('获取习题详情失败', error);
    }
  }
}