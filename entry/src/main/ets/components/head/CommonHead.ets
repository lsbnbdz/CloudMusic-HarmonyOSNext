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
    // 避让状态栏
    .padding({ top: px2vp(this.topRectHeight), left: 10, right: 10 })
    .width('100%')
    .height(90)
    .backgroundColor(Color.Transparent)
  }

  @Builder Extra() {}
}