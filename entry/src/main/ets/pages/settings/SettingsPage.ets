import { SetPlayQuality } from '../../components/settings/SetPlayQuality'
import { SetApiUrl } from '../../components/settings/SetApiUrl'
import { RemoveCache } from '../../components/settings/RemoveCache'
import {
  OtherContents,
  Settings_Bottom, TextContents} from '../../components/settings/TextContent'
import Constants from '../../common/constants/Constants'
import { SetDefaultHomePage } from '../../components/settings/SetDefaultHomePage'
import { MixWithOthers } from '../../components/settings/MixWithOthers'
import { SongClickAction } from '../../components/settings/SongClickAction'
import { SongClickActionPage } from './SongClickActionPage'
import { ApiSetPage } from './ApiSetPage'
import { WebPage } from '../WebPage'
import { WebPageParam } from '../../common/entities/PageParams'
import { DebugPage } from '../DebugPage'

/**
 * 设置页面
 */
@Component
export struct SettingsPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @Provide('settingsPageInfos') settingsPageInfos: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.settingsPageInfos) {
      Stack() {
        Scroll() {
          Column({ space: 10 }) {
            List({ space: 10 }) {
              ListItem() {
                SetDefaultHomePage().padding({ left: 10, right: 10 })
              }.listItemStyle()

              ListItem() {
                Column({ space: 20 }) {
                  SetPlayQuality()
                  MixWithOthers()
                }
                .padding(10)
              }.listItemStyle()

              ListItem() {
                Column({ space: 20 }) {
                  SongClickAction()
                    .onClick(() => {
                      this.settingsPageInfos.pushPathByName('SongClickActionPage', null)
                    })
                  SetApiUrl()
                    .onClick(() => {
                      this.settingsPageInfos.pushPathByName('ApiSetPage', null)
                    })
                }
                .padding(10)
              }.listItemStyle()

              ListItem() {
                RemoveCache().padding({ left: 10, right: 10 })
              }.listItemStyle()

              ListItem() {
                Divider().padding({ left: 20, right: 20 })
              }

              ListItem() {
                TextContents()
              }.listItemStyle()

              ListItem() {
                OtherContents()
              }.listItemStyle()

              ListItem() {
                Settings_Bottom()
              }

              ListItem().height(px2vp(this.bottomRectHeight))
            }
            .scrollBar(BarState.Auto)
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          }
        }
        .width('100%')
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.background'))
    .title('设置')
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .navDestination(this.PageMap)
  }

  @Builder PageMap(name: string, param: Object) {
    if(name === 'SongClickActionPage') {
      SongClickActionPage()
    }
    else if(name == 'ApiSetPage') {
      ApiSetPage()
    }
    else if(name === 'WebPage') {
      WebPage({ param: param as WebPageParam })
    }
    else if(name == 'DebugPage') {
      DebugPage()
    }
  }

  @Styles listItemStyle() {
    .backgroundColor($r('app.color.main'))
    .borderRadius(Constants.RADIUS_CARD)
    .margin({ left: 20, right: 20 })
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .constraintSize({
      minHeight: 60,
      maxHeight: '100%'
    })
  }
}

