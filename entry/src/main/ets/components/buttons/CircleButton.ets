/**
 * 圆形按钮组件
 */
import Constants from "../../common/constants/Constants"

/**
 * 圆形图片按钮
 */
@Component
export struct CircleImageButton {
  imgUrl: ResourceStr | string = ''
  BgColor: string = 'transparent'
  wid: number = Constants.SIZE_ICON_BUTTON_COMMON

  build() {
    Column() {
      Button({type: ButtonType.Circle}) {
        Image(this.imgUrl)
          .borderRadius(50)
          .width(this.wid)
          .fillColor($r('app.color.reverse'))
      }
      .height(this.wid)
      .width(this.wid)
      .backgroundColor(this.BgColor)
      .opacity(0.8)
    }
  }
}