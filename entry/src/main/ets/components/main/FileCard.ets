import { ToastUtil } from "@pura/harmony-utils"

@Component
export struct FileCard {
  @State fileName: string = ''
  build() {
    Button() {
      Text(this.fileName)
        .width('100%')
        .fontSize(18)
        .fontColor($r('app.color.reverse'))
        .padding({ left: 10, right: 10 })
    }
    .type(ButtonType.Normal)
    .backgroundColor(Color.Transparent)
    .borderRadius(15)
    .width('100%')
    .height(60)
    .bindMenu(this.ClickMenu())
  }

  @Builder
  ClickMenu() {
    Menu() {
      MenuItem({ content: '播放' })
        .onClick(async () => {
          ToastUtil.showToast('该功能正在开发，敬请期待。')
        })
      MenuItem({ content: '预览' })
        .onClick(async () => {
          ToastUtil.showToast('该功能正在开发，敬请期待。')
        })
    }
  }
}