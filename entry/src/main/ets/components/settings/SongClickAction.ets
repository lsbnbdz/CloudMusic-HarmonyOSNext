import { CircleImageButton } from '../buttons/CircleButton'
import Constants from '../../common/constants/Constants'
import { SongClickActionPage } from '../../pages/settings/SongClickActionPage'

/**
 * 歌曲卡片单击操作
 */
@Component
export struct SongClickAction {
  build() {
    Column({ space: 5 }) {
      Row() {
        Row({ space: 5 }) {
          Text('歌曲卡片点击模式').LeftText()
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