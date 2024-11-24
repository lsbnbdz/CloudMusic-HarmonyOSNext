/**
 * 圆形按钮组件
 */

@Component
export struct CommonCircleButton {
  ButtonImageName: string = ''
  BgColor: string = '#ffdbdbdb'

  build() {
    Column() {
      Button({type: ButtonType.Circle}) {
        Image($r(`app.media.${this.ButtonImageName}`))
          .width(25)
          .fillColor($r('app.color.reverse'))
      }
      .height(35)
      .width(35)
      .backgroundColor(this.BgColor)
      .opacity(0.8)
    }
  }
}