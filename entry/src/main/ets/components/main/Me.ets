import { DialogUtil } from "@pura/harmony-utils"
import { logOut } from "../../api/LogOut"
import Constants from "../../common/constants/Constants"
import { User, UserClass } from "../../common/entities/User"
import { CircleImageButton } from "../buttons/CircleButton"

@Component
export struct Me {
  @StorageProp("isValidCookie") isValidCookie: boolean = false
  @StorageProp('User') user: User = UserClass
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Column({ space: 10 }) {
      if (this.isValidCookie && this.user) {
        Row({ space: 20 }) {
          CircleImageButton({ imgUrl: this.user.data.profile.avatarUrl + '?param=256y256', wid: 64 })
          Text(this.user.data.profile.nickname).textStyle(Constants.FONT_SIZE_TITLE).fontWeight(FontWeight.Bold)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ bottom: 10 })
      } else {
        Row({ space: 20 }) {
          CircleImageButton({ imgUrl: $r('app.media.ic_user_portrait'), wid: 64 })
          Text('未登录').textStyle(Constants.FONT_SIZE_TITLE).fontWeight(FontWeight.Bold)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ bottom: 10 })
      }

      Column() {
        this.ItemCard($r('app.media.ic_public_settings_filled'), '设置', () => {
          this.pageInfos.pushPathByName('SettingsPage', null)
        })
      }
      .itemColumnStyle()

      Column() {
        this.ItemCard($r('app.media.ic_public_download_filled'), '下载', () => {
          this.pageInfos.pushPathByName('DownloadPage', null)
        })
      }
      .itemColumnStyle()

      Column().padding(30)

      if(this.isValidCookie) {
        this.LoginButton($r('app.color.app_red'), '退出登录', () => {
          this.LogOut()
        })
      } else {
        this.LoginButton(Color.Blue, '登 录', () => {
          this.pageInfos.pushPathByName('LoginPage', null)
        })
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .padding({ left: 20, right: 20 })
  }

  @Builder ItemCard(icon: ResourceStr | string, text: string, action: () => void) {
    Button() {
      Row({ space: 10 }) {
        Image(icon).iconStyle()
        Text(text).textStyle(Constants.FONT_SIZE_COMMON + 2).textAlign(TextAlign.Start).layoutWeight(1)
        Image($r('app.media.ic_public_arrow_right')).iconStyle()
      }
    }
    .backgroundColor(Color.Transparent)
    .width('100%')
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .onClick(action)
  }

  @Builder LoginButton(color: Color | string | ResourceStr, text: string, action: () => void) {
    Button() {
      Row({ space: 10 }) {
        Text(text)
          .textStyle(Constants.FONT_SIZE_COMMON + 2)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
      }
    }
    .backgroundColor(color)
    .width('100%')
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .onClick(action)
  }

  private LogOut() {
    DialogUtil.showPrimaryDialog({
      title: '确认',
      message: '是否退出登录?',
      primaryButton: "取消",
      secondaryButton: {
        value: '确认',
        fontColor: Color.Red,
        action: async () => {
          logOut()
        }
      }
    })
  }
}

@Extend(Text) function textStyle(size: number = Constants.FONT_SIZE_COMMON) {
  .fontSize(size)
  .textAlign(TextAlign.Center)
  .fontColor($r('app.color.reverse'))
}

@Extend(Image) function iconStyle() {
  .width(Constants.SIZE_ICON_BUTTON_BAR)
  .fillColor(Color.Gray)
  .draggable(false)
}

@Extend(Column) function itemColumnStyle() {
  .backgroundColor($r('app.color.main'))
  .borderRadius(Constants.RADIUS_CARD)
  .width('100%')
  .padding(5)
}