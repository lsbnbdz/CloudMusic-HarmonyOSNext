import { HttpRequest } from '../common/utils/HttpRequestUtil'
import { IndexHead } from '../components/head/IndexHead'
import { PlayLists } from '../components/main/PlayLists'
import { SearchComponent } from '../components/main/SearchComponent'

@Entry
@Component
struct Index {
  @StorageProp("isValidCookie") isValidCookie:boolean = false
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  async build() {
    Stack() {
      Column({ space: 10 }) {
        IndexHead()
        SearchComponent()
        if (this.isValidCookie) {
          PlayLists()
            .layoutWeight(1)
        }
        else {
          Column({ space: 5 }) {
            Text('登录账号\n' +
              '以显示你的歌单')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .padding({top:50})
          }.width('100%')
          .layoutWeight(1)
        }
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main'))
  }
}