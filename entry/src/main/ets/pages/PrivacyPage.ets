import { CommonHead } from '../components/head/CommonHead';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct PrivacyPage {
  controller: webview.WebviewController = new webview.WebviewController()
  build() {
    Column() {
      CommonHead({ title: '隐私政策' })
      Web({ src: 'https://docs.chenlvin.cc/cloudmusic/#/privacy', controller: this.controller })
        .width('100%')
        .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
  }
}