import { User } from "../../common/entities/User";

@Component
export struct LoginHelpSheet {
  @StorageLink("ValidCookie") validCookie: boolean = false;
  @StorageLink("User") user: User | null = null
  @StorageProp("bottomRectHeight") bottomRectHeight: number = 0;
  @Link isShowSheet:boolean

  build() {
    Column({ space: 20 }) {
      Text('- 如何登录 -').textStyle(24)
      Text('在当前网页中登录你的网易云音乐账号').textStyle(16)
      Text('（任意登录方式均可）').textStyle(16)
      Text('登录完成后点击页面最下方的按钮').textStyle(16)
      Text('之后等待登录完成').textStyle(16)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding({bottom:px2vp(this.bottomRectHeight)})
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.background'))
}