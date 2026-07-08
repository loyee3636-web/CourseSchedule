import { Course } from '../model/Course';
import { CourseDb } from '../database/CourseDb';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { NotificationService } from '../service/NotificationService';
import promptAction from '@ohos.promptAction';
import { AppSettings } from '../model/AppSettings';

@Component
export struct CourseEdit {
  mode: string = 'add';
  courseId: number = 0;
  onSaved?: () => void;
  onBack?: () => void;

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
  private dayNameArr: string[] = ['一', '二', '三', '四', '五', '六', '日'];

  private initWeekList(): number[] {
    const arr: number[] = [];
    for (let i: number = 1; i <= 16; i++) {
      arr.push(i);
    }
    return arr;
  }

  aboutToAppear(): void {
    this.initData();
  }

  async initData(): Promise<void> {
    this.settings = await PreferencesUtil.getInstance().getSettings();
    this.form.semester = this.settings!.currentSemester;
    this.form.weekList = this.initWeekList();

    if (this.mode === 'edit' && this.courseId > 0) {
      const course: Course | null = await CourseDb.getInstance().getCourseById(this.courseId);
      if (course !== null) {
        this.form = course;
      }
    }
  }

  // 切换星期 - 完整替换对象触发UI刷新
  changeDay(): void {
    const newDay: number = this.form.dayOfWeek >= 7 ? 1 : this.form.dayOfWeek + 1;
    const newForm: Course = {
      id: this.form.id,
      name: this.form.name,
      teacher: this.form.teacher,
      classroom: this.form.classroom,
      semester: this.form.semester,
      dayOfWeek: newDay,
      startSection: this.form.startSection,
      endSection: this.form.endSection,
      weekList: this.form.weekList,
      isRemind: this.form.isRemind
    };
    this.form = newForm;
  }

  // 切换开始节次
  changeStartSection(): void {
    if (this.form.startSection >= 10) {
      return;
    }
    const newStart: number = this.form.startSection + 1;
    const newEnd: number = newStart > this.form.endSection ? newStart : this.form.endSection;
    const newForm: Course = {
      id: this.form.id,
      name: this.form.name,
      teacher: this.form.teacher,
      classroom: this.form.classroom,
      semester: this.form.semester,
      dayOfWeek: this.form.dayOfWeek,
      startSection: newStart,
      endSection: newEnd,
      weekList: this.form.weekList,
      isRemind: this.form.isRemind
    };
    this.form = newForm;
  }

  // 切换结束节次
  changeEndSection(): void {
    if (this.form.endSection <= this.form.startSection) {
      return;
    }
    const newEnd: number = this.form.endSection - 1;
    const newForm: Course = {
      id: this.form.id,
      name: this.form.name,
      teacher: this.form.teacher,
      classroom: this.form.classroom,
      semester: this.form.semester,
      dayOfWeek: this.form.dayOfWeek,
      startSection: this.form.startSection,
      endSection: newEnd,
      weekList: this.form.weekList,
      isRemind: this.form.isRemind
    };
    this.form = newForm;
  }

  async saveCourse(): Promise<void> {
    if (this.form.name.trim().length === 0) {
      promptAction.showToast({ message: '请输入课程名称' });
      return;
    }

    let excludeId: number | undefined = undefined;
    if (this.mode === 'edit') {
      excludeId = this.courseId;
    }
    const conflicts: Course[] = await CourseDb.getInstance().checkConflict(this.form, excludeId);

    if (conflicts.length > 0) {
      let names: string = '';
      for (let i: number = 0; i < conflicts.length; i++) {
        if (i > 0) {
          names += '、';
        }
        names += conflicts[i].name;
      }
      promptAction.showToast({ message: '课程冲突：' + names });
      return;
    }

    if (this.mode === 'add') {
      const newId: number = await CourseDb.getInstance().addCourse(this.form);
      this.form.id = newId;
      promptAction.showToast({ message: '新增成功' });
    } else {
      await CourseDb.getInstance().updateCourse(this.form);
      promptAction.showToast({ message: '修改成功' });
    }

    if (this.form.isRemind && this.settings !== null) {
      await NotificationService.getInstance().setCourseReminder(
        this.form,
        this.settings.sectionList,
        this.settings.remindBeforeMin
      );
    } else {
      await NotificationService.getInstance().cancelCourseReminder(this.form.id);
    }

    if (this.onSaved !== undefined) {
      this.onSaved();
    }
  }

  @Builder
  InputRow(label: string, value: string, onChange: (val: string) => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#666666')
        .width(80)
      TextInput({ text: value })
        .layoutWeight(1)
        .backgroundColor('#F5F7FA')
        .borderRadius(8)
        .height(40)
        .onChange((val: string): void => onChange(val))
    }
    .padding(16)
    .width('100%')
    .border({ width: { bottom: 1 }, color: '#EEEEEE' })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  SelectRow(label: string, value: string, onClick: () => void) {
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
          .onClick((): void => {
            if (this.onBack !== undefined) {
              this.onBack();
            }
          })
        Blank()
        Text(this.mode === 'add' ? '新增课程' : '编辑课程')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('保存')
          .fontSize(16)
          .fontColor('#2E7D32')
          .onClick((): void => {
            this.saveCourse();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#EEEEEE' })

      // 表单内容
      Column() {
        this.InputRow('课程名称', this.form.name, (val: string): void => {
          const newForm: Course = {
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
        })
        this.InputRow('授课教师', this.form.teacher, (val: string): void => {
          const newForm: Course = {
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
        })
        this.InputRow('上课教室', this.form.classroom, (val: string): void => {
          const newForm: Course = {
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
        })

        this.SelectRow('星期', '周' + this.dayNameArr[this.form.dayOfWeek - 1], (): void => {
          this.changeDay();
        })

        this.SelectRow('开始节次', '第' + this.form.startSection + '节', (): void => {
          this.changeStartSection();
        })

        this.SelectRow('结束节次', '第' + this.form.endSection + '节', (): void => {
          this.changeEndSection();
        })

        Row() {
          Text('上课提醒')
            .fontSize(15)
            .fontColor('#666666')
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.form.isRemind })
            .onChange((val: boolean): void => {
              const newForm: Course = {
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
  }
}