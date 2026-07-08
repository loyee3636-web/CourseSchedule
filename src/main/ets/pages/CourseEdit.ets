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

  @State showSheet: boolean = false;
  @State sheetType: string = '';

  private dayNameArr: string[] = ['一', '二', '三', '四', '五', '六', '日'];
  private sectionArr: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  aboutToAppear(): void {
    this.initData();
  }

  async initData(): Promise<void> {
    this.settings = await PreferencesUtil.getInstance().getSettings();
    let weekArr: number[] = [];
    for (let i: number = 1; i <= 16; i++) {
      weekArr.push(i);
    }
    this.form = {
      id: 0,
      name: '',
      teacher: '',
      classroom: '',
      semester: this.settings!.currentSemester,
      dayOfWeek: 1,
      startSection: 1,
      endSection: 2,
      weekList: weekArr,
      isRemind: true
    };

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

  onSelectDay(index: number): void {
    let newForm: Course = {
      id: this.form.id,
      name: this.form.name,
      teacher: this.form.teacher,
      classroom: this.form.classroom,
      semester: this.form.semester,
      dayOfWeek: index + 1,
      startSection: this.form.startSection,
      endSection: this.form.endSection,
      weekList: this.form.weekList,
      isRemind: this.form.isRemind
    };
    this.form = newForm;
    this.showSheet = false;
  }

  onSelectStartSection(section: number): void {
    let newEnd: number = this.form.endSection;
    if (newEnd < section) {
      newEnd = section;
    }
    let newForm: Course = {
      id: this.form.id,
      name: this.form.name,
      teacher: this.form.teacher,
      classroom: this.form.classroom,
      semester: this.form.semester,
      dayOfWeek: this.form.dayOfWeek,
      startSection: section,
      endSection: newEnd,
      weekList: this.form.weekList,
      isRemind: this.form.isRemind
    };
    this.form = newForm;
    this.showSheet = false;
  }

  onSelectEndSection(section: number): void {
    let newForm: Course = {
      id: this.form.id,
      name: this.form.name,
      teacher: this.form.teacher,
      classroom: this.form.classroom,
      semester: this.form.semester,
      dayOfWeek: this.form.dayOfWeek,
      startSection: this.form.startSection,
      endSection: section,
      weekList: this.form.weekList,
      isRemind: this.form.isRemind
    };
    this.form = newForm;
    this.showSheet = false;
  }

  @Builder
  SheetBuilder() {
    Column() {
      if (this.sheetType === 'day') {
        Text('选择星期')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 16, bottom: 12 });
      } else if (this.sheetType === 'start') {
        Text('选择开始节次')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 16, bottom: 12 });
      } else if (this.sheetType === 'end') {
        Text('选择结束节次')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 16, bottom: 12 });
      }

      Scroll() {
        Column() {
          if (this.sheetType === 'day') {
            ForEach(this.dayNameArr, (item: string, index: number) => {
              Button(item)
                .type(ButtonType.Normal)
                .backgroundColor(this.form.dayOfWeek === index + 1 ? '#2E7D32' : '#F5F7FA')
                .fontColor(this.form.dayOfWeek === index + 1 ? '#FFFFFF' : '#333333')
                .width('90%')
                .height(44)
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.onSelectDay(index);
                });
            }, (item: string, index: number): string => index.toString());
          } else {
            ForEach(this.sectionArr, (item: number) => {
              Button('第' + item + '节')
                .type(ButtonType.Normal)
                .backgroundColor(
                  this.sheetType === 'end' && item < this.form.startSection
                    ? '#EEEEEE'
                    : (this.sheetType === 'start' && this.form.startSection === item)
                    || (this.sheetType === 'end' && this.form.endSection === item)
                    ? '#2E7D32'
                    : '#F5F7FA'
                )
                .fontColor(
                  this.sheetType === 'end' && item < this.form.startSection
                    ? '#CCCCCC'
                    : (this.sheetType === 'start' && this.form.startSection === item)
                    || (this.sheetType === 'end' && this.form.endSection === item)
                    ? '#FFFFFF'
                    : '#333333'
                )
                .width('90%')
                .height(44)
                .margin({ bottom: 8 })
                .enabled(!(this.sheetType === 'end' && item < this.form.startSection))
                .onClick(() => {
                  if (this.sheetType === 'start') {
                    this.onSelectStartSection(item);
                  } else {
                    this.onSelectEndSection(item);
                  }
                });
            }, (item: number): string => item.toString());
          }
        }
        .width('100%');
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height(400)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 });
  }

  build() {
    Column() {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#2E7D32')
          .onClick(() => {
            this.onBack();
          });
        Blank();
        Text(this.mode === 'add' ? '新增课程' : '编辑课程')
          .fontSize(18)
          .fontWeight(FontWeight.Medium);
        Blank();
        Text('保存')
          .fontSize(16)
          .fontColor('#2E7D32')
          .onClick(() => {
            this.saveCourse();
          });
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF');

      Column() {
        Row() {
          Text('课程名称')
            .fontSize(15)
            .fontColor('#666666')
            .width(80);
          TextInput({ text: this.form.name })
            .layoutWeight(1)
            .height(40)
            .onChange((val: string) => {
              let newForm: Course = {
                id: this.form.id,
                name: val,
                teacher: this.form.teacher,
                classroom: this.form.classroom,
                semester: this.form.semester,
                dayOfWeek: this.form.dayOfWeek,
                startSection: this.form.startSection,
                endSection: this.form.endSection,
                weekList: this.form.weekList,
                isRemind: this.form.isRemind
              };
              this.form = newForm;
            });
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#EEEEEE' });

        Row() {
          Text('授课教师')
            .fontSize(15)
            .fontColor('#666666')
            .width(80);
          TextInput({ text: this.form.teacher })
            .layoutWeight(1)
            .height(40)
            .onChange((val: string) => {
              let newForm: Course = {
                id: this.form.id,
                name: this.form.name,
                teacher: val,
                classroom: this.form.classroom,
                semester: this.form.semester,
                dayOfWeek: this.form.dayOfWeek,
                startSection: this.form.startSection,
                endSection: this.form.endSection,
                weekList: this.form.weekList,
                isRemind: this.form.isRemind
              };
              this.form = newForm;
            });
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#EEEEEE' });

        Row() {
          Text('上课教室')
            .fontSize(15)
            .fontColor('#666666')
            .width(80);
          TextInput({ text: this.form.classroom })
            .layoutWeight(1)
            .height(40)
            .onChange((val: string) => {
              let newForm: Course = {
                id: this.form.id,
                name: this.form.name,
                teacher: this.form.teacher,
                classroom: val,
                semester: this.form.semester,
                dayOfWeek: this.form.dayOfWeek,
                startSection: this.form.startSection,
                endSection: this.form.endSection,
                weekList: this.form.weekList,
                isRemind: this.form.isRemind
              };
              this.form = newForm;
            });
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ width: { bottom: 1 }, color: '#EEEEEE' });

        Button() {
          Row() {
            Text('星期')
              .fontSize(15)
              .fontColor('#666666');
            Blank();
            Text(this.dayNameArr[this.form.dayOfWeek - 1])
              .fontSize(15)
              .fontColor('#333333');
            Text(' >')
              .fontSize(15)
              .fontColor('#999999');
          }
          .width('100%');
        }
        .type(ButtonType.Normal)
        .backgroundColor('#FFFFFF')
        .width('100%')
        .height(56)
        .border({ width: { bottom: 1 }, color: '#EEEEEE' })
        .onClick(() => {
          this.sheetType = 'day';
          this.showSheet = true;
        });

        Button() {
          Row() {
            Text('开始节次')
              .fontSize(15)
              .fontColor('#666666');
            Blank();
            Text('第' + this.form.startSection + '节')
              .fontSize(15)
              .fontColor('#333333');
            Text(' >')
              .fontSize(15)
              .fontColor('#999999');
          }
          .width('100%');
        }
        .type(ButtonType.Normal)
        .backgroundColor('#FFFFFF')
        .width('100%')
        .height(56)
        .border({ width: { bottom: 1 }, color: '#EEEEEE' })
        .onClick(() => {
          this.sheetType = 'start';
          this.showSheet = true;
        });

        Button() {
          Row() {
            Text('结束节次')
              .fontSize(15)
              .fontColor('#666666');
            Blank();
            Text('第' + this.form.endSection + '节')
              .fontSize(15)
              .fontColor('#333333');
            Text(' >')
              .fontSize(15)
              .fontColor('#999999');
          }
          .width('100%');
        }
        .type(ButtonType.Normal)
        .backgroundColor('#FFFFFF')
        .width('100%')
        .height(56)
        .border({ width: { bottom: 1 }, color: '#EEEEEE' })
        .onClick(() => {
          this.sheetType = 'end';
          this.showSheet = true;
        });

        Row() {
          Text('上课提醒')
            .fontSize(15)
            .fontColor('#666666');
          Blank();
          Toggle({ type: ToggleType.Switch, isOn: this.form.isRemind })
            .onChange((val: boolean) => {
              let newForm: Course = {
                id: this.form.id,
                name: this.form.name,
                teacher: this.form.teacher,
                classroom: this.form.classroom,
                semester: this.form.semester,
                dayOfWeek: this.form.dayOfWeek,
                startSection: this.form.startSection,
                endSection: this.form.endSection,
                weekList: this.form.weekList,
                isRemind: val
              };
              this.form = newForm;
            });
        }
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF');
      }
      .width('100%')
      .margin({ top: 12 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .bindSheet($$this.showSheet, this.SheetBuilder);
  }
}