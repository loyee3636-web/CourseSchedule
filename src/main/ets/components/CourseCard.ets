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
    endSection: 1,
    weekList: [],
    isRemind: false
  };
  sectionList: SectionItem[] = [];
  onItemClick?: () => void;

  private getTimeText(): string {
    const startItem: SectionItem | undefined = this.sectionList[this.course.startSection - 1];
    const endItem: SectionItem | undefined = this.sectionList[this.course.endSection - 1];
    const start: string = startItem ? startItem.startTime : '';
    const end: string = endItem ? endItem.endTime : '';
    return `${start}-${end}`;
  }

  build() {
    Column() {
      Text(this.course.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(this.course.classroom)
        .fontSize(12)
        .fontColor('#FFFFFF')
        .opacity(0.9)
        .margin({ top: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Text(this.getTimeText())
        .fontSize(11)
        .fontColor('#FFFFFF')
        .opacity(0.8)
        .margin({ top: 2 })
        .maxLines(1)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .borderRadius(8)
    .backgroundColor('#4CAF50')
    .justifyContent(FlexAlign.Start)
    .onClick((): void => {
      if (this.onItemClick !== undefined) {
        this.onItemClick();
      }
    })
  }
}