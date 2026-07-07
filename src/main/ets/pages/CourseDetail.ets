import { Course } from '../model/Course';
import { CourseDb } from '../database/CourseDb';
import { NotificationService } from '../service/NotificationService';
import promptAction from '@ohos.promptAction';

@Component
export struct CourseDetail {
  courseId: number = 0;
  onBack?: () => void;
  onEdit?: (id: number) => void;
  @State course: Course | null = null;
  private dayNameArr: string[] = ['一', '二', '三', '四', '五', '六', '日'];

  aboutToAppear(): void {
    this.loadCourse();
  }

  async loadCourse(): Promise<void> {
    this.course = await CourseDb.getInstance().getCourseById(this.courseId);
  }

  async deleteCourse(): Promise<void> {
    if (this.course === null) {
      return;
    }
    await NotificationService.getInstance().cancelCourseReminder(this.course.id);
    await CourseDb.getInstance().deleteCourse(this.course.id);
    promptAction.showToast({ message: '删除成功' });
    if (this.onBack !== undefined) {
      this.onBack();
    }
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#666666')
      Blank()
      Text(value)
        .fontSize(15)
        .fontColor('#333333')
    }
    .padding(16)
    .width('100%')
    .border({ width: { bottom: 1 }, color: '#EEEEEE' })
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
        Text('课程详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('编辑')
          .fontSize(16)
          .fontColor('#2E7D32')
          .onClick((): void => {
            if (this.onEdit !== undefined) {
              this.onEdit(this.course!.id);
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#EEEEEE' })

      if (this.course !== null) {
        List() {
          ListItem() {
            this.InfoRow('课程名称', this.course!.name)
          }
          ListItem() {
            this.InfoRow('授课教师', this.course!.teacher || '无')
          }
          ListItem() {
            this.InfoRow('上课教室', this.course!.classroom || '无')
          }
          ListItem() {
            this.InfoRow('上课星期', '周' + this.dayNameArr[this.course!.dayOfWeek - 1])
          }
          ListItem() {
            this.InfoRow('节次', '第' + this.course!.startSection + '-' + this.course!.endSection + '节')
          }
          ListItem() {
            this.InfoRow('周次', this.course!.weekList.length + '周')
          }
          ListItem() {
            this.InfoRow('上课提醒', this.course!.isRemind ? '已开启' : '已关闭')
          }
        }
        .width('100%')
        .margin({ top: 12 })
        .layoutWeight(1)

        Row({ space: 16 }) {
          Button('编辑')
            .layoutWeight(1)
            .backgroundColor('#2E7D32')
            .onClick((): void => {
              if (this.onEdit !== undefined) {
                this.onEdit(this.course!.id);
              }
            })
          Button('删除')
            .layoutWeight(1)
            .backgroundColor('#F44336')
            .onClick((): void => {
              this.deleteCourse();
            })
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}