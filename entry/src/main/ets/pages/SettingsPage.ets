import { UsePublicCookie } from '../components/settings/UsePublicCookie'
import { SetPlayQuality } from '../components/settings/SetPlayQuality'
import { CustomApiUrl } from '../components/settings/CustomApiUrl'
import { RemoveCache } from '../components/settings/RemoveCache'
import {
  OtherContents,
  Settings_Bottom } from '../components/settings/TextContent'
import Constants from '../common/constants/Constants'
import { SetDefaultHomePage } from '../components/settings/SetDefaultHomePage'

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
            ListItem() { SetPlayQuality().padding({ left: 10, right: 10 }) }.listItemStyle()
            ListItem() { SetDefaultHomePage().padding({ left: 10, right: 10 }) }.listItemStyle()
            ListItem() { UsePublicCookie().padding({ left: 10, right: 10 }) }.listItemStyle()
            ListItem() { CustomApiUrl().padding({ left: 10, right: 10 }) }.listItemStyle()
            ListItem() { RemoveCache().padding({ left: 10, right: 10 }) }.listItemStyle()
            ListItem() { Divider().padding({ left: 20, right: 20 }) }
            ListItem() { OtherContents() }.listItemStyle()
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
    // .height(Constants.HEIGHT_SETTINGS_ITEM)
    .margin({ left: 20, right: 20 })
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .constraintSize({
      minHeight: 60,
      maxHeight: '100%'
    })
  }
}

