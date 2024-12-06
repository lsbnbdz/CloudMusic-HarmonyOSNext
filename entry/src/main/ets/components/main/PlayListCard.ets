import { router } from "@kit.ArkUI"
import { playList } from "../../common/entities/PlayList"
import { playListClass } from "../../common/entities/PlayList"

@Preview
@Component
export struct PlayListCard {
  @State isShowSheet:boolean = false

  playList:playList = playListClass

  build() {
    Button() {
      Row({ space:15 }) {
        Image(`${this.playList.coverImgUrl}?param=128y128`).width(50).borderRadius(15)
        Column({ space: 8 }) {
          Text(this.playList.name).textStyle(16).fontWeight(FontWeight.Medium)
          Text(`歌单 · ${this.playList.trackCount} 首 · ${this.playList.playCount} 次播放`).textStyle(12)
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/PlayListPage',
        params: { 'playList': this.playList, 'trackCount': this.playList.trackCount }
      })
    })
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .alignSelf(ItemAlign.Start)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}




