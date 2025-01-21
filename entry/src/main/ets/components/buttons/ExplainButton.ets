import { DialogUtil } from "@pura/harmony-utils"

@Component
export struct ExplainButton {
  @State title: string = ''
  @State msg: string = ''
  build() {
    Button() {
      Image($r('app.media.ic_public_help'))
        .fillColor($r('app.color.reverse'))
        .width(15)
        .draggable(false)
    }
    .type(ButtonType.Circle)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      DialogUtil.showConfirmDialog({
        title: this.title, message: this.msg
      })
    })
  }
}