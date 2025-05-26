import { router } from '@kit.ArkUI';
import { LogUtil } from '@pura/harmony-utils';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Const } from 'shared';

@Entry
@Component
struct test {
  @State message: string = 'test';
  private context?: common.UIAbilityContext;
  async aboutToAppear() {
    this.context = getContext(this) as common.UIAbilityContext;
  }

  startAbility(name: string = '', router: string = ''): void {
    if (!this.context) {
      return;
    }
    let want: Want = {
      bundleName: Const.BUNDLE_NAME,
      abilityName: name,
      parameters: {
        file: false,
        router: router
      }
    };

    this.context.startAbility(want).then(() => {
      LogUtil.info('start video ability success');
    }).catch((error: BusinessError) => {
      LogUtil.error('start video ability failed, error: ' + JSON.stringify(error));
    });
  }

  build() {
    RelativeContainer() {
      Column({ space: 10 }) {
        Button('test1')
          .onClick(() => {
            router.pushUrl({ url: 'pages/test1' })
          })
        Button('Index')
          .onClick(() => {
            router.pushUrl({ url: 'pages/Index' })
          })
        Button('back')
          .onClick(() => {
            router.back()
          })
        // 使用 Array.from 将 IterableIterator 转换为数组
        ForEach(Const.FUNCTION, (item: string) => {
          Row() {
            Text(item)
              .textAlign(TextAlign.Center)
              .fontSize(20)
              .layoutWeight(1)
              .margin(10)
          }
          .width('100%')
          .height(40)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .onClick(() => {
            this.startAbility(Const.FUNCTION_URL_MAP.get(item), 'Index')
          })
        })
      }
      .padding(20)
    }
    .height('100%')
    .width('100%')
  }
}