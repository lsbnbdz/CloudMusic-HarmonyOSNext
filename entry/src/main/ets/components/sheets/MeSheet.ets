import { router } from "@kit.ArkUI";
import { logOut } from "../../api/LogOut";
import { User, UserClass } from "../../common/entities/User";

@Component
export struct MeSheet {
  @StorageProp("isValidCookie") isValidCookie: boolean = false
  @StorageProp("User") user: User = UserClass
  @StorageProp("bottomRectHeight") bottomRectHeight: number = 0
  @Link isShowSheet:boolean

  build() {
    Column({ space: 20 }) {
      if (!this.isValidCookie || !this.user) {// 未登录
        Image($r('app.media.ic_user_portrait')).width(80)
        Text('未登录').NormalText(24)
        Button('登 录').LoginButton()
          .onClick(() => {
            router.pushUrl({ url:'pages/login/LoginPage' })
          })
        } else {
        Column({ space: 20 }) {
          Image(this.user.data.profile.avatarUrl).width(80).borderRadius(50)
          Text(this.user.data.profile.nickname).NormalText(24)
          Button('退出登录').LoginButton()
            .onClick(() => {
              this.isShowSheet = !this.isShowSheet
              logOut()
            })
        }.width('100%')
      }
    }
    .width('100%')
    .padding({ top:20, bottom:px2vp(this.bottomRectHeight)})
  }

}

@Extend(Text) function NormalText(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
}

@Extend(Button) function LoginButton() {
  .buttonStyle(ButtonStyleMode.NORMAL)
  .borderRadius(20)
  .padding({left:5, right:5})
  .width(120)
}
