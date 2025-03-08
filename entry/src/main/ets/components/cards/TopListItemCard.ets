import Constants from "../../common/constants/Constants"
import { PlayListPageParam } from "../../common/entities/PageParams"
import { TopListItem } from "../../common/entities/TopList"

@Component

export struct TopListItemCard {
  @State topListItem: TopListItem = {
    id: 0,
    name: "",
    trackCount: 0,
    updateFrequency: "",
    coverImgUrl: "",
    description: "",
    playCount: 0,
    subscribedCount: 0
  }
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Button() {
      Column({ space: 5 }) {
        Image(this.topListItem.coverImgUrl)
          .width(120)
          .aspectRatio(1)
          .borderRadius(Constants.RADIUS_CARD)
          .draggable(false)
      }
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(Constants.RADIUS_CARD)
    .type(ButtonType.Normal)
    .width(120)
    .aspectRatio(1)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(() => {
      let param: PlayListPageParam = {
        playList: {
          userId: 0,
          id: this.topListItem.id,
          name: this.topListItem.name,
          playCount: this.topListItem.playCount,
          coverImgUrl: this.topListItem.coverImgUrl,
          trackCount: this.topListItem.trackCount,
          subscribedCount: this.topListItem.subscribedCount,
          subscribed: false,
          creator: {
            userId: 0,
            nickname: '官方'
          }
        },
        isShowHeart: false,
        useTimestamp: false
      }
      if(this.pageInfos.size() < 2) {
        this.pageInfos.pushPathByName('PLayListPage', param, true)
      } else {
        this.pageInfos.replacePathByName('PLayListPage', param, true)
      }
    })
  }
}