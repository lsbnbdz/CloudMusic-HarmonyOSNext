import { ToastUtil } from "@pura/harmony-utils";
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
      Text(`${this.playListName}`).fontSize(20).fontColor($r('app.color.reverse')).maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1).textAlign(TextAlign.Center)
      CommonCircleButton({ ButtonImageName: 'ic_public_share_filled' })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 15, right: 10 })
    .width('100%')
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      ToastUtil.showToast(`${this.playListName}`)
    })
  }
}