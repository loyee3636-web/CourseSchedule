@Entry
@Component
struct CourseWidget {
  @LocalStorageLink('todayCourses') todayCourses: object[] = [];

  build() {
    Column() {
      Row() {
        Text('今日课程')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2E7D32')
        Blank()
        Text(this.todayCourses.length.toString() + ' 门')
          .fontSize(12)
          .fontColor('#666')
      }
      .width('100%')
      .margin({ bottom: 8 })

      if (this.todayCourses.length === 0) {
        Text('今天没有课，好好休息~')
          .fontSize(13)
          .fontColor('#999')
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.todayCourses.slice(0, 4), (item: object) => {
            ListItem() {
              Row() {
                Column() {
                  Text((item as Record<string, string>).name || '')
                    .fontSize(13)
                    .maxLines(1)
                    .fontColor('#333')
                  Text((item as Record<string, string>).classroom || '')
                    .fontSize(11)
                    .fontColor('#999')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })
            }
          }, (_item: object, index: number): string => index.toString())
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick((): void => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility'
      });
    })
  }
}