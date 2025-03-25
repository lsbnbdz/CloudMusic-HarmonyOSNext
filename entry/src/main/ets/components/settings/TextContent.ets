import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { AppConstants } from "../../common/constants/AppConstants"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AppInfo, AppInfoClass } from "../../common/entities/AppInfo"

@Component
export struct VersionCard {
  @StorageProp(StorageConstants.APP_INFO) appInfo: AppInfo = AppInfoClass
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack

  build() {
    ListItem() {
      Button() {
        Row() {
          Row({ space: 10 }) {
            Text('关于应用')
              .fontColor($r('app.color.reverse'))
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontWeight(Constants.FONT_WEIGHT_SETTINGS)
            if(this.appInfo.data.Version.currentVersionCode > AppConstants.VERSIONCODE) {
              Text('发现新版本')
                .fontWeight(FontWeight.Medium)
                .fontSize(12)
                .fontColor($r('app.color.app_red'))
            }
          }
          Image($r('app.media.ic_public_arrow_right'))
            .width(Constants.FONT_SIZE_TITLE)
            .fillColor($r('app.color.reverse'))
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height(Constants.HEIGHT_SETTINGS_ITEM)
      .backgroundColor(Color.Transparent)
      .padding(Constants.PADDING_EDGE_DEFAULT)
      .gesture(
        LongPressGesture({
        }).onAction(() => {
          this.settingsPageInfos.pushDestinationByName('DebugPage', null)
        })
      )
      .onClick(() => {
        this.settingsPageInfos.pushPathByName('AboutPage', null)
      })
    }
  }
}

/**
 * 底部信息
 */
@Component
export struct Settings_Bottom {
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Column() {
      Text('云音汇 For HarmonyOS NEXT\n' +
        'Chenlvin/CloudMusic-HarmonyOSNext').BottomText()
    }
    .width('100%')
  }
}

@Extend(Text) function BottomText() {
  .lineHeight(20)
  .fontSize(12)
  .textAlign(TextAlign.Center)
  .onClick(() => {
    PasteboardUtil.setDataText('https://github.com/Chenlvin/CloudMusic-HarmonyOSNext')
    ToastUtil.showToast('已复制GitHub链接到剪贴板')
  })
}