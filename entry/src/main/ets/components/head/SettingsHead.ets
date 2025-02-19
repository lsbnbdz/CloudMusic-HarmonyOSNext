import { promptAction } from "@kit.ArkUI";
import Constants from "../../common/constants/Constants";
import { MsgConstants } from "../../common/constants/MsgConstants";
import { BackButton } from "../buttons/BackButton";
import { CommonCircleButton } from "../buttons/CircleButton";

@Component
export struct SettingsHead {
  build() {
    Row() {
      BackButton()
      Text("设置")
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontColor($r('app.color.reverse'))
      CommonCircleButton({ ButtonImageName:'ic_public_share_filled', BgColor:'#00cbcbcb', wid: Constants.SIZE_ICON_BUTTON_HEAD })
        .onClick(() => {
          promptAction.showToast({ message: MsgConstants.DEVELOPING })
        })
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .backgroundColor(Color.Transparent)
  }
}