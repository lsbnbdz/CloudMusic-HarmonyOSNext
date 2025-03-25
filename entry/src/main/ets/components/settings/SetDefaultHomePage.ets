import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { changeSettings } from "../../common/functions/app/settings"

/**
 * 设置默认页面
 */
@Component
export struct SetDefaultHomePage {
  @StorageLink(StorageConstants.DEFAULT_PAGE_INDEX) selected: number = 0

  build() {
    Row() {
      Text('默认首页')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.reverse'))
      Row() {
        Radio({ value: '发现', group: 'Radio' })
          .checked(this.selected == 0)
          .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
          .onClick(() => {
            changeSettings(StorageConstants.DEFAULT_PAGE_INDEX, 0)
          })
        Text('发现')
          .fontColor($r('app.color.reverse'))
          .fontSize(Constants.FONT_SIZE_COMMON)
          .padding({ right: 10 })
        Radio({ value: '歌单', group: 'Radio' })
          .checked(this.selected == 1)
          .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
          .onClick(() => {
            changeSettings(StorageConstants.DEFAULT_PAGE_INDEX, 1)
          })
        Text('歌单')
          .fontColor($r('app.color.reverse'))
          .fontSize(Constants.FONT_SIZE_COMMON)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .height(Constants.HEIGHT_SETTINGS_ITEM)
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }
}