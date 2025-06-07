import { promptAction, router } from '@kit.ArkUI';
import axios,{AxiosError,AxiosResponse} from '@ohos/axios';
import picker from '@ohos.file.picker';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { preferenceUtil } from '../utils/PreferencesUtil';

//教师端，添加习题

interface Body {
  title: string;
  type: string;
  content: string;
  //image_url: string;
  answer: string;
  userId: string;
}

@Entry
@Component
struct AddExercise {
  @State excerciseTitle: string = '';
  @State excerciseType: string = '有限自动机';
  @State excerciseContent: string = '';
  @State excerciseImageUrl: string = '';
  @State excerciseAnswer: string = '';

  build() {
    Column(){
      Row(){
        Image($r('app.media.ic_arrow_left'))
          .width(30)
          .onClick(()=> {
            router.back()
          })
      }
      .width('100%')
      .height(30)
      Row() {
        Text('标题')
          .margin({left:5,right:5})
        TextInput()
          .width('100%')
          .height(50)
          .padding({left:10,right:10})
          .onChange((value: string) => {
            this.excerciseTitle = value;
          })
      }
      .justifyContent(FlexAlign.Start).width('100%')
      //题目类型
      Row() {
        Column(){
          Text('题目类型')
        }.justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Start)
        Column(){
          Row() {
            Radio({value: '1',group:'radioGroup'})
              .width(20).height(20)
              .onClick(() => {
                this.excerciseType = '有限自动机'
              })
            Text('有限自动机')
          }
          Row() {
            Radio({value: '2',group:'radioGroup'})
              .width(20).height(20)
              .onClick(() => {
                this.excerciseType = '下推自动机'
              })
            Text('下推自动机')
          }
        }
        Column(){
          Row() {
            Radio({value: '3',group:'radioGroup'})
              .width(20).height(20)
              .onClick(() => {
                this.excerciseType = '正则表达式'
              })
            Text('正则表达式')
          }
          Row() {
            Radio({value: '4',group:'radioGroup'})
              .width(20).height(20)
              .onClick(() => {
                this.excerciseType = '图灵机'
              })
            Text('图灵机')
          }
        }
      }.justifyContent(FlexAlign.SpaceAround).width('100%')

      Row(){
        Text('题干')
          .margin({left:5,right:5})
        TextArea()
          .onChange((value: string) => {
            this.excerciseContent = value;
          })
      }.width('100%').height(50).justifyContent(FlexAlign.SpaceBetween)
      // Row(){
      //   Text('上传图片')
      //     .margin({left:5})
      // }.width('100%').height(50).justifyContent(FlexAlign.Start)
      // Row(){
      //   //点击事件
      //   Image($r("app.media.ic_uploadfile"))
      //     .width(100)
      //     .onClick(async () => {
      //       //打开相册，上传图片
      //       let photoPicker = new photoAccessHelper.PhotoViewPicker();
      //       const res = await photoPicker.select({
      //         //可选择的媒体文件类型，若无此参数，则默认为图片和视频类型。
      //         MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
      //         //选择媒体文件的最大数量
      //         maxSelectNumber: 1
      //       })
      //       //完成后,获取图片的url
      //
      //     })
      // }
      // .width('100%')
      // .justifyContent(FlexAlign.Center)
      Row(){
        //点击事件，点击进入作图界面，上传文件
        Text('上传答案')
          .margin({left:5})
      }.width('100%').height(50).justifyContent(FlexAlign.Start)
      Row(){
        Image($r("app.media.ic_uploadfile"))
          .width(100)
          .onClick(() => {
            //打开本地文件夹，上传答案

            //完成后
            this.excerciseAnswer = '';
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      Row(){
        Button('取消')
          .onClick(()=> {
            router.back()
          })
        Button('完成')
          .onClick(async ()=> {
            const body: Body = {
              title: this.excerciseTitle,
              type: this.excerciseType,
              content: this.excerciseContent,
              //image_url: 'image',
              //answer: '100',
              answer:this.excerciseAnswer,
              //userId: '272'
              userId:preferenceUtil.readData('userId')
            };
            console.log('body', JSON.stringify(body))
            await axios.post('http://192.168.88.1:3001/teacher/excercises/', body)
              .then((res: AxiosResponse) => {
                console.log('添加题目成功', JSON.stringify(res.data.data))
                // 提示添加成功
                promptAction.showToast({
                  message: '添加成功',
                  duration: 2000
                })
              })
              .catch((error: AxiosError) => {
                console.error('添加题目失败', error)
                promptAction.showToast({
                  message: '添加失败',
                  duration: 2000
                })
              })
            router.back()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.SpaceBetween)

  }
}