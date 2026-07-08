import { PreferencesUtil } from '../utils/PreferencesUtil';
import { CourseDb } from '../database/CourseDb';
import { Course } from '../model/Course';
import { AppSettings } from '../model/AppSettings';
import { CourseDataSource } from '../utils/CourseDataSource';
import { CourseCard } from '../components/CourseCard';
import { CourseDetail } from './CourseDetail';
import { CourseEdit } from './CourseEdit';
import { Settings } from './Settings';
import promptAction from '@ohos.promptAction';

// 页面枚举
type PageType = 'home' | 'edit' | 'detail' | 'settings';

@Entry
@Component
struct Index {
  @State currentPage: PageType = 'home';
  @State settings: AppSettings | null = null;
  @State courseList: Course[] = [];
  @State viewMode: string = 'week';
  // 跳转传参用的状态
  @State editMode: string = 'add';
  @State targetCourseId: number = 0;

  private weekDataSource: CourseDataSource = new CourseDataSource([]);
  private dayDataSource: CourseDataSource = new CourseDataSource([]);
  private dayNameArr: string[] = ['一', '二', '三', '四', '五', '六', '日'];

  async refreshData(): Promise<void> {
    this.settings = await PreferencesUtil.getInstance().getSettings();
    if (this.settings !== null) {
      this.courseList = await CourseDb.getInstance()
        .getCoursesBySemester(this.settings.currentSemester);
      this.weekDataSource.updateData(this.courseList);
      const today: number = new Date().getDay();
      const dayOfWeek: number = today === 0 ? 7 : today;
      const todayCourses: Course[] = this.courseList.filter((c: Course): boolean => c.dayOfWeek === dayOfWeek);
      this.dayDataSource.updateData(todayCourses);
    }
  }

  private getRowsTemplate(): string {
    const sectionCount: number = this.settings !== null ? this.settings.sectionList.length : 10;
    return `auto ${Array(sectionCount).fill('1fr').join(' ')}`;
  }

  aboutToAppear(): void {
    this.refreshData();
  }

  // 跳转课程详情
  goToDetail(courseId: number): void {
    this.targetCourseId = courseId;
    this.currentPage = 'detail';
  }

  // 跳转新增课程
  goToAddCourse(): void {
    this.editMode = 'add';
    this.targetCourseId = 0;
    this.currentPage = 'edit';
  }

  // 跳转编辑课程
  goToEditCourse(courseId: number): void {
    this.editMode = 'edit';
    this.targetCourseId = courseId;
    this.currentPage = 'edit';
  }

  // 跳转设置页
  goToSettings(): void {
    this.currentPage = 'settings';
  }

  // 返回首页
  backToHome(): void {
    this.currentPage = 'home';
    this.refreshData();
  }

  // 顶部栏
  @Builder
  TopBar() {
    Column() {
      Text('我的课程表')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: 12 })
      Row() {
        Text(this.settings !== null ? this.settings.currentSemester : '')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .onClick((): void => {
            promptAction.showToast({ message: '学期切换在设置页操作' });
          })
        Blank()
        Button(this.viewMode === 'week' ? '切日视图' : '切周视图')
          .type(ButtonType.Normal)
          .backgroundColor('#2E7D32')
          .fontSize(14)
          .height(32)
          .onClick((): void => {
            this.viewMode = this.viewMode === 'week' ? 'day' : 'week';
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  // 周视图 - 修复：网格布局按节次精准定位
  @Builder
  WeekView() {

    Grid() {
      // 星期标题行
      ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
        GridItem() {
          Text(this.dayNameArr[day - 1])
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding({ top: 8, bottom: 8 })
        }
        .columnStart(day)
        .rowStart(1) // 强制所有星期标题都在第1行
      }, (day: number): string => day.toString())

      // 课程卡片 - 按节次定位行位置
      LazyForEach(this.weekDataSource, (item: Course) => {
        GridItem() {
          CourseCard({
            course: item,
            sectionList: this.settings !== null ? this.settings.sectionList : [],
            onItemClick: (): void => {
              this.goToDetail(item.id);
            }
          })
            .margin(2)
            .height('100%')
        }
        .columnStart(item.dayOfWeek)
        .rowStart(item.startSection + 1)
        .rowEnd(item.endSection + 1)
      }, (item: Course): string => item.id.toString())
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsTemplate(this.getRowsTemplate())
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 8, right: 8, bottom: 8 })
  }

  // 日视图
  @Builder
  DayView() {
    Column() {
      Text('今日课程')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 12 })
      List() {
        LazyForEach(this.dayDataSource, (item: Course) => {
          ListItem() {
            CourseCard({
              course: item,
              sectionList: this.settings !== null ? this.settings.sectionList : [],
              onItemClick: (): void => {
                this.goToDetail(item.id);
              }
            })
              .margin({ bottom: 10 })
          }
        }, (item: Course): string => item.id.toString())
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .layoutWeight(1)
  }

  // 底部导航栏
  @Builder
  BottomBar() {
    Row() {
      Column() {
        Text('首页')
          .fontSize(12)
          .fontColor('#2E7D32')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .height('100%')

      Column() {
        Text('+ 新增课程')
          .fontSize(12)
          .fontColor('#333333')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .onClick((): void => {
        this.goToAddCourse();
      })

      Column() {
        Text('设置')
          .fontSize(12)
          .fontColor('#333333')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .onClick((): void => {
        this.goToSettings();
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#EEEEEE' })
  }

  // 首页内容
  @Builder
  HomePage() {
    Column() {
      this.TopBar()
      if (this.settings !== null) {
        if (this.viewMode === 'week') {
          this.WeekView()
        } else {
          this.DayView()
        }
      }
      this.BottomBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  build() {
    // 根据当前状态渲染对应页面
    if (this.currentPage === 'home') {
      this.HomePage()
    } else if (this.currentPage === 'edit') {
      CourseEdit({
        mode: this.editMode,
        courseId: this.targetCourseId,
        onSaved: (): void => {
          this.backToHome();
        },
        onBack: (): void => {
          this.backToHome();
        }
      })
    } else if (this.currentPage === 'detail') {
      CourseDetail({
        courseId: this.targetCourseId,
        onBack: (): void => {
          this.backToHome();
        },
        onEdit: (id: number): void => {
          this.goToEditCourse(id);
        }
      })
    } else if (this.currentPage === 'settings') {
      Settings({
        onBack: (): void => {
          this.backToHome();
        },
        onSettingsChanged: (): void => {
          this.refreshData();
        }
      })
    }
  }
}