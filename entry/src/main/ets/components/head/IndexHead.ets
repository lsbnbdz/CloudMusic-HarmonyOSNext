import { CircleImageButton, CommonCircleButton } from "../buttons/CircleButton";
import { MeSheet } from "../sheets/MeSheet";
import { router } from "@kit.ArkUI";
import { User, UserClass } from "../../common/entities/User";

@Component
export struct IndexHead {
  @State isShowSheet: boolean = false;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('isValidCookie') isValidCookie: boolean = false
  @StorageProp('User') user: User = UserClass

  build() {
    Row() {
      if(this.isValidCookie) {
        CircleImageButton({ imgUrl: this.user.data.profile.avatarUrl + '?param=100y100' })
          .bindSheet(this.isShowSheet, this.Sheet(), {
            height: '50%',
            dragBar: false,
            showClose: false,
            blurStyle: BlurStyle.Thick,
            onDisappear: () => { this.isShowSheet = false }
          })
          .onClick(() => { this.isShowSheet = !this.isShowSheet })
        Text(`${this.user.data.profile.nickname} 的歌单`).textStyle()
      } else {
        CommonCircleButton({ ButtonImageName:'ic_public_contacts_filled', BgColor:'#00cbcbcb'})
          .bindSheet(this.isShowSheet, this.Sheet(), {
            height: '50%',
            dragBar: false,
            showClose: false,
            blurStyle: BlurStyle.Thick,
            onDisappear: () => { this.isShowSheet = false }
          })
          .onClick(() => { this.isShowSheet = !this.isShowSheet })
        Text(`云音汇`).textStyle()
      }

      CommonCircleButton({ ButtonImageName:'ic_public_more_filled', BgColor:'#00cbcbcb'})
        .bindMenu(this.MoreMenu())
    }
    .padding({ left: 10, right: 10 })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }

  // 更多菜单
  @Builder
  MoreMenu() {
    Menu() {
      MenuItem({ startIcon: $r('app.media.ic_public_settings_filled') ,content: "设置" })
        .contentFontColor($r('app.color.reverse'))
        .onClick(()=>{
          router.pushUrl({ url:'pages/Settings' })
        })

      MenuItem({ startIcon: $r('app.media.ic_public_download_filled'), content: "下载管理" })
        .contentFontColor($r('app.color.reverse'))
        .onClick(()=>{
          router.pushUrl({ url:'pages/DownloadPage' })
        })
    }
  }

  // 半模态
  @Builder
  Sheet() {
    MeSheet({ isShowSheet: this.isShowSheet })
  }
}

@Extend(Text) function textStyle() {
  .fontSize(18)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .layoutWeight(1)
  .width('100%')
  .padding({ left:10, right: 10})
  .textAlign(TextAlign.Center)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}