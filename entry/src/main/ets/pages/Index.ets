import { HttpRequest } from '../common/utils/HttpRequestUtil'
import { IndexHead } from '../components/head/IndexHead'
import { PlayLists } from '../components/main/PlayLists'
import { SearchComponent } from '../components/main/SearchComponent'

@Entry
@Component
struct Index {
  @StorageProp("isValidCookie") isValidCookie:boolean = false
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  onPageShow(): void {
    const url = 'http://111.229.38.178:3000/login/status'
    const request = new HttpRequest(url)
    request.Request().then((data) => { console.log('IndexGotResult: ' + JSON.stringify(data.result))})

    const url2 = 'http://111.229.38.178:3000/song/download/url/v1?id=108485&level=hires'
    const request2 = new HttpRequest(url2)
    request2.Request().then((data) => { console.log('IndexGotResult2: ' + JSON.stringify(data.result))})
  }

  async build() {
    Stack() {
      Column({ space: 10 }) {
        IndexHead()
        SearchComponent()
        if (this.isValidCookie) {
          PlayLists().layoutWeight(1)
        } else {
          Column({ space: 5 }) {
            Text('登录账号\n' +
              '以显示你的歌单')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .padding({top:50})
          }.width('100%').layoutWeight(1)
        }
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main'))
  }
}