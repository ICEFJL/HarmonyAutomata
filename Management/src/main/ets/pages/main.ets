
import { promptAction, router } from '@kit.ArkUI';
import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
import {preferenceUtil} from "../utils/PreferencesUtil";

//学生端，主页（下推、图灵、有限、正则）
@Entry
@Component
struct Main {
  @State currentPage: string = 'exercises'
  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_personal'))
          .position({ x: '85%', y: '20%' })
          .width(35)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/personal',
              params: {
                role:'student',
              }
            });
          });
      }
      .width('100%')
      .height(50)
      .align(Alignment.TopStart)
      .backgroundColor('#F8F8F8')
      .shadow({
        color: '#C0C0C0',
        radius: 5
      })
      .padding(10)
      if(this.currentPage === 'exercises') {
        Column(){
          // 下推自动机模块
          Column() {
            Row() {
              Column() {
                Text('下推自动机')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                Text('研究具有堆栈存储器的自动机理论')
                  .fontSize(14)
                  .fontColor('#666666')
              }
            }
          }
          .width('90%')
          .margin({ bottom: 10,top: 10,left: 15 })
          .backgroundColor('#F8F8F8')
          .borderRadius(10)
          .padding(10)
          .shadow({
            color: '#C0C0C0',
            radius: 5
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ExcerciseList',
              params: {
                excerciseType: '下推自动机',
              }
            });
          })

          // 有限自动机模块
          Column() {
            Row() {
              Column() {
                // Image($r('app.media.finite')) // 需替换为实际图标资源路径
                //   .size(40)
              }
              Column() {
                Text('有限自动机')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                Text('学习最基础的自动机类型')
                  .fontSize(14)
                  .fontColor('#666666')
              }
            }
          }
          .width('90%')
          .margin({ bottom: 10, top: 10,left: 15 })
          .backgroundColor('#F8F8F8')
          .borderRadius(10)
          .padding(10)
          .shadow({
            color: '#C0C0C0',
            radius: 5
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ExcerciseList',
              params: {
                excerciseType: '有限自动机'
              }
            });
          })

          // 图灵机模块
          Column() {
            Row() {
              Column() {
              }
              Column() {
                Text('图灵机')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                Text('探索计算理论的基础模型')
                  .fontSize(14)
                  .fontColor('#666666')
              }
            }
          }
          .width('90%')
          .margin({ bottom: 10,top: 10,left: 15 })
          .backgroundColor('#F8F8F8')
          .borderRadius(10)
          .padding(10)
          .shadow({
            color: '#C0C0C0',
            radius: 5
          })
          .onClick(() => {
            router.pushUrl({
              //传参excerciseType
              params: {
                excerciseType: '图灵机',
              },
              url: 'pages/ExcerciseList',
            });
          })

          // 正则表达式模块
          Column() {
            Row() {
              Column() {
              }
              Column() {
                Text('正则表达式')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                Text('掌握字符串模式的形式化表示')
                  .fontSize(14)
                  .fontColor('#666666')
              }
            }
          }
          .width('90%')
          .margin({ bottom: 10, top: 10,left: 15 })
          .backgroundColor('#F8F8F8')
          .borderRadius(10)
          .padding(10)
          .shadow({
            color: '#C0C0C0',
            radius: 5
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ExcerciseList',
              params: {
                excerciseType: '正则表达式',
              }
            });
          })
        }
      }else if(this.currentPage === 'mine'){

      }
    }
  }
}