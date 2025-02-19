import { CommonCircleButton } from "./CircleButton";
import { router } from "@kit.ArkUI";
import Constants from "../../common/constants/Constants";

/**
 * 返回按钮（router 返回上一页面）
 */

@Component
export struct BackButton {
  build() {
    CommonCircleButton({ ButtonImageName:'ic_public_back', wid: Constants.SIZE_ICON_BUTTON_HEAD })
      .onClick(() => {
        router.back()
      })
  }
}