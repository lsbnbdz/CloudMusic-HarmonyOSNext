import { ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import PreferencesUtils from "../../common/utils/app/PreferencesUtils"
import { ExplainButton } from "../buttons/ExplainButton"

/**
 * 自定义API服务器地址
 * Sheet
 */
@Component
export struct CustomApiUrlSheet {
  @StorageLink('set-isCustomApiUrl') isCustomApiUrl: boolean = false
  @StorageProp('set-customApiUrl') customApiUrl: string = ''
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Link isShowSheet: boolean

  build() {
    Column({ space: 5 }) {
      Text('API服务器设置')
        .width('100%')
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontWeight(FontWeight.Bold)
        .padding(Constants.PADDING_EDGE_TEXT)
      Row() {
        Row({ space: 5 }) {
          Text('自定义API服务器地址').LeftText()
          ExplainButton({ title: '自定义API服务器地址',
            msg: '使用自定义网易云音乐API地址\n' +
              '需要搭建NeteaseCloudMusicApi服务\n\n' +
              '地址格式: http://example.com:3000\n' +
              '(注意末尾不带\"/\")'
          })
        }
        Toggle({ type: ToggleType.Switch, isOn: this.isCustomApiUrl }).height(24).width(48)
          .onChange(() => {
            this.toggleCustomApiUrl()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      if(this.isCustomApiUrl) {
        Row({ space: 10 }) {
          TextInput({ text: this.customApiUrl })
            .layoutWeight(4)
            .onChange((text) => this.customApiUrl = text)
          Button('设置')
            .layoutWeight(1)
            .onClick(() => {
              this.setCustomApiUrl()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
      }
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT })
    .width('100%')
  }

  toggleCustomApiUrl() {
    this.isCustomApiUrl = !this.isCustomApiUrl
    AppStorage.setOrCreate('set-isCustomApiUrl', this.isCustomApiUrl)
    PreferencesUtils.putPreferenceValue('Settings', 'isCustomApiUrl', this.isCustomApiUrl)
  }

  setCustomApiUrl() {
    AppStorage.setOrCreate('set-customApiUrl',this.customApiUrl)
    PreferencesUtils.putPreferenceValue('Settings','customApiUrl',this.customApiUrl)
    ToastUtil.showToast('设置成功，API地址：\n' + this.customApiUrl)
  }

}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}