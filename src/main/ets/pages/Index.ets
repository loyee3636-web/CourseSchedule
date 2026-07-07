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

@Entry
@Component
struct Index {
  @State pathStack: NavPathStack = new NavPathStack();
  @State settings: AppSettings | null = null;
  @State courseList: Course[] = [];
  @State viewMode: string = 'week';

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

  aboutToAppear(): void {
    this.refreshData();
  }

  // 跳转课程详情
  goToDetail(courseId: number): void {
    const param: Record<string, Object> = {} as Record<string, Object>;
    param['courseId'] = courseId as Object;
    this.pathStack.pushPathByName('CourseDetail', param);
  }

  // 跳转新增课程
  goToAddCourse(): void {
    const param: Record<string, Object> = {} as Record<string, Object>;
    param['mode'] = 'add' as Object;
    this.pathStack.pushPathByName('CourseEdit', param);
  }

  // 跳转设置页
  goToSettings(): void {
    const param: Record<string, Object> = {} as Record<string, Object>;
    param['onSettingsChanged'] = ((): void => {
      this.refreshData();
    }) as Object;
    this.pathStack.pushPathByName('Settings', param);
  }

  // 编辑课程回调
  onEditCourse(id: number): void {
    const editParam: Record<string, Object> = {} as Record<string, Object>;
    editParam['mode'] = 'edit' as Object;
    editParam['courseId'] = id as Object;
    this.pathStack.replacePathByName('CourseEdit', editParam);
  }

  // 路由构建器：纯UI语法，无逻辑变量
  @Builder
  RouteMap(name: string, param: Object) {
    if (name === 'CourseDetail') {
      NavDestination() {
        CourseDetail({
          courseId: (param as Record<string, Object>)['courseId'] as number,
          onBack: (): void => { this.pathStack.pop(); },
          onEdit: (id: number): void => { this.onEditCourse(id); }
        })
      }
    } else if (name === 'CourseEdit') {
      NavDestination() {
        CourseEdit({
          mode: (param as Record<string, Object>)['mode'] as string,
          courseId: (param as Record<string, Object>)['courseId'] as number,
          onSaved: (): void => {
            this.refreshData();
            this.pathStack.pop();
          },
          onBack: (): void => { this.pathStack.pop(); }
        })
      }
    } else if (name === 'Settings') {
      NavDestination() {
        Settings({
          onBack: (): void => { this.pathStack.pop(); },
          onSettingsChanged: (param as Record<string, Object>)['onSettingsChanged'] as () => void
        })
      }
    }
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

  // 周视图
  @Builder
  WeekView() {
    Grid() {
      ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
        GridItem() {
          Column() {
            Text(this.dayNameArr[day - 1])
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 8 })

            List() {
              LazyForEach(this.weekDataSource, (item: Course) => {
                ListItem() {
                  if (item.dayOfWeek === day) {
                    CourseCard({
                      course: item,
                      sectionList: this.settings !== null ? this.settings.sectionList : [],
                      onItemClick: (): void => {
                        this.goToDetail(item.id);
                      }
                    })
                      .margin({ bottom: 6 })
                  }
                }
              }, (item: Course): string => item.id.toString())
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(6)
        }
      }, (day: number): string => day.toString())
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
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

  build() {
    Navigation(this.pathStack) {
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
    .hideTitleBar(true)
    .navDestination(this.RouteMap.bind(this))
    .backgroundColor('#FFFFFF')
  }
}