import { AppUtil, DialogUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { AppConstants } from "../../common/constants/AppConstants"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AppInfo, AppInfoClass } from "../../common/entities/AppInfo"
import { WebPageParam } from "../../common/entities/PageParams"
import { WarrantyDialog } from "../dialog/WarrantyDialog"
import SystemAppUtils from "../../common/utils/system/SystemAppUtils"

@Builder
function TextContent(title: string, text: string, action?: () => void) {
  Button() {
    Row() {
      Text(title)
        .LeftText()
      if (!text) {
        Image($r('app.media.ic_public_arrow_right'))
          .width(Constants.FONT_SIZE_TITLE)
          .fillColor($r('app.color.reverse'))
      } else {
        Text(text)
          .RightText()
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .backgroundColor(Color.Transparent)
  .padding(Constants.PADDING_EDGE_DEFAULT)
  .onClick(action)
}

@Component
export struct TextContents {
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  @StorageProp(StorageConstants.APP_INFO) appInfo: AppInfo = AppInfoClass
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack

  build() {
    Column() {
      Column() {
        Button() {
          Row() {
            Row({ space: 10 }) {
              Text('应用版本')
                .LeftText()
              if(this.appInfo.data.Version.currentVersionCode > AppConstants.VERSIONCODE) {
                Text('发现新版本')
                  .fontWeight(FontWeight.Medium)
                  .fontSize(12)
                  .fontColor($r('app.color.app_red'))
              }
            }
            Text(AppConstants.VERSION + AppConstants.VER_DESC)
              .RightText()
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .backgroundColor(Color.Transparent)
        .padding(Constants.PADDING_EDGE_DEFAULT)
        .gesture(
          LongPressGesture({
          }).onAction(() => {
            this.settingsPageInfos.pushDestinationByName('DebugPage', null)
          })
        )
        .onClick(() => {
          if(this.appInfo.data.Version.currentVersionCode > AppConstants.VERSIONCODE) {
            this.handleUpdate()
          }
        })
      }
      TextContent('使用文档', '', () => {
        let param: WebPageParam = {
          title: '使用文档', url: 'https://docs.chenlvin.cc/cloudmusic/#/help'
        }
        this.pushWebPage(param)
      })
      TextContent('建议反馈', '', () => {
        let param: WebPageParam = {
          title: '建议反馈', url: 'https://www.wjx.cn/vm/PeLnYfc.aspx#'
        }
        this.pushWebPage(param)
      })
    }
    .padding({ top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
  }

  private pushWebPage(param: WebPageParam) {
    if(this.settingsPageInfos.size() < 2) {
      this.settingsPageInfos.pushPathByName('WebPage', param)
    } else {
      this.settingsPageInfos.replacePathByName('WebPage', param)
    }
  }

  private handleUpdate() {
    DialogUtil.showPrimaryDialog({
      title: '发现新版本',
      message: `Version ${AppConstants.VERSION} → ${this.appInfo.data.Version.currentVersion}`,
      primaryButton: "关闭",
      secondaryButton: {
        value: '前往下载',
        action: async () => {
          SystemAppUtils.openInBrowser(this.appInfo.data.Version.downloadUrl)
        }
      }
    })
  }
}

@Component
export struct OtherContents {
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack

  build() {
    Column() {
      TextContent('隐私政策', '', () => {
        let param: WebPageParam = {
          title: '隐私政策', url: 'https://docs.chenlvin.cc/cloudmusic/#/privacy'
        }
        this.pushWebPage(param)
      })
      TextContent('免责声明', '', () => {
        this.warrantyDialogController.open()
      })
    }
    .padding({ top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
  }

  private pushWebPage(param: WebPageParam) {
    if(this.settingsPageInfos.size() < 2) {
      this.settingsPageInfos.pushPathByName('WebPage', param)
    } else {
      this.settingsPageInfos.replacePathByName('WebPage', param)
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
      Text('云音汇 CloudMusic\n' +
        'For HarmonyOS NEXT').BottomText()
    }
    .width('100%')
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}

@Extend(Text) function RightText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
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