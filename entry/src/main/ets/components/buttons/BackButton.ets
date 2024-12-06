import { CommonCircleButton } from "./CircleButton";
import { router } from "@kit.ArkUI";

/**
 * 返回按钮（router 返回上一页面）
 */

@Component
export struct BackButton {
  build() {
    CommonCircleButton({ ButtonImageName:'ic_public_back' })
      .onClick(() => {
        router.back()
      })
  }
}