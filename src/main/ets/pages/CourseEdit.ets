import { Course } from '../model/Course';
import { CourseDb } from '../database/CourseDb';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import promptAction from '@ohos.promptAction';
import { AppSettings } from '../model/AppSettings';

@Component
export struct CourseEdit {
  mode: string = 'add';
  courseId: number = 0;
  onSaved: () => void = () => {};
  onBack: () => void = () => {};

  @State settings: AppSettings | null = null;
  @State form: Course = {
    id: 0,
    name: '',
    teacher: '',
    classroom: '',
    semester: '',
    dayOfWeek: 1,
    startSection: 1,
    endSection: 2,
    weekList: [],
    isRemind: true
  };

  // 弹窗控制
  @State showDaySheet: boolean = false;
  @State showStartSectionSheet: boolean = false;
  @State showEndSectionSheet: boolean = false;

  private dayNameArr: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  private sectionArr: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  aboutToAppear(): void {
    this.initData();
  }

  async initData(): Promise<void> {
    this.settings = await PreferencesUtil.getInstance().getSettings();
    this.form.semester = this.settings!.currentSemester;

    let weekArr: number[] = [];
    for (let i: number = 1; i <= 16; i++) {
      weekArr.push(i);
    }
    this.form.weekList = weekArr;

    if (this.mode === 'edit' && this.courseId > 0) {
      let course: Course | null = await CourseDb.getInstance().getCourseById(this.courseId);
      if (course !== null) {
        this.form = course;
      }
    }
  }

  async saveCourse(): Promise<void> {
    if (this.form.name.trim() === '') {
      promptAction.showToast({ message: '请输入课程名称' });
      return;
    }
    if (this.mode === 'add') {
      await CourseDb.getInstance().addCourse(this.form);
      promptAction.showToast({ message: '新增成功' });
    } else {
      await CourseDb.getInstance().updateCourse(this.form);
      promptAction.showToast({ message: '修改成功' });
    }
    this.onSaved();
  }

  // 选择星期
  selectDay(day: number): void {
    this.form.dayOfWeek = day;
    this.showDaySheet = false;
  }

  // 选择开始节次
  selectStartSection(section: number): void {
    this.form.startSection = section;
    // 仅当结束节次小于开始时，自动拉齐，不会主动同步
    if (this.form.endSection < section) {
      this.form.endSection = section;
    }
    this.showStartSectionSheet = false;
  }

  // 选择结束节次
  selectEndSection(section: number): void {
    this.form.endSection = section;
    this.showEndSectionSheet = false;
  }

  // 星期选择弹窗
  @Builder
  DaySheetBuilder() {
    Column() {
      Text('选择星期')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 12 })

