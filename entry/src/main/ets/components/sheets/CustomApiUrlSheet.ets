import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { openInWeb } from "../../common/functions/app/open"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import { ExplainButton } from "../buttons/ExplainButton"

/**
 * 自定义API服务器地址
 * Sheet
 */
@Component
export struct SetApiSheet {
  @StorageLink(StorageConstants.IS_CUSTOM_COOKIE) isCustomCookie: boolean = false
  @StorageProp(StorageConstants.CUSTOM_COOKIE) customCookie: string = ''
  @StorageProp(StorageConstants.CUSTOM_API_URL) customApiUrl: string = ''
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Link isShowSheet: boolean

  build() {
    Column({ space: 20 }) {
      Text('设置')
        .width('100%')
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontWeight(FontWeight.Bold)
        .padding({ top: Constants.PADDING_EDGE_TEXT, left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      this.SetApiUrl()

      this.SetCookie()
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT })
    .width('100%')
  }

  @Builder SetApiUrl() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 5 }) {
          Text('API服务器地址').LeftText()
          Button() {
            Image($r('app.media.ic_public_help'))
              .fillColor($r('app.color.reverse'))
              .width(15)
              .draggable(false)
          }
          .type(ButtonType.Circle)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            DialogUtil.showPrimaryDialog({
              title: 'API服务器地址',
              message: '你需要填入API服务器地址才可以正常使用本软件\n' +
                '需要自行搭建NeteaseCloudMusicApi服务\n\n' +
                '地址格式: http://example.com:3000\n' +
                '(注意末尾不带\"/\")\n\n' +
                '填入后重启应用生效',
              primaryButton: {
                value: '使用文档',
                action: () => { openInWeb('https://docs.chenlvin.cc/cloudmusic/#/help?timestamp=' + new Date().getTime()) }
              },
              secondaryButton: '确认'
            })
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

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
  }

  @Builder SetCookie() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 5 }) {
          Text('手动设置Cookie').LeftText()
          ExplainButton({ title: '手动设置Cookie',
            msg: '设置后每次API请求都将使用该Cookie, 包括登录、用户信息等获取, 重启后生效\n\n' +
              'Cookie只需要其中key为MUSIC_U的数据即可\n' +
              '例如: MUSIC_U=XXXXX'
          })
        }
        Toggle({ type: ToggleType.Switch, isOn: this.isCustomCookie })
          .height(24)
          .width(48)
          .selectedColor($r('app.color.app_red'))
          .onChange((isOn) => {
            animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
              this.toggleCustomCookie(isOn)
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })

      if(this.isCustomCookie) {
        Row({ space: 10 }) {
          TextInput({ text: this.customCookie })
            .layoutWeight(4)
            .onChange((text) => this.customCookie = text)
            .borderRadius(Constants.RADIUS_IMG)
          Button('设置')
            .backgroundColor($r('app.color.app_red'))
            .layoutWeight(1)
            .onClick(() => {
              this.setCustomCookie()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
      }
    }
  }

  toggleCustomCookie(isOn: boolean) {
    this.isCustomCookie = isOn
    AppStorage.setOrCreate(StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
  }

  setCustomApiUrl() {
    AppStorage.setOrCreate(StorageConstants.CUSTOM_API_URL,this.customApiUrl)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.CUSTOM_API_URL,this.customApiUrl)
    ToastUtil.showToast('设置成功')
  }

  setCustomCookie() {
    let cookie = this.customCookie + '; OS=pc'
    AppStorage.setOrCreate(StorageConstants.CUSTOM_COOKIE, cookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.CUSTOM_COOKIE, cookie)
    ToastUtil.showToast('设置成功，Cookie：\n' + cookie)
  }
}

@Extend(Text) function LeftText() {
  .fontSize(18)
  .fontWeight(FontWeight.Bold)
}