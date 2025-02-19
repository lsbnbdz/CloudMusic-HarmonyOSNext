import { ToastUtil } from "@pura/harmony-utils";
import Constants from "../../common/constants/Constants";
import { BackButton } from "../buttons/BackButton";
import { CommonCircleButton } from "../buttons/CircleButton";

@Component
export struct ListHead {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  title:string = ''

  @BuilderParam slot: () => void = this.Slot

  build() {
    Row({ space: 20 }) {
      BackButton()
      Text(`${this.title}`)
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontColor($r('app.color.reverse'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      this.slot()
    }
    .padding({
      left: Constants.PADDING_EDGE_DEFAULT,
      right: Constants.PADDING_EDGE_DEFAULT,
      top: px2vp(this.topRectHeight),
      bottom: 5
    })
    .width('100%')
    .backgroundColor(Color.Transparent)
    .backdropBlur(50)
    .onClick(() => {
      ToastUtil.showToast(`${this.title}`)
    })
  }

  @Builder
  Slot() {
    CommonCircleButton({ wid: Constants.SIZE_ICON_BUTTON_HEAD })
  }
}