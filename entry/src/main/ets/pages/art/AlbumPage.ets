import { DialogUtil } from "@pura/harmony-utils"
import { getAlbumInfo } from "../../api/albumApi"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AlbumParam } from "../../common/entities/local/PageParams"
import { PlayListSong } from "../../common/entities/playlist/PlayListSongs"
import { SongCard } from "../../components/cards/SongCard"
import Constants from "../../common/constants/Constants"
import { BottomBarComponent } from "../../components/play/BottomBarComponent"
import { AlbumResult, AlbumResultItem } from "../../common/entities/song/Album"
import { playListToQueue } from "../../common/functions/play/playListOp"

@Component
export struct AlbumPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageLink(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @State songs: PlayListSong[] = []
  @State isLoading: boolean = true
  @State albumInfo: AlbumResult = AlbumResultItem
  @State param: AlbumParam = {
    album: {
      id: 0,
      name: '',
      picUrl: ''
    }
  }

  async aboutToAppear(): Promise<void> {
    this.albumInfo = await getAlbumInfo(this.param.album.id)
    this.songs = this.albumInfo.songs
    this.isLoading = false
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        // Loading
        if(this.isLoading) {
          Column() {
            LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .width('100%')
          .height('100%')
          .padding({ bottom: px2vp(this.bottomRectHeight)})
          .justifyContent(FlexAlign.Center)
        } else {
          // Main List Content
          List() {
            this.AlbumInfo()
            ListItem() {
              this.PlayAllButton()
            }
            .padding({ left: Constants.PADDING_EDGE_DEFAULT })
            ForEach(this.songs, (item: PlayListSong, index) => {
              SongCard({
                playmode: 1,
                song: {
                  id: item.id,
                  artists: item.ar,
                  album: item.al,
                  name: item.name,
                  duration: item.dt,
                  alias: [],
                  fee: item.fee
                },
                index: index,
                sid: index,
                isShowArtistSheet: false
              })
            })
            ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
          }
          .height('100%')
          .width('100%')
          .lanes(this.breakpoint === 'sm' ? 1 : 2)
          .scrollBar(BarState.Auto)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .cachedCount(10)
          .visibility(this.isLoading ? Visibility.None : Visibility.Visible)
          .edgeEffect(EdgeEffect.Spring)
          .backToTop(true)
        }

        BottomBarComponent()
          .padding(Constants.PADDING_EDGE_DEFAULT)
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.background'))
    .title('专辑')
  }

  @Builder PlayAllButton() {
    if(this.isPlayerLoading) {
      Column() {
        LoadingProgress()
          .width(Constants.SIZE_LOADING_PROGRESS_CARD)
      }
      .padding({ left: Constants.PADDING_EDGE_TEXT})
      .height(Constants.HEIGHT_TEXT_BUTTON)
      .justifyContent(FlexAlign.Center)
    } else {
      Button() {
        Row({ space: 5 }) {
          Image($r('app.media.ic_play_fill')).width(Constants.FONT_SIZE_COMMON)
            .fillColor(Color.Gray)
          Row({ space: 5 }) {
            Text(`播放全部 (${this.songs.length})`)
              .fontSize(Constants.FONT_SIZE_COMMON)
          }
        }
        .padding({ left: 5, right: 5 })
      }
      .height(Constants.HEIGHT_TEXT_BUTTON)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.isPlayerLoading = true
        playListToQueue(this.songs, 0)
        setTimeout(() => {
          this.isPlayerLoading = false
        }, 500)
      })
    }
  }

  @Builder AlbumInfo() {
    Row({ space: Constants.PADDING_EDGE_DEFAULT }) {
      Image(this.albumInfo.album.picUrl + '?param=512y512')
        .width(120)
        .aspectRatio(1)
        .borderRadius(Constants.RADIUS_IMG)
      Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
        Text(this.albumInfo.album.name)
          .textStyle(Constants.FONT_SIZE_TITLE, Constants.FONT_WEIGHT_BOLD)
          .fontColor($r('app.color.reverse'))
        Text(`发行商: ${this.albumInfo.album.company}`)
          .textStyle()
          .visibility(this.albumInfo.album.company ? Visibility.Visible : Visibility.None)
        Text(this.albumInfo.album.description)
          .textStyle(12)
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
          .onClick(() => {
            DialogUtil.showConfirmDialog({
              title: this.albumInfo.album.name,
              message: this.albumInfo.album.description
            })
          })
      }
      .layoutWeight(1)
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
  }
}

@Extend(Text) function textStyle(size: number = Constants.FONT_SIZE_COMMON, bold: number = FontWeight.Medium) {
  .width('100%')
  .fontWeight(bold)
  .fontSize(size)
  .fontColor(Color.Gray)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}