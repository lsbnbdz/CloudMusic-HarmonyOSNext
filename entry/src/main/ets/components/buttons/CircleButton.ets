/**
 * 圆形按钮组件
 */

/**
 * 圆形图标按钮
 */
@Component
export struct CommonCircleButton {
  ButtonImageName: string = ''
  BgColor: string = 'transparent'

  build() {
    Column() {
      Button({type: ButtonType.Circle}) {
        Image($r(`app.media.${this.ButtonImageName}`))
          .width(30)
          .fillColor($r('app.color.reverse'))
          .draggable(false)
      }
      .height(35)
      .width(35)
      .backgroundColor(this.BgColor)
      .opacity(0.8)
    }
  }
}

/**
 * 圆形图片按钮
 */
@Component
export struct CircleImageButton {
  imgUrl: ResourceStr = ''
  BgColor: string = 'transparent'

  build() {
    Column() {
      Button({type: ButtonType.Circle}) {
        Image(this.imgUrl)
          .borderRadius(50)
          .width(35)
          .fillColor($r('app.color.reverse'))
      }
      .height(35)
      .width(35)
      .backgroundColor(this.BgColor)
      .opacity(0.8)
    }
  }
}

/**
 * svg 圆形图标按钮
 */
@Component
export struct CircleButton {
  @State bgColor: Color | string = Color.Transparent
  @State fillColor: Color | string | Resource = Color.White
  @State imgUrl: ResourceStr = ''
  @State btnWidth: number = 45
  @State imgWidth: number = 35

  build() {
    Button() {
      Image(this.imgUrl)
        .height(this.imgWidth)
        .padding(5)
        .fillColor(this.fillColor)
    }
    .type(ButtonType.Circle)
    .backgroundColor(this.bgColor)
    .height(this.btnWidth)
  }
}