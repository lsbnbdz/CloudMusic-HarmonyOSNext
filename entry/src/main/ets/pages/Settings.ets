import { SettingsHead } from '../components/head/SettingsHead'
import { CustomApiUrl } from '../common/settings/CustomApiUrl'
import { SetPlayQuality } from '../common/settings/SetPlayQuality'
import { RemoveCache } from '../common/settings/RemoveCache'
import { Animation } from '../common/settings/Animation'
import { UsePublicCookie } from '../common/settings/UsePublicCookie'
import { Settings_Bottom,
  Settings_Feedback,
  Settings_Version } from '../common/settings/TextContent'

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
        SettingsHead().padding({ bottom: 20 })

        List({ space: 20 }) {
          ListItem() { Animation() }
          ListItem() { UsePublicCookie() }
          ListItem() { SetPlayQuality() }
          ListItem() { CustomApiUrl() }
          ListItem() { RemoveCache() }
          ListItem() { Divider() }
          ListItem() { Settings_Version() }
          ListItem() { Settings_Feedback() }
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
}

