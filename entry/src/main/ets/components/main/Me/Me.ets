import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import { getLoginStatus, logOut } from "../../../api/loginApi"
import Constants from "../../../common/constants/Constants"
import { StorageConstants } from "../../../common/constants/StorageConstants"
import { User, UserItem } from "../../../common/entities/user/User"
import { initUserInfo } from "../../../common/functions/app/appInit"
import { SettingsPage } from "../../../pages/settings/SettingsPage"
import { CircleImageButton } from "../../buttons/CircleButton"

@Component
export struct Me {
  @StorageProp(StorageConstants.IS_LOGGED) isLogged: boolean = false
  @StorageProp(StorageConstants.USER) user: User = UserItem
  @StorageProp(StorageConstants.VALID_API_URL) isValidAPI: boolean = true
  @StorageProp(StorageConstants.VALID_COOKIE) isValidCookie: boolean = true
  @StorageProp(StorageConstants.COOKIE) cookie: string = ''
  @StorageProp(StorageConstants.APP_LOADING) appLoading: boolean = true
  @State isRefreshing: boolean = false
  @Prop breakpoint: string = 'sm'
  @StorageLink('isShowSettings') isShowSettings: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack

  async aboutToAppear(): Promise<void> {
    if(this.isValidAPI && this.cookie && !this.isLogged) {
      this.appLoading = true
      await getLoginStatus(this.cookie)
      this.appLoading = false
    }
  }

  private async handleRefresh() {
    this.isRefreshing = true
    ToastUtil.showToast('正在刷新登录状态')
    try {
      await initUserInfo()
    } finally {
      this.isRefreshing = false
    }
  }

  build() {
    Column({ space: 10 }) {
      Column() {
        if (this.isLogged) {
          Row({ space: 20 }) {
            CircleImageButton({ imgUrl: this.user.data.profile.avatarUrl + '?param=256y256', wid: 64 })
            Text(this.user.data.profile.nickname).textStyle(Constants.FONT_SIZE_TITLE).fontWeight(FontWeight.Bold)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .padding({ bottom: 10 })
        } else if(this.appLoading) {
          LoadingProgress().width(40)
        } else if(this.isValidAPI) {
          Row({ space: 20 }) {
            CircleImageButton({ imgUrl: $r('app.media.ic_user_portrait'), wid: 64 })
            Text('未登录').textStyle(Constants.FONT_SIZE_TITLE).fontWeight(FontWeight.Bold)
            this.RefreshButton()
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .padding({ bottom: 10 })
        }
      }
      .height(80)

      Column() {
        this.ItemCard($r('app.media.ic_public_settings_filled'), '应用设置', () => {
          this.isShowSettings = true
        })
      }
      .itemColumnStyle()

      Column() {
        this.ItemCard($r('app.media.ic_public_folder_filled'), '本地曲库', () => {
          this.pageInfos.pushPath({ name: 'LocalSongPage', param: null }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
        })
      }
      .itemColumnStyle()

      Column().padding(30)

      if(this.isValidAPI && !this.appLoading) {
        if(this.isLogged) {
          this.LoginButton($r('app.color.app_red'), '退出登录', () => {
            this.LogOut()
          })
        } else {
          this.LoginButton(Color.Blue, '登 录', () => {
            this.pageInfos.pushPathByName('LoginPage', null, this.breakpoint === 'lg' && this.pageInfos.size() === 0 ? false : true)
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .constraintSize({
      minWidth: 200,
      maxWidth: 500
    })
    .backgroundColor($r('app.color.background'))
    .padding({ left: 20, right: 20 })
    .bindSheet(this.isShowSettings, this.Settings(), {
      preferType: SheetType.CENTER,
      height: SheetSize.LARGE,
      dragBar: false,
      showClose: false,
      scrollSizeMode: ScrollSizeMode.FOLLOW_DETENT,
      backgroundColor: $r('app.color.background'),
      onDisappear: () => { this.isShowSettings = false }
    })
  }

  @Builder ItemCard(icon: ResourceStr | string, text: string, action: () => void) {
    Button() {
      Row({ space: 10 }) {
        Image(icon).iconStyle()
        Text(text).textStyle(16).fontWeight(FontWeight.Medium).textAlign(TextAlign.Start).layoutWeight(1)
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

  @Builder RefreshButton() {
    if(this.isRefreshing) {
      LoadingProgress().width(Constants.FONT_SIZE_COMMON).aspectRatio(1)
    } else {
      Image($r('app.media.ic_public_refresh'))
        .width(Constants.FONT_SIZE_COMMON)
        .aspectRatio(1)
        .fillColor($r('app.color.reverse'))
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
        .onClick(() => {
          this.handleRefresh()
        })
    }
  }

  @Builder Settings() {
    SettingsPage()
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
          let result = await logOut()
          if(result) {
            ToastUtil.showToast('成功退出登录')
          } else {
            ToastUtil.showToast('退出登录时出错')
          }
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