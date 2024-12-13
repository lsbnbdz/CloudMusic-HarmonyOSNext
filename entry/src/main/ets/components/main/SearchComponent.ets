import { router } from "@kit.ArkUI"

@Component
export struct SearchComponent {
  @State searchKeyword:string = ''

  build() {
    Column() {
      Search({
        placeholder: '搜索内容',
        icon: '/resources/base/media/ic_public_search_filled.svg',
      })
        .sharedTransition('search_component', {
          duration: 300,
          curve: Curve.Friction
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
  }
}