      ForEach(this.dayNameArr, (item: string, index: number) => {
        Button(item)
          .type(ButtonType.Normal)
          .backgroundColor(this.form.dayOfWeek === index + 1 ? '#2E7D32' : '#F5F7FA')
          .fontColor(this.form.dayOfWeek === index + 1 ? '#FFFFFF' : '#333333')
          .width('90%')
          .height(44)
          .margin({ bottom: 8 })
          .onClick(() => {
            this.selectDay(index + 1);
          })
      }, (item: string, index: number): string => index.toString())
    }
    .width('100%')
    .height(360)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  // 开始节次选择弹窗
  @Builder
  StartSectionSheetBuilder() {
    Column() {
      Text('选择开始节次')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 12 })

      Scroll() {
        Column() {
          ForEach(this.sectionArr, (item: number) => {
            Button('第' + item + '节')
              .type(ButtonType.Normal)
              .backgroundColor(this.form.startSection === item ? '#2E7D32' : '#F5F7FA')
              .fontColor(this.form.startSection === item ? '#FFFFFF' : '#333333')
              .width('90%')
              .height(44)
              .margin({ bottom: 8 })
              .onClick(() => {
                this.selectStartSection(item);
              })
          }, (item: number): string => item.toString())
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height(400)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  // 结束节次选择弹窗
  @Builder
  EndSectionSheetBuilder() {
    Column() {
      Text('选择结束节次')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 12 })

      Scroll() {
        Column() {
          ForEach(this.sectionArr, (item: number) => {
            // 结束节次必须 >= 开始节次，小于的禁用
            Button('第' + item + '节')
              .type(ButtonType.Normal)
              .backgroundColor(item < this.form.startSection ? '#EEEEEE' :
                (this.form.endSection === item ? '#2E7D32' : '#F5F7FA'))
              .fontColor(item < this.form.startSection ? '#CCCCCC' :
                (this.form.endSection === item ? '#FFFFFF' : '#333333'))
              .width('90%')
              .height(44)
              .margin({ bottom: 8 })
              .enabled(item >= this.form.startSection)
              .onClick(() => {
                this.selectEndSection(item);
              })
          }, (item: number): string => item.toString())
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height(400)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder
  FormRow(label: string, value: string, onClick: () => void) {
    Button() {
      Row() {
        Text(label)
          .fontSize(15)
          .fontColor('#666666')
        Blank()
        Text(value)
          .fontSize(15)
          .fontColor('#333333')
        Text(' >')
          .fontSize(15)
          .fontColor('#999999')
      }
      .width('100%')
    }
    .type(ButtonType.Normal)
    .backgroundColor('#FFFFFF')
    .width('100%')
    .height(56)
    .border({ width: { bottom: 1 }, color: '#EEEEEE' })
    .onClick(onClick)
  }

  build() {
    Column() {
      // 顶部返回栏
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#2E7D32')
          .onClick(() => {
            this.onBack();
          })
        Blank()
        Text(this.mode === 'add' ? '新增课程' : '编辑课程')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('保存')
          .fontSize(16)
          .fontColor('#2E7D32')
          .onClick(() => {
            this.saveCourse();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 表单区域
      Column() {
        // 课程名称
        Row() {
          Text('课程名称')
            .fontSize(15)
            .fontColor('#666666')
            .width(80)
          TextInput({ text: this.form.name })
            .layoutWeight(1)
            .height(40)
            .onChange((val: string) => {
              this.form.name = val;
            })
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#EEEEEE' })

        // 授课教师
        Row() {
          Text('授课教师')
            .fontSize(15)
            .fontColor('#666666')
            .width(80)
          TextInput({ text: this.form.teacher })
            .layoutWeight(1)
            .height(40)
            .onChange((val: string) => {
              this.form.teacher = val;
            })
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#EEEEEE' })

        // 上课教室
        Row() {
          Text('上课教室')
            .fontSize(15)
            .fontColor('#666666')
            .width(80)
          TextInput({ text: this.form.classroom })
            .layoutWeight(1)
            .height(40)
            .onChange((val: string) => {
              this.form.classroom = val;
            })
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#EEEEEE' })

        // 星期选择
        this.FormRow('星期', this.dayNameArr[this.form.dayOfWeek - 1], () => {
          this.showDaySheet = true;
        })

        // 开始节次选择
        this.FormRow('开始节次', '第' + this.form.startSection + '节', () => {
          this.showStartSectionSheet = true;
        })

        // 结束节次选择
        this.FormRow('结束节次', '第' + this.form.endSection + '节', () => {
          this.showEndSectionSheet = true;
        })

        // 上课提醒
        Row() {
          Text('上课提醒')
            .fontSize(15)
            .fontColor('#666666')
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.form.isRemind })
            .onChange((val: boolean) => {
              this.form.isRemind = val;
            })
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .bindSheet($$this.showDaySheet, this.DaySheetBuilder)
    .bindSheet($$this.showStartSectionSheet, this.StartSectionSheetBuilder)
    .bindSheet($$this.showEndSectionSheet, this.EndSectionSheetBuilder)
  }
}