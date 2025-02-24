import { CircleButton, CircleImageButton, CommonCircleButton } from "../buttons/CircleButton";
import { MeSheet } from "../sheets/MeSheet";
import { User, UserClass } from "../../common/entities/User";
import Constants from "../../common/constants/Constants";

@Component
export struct IndexHead {
  @State isShowSheet: boolean = false
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('isValidCookie') isValidCookie: boolean = false
  @StorageProp('User') user: User = UserClass
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Stack() {
      Row({ space: 15 }) {
        if (this.isValidCookie) {
          CircleImageButton({ imgUrl: this.user.data.profile.avatarUrl + '?param=100y100' })
            .bindSheet(this.isShowSheet, this.Sheet(), {
              backgroundColor: $r('app.color.background'),
              height: '50%',
              dragBar: false,
              showClose: false,
              onDisappear: () => {
                this.isShowSheet = false
              }
            })
            .onClick(() => {
              this.isShowSheet = !this.isShowSheet
            })

        } else {
          CommonCircleButton({ ButtonImageName: 'ic_user_portrait', BgColor: '#00cbcbcb' })
            .bindSheet(this.isShowSheet, this.Sheet(), {
              preferType: SheetType.CENTER,
              backgroundColor: $r('app.color.background'),
              height: '50%',
              dragBar: false,
              showClose: false,
              onDisappear: () => {
                this.isShowSheet = false
              }
            })
            .onClick(() => {
              this.isShowSheet = !this.isShowSheet
            })
        }

        // 搜索按钮
        CircleButton({ imgUrl: $r('app.media.ic_public_search_filled'), bgColor: '#00cbcbcb', fillColor: $r('app.color.reverse') })
          .position({ right: 50 })
          .onClick(() => {
            this.pageInfos.pushPathByName('SearchPage', null)
          })
        CommonCircleButton({ ButtonImageName: 'ic_public_more_filled', BgColor: '#00cbcbcb' })
          .bindMenu(this.MoreMenu())
      }
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
  }

  // 更多菜单
  @Builder
  MoreMenu() {
    Menu() {
      MenuItem(this.MenuItem($r('app.media.ic_public_download_filled'), '下载'))
        .contentFontColor($r('app.color.reverse'))
        .onClick(()=>{
          this.pageInfos.pushPathByName('DownloadPage', null)
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_settings_filled') ,'设置'))
        .contentFontColor($r('app.color.reverse'))
        .onClick(()=>{
          this.pageInfos.pushPathByName('SettingsPage', null)
        })
    }
  }

  @Builder
  MenuItem(image: ResourceStr, title: string) {
    Row({ space: 10 }) {
      Column() {
        Image(image)
          .fillColor($r('app.color.reverse'))
          .width(20)
      }
      .width(22)
      Text(title)
        .fontColor($r('app.color.reverse'))
        .fontSize(Constants.FONT_SIZE_COMMON)
    }
    .padding({ left: 15, right: 15, top: 5, bottom: 5 })
    .height(40)
  }

  // 半模态
  @Builder
  Sheet() {
    MeSheet({ isShowSheet: this.isShowSheet })
  }
}