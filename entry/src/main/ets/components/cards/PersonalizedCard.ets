import Constants from "../../common/constants/Constants"
import { PlayListPageParam } from "../../common/entities/PageParams"
import { PersonalListItem } from "../../common/entities/Personalized"

@Component
@Reusable
export struct PersonalizedCard {
  @State item: PersonalListItem = {
    id: 0,
    type: 0,
    name: "",
    copywriter: "",
    picUrl: "",
    playCount: 0,
    trackCount: 0
  }
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Row({ space: 10 }) {
      Image(this.item.picUrl)
        .height(80)
        .borderRadius(Constants.RADIUS_IMG)

      Column() {
        Text(this.item.name)
          .fontColor($r('app.color.reverse'))
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .width('100%')
          .textAlign(TextAlign.Start)
          .lineHeight(22)
      }
      .layoutWeight(1)
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .width(250)
    .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.9 })
    .onClick(() => {
      let param: PlayListPageParam = {
        playList: {
          userId: 0,
          id: this.item.id,
          name: this.item.name,
          playCount: this.item.playCount,
          coverImgUrl: this.item.picUrl,
          trackCount: this.item.trackCount,
          subscribedCount: 0,
          subscribed: false,
          creator: {
            userId: 0,
            nickname: '官方'
          }
        },
        isShowHeart: false
      }
      if(this.pageInfos.size() < 2) {
        this.pageInfos.pushPathByName('PLayListPage', param, true)
      } else {
        this.pageInfos.replacePathByName('PLayListPage', param, true)
      }
    })
  }
}