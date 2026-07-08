import { Course } from '../model/Course';
import { SectionItem } from '../model/AppSettings';

@Component
export struct CourseCard {
  course: Course = {
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
  sectionList: SectionItem[] = [];
  onItemClick: () => void = () => {};

  build() {
    Column() {
      // 第一行：课程名称
      Text(this.course.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      // 第二行：教室
      if (this.course.classroom !== '') {
        Text(this.course.classroom)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .opacity(0.9)
          .width('100%')
          .margin({ top: 4 })
      }

      // 第三行：节次
      Text('第' + this.course.startSection + '-' + this.course.endSection + '节')
        .fontSize(11)
        .fontColor('#FFFFFF')
        .opacity(0.8)
        .width('100%')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(8)
    .backgroundColor('#2E7D32')
    .borderRadius(6)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.onItemClick();
    })
  }
}