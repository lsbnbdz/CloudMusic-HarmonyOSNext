import { getSongPicUrl } from "../../api/songApi"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration, getArtists } from "../../common/functions/commonFunction"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { promptAction } from "@kit.ArkUI"
import { PlayList, playListClass } from "../../common/entities/PlayList"
import Constants from "../../common/constants/Constants"
import { playListToQueue } from "../../common/functions/play/playListOp"
import { playMusicByUrl } from "../../common/functions/play/playControl"
import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { DownloadDialog } from "../dialog/DownloadDialog"

@Component
export struct SongCard {
  @StorageProp('isPlayerLoading') isPlayerLoading:boolean = false
  @StorageProp('isValidCookie') isValidCookie:boolean = false
  @State showPlayButton: boolean = true
  @State showAddQueueButton: boolean = true
  @State showSid: boolean = true
  @State startHeight: number = 60
  @State startOpacity: number = 1
  @State picUrl: string = ''
  @State isPlayList: boolean = false
  @State playList: PlayList = playListClass
  @State index: number = 0
  @State reason: string = ''
  song:Song = SongClass
  sid:number = -1
  artists:string = ''

  downloadDialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
  })

  async aboutToAppear(): Promise<void> {
    this.startHeight = 120; this.startOpacity = 0.1
    const artistsStr = await getArtists(this.song.artists)
    this.artists = artistsStr
    const picUrl = await getSongPicUrl(this.song)
    this.picUrl = picUrl
  }

  build() {
    Button() {
      Row() {
        Row() {
          Text(`${this.sid + 1}`)
            .width(40)
            .fontWeight(FontWeight.Bold)
          Image(this.picUrl + '?param=100y100')
            .width(50)
            .padding({ right: 10 })
            .borderRadius(5)
          Column({ space: 5 }) {
            Row({ space: 5 }) {
              Text(this.song.name).textStyle(16)
              if(this.song.alias.length > 0) {
                Text(`(${this.song.alias[0]})`)
                  .layoutWeight(1)
                  .fontSize(Constants.FONT_SIZE_COMMON)
                  .fontColor(Color.Gray)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
            }
            .width('100%')

            Row({ space: 5 }) {
              if(this.reason) {
                Text(this.reason).reasonText()
              }
              Text(this.artists).textStyle(12).fontColor(Color.Gray)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width(`100%`)
        }
        .layoutWeight(1)

        /**
         * 添加到播放列表
         */
        if(this.showAddQueueButton) {
          Button() {
            Image($r('app.media.ic_public_add_norm'))
              .fillColor($r('app.color.reverse'))
              .width(15)
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
            promptAction.showToast({ message: '成功添加至播放列表' })
          })
        }
      }
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
    .bindMenu(this.ClickMenu)
  }

  @Builder
  ClickMenu() {
    Menu() {
      MenuItem(this.MenuInfo())
      if(this.isPlayerLoading) {
        MenuItem(this.Loading())
      } else {
        MenuItem(this.MenuContent($r('app.media.ic_public_play_norm'), '单曲播放'))
          .onClick(() => {
            this.playSingleSong()
          })
        if(this.isPlayList) {
          MenuItem(this.MenuContent($r('app.media.ic_public_play_norm'), '播放歌单'))
            .onClick(() => {
              playListToQueue(this.playList.id, this.playList.trackCount, this.index)
            })
        }
        MenuItem(this.MenuContent($r('app.media.ic_public_cloud_download'), '下载'))
          .onClick(() => {
            this.downloadDialogController.open()
          })
        MenuItem() {
          Text('左滑歌曲卡片进行歌单操作').textStyle(12).textAlign(TextAlign.Center).width('100%')
        }
      }
    }
    .width('80%')
    .constraintSize({
      minWidth: 100,
      maxWidth: 300
    })
  }

  @Builder MenuInfo() {
    Row() {
      Image(this.picUrl + '?param=100y100')
        .width(Constants.SIZE_IMG_CARD)
        .padding({ right: Constants.PADDING_EDGE_DEFAULT })
        .borderRadius(Constants.RADIUS_IMG)
      Column({ space: 5 }) {
        Row({ space: 5 }) {
          Text(this.song.name).textStyle(Constants.FONT_SIZE_COMMON)
          if(this.song.alias.length > 0) {
            Text(`(${this.song.alias[0]})`)
              .layoutWeight(1)
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontColor(Color.Gray)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')

        Row({ space: 5 }) {
          Text(this.artists).textStyle(12).fontColor(Color.Gray)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width(`100%`)
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .layoutWeight(1)
    .onClick(() => {
      PasteboardUtil.setDataText(this.song.name + ' - ' + this.artists)
      ToastUtil.showToast('已复制歌名与歌手信息至剪贴板', { duration: 3000 })
    })
  }

  @Builder
  MenuContent(image: ResourceStr | string, title: string, contentColor: string | Color | ResourceStr = $r('app.color.reverse')) {
    Row({ space: 10 }) {
      Column() {
        Image(image)
          .fillColor(contentColor)
          .width(Constants.FONT_SIZE_COMMON)
      }
      Text(title)
        .fontColor(contentColor)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
    .height(Constants.HEIGHT_MENU_ITEM_DEFAULT)
  }

  @Builder Loading() {
    Row({ space: 10 }) {
      LoadingProgress().width(Constants.FONT_SIZE_COMMON)
      Text('当前有正在加载的播放任务').fontSize(Constants.FONT_SIZE_COMMON).fontColor($r('app.color.reverse'))
    }
    .justifyContent(FlexAlign.Center)
    .height(Constants.HEIGHT_MENU_ITEM_DEFAULT)
    .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
  }

  private playSingleSong() {
    AppStorage.setOrCreate('isPlayerLoading', true)
    playMusicByUrl(this.song, this.artists, this.isValidCookie).then(() => {
      PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
      PlayQueueUtils.setIndex(PlayQueueUtils.currentQueueIndex + 1)
      AppStorage.setOrCreate('isPlayerLoading', false)
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

@Extend(Text) function reasonText() {
  .fontColor('#ffff3232')
  .fontSize(10)
  .padding(2)
  .backgroundColor('#ffffd2d2')
  .borderRadius(5)
}

@Extend(Span) function menuSpanStyle() {
  .fontSize(Constants.FONT_SIZE_COMMON)
}



