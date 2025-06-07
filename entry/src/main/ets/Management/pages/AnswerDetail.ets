import { DividerModifier, promptAction, router } from '@kit.ArkUI';
import axios, { AxiosResponse,AxiosError } from '@ohos/axios';
import { ExcerciseItemType } from '../data/excerciseList'
import { ExcerciseResponseDataType,PageType,ResponseType,ExcerciseDetailResponseType,AnswerResponseDataType } from '../data/index'
import { ExcerciseDetailType } from '../data/excerciseDetal'
import { AnswerListItemType } from '../data/answerList'
import { preferences } from '@kit.ArkData';
import { preferenceUtil } from '../utils/PreferencesUtil';

//教师端，答题详情

interface ParamsObj {
  excerciseId: string;
}


@Entry
@Component
struct AnswerDetail {
  @State excerciseId: string = '';
  @State answerList: AnswerListItemType[] = [];
  @State completedNum: number = 0;
  @State uncompletedNum: number = 0;
  @State completedAnswerList: AnswerListItemType[] = [];
  @State uncompletedAnswerList: AnswerListItemType[] = [];
  @State completedPercentage: number = 0;
  @State trueNum: number = 0;
  @State falseNum: number = 0;

  build() {
    Column({space:5}) {

      Gauge({ value: this.completedNum, min: 0, max: this.answerList.length }) {
        Column() {
          Text(this.completedNum.toString())
            .fontSize(20)
            .maxFontSize('60sp')
            .minFontSize('30.0vp')
            .fontWeight(FontWeight.Medium)
            .fontColor("#ff182431")
            .width('62%')
            .textAlign(TextAlign.Center)
            .margin({ top: '35%' })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
          Text('已完成')
            .maxFontSize('16sp')
            .minFontSize("10.0vp")
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Regular)
            .width('67.4%')
            .height('9.5%')
            .textAlign(TextAlign.Center)
        }.width('100%').height('100%')
      }
      .startAngle(225)
      .endAngle(135)
      .colors(Color.Red)
      .width('100%')
      .height('80%')
      .indicator(null)
      .strokeWidth(18)
      .trackShadow({ radius: 7, offsetX: 7, offsetY: 7 })
      .padding(18)

      // List() {
      //   ListItem() {
      //     Text('已完成')
      //       .fontSize(20)
      //       .fontColor('#182431')
      //       .fontWeight(FontWeight.Medium)
      //       .width('100%')
      //       .textAlign(TextAlign.Center)
      //       .margin({ top: 20 })
      //       .textOverflow({ overflow: TextOverflow.Ellipsis })
      //       .maxLines(1)
      //   }
      //   ListItem() {
      //     Text('未完成')
      //       .fontSize(20)
      //       .fontColor('#182431')
      //       .fontWeight(FontWeight.Medium)
      //       .width('100%')
      //       .textAlign(TextAlign.Center)
      //       .margin({ top: 20 })
      //       .textOverflow({ overflow: TextOverflow.Ellipsis })
      //       .maxLines(1)
      //   }
      // }

      }
      .alignItems(HorizontalAlign.Center)
    }

    async aboutToAppear() {
      const param = router.getParams() as ParamsObj;
      this.excerciseId = param.excerciseId;
      console.log('获取答案列表的id',this.excerciseId)
      await this.loadingAnswers();
    }

    async loadingAnswers() {
      try {
        await axios.get('http://192.168.88.1:3001/teacher/answers/'+this.excerciseId,{
          params: {
            //userId:'272'
            userId: preferenceUtil.readData('userId')
          }
        })
          .then((res:AxiosResponse<ResponseType<AnswerResponseDataType<AnswerListItemType>>>) => {
            console.log('获取答案成功',JSON.stringify(res.data.data.result))
            this.answerList = res.data.data.result;
            //分类统计，answer为null的
            for (let i = 0; i < this.answerList.length; i++) {
              if (this.answerList[i].answer == null) {
                this.uncompletedAnswerList.push(this.answerList[i]);
                this.uncompletedNum  = this.uncompletedNum + 1;
              } else {
                this.completedAnswerList.push(this.answerList[i]);
                this.completedNum  = this.completedNum + 1;
              }
            }
            this.completedPercentage = this.completedNum/this.answerList.length*100;
            this.completedPercentage = Math.round(this.completedPercentage);
          })
          .catch((error:AxiosError) =>{
            console.log('获取答案失败',error.message)
          })
      } catch (error) {
        console.log('获取答案失败', error);
        promptAction.showToast({
          message: '获取答案失败',
          duration: 2000,
        })
      }
    }
}