import { PreferencesUtil } from '../utils/PreferencesUtil';
import { AppSettings, SectionItem } from '../model/AppSettings';
import promptAction from '@ohos.promptAction';

@Component
export struct Settings {
  onBack?: () => void;
  onSettingsChanged?: () => void;
  @State settings: AppSettings | null = null;
  @State showSemesterDialog: boolean = false;

  aboutToAppear(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.settings = await PreferencesUtil.getInstance().getSettings();
  }

  async switchSemester(semester: string): Promise<void> {
    await PreferencesUtil.getInstance().setCurrentSemester(semester);
    if (this.settings !== null) {
      this.settings.currentSemester = semester;
    }
    promptAction.showToast({ message: '已切换到' + semester });
    this.showSemesterDialog = false;
    if (this.onSettingsChanged !== undefined) {
      this.onSettingsChanged();
    }
  }

  async changeRemindTime(delta: number): Promise<void> {
    if (this.settings === null) {
      return;
    }
    const newVal: number = this.settings.remindBeforeMin + delta;
    if (newVal < 1 || newVal > 60) {
      return;
    }
    this.settings.remindBeforeMin = newVal;
    await PreferencesUtil.getInstance().setRemindBeforeMin(newVal);
    if (this.onSettingsChanged !== undefined) {
      this.onSettingsChanged();
    }
  }

  @Builder
  SectionHeader(title: string) {
    Text(title)
      .fontSize(14)
      .fontColor('#666666')
      .width('100%')
      .padding({ left: 16, top: 16, bottom: 8 })
  }

  @Builder
  SettingRow(label: string, value: string, onClick: () => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#333333')
      Blank()
      Text(value)
        .fontSize(15)
        .fontColor('#666666')
      Text(' >')
        .fontSize(15)
        .fontColor('#999999')
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#EEEEEE' })
    .onClick(onClick)
  }

  @Builder
  SemesterSheetBuilder() {
    Column() {
      Text('选择学期')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16 })

      Button('2025-2026-1')
        .width('90%')
        .margin({ bottom: 8 })
        .onClick((): void => {
          this.switchSemester('2025-2026-1');
        })

      Button('2025-2026-2')
        .width('90%')
        .onClick((): void => {
          this.switchSemester('2025-2026-2');
        })
    }
    .width('100%')
    .height(300)
    .padding(16)
  }

  build() {
    Column() {
      // 顶部返回栏
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#2E7D32')
          .onClick((): void => {
            if (this.onBack !== undefined) {
              this.onBack();
            }
          })
        Blank()
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('  ')
          .fontSize(16)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#EEEEEE' })

      // 设置内容
      List() {
        ListItem() {
          this.SectionHeader('学期管理')
        }
        ListItem() {
          this.SettingRow('当前学期', this.settings !== null ? this.settings.currentSemester : '', (): void => {
            this.showSemesterDialog = true;
          })
        }

        ListItem() {
          this.SectionHeader('提醒设置')
        }
        ListItem() {
          Row() {
            Text('提前提醒时间')
              .fontSize(15)
              .fontColor('#333333')
            Blank()
            Text((this.settings !== null ? this.settings.remindBeforeMin : 10).toString() + ' 分钟')
              .fontSize(15)
              .fontColor('#666666')
            Row() {
              Text('-')
                .fontSize(20)
                .width(32)
                .textAlign(TextAlign.Center)
                .onClick((): void => { this.changeRemindTime(-5); })
              Text('+')
                .fontSize(20)
                .width(32)
                .textAlign(TextAlign.Center)
                .onClick((): void => { this.changeRemindTime(5); })
            }
          }
          .padding(16)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .border({ width: { bottom: 1 }, color: '#EEEEEE' })
        }

        ListItem() {
          this.SectionHeader('节次时间')
        }
        ForEach(this.settings !== null ? this.settings.sectionList : [], (item: SectionItem) => {
          ListItem() {
            Row() {
              Text('第' + item.section + '节')
                .fontSize(15)
                .fontColor('#333333')
              Blank()
              Text(item.startTime + ' - ' + item.endTime)
                .fontSize(14)
                .fontColor('#666666')
            }
            .padding(16)
            .width('100%')
            .backgroundColor('#FFFFFF')
            .border({ width: { bottom: 1 }, color: '#EEEEEE' })
          }
        }, (item: SectionItem): string => item.section.toString())
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .bindSheet($$this.showSemesterDialog, this.SemesterSheetBuilder)
  }
}