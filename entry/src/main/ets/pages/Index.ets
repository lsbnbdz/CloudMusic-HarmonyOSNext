import { IndexHead } from '../components/head/IndexHead'
import { UserPlayLists } from '../components/lists/UserPlayLists'
import { BottomPlayController } from '../components/play/BottomPlayController';

@Entry
@Component
struct Index {
  @StorageProp("isValidCookie") isValidCookie:boolean = false
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State isShowSearchButton: boolean = false

  pageTransition() {
    PageTransitionEnter({ duration: 100, curve: Curve.Ease })
  }

  async build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        IndexHead({ isShowSearchButton: this.isShowSearchButton })
        Stack({ alignContent: Alignment.Top }) {
          if (this.isValidCookie) {
            UserPlayLists({ isShowSearchButton: this.isShowSearchButton })
              .layoutWeight(1)
          } else {
            Column({ space: 5 }) {
              Text('登录账号\n' +
                '以显示你的歌单')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .padding({ top: 100 })
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
          }
        }

      }
      BottomPlayController()
        .padding({ left: 10, right: 10, bottom: px2vp(this.bottomRectHeight)})
        .backgroundColor(Color.Transparent)
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}