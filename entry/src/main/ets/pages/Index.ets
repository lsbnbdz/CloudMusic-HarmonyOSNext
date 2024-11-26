import { IndexHead } from '../components/head/IndexHead'
import { PlayLists } from '../components/main/PlayLists'
import { SearchComponent } from '../components/main/SearchComponent'

@Entry
@Component
struct Index {
  @StorageProp("ValidCookie") isValidCookie:boolean = false

  async build() {
    Stack() {
      Column() {
        IndexHead()
        Column() {
          SearchComponent()
          if (this.isValidCookie) {
            PlayLists()
          } else {
            Column({ space: 5 }) {
              Text('登录账号').fontSize(24).fontWeight(FontWeight.Bold)
              Text('以显示你的歌单').fontSize(24).fontWeight(FontWeight.Bold)
            }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 40 })
          }
        }.height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main'))
  }
}