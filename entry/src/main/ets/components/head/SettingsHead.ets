import { promptAction } from "@kit.ArkUI";
import { BackButton } from "../buttons/BackButton";
import { CommonCircleButton } from "../buttons/CommonCircleButton";

@Component
export struct SettingsHead {
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;

  build() {
    Row() {
      BackButton()
      Text("设置").fontSize(20).fontColor($r('app.color.reverse'))
      CommonCircleButton({ ButtonImageName:'ic_public_share_filled', BgColor:'#00cbcbcb'})
        .onClick(() => {
          promptAction.showToast({ message:"该功能暂未开发完成" })
        })
    }
    // 避让状态栏
    .padding({ top: px2vp(this.topRectHeight), left: 10, right: 10 })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(90)
    .backgroundColor(Color.Transparent)
  }
}