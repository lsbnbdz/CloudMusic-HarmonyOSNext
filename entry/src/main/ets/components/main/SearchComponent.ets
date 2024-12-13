import { router } from "@kit.ArkUI"
import { ToastUtil } from "@pura/harmony-utils"

@Component
export struct SearchComponent {
  @State searchKeyword:string = ''

  build() {
    Column() {
      Search({
        placeholder: '搜索内容',
        icon: '/resources/base/media/ic_public_search_filled.svg',
      })
        .focusable(false)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SongsListPage'
          })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)

    // Column() {
    //   Row({ space: 10 }) {
    //     Image($r('app.media.ic_public_search_filled')).width(16).fillColor(Color.Gray)
    //     Text('搜索内容').fontSize(16).fontColor(Color.Gray)
    //   }
    //   .padding({ left: 15, top: 5, bottom: 5 })
    //   .borderRadius(20)
    //   .width('100%')
    //   .height(40)
    //   .backgroundColor($r('app.color.component_background'))
    //   .onClick(() => {
    //     router.pushUrl({
    //       url: 'pages/SongsListPage',
    //     })
    //   })
    // }
    // .padding({ top: 10 })
  }
}