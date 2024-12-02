import { ToastUtil } from "@pura/harmony-utils";
import { BackButton } from "../buttons/BackButton";
import { CommonCircleButton } from "../buttons/CircleButton";
import { PlayController } from "../main/PlayController";

@Component
export struct ListHead {
  title:string = ''

  build() {
    Row({ space: 20 }) {
      BackButton()
      Text(`${this.title}`).fontSize(18).fontColor($r('app.color.reverse')).maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1).textAlign(TextAlign.Center)
      PlayController()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 10, right: 10 })
    .width('100%')
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      ToastUtil.showToast(`${this.title}`)
    })
  }
}