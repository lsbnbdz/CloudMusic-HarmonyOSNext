import { CommonHead } from '../components/head/CommonHead';
import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct WebPage {
  title:string = Object(router.getParams())['title']
  url:string = Object(router.getParams())['url']
  controller: webview.WebviewController = new webview.WebviewController()
  build() {
    Column() {
      CommonHead({ title: this.title })
      Web({ src: this.url, controller: this.controller })
        .width('100%')
        .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
  }
}