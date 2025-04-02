import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { checkValidUrl } from "../../common/functions/common/get"
import { openInWeb } from "../../common/functions/common/open"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"

@CustomDialog
export struct ApiDialog {
  @StorageProp(StorageConstants.API_URL) customApiUrl: string = ''
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = false
  controller: CustomDialogController

  build() {
    Column({ space: 20 }) {
      Row({ space: 10 }) {
        Text('启用在线服务')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.reverse'))
          .textAlign(TextAlign.Center)
          .lineHeight(30)
      }

      this.SetApiUrl()

      Text() {
        Span(`当前服务器状态: `)
        Span(`${this.validApiUrl ? '正常' : '不可用'}`)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.validApiUrl ? Color.Green : $r('app.color.app_red'))
      }
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontColor($r('app.color.reverse'))
      .fontSize(Constants.FONT_SIZE_COMMON)

      Button('确认并关闭')
        .onClick(() => {
          this.setCustomApiUrl()
          this.controller.close()
        })
        .margin({ top: 20 })
    }
    .backgroundColor($r('app.color.background'))
    .padding({ top: Constants.PADDING_EDGE_TEXT, bottom: Constants.PADDING_EDGE_TEXT })
  }

  @Builder SetApiUrl() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        TextInput({ text: this.customApiUrl })
          .layoutWeight(4)
          .onChange((text) => this.customApiUrl = text)
          .borderRadius(Constants.RADIUS_IMG)
        Button('设置')
          .backgroundColor($r('app.color.app_red'))
          .layoutWeight(1)
          .onClick(() => {
            this.setCustomApiUrl()
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
    }
    .width('100%')
  }

  setCustomApiUrl() {
    AppStorage.setOrCreate(StorageConstants.API_URL,this.customApiUrl)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.API_URL,this.customApiUrl)
    ToastUtil.showToast('设置成功')
    checkValidUrl()
  }
}