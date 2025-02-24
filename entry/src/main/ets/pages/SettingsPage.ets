import { UsePublicCookie } from '../components/settings/UsePublicCookie'
import { SetPlayQuality } from '../components/settings/SetPlayQuality'
import { CustomApiUrl } from '../components/settings/CustomApiUrl'
import { RemoveCache } from '../components/settings/RemoveCache'
import { Settings_Bottom, Settings_Feedback, Settings_Version } from '../components/settings/TextContent'
import Constants from '../common/constants/Constants'

/**
 * 设置页面
 */
@Component
export struct SettingsPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Stack() {
        Column({ space: 10 }) {
          List({ space: 10 }) {
            ListItem() { SetPlayQuality() }.listItemStyle()
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
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

          Settings_Bottom()
        }
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .backgroundColor($r('app.color.background'))
    .title('设置')
  }

  @Styles listItemStyle() {
    .backgroundColor($r('app.color.main'))
    .borderRadius(Constants.RADIUS_CARD)
    .height(Constants.HEIGHT_SETTINGS_ITEM)
    .margin({ left: 20, right: 20 })
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }
}

