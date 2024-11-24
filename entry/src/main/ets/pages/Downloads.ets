import { CommonHead } from '../components/head/CommonHead'

@Entry
@Component
struct Downloads {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    Column() {
      CommonHead({ title: '下载管理' })
      Column() {
        Text('敬请期待').fontSize(24).fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Center)
      .height(`calc(100% - ${this.topRectHeight*2 + 90}px)`)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main'))
  }
}