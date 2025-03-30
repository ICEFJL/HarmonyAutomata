import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
export let funcAbilityWant: Want | undefined = undefined;

export default class TuringMachineAbility extends UIAbility {
  uiContext: UIContext | undefined = undefined;
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    funcAbilityWant = want;
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    let url = 'pages/Index';
    if (funcAbilityWant?.parameters?.router) {
      url = 'pages/'+ funcAbilityWant?.parameters?.router;
    }
    windowStage.loadContent(url, (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      let windowClass: window.Window;
      windowStage.getMainWindow((err, data) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', `Failed to obtain the main window. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        windowClass = data;
        this.uiContext = windowClass.getUIContext();
      });
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');

    });
  }

  onNewWant(want: Want) {
    funcAbilityWant = want;
    if (this.uiContext && want.parameters?.router) {
      let router = this.uiContext.getRouter();
      router.replaceUrl({ url: 'pages/' + want.parameters?.router });
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
