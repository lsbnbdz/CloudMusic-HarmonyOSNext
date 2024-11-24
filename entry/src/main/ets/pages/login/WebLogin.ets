import { CommonHead } from '../../components/head/CommonHead';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { getLoginStatus } from '../../api/getLoginStatus';
import { LoginHelpSheet } from '../../components/sheets/LoginHelpSheet';

@Entry
@Component
struct WebLogin {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @State userAgent: string = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0'
  controller: webview.WebviewController = new webview.WebviewController()

  build() {
    Stack() {
      Column() {
        CommonHead({ title: '登录'})
        Help().padding({bottom:10})
        Web({ src: '', controller: this.controller })
          .width('100%')
          .height('100%')
          .onControllerAttached(() => {
            try {
              this.controller.setCustomUserAgent(this.userAgent)
              this.controller.loadUrl("https://music.163.com/#/login")
            } catch (error) {
              console.error('Login Web Error: ' + error.message)
            }
          })

        Column() {
          Button('获取登录信息').onClick(() => { this.getCookie() })
        }.width('100%').padding({ top:20 })
      }
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.main'))
    .padding({ bottom: vp2px(this.bottomRectHeight) })
  }

  async getCookie() {
    try {
      let cookie = webview.WebCookieManager.fetchCookieSync('https://music.163.com')
      if (cookie) {
        cookie = cookie + '; OS=pc'
        AppStorage.setOrCreate("cookie",cookie)
        console.log('Cookie => ' + cookie)
        getLoginStatus(cookie)
      } else {
        promptAction.showToast({ message: '获取登录信息失败！' })
      }
    } catch (error) {
      console.error('获取Cookie失败', error.message)
      promptAction.showToast({
        message: '获取Cookie失败：' + error.message
      })
    }
  }
}

@Component
struct Help {
  @State isShowHelpSheet:boolean = false
  build() {
    // Help
    Column() {
      Button() {
        Row({ space: 5 }) {
          Image($r('app.media.ic_public_help')).fillColor($r('app.color.reverse')).height('80%')
          Text('如何登录？').fontColor($r('app.color.reverse')).height('80%')
        }.padding({ right: 10 })
      }.height(30).alignSelf(ItemAlign.End).backgroundColor(Color.Transparent)
      .bindSheet(this.isShowHelpSheet, this.HelpSheet(), {
        height: '50%',
        dragBar: false,
        onDisappear: () => {
          this.isShowHelpSheet = !this.isShowHelpSheet
        }
      })
      .onClick(() => {
        this.isShowHelpSheet = !this.isShowHelpSheet
      })
    }.width('100%')
  }

  @Builder
  HelpSheet() {
    LoginHelpSheet({ isShowSheet: this.isShowHelpSheet })
  }
}