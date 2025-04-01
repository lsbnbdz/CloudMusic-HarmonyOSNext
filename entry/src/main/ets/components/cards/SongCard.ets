import { Song, SongItem } from "../../common/entities/song/SongsResult"
import { getArtists } from "../../common/functions/common/convert"
import { PlayList, playListItem } from "../../common/entities/playlist/PlayList"
import Constants from "../../common/constants/Constants"
import { cleanLastPlayInfo, playListToQueue } from "../../common/functions/play/playListOp"
import { ToastUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../../common/constants/StorageConstants"
import VibratorUtils from "../../common/utils/system/VibratorUtils"
import { ArtistsSheet } from "../sheets/ArtistsSheet"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { playQueue } from "../../common/functions/play/playControl"
import { SongInfoSheet } from "../sheets/SongInfoSheet"
import { PlayListAddSheet } from "../sheets/PlayListAddSheet"

@Component
export struct SongCard {
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.SONG_CLICK_ACTION) clickAction: number = 0
  @StorageProp(StorageConstants.PLAY_SONG) playSong: Song = SongItem
  @State picUrl: string | ResourceStr = ''
  @State playlist: PlayList = playListItem
  @State index: number = 0
  @State reason: string = ''
  @State sid: number = -1
  @State allowToArtist: boolean = true
  @State isShowSheet: boolean = false
  @State isShowAddSheet: boolean = false
  @State isShowArtistSheet: boolean = false
  playmode: number = 1 // 0-本地歌曲   1-单曲   2-歌单歌曲   3-电台歌曲
  song: Song = SongItem
  artists: string = ''


  async aboutToAppear(): Promise<void> {
    if(this.song.artists[0].id == -1) {
     this.artists = '未知'
      this.song.artists[0] = {"id": 0, "name": '未知'}
    }
    const artistsStr = await getArtists(this.song.artists)
    this.artists = artistsStr
  }


  private handleClick() {
    if(this.song.id == this.playSong.id) {
      return
    } else if(this.clickAction == 0) {
      this.isShowSheet = true
    } else if(this.clickAction == 1) {
      this.playSingleSong()
    } else if(this.playlist.id > 0) {
      this.playWithPlayList()
    } else {
      this.playSingleSong()
    }
  }

  private playSingleSong() {
    if(!this.isPlayerLoading) {
      cleanLastPlayInfo()
      AppStorage.setOrCreate('isPlayerLoading', true)
      PlayQueueUtils.queueAdd(this.playmode, this.song, this.artists, '')
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
      await playListToQueue(this.playlist.id, this.playlist.trackCount, this.index)
      this.isPlayerLoading = false
    } else {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
    }
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
            .bindSheet(this.isShowAddSheet, this.AddToPlaylistSheet(), {
              preferType: SheetType.CENTER,
              height: '60%',
              dragBar: false,
              showClose: false,
              backgroundColor: Color.Transparent,
              blurStyle: BlurStyle.Regular,
              onDisappear: (() => { this.isShowAddSheet = false})
            })

            Row({ space: 5 }) {
              if(this.reason) {
                Text(this.reason)
                  .reasonText()
              }
              if(this.song.fee != 8 && this.song.fee != 0) {
                Text(this.song.fee == 1 ? ' VIP ' : '单曲付费')
                  .reasonText()
              }
              Text(this.artists).textStyle(12).fontColor(Color.Gray).layoutWeight(1)
            }
            .width('100%')
            .bindSheet(this.isShowArtistSheet, this.ArtistsSheet(), {
              preferType: SheetType.CENTER,
              height: SheetSize.FIT_CONTENT,
              dragBar: false,
              showClose: false,
              backgroundColor: Color.Transparent,
              blurStyle: BlurStyle.Regular,
              onDisappear: () => { this.isShowArtistSheet = false }
            })
          }
          .layoutWeight(1)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT })
          .width(`100%`)
        }
        .layoutWeight(1)

        /**
         * ShowSheet
         */
        Button() {
          Image($r('app.media.ic_public_more_list'))
            .draggable(false)
            .fillColor($r('app.color.reverse'))
            .width(20)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => { this.isShowSheet = true })
        .bindSheet(this.isShowSheet, this.InfoSheet(), {
          preferType: SheetType.CENTER,
          height: SheetSize.FIT_CONTENT,
          dragBar: false,
          showClose: false,
          backgroundColor: Color.Transparent,
          blurStyle: BlurStyle.Regular,
          onDisappear: () => { this.isShowSheet = false }
        })
      }
      .height(60)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: this.sid === -1 ? 10 : 5 , right: 20 })
    // Card 点击
    .onClick(() => { this.handleClick() })
    .gesture(
      LongPressGesture({
        duration: 500
      }).onAction(() => {
        VibratorUtils.startCount('sharp', 1, 100)
        this.isShowSheet = true
      })
    )
  }

  @Builder InfoSheet() {
    SongInfoSheet({
      song: this.song,
      artists: this.artists,
      playlist: this.playlist,
      picUrl: this.picUrl,
      index: this.index,
      isShow: this.isShowSheet,
      isShowArtistsSheet: this.isShowArtistSheet,
      isShowAddSheet: this.isShowAddSheet,
      allowToArtist: this.allowToArtist,
      playmode: this.playmode
    })
  }

  @Builder ArtistsSheet() {
    ArtistsSheet({
      isShow: this.isShowArtistSheet,
      isShowCover: this.isShowArtistSheet,
      artists: this.song.artists
    })
  }

  @Builder AddToPlaylistSheet() {
    PlayListAddSheet({
      songId: this.song.id,
      isShow: this.isShowAddSheet
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


