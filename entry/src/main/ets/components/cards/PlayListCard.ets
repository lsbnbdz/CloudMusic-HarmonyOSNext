import { PlayList } from "../../common/entities/PlayList"
import { playListClass } from "../../common/entities/PlayList"
import { PlayListPageParam } from "../../common/entities/PageParams"
import Constants from "../../common/constants/Constants"

@Component
export struct PlayListCard {
  @Consume('pageInfos') pageInfos: NavPathStack
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
        Image(`${this.playList.coverImgUrl}?param=256y256`)
          .width(50)
          .borderRadius(15)
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
      let param: PlayListPageParam = {
        playList: this.playList,
        isShowHeart: this.isShowHeart
      }
      this.pageInfos.pushPathByName('PLayListPage', param, true)
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

@Component
export struct PlayListCard_Skeleton {
  build() {
    Button() {
      Row({ space:15 }) {
        Column()
          .backgroundColor($r('app.color.main'))
          .width(50)
          .aspectRatio(1)
          .borderRadius(Constants.RADIUS_CARD)
        Column({ space: 8 }) {
          Column().backgroundColor($r('app.color.main')).borderRadius(Constants.RADIUS_CARD).height(Constants.FONT_SIZE_TITLE).width('100%')
          Column().backgroundColor($r('app.color.main')).borderRadius(Constants.RADIUS_CARD).height(Constants.FONT_SIZE_COMMON).width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(Constants.HEIGHT_TEXT_BUTTON)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20, bottom: 10 })
  }
}



