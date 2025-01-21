import { router } from "@kit.ArkUI"
import { PlayList } from "../../common/entities/PlayList"
import { playListClass } from "../../common/entities/PlayList"

@Component
export struct PlayListCard {
  @State hasAnimation: boolean = false
  @State startOpacity:number = 1
  @State startHeight:number = 60
  @State isShowHeart: boolean = true
  playList:PlayList = playListClass

  aboutToAppear(): void {
    if(this.hasAnimation) { this.startHeight = 120; this.startOpacity = 0.1}
  }

  build() {
    Button() {
      Row({ space:15 }) {
        Image(`${this.playList.coverImgUrl}?param=128y128`).width(50).borderRadius(15)
        Column({ space: 8 }) {
          Text(this.playList.name).textStyle(16).fontWeight(FontWeight.Medium)
          Text(`歌单 · ${this.playList.trackCount} 首 · ${this.playList.creator.nickname}`).textStyle(12)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(this.startHeight)
      .opacity(this.startOpacity)
      .onAppear( () => {
        this.startHeight = 60
        this.startOpacity = 1
      })
      .animation({
        duration: 600,
        curve: Curve.LinearOutSlowIn,
      })
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
        params: { 'playList': this.playList, 'trackCount': this.playList.trackCount, 'isShowHeart': this.isShowHeart }
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




