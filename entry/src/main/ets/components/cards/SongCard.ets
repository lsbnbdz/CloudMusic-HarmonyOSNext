import { Song, SongClass } from "../../common/entities/song/SongsResult"
import { changeDuration, getArtists } from "../../common/functions/common/convert"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { promptAction } from "@kit.ArkUI"
import { PlayList, playListClass } from "../../common/entities/playlist/PlayList"
import Constants from "../../common/constants/Constants"
import { cleanLastPlayInfo, playListToQueue } from "../../common/functions/play/playListOp"
import { playQueue } from "../../common/functions/play/playControl"
import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { DownloadDialog } from "../dialog/DownloadDialog"
import { StorageConstants } from "../../common/constants/StorageConstants"
import VibratorUtils from "../../common/utils/system/VibratorUtils"
import { ArtistsSheet } from "../sheets/ArtistsSheet"

@Component
export struct SongCard {
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.SONG_CLICK_ACTION) clickAction: number = 0
  @StorageProp(StorageConstants.PLAY_SONG) playSong: Song = SongClass
  @State showAddQueueButton: boolean = true
  @State picUrl: string | ResourceStr = ''
  @State isPlayList: boolean = false
  @State playList: PlayList = playListClass
  @State index: number = 0
  @State reason: string = ''
  @State isShowMenu: boolean = false
  @State sid: number = -1
  @State isShowArtists: boolean = false
  @State allowToArtist: boolean = true
  song: Song = SongClass
  artists: string = ''

  downloadDialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
  })

  async aboutToAppear(): Promise<void> {
    if(this.song.artists[0].id == 0) {
     this.artists = '未知'
      this.song.artists[0] = {"id": 0, "name": '未知'}
    }
    const artistsStr = await getArtists(this.song.artists)
    this.artists = artistsStr
  }

  build() {
    Button() {
      Row() {
        Row() {
          Text(`${this.sid + 1}`)
            .width(40)
            .fontSize(Constants.FONT_SIZE_BAR)
            .fontColor(Color.Gray)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .visibility(this.sid === -1 ? Visibility.None : Visibility.Visible)
            .padding({ right: 5 })
          if(this.picUrl) {
            Image(typeof this.picUrl === 'string' ? this.picUrl + '?param=100y100' : this.picUrl)
              .width(Constants.SIZE_IMG_CARD)
              .padding(3)
              .aspectRatio(1)
              .borderRadius(5)
              .draggable(false)
          }
          Column({ space: 5 }) {
            Row({ space: 5 }) {
              Text(this.song.name)
                .textStyle(16)
                .fontColor(this.song.id == this.playSong.id ? $r('app.color.app_red') : $r('app.color.reverse'))
                .fontWeight(this.song.id == this.playSong.id ? FontWeight.Bold : FontWeight.Medium)
              if(this.song.alias?.length > 0) {
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
              if(this.song.fee != 8 && this.song.fee != 0) {
                Text(this.song.fee == 1 ? ' VIP ' : '单曲付费')
                  .reasonText()
              }
              Text(this.artists).textStyle(12).fontColor(Color.Gray).layoutWeight(1)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT })
          .width(`100%`)
        }
        .layoutWeight(1)

        /**
         * 添加到播放列表
         */
        if(this.showAddQueueButton) {
          Button() {
            Image($r('app.media.ic_public_add_norm'))
              .draggable(false)
              .fillColor($r('app.color.reverse'))
              .width(15)
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.addToQueue()
          })
        }
      }
      .height(60)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: this.sid === -1 ? 20 : 5 , right: 20 })
    // Card 点击
    .onClick(async () => {
      if(this.song.id == this.playSong.id) {
        return
      } else if(this.clickAction == 0) {
        this.isShowMenu = true
      } else if(this.clickAction == 1) {
        this.playSingleSong()
      } else if(this.isPlayList) {
        this.playWithPlayList()
      } else {
        this.playSingleSong()
      }
    })
    .bindContextMenu(this.isShowMenu, this.ClickMenu, { onDisappear: () => { this.isShowMenu = false }})
    .bindSheet(this.isShowArtists, this.ArtistsSheet(), {
      preferType: SheetType.CENTER,
      height: SheetSize.FIT_CONTENT,
      dragBar: false,
      showClose: false,
      backgroundColor: Color.Transparent,
      blurStyle: BlurStyle.Regular,
      onDisappear: () => { this.isShowArtists = false }
    })
    .gesture(
      LongPressGesture({
        duration: 500
      }).onAction(() => {
        VibratorUtils.startCount('sharp', 1, 100)
        this.isShowMenu = true
      })
    )
  }

  @Builder ArtistsSheet() {
    ArtistsSheet({ isShow: this.isShowArtists, isShowCover: this.isShowArtists, artists: this.song.artists })
  }

  @Builder ClickMenu() {
    Menu() {
      MenuItem(this.MenuInfo())
      if(this.isPlayerLoading) {
        MenuItem(this.Loading())
      }
      else {
        MenuItem(this.MenuContent($r('app.media.ic_public_play_norm'), '单曲播放'))
          .onClick(() => {
            this.playSingleSong()
          })

        MenuItem(this.MenuContent($r('app.media.ic_public_play_norm'), '随歌单播放'))
          .visibility(this.isPlayList ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            playListToQueue(this.playList.id, this.playList.trackCount, this.index)
          })

        MenuItem(this.MenuContent($r('app.media.ic_public_add_norm'), '添加到下一首'))
          .onClick(() => {
            this.addToQueue()
          })

        MenuItem(this.MenuContent($r('app.media.ic_user_portrait'), '查看歌手'))
          .visibility(this.song.artists[0].id !== 0 && this.allowToArtist ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.isShowArtists = true
          })

        MenuItem(this.MenuContent($r('app.media.ic_public_cloud_download'), '缓存至本地曲库'))
          .onClick(() => {
            this.downloadDialogController.open()
          })
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
      if(this.picUrl) {
        Image(this.picUrl + '?param=100y100')
          .width(Constants.SIZE_IMG_CARD)
          .padding({ right: Constants.PADDING_EDGE_DEFAULT })
          .borderRadius(Constants.RADIUS_IMG)
      }
      Column({ space: 5 }) {
        Row({ space: 5 }) {
          Text(this.song.name)
            .fontWeight(FontWeight.Bold)
            .fontSize(Constants.FONT_SIZE_COMMON)
            .alignSelf(ItemAlign.Start)
            .fontColor($r('app.color.reverse'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if(this.song.alias?.length > 0) {
            Text(`(${this.song.alias[0]})`)
              .layoutWeight(1)
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontColor(Color.Gray)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.MARQUEE })
          }
        }
        .width('100%')

        Row({ space: 5 }) {
          Text(this.artists)
            .textStyle(12)
            .fontColor(Color.Gray)
            .fontWeight(FontWeight.Medium)
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

  private addToQueue() {
    cleanLastPlayInfo()
    PlayQueueUtils.queueAdd(1, this.song, this.artists, '', this.picUrl ?? $r('app.media.ic_public_music'))
    ToastUtil.showToast('成功添加到下一首播放')
  }

  private playSingleSong() {
    if(!this.isPlayerLoading) {
      cleanLastPlayInfo()
      AppStorage.setOrCreate('isPlayerLoading', true)
      PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
      PlayQueueUtils.setIndex(PlayQueueUtils.currentQueueIndex + 1)
      playQueue(PlayQueueUtils.currentQueueIndex)
      setTimeout(() => {
        AppStorage.setOrCreate('isPlayerLoading', false)
      }, 500)
    } else {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
    }
  }

  private async playWithPlayList() {
    if(!this.isPlayerLoading) {
      this.isPlayerLoading = true
      await playListToQueue(this.playList.id, this.playList.trackCount, this.index)
      this.isPlayerLoading = false
    } else {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
    }
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


