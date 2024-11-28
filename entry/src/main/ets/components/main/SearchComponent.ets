import { promptAction, router } from "@kit.ArkUI"
import { ToastUtil } from "@pura/harmony-utils"

@Component
export struct SearchComponent {
  @State searchKeyword:string = ''

  build() {
    Column() {
      // 搜索框和按钮
      Row({ space: 10 }) {
        // 搜索框
        TextInput({ placeholder: '请输入搜索内容' }).width('70%').backgroundColor('#ffdbd9d9').height(40).placeholderColor(Color.Gray).fontColor(Color.Black)
          .onChange((value:string) => {
            this.searchKeyword = value
          })

        //搜索按钮
        Button() {
          Image($r('app.media.ic_public_search_filled')).fillColor(Color.White).width(30)
        }
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .onClick(() => {
          if(this.searchKeyword) {
            router.pushUrl({
              url: 'pages/SongsListPage',
              params: { 'searchKeyword': this.searchKeyword }
            })
          } else { ToastUtil.showToast('请输入搜索内容') }
        })
      }.width('100%').justifyContent(FlexAlign.Center)
    }
    .backgroundColor(Color.Transparent)
  }
}