import { DialogUtil } from "@pura/harmony-utils"

@Component
export struct QuestionButton {
  @State title: string = ''
  @State msg: string = ''
  @State comSize: number = 35

  build() {
    Column() {
      Button({type: ButtonType.Circle}) {
        Image($r(`app.media.ic_public_help`))
          .width(this.comSize - 5)
          .fillColor($r('app.color.reverse'))
          .draggable(false)
      }
      .height(this.comSize)
      .width(this.comSize)
      .backgroundColor(Color.Transparent)
      .opacity(0.8)
      .onClick(() => {
        DialogUtil.showConfirmDialog({
          title: this.title,
          message: this.msg
        })
      })
    }
  }
}