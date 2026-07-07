import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { CourseDb } from '../database/CourseDb';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    await CourseDb.getInstance().initDb(this.context);
    await PreferencesUtil.getInstance().init(this.context);
  }

  onDestroy(): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err.code) {
        return;
      }
    });
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}