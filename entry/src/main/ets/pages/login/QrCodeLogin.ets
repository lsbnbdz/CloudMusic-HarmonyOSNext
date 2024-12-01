import { checkQrLogin, getQrCode } from '../../api/QrCodeLogin';
import { CommonHead } from '../../components/head/CommonHead';

@Entry
@Component
struct QrCodeLogin {
  @State qrCode:string[] = []

  async onPageShow(): Promise<void> {
    this.qrCode = await getQrCode()
  }

  build() {
    Stack() {
      Column({ space: 30 }) {
        CommonHead({ title: '登录' })
        Column({ space: 10 }) {
          Text('使用网易云音乐App扫描下方二维码')
          // QR Code
          if(!this.qrCode) { Text('获取二维码出错').fontColor(Color.Red) }
          else {
            Image(this.qrCode[1]).width(256)
          }
          Button('获取登录状态')
            .onClick(() => {
              checkQrLogin(this.qrCode[0])
            })
        }
        .layoutWeight(1)

      }
    }
    .height('100%')
    .width('100%')
  }
}