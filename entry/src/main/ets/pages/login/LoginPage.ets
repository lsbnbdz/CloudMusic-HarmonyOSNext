import { CommonHead } from '../../components/head/CommonHead'
import { promptAction, router } from '@kit.ArkUI';

/**
 * 登录页面
 */

@Entry
@Component
struct LoginPage {
  build() {
    Stack() {
      Column({ space: 30 }) {
        CommonHead({ title: '登录' })

        Text('登录账号').textStyle(24).padding({ bottom: 10 })

        Button({ type: ButtonType.Normal }) {
          Row({ space: 10 }) {
            Image($r('app.media.ic_celiakeyboard_default')).imageStyle()
            Text('网页登录').textStyle(20)
          }.height('100%').onClick(() => {
            router.replaceUrl({ url:'pages/login/WebLogin' })
          })
        }.backgroundColor('#ff3e93ea').borderRadius(10).height(80).width(240)

        Button({ type: ButtonType.Normal }) {
          Row({ space: 10 }) {
            Image($r('app.media.ic_public_input_code')).imageStyle()
            Text('二维码登录').textStyle(20)
          }.height('100%').onClick(() => {
            router.replaceUrl({ url:'pages/login/QrCodeLogin' })
          })
        }.backgroundColor('#ffff3737').borderRadius(10).height(80).width(240)


      }
      .backgroundColor($r('app.color.main'))
      .height('100%')
      .width('100%')

    }
    .width('100%').height('100%')
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontColor($r('app.color.reverse'))
  .fontSize(size)
  .fontWeight(FontWeight.Bold)
}

@Extend(Image) function imageStyle() {
  .height('60%')
  .fillColor($r('app.color.reverse'))
}
