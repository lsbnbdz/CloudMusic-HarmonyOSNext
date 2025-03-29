import Constants from "../../common/constants/Constants"
import { ArtistParam } from "../../common/entities/local/PageParams"
import { ArtistItem } from "../../common/entities/song/ArtistsResult"

@Component
export struct ArtistCard {
  @Consume('pageInfos') pageInfos: NavPathStack

  artistItem: ArtistItem = {
    artistId: 0,
    artistName: "",
    artistAvatarPicUrl: ""
  }

  build() {
    Button() {
      Row({ space: 10 }) {
        Image(this.artistItem.artistAvatarPicUrl)
          .width(Constants.SIZE_IMG_CARD)
          .aspectRatio(1)
          .borderRadius(Constants.RADIUS_CARD)
        Text(this.artistItem.artistName)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.reverse'))
        .layoutWeight(1)
      }
      .padding({ left: 20, right: 20 })
    }
    .type(ButtonType.Normal)
    .backgroundColor(Color.Transparent)
    .borderRadius(10)
    .width('100%')
    .height(60)
    .onClick(() => {
      const param: ArtistParam = {
        artist: {
          id: this.artistItem.artistId,
          name: this.artistItem.artistName
        }
      }
      this.pageInfos.pushPathByName('ArtistPage', param)
    })
  }
}