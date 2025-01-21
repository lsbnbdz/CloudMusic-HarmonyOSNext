import { BackButton } from "../buttons/BackButton";

@Component
export struct CommonHead {
  title:string = ''
  @StorageProp('topRectHeight')

  topRectHeight: number = 0;
  build() {
    Row({ space: 20 }) {
      BackButton()
      Text(this.title).fontSize(20).fontColor($r('app.color.reverse'))
    }
    .padding({ top: px2vp(this.topRectHeight), left: 10, right: 10, bottom: 5 })
    .width('100%')
    .backgroundColor(Color.Transparent)
  }

  @Builder Extra() {}
}