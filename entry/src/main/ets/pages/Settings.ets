import { SettingsHead } from '../components/head/SettingsHead'
import { CustomApiUrl } from '../components/settings/CustomApiUrl'
import { SetPlayQuality } from '../components/settings/SetPlayQuality'
import { RemoveCache } from '../components/settings/RemoveCache'
import { Animation } from '../components/settings/Animation'
import { UsePublicCookie } from '../components/settings/UsePublicCookie'
import { Settings_Bottom,
  Settings_Feedback,
  Settings_Version } from '../components/settings/TextContent'
import Constants from '../common/constants/Constants'

/**
 * 设置页面
 */
@Entry
@Component
struct Settings {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

  build() {
    Stack() {
      Column({ space: 10 }) {
        SettingsHead()

        List({ space: 10 }) {
          ListItem() { SetPlayQuality() }.listItemStyle()
          ListItem() { Animation() }.listItemStyle()
          ListItem() { UsePublicCookie() }.listItemStyle()
          ListItem() { CustomApiUrl() }.listItemStyle()
          ListItem() { RemoveCache() }.listItemStyle()
          ListItem() { Divider() }
          ListItem() { Settings_Version() }.listItemStyle()
          ListItem() { Settings_Feedback() }.listItemStyle()
        }
        .scrollBar(BarState.Auto)
        .width('100%')
        .height('100%')
        .layoutWeight(1)

        Settings_Bottom()
          .padding({ bottom: px2vp(this.bottomRectHeight) })
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Styles listItemStyle() {
    .backgroundColor($r('app.color.main'))
    .borderRadius(Constants.RADIUS_CARD)
    .height(Constants.HEIGHT_SETTINGS_ITEM)
    .margin({ left: 20, right: 20 })
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }
}

