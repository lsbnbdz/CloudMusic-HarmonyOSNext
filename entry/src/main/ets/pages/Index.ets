import { IndexHead } from '../components/head/IndexHead'
import { UserPlayLists } from '../components/lists/UserPlayLists'
import { BottomPlayController } from '../components/play/BottomPlayController';
import { router } from '@kit.ArkUI';
import { RecommendCards_NotLogged } from '../components/main/RecommendCards';

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
            this.NotLogged()
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

  @Builder
  NotLogged() {
    List({ space: 10 }) {
      ListItem() {
        Search({
          placeholder: '搜索内容',
          icon: '/resources/base/media/ic_public_search_filled.svg',
        })
          .sharedTransition('search_component', {
            duration: 300,
            curve: Curve.Friction
          })
          .focusable(false)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SearchPage'
            })
          })
      }
      .padding({ left: 20, right: 20 })
      ListItem() {
        RecommendCards_NotLogged()
      }
      ListItem() {
        Column({ space: 15 }) {
          Text('尚未登录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .padding({ top: 100 })
          Text('点击左上角图标进行登录\n以获取日推、歌单、云盘等内容')
            .fontSize(18)
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
      }
    }
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
  }
}