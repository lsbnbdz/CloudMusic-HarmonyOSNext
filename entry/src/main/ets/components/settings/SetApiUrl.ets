import { CircleImageButton } from '../buttons/CircleButton'
import Constants from '../../common/constants/Constants'

/**
 * 自定义API地址
 */
@Component
export struct SetApiUrl {
  @State isShowSheet: boolean = false
  build() {
    Column({ space: 5 }) {
      Row() {
        Row({ space: 5 }) {
          Text('API与Cookie设置').LeftText()
        }
        Image($r('app.media.ic_public_arrow_right'))
          .width(Constants.FONT_SIZE_TITLE)
          .fillColor($r('app.color.reverse'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .height(35)
    }
    .width('100%')
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}