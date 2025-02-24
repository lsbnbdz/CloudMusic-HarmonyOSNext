import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';
import { WebPageParam } from '../common/entities/PageParams';

@Component
export struct WebPage {
  @State param: WebPageParam = {
    title: '',
    url: ''
  }
  controller: webview.WebviewController = new webview.WebviewController()
  build() {
    NavDestination() {
      Column() {
        Web({ src: this.param.url, controller: this.controller })
          .width('100%')
          .layoutWeight(1)
      }
      .height('100%')
      .width('100%')
    }
    .title(this.param.title)
  }
}