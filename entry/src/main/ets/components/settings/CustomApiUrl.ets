import { ToastUtil } from '@pura/harmony-utils'
import { CircleImageButton } from '../buttons/CircleButton'
import { ExplainButton } from '../buttons/ExplainButton'
import { CustomApiUrlSheet } from '../sheets/CustomApiUrlSheet'
import Constants from '../../common/constants/Constants'
import PreferencesUtils from '../../common/utils/data/PreferencesUtils'

/**
 * 自定义API地址
 */
@Component
export struct CustomApiUrl {
  @State isShowSheet: boolean = false
  build() {
    Column({ space: 5 }) {
      Row() {
        Row({ space: 5 }) {
          Text('API服务器与Cookie设置').LeftText()
        }
        CircleImageButton({ imgUrl: $r('app.media.ic_public_arrow_right'), })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .bindSheet(this.isShowSheet, this.Sheet(), {
        backgroundColor: $r('app.color.background'),
        preferType: SheetType.BOTTOM,
        height: SheetSize.MEDIUM,
        dragBar: true,
        onDisappear: () => {
          this.isShowSheet = false
        }
      })
      .onClick(() => {
        this.isShowSheet = !this.isShowSheet
      })
    }
    .width('100%')
  }

  @Builder
  Sheet() {
    CustomApiUrlSheet({ isShowSheet: this.isShowSheet })
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}