import { BackButton } from "../buttons/BackButton";
import { CommonCircleButton } from "../buttons/CommonCircleButton";

@Component
export struct PlayListHead {
  playListName:string = ''

  @StorageProp('topRectHeight')
  topRectHeight: number = 0;

  build() {
    Row({ space: 20 }) {
      BackButton()
      Text(`${this.playListName}`).fontSize(20).fontColor($r('app.color.reverse')).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      CommonCircleButton({ ButtonImageName: 'ic_public_share_filled' })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: px2vp(this.topRectHeight), left: 15, right: 10 })
    .width('100%')
    .height(90)
    .backgroundColor(Color.Transparent)
  }
}