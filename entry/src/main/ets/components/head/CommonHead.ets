import Constants from "../../common/constants/Constants";
import { BackButton } from "../buttons/BackButton";

@Component
export struct CommonHead {
  private title: string = ''
  @StorageProp('topRectHeight') topRectHeight: number = 0

  build() {
    Row({ space: 20 }) {
      BackButton()
      Text(this.title)
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontColor($r('app.color.reverse'))
    }
    .padding({
      top: px2vp(this.topRectHeight),
      left: 10,
      right: 10,
      bottom: 5
    })
    .width('100%')
    .backgroundColor(Color.Transparent)
  }
}