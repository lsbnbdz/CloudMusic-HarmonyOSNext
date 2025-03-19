import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { MsgConstants } from "../../common/constants/MsgConstants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration } from "../../common/functions/common/convert"
import { likeThisSong } from "../../common/functions/play/songLike"
import { DownloadDialog } from "../dialog/DownloadDialog"
import { SetPlayQuality } from "../settings/SetPlayQuality"

@Component
export struct PlayerActionSheet {
  @Link isShow: boolean
  @Link isShowTimer: boolean
  @Link isShowAddSheet: boolean
  @StorageProp(StorageConstants.PLAY_SONG) song: Song = SongClass
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = ''
  @StorageProp(StorageConstants.PIC_URL) picUrl: string = ''
  @StorageProp(StorageConstants.PLAY_MODE) playmode: number = 1
  @StorageProp(StorageConstants.ISLIKED) isLiked: boolean = false
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
  })

  build() {
    Column() {
      Text(this.song.name)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight(FontWeight.Bold)
        .fontSize(Constants.FONT_SIZE_TITLE)
        .width('70%')
        .textAlign(TextAlign.Start)
        .alignSelf(ItemAlign.Start)

      SetPlayQuality().padding(10)
      Divider()
      Scroll() {
        Column({ space: 10 }) {
          if (this.song.id != 0) {
            this.Item(this.isLiked ? $r('app.media.ic_public_favor') : $r('app.media.ic_public_favor_filled'),
              this.isLiked ? '取消喜欢该歌曲' : '喜欢该歌曲', () => {
                this.isShow = false
                likeThisSong()
              })
            this.Item($r('app.media.ic_playlist_add_icon'), '添加到歌单', () => {
              this.isShow = false
              setTimeout(() => {
                this.isShowAddSheet = true
              }, 300)
            }, 24)
            this.Item($r('app.media.ic_arrow_down_o_icon'), '缓存到本地', () => {
              this.isShow = false
              this.dialogController.open()
            }, 21)
          }
          this.Item($r('app.media.ic_timer_icon'), '定时关闭', () => {
            this.isShow = false
            setTimeout(() => {
              this.isShowTimer = true
            }, 300)
          }, 24)
          this.Item($r('app.media.ic_music_fill'), `复制歌曲名: ${this.song.name}`, () => {
            this.isShow = false
            setTimeout(() => {
              PasteboardUtil.setDataText(this.song.name)
              ToastUtil.showToast('已复制歌曲名至剪贴板')
            }, 300)
          })
          this.Item($r('app.media.ic_user_portrait'), `复制歌手名: ${this.artists}`, () => {
            this.isShow = false
            setTimeout(() => {
              PasteboardUtil.setDataText(this.artists)
              ToastUtil.showToast('已复制歌手名至剪贴板')
            }, 300)
          })
          this.Item($r('app.media.ic_public_share_filled'), `分享`, () => {
            this.isShow = false
            setTimeout(() => {
              ToastUtil.showToast(MsgConstants.DEVELOPING)
            }, 300)
          })
          Column().height(px2vp(this.bottomRectHeight)).width('100%')
        }
        .height('auto')
      }
      .scrollable(ScrollDirection.Vertical)
      .padding({ top: 10 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .height('100%')
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .height('100%')
    .padding({
      left:  Constants.PADDING_EDGE_TEXT,
      right: Constants.PADDING_EDGE_TEXT,
      top: Constants.PADDING_EDGE_TEXT
    })
  }

  @Builder Item(icon: ResourceStr, name: string, action: () => void, size: number = 20) {
    Button() {
      Row({ space: 10 }) {
        Column() {
          Image(icon)
            .fillColor($r('app.color.reverse'))
            .height(size)
            .width(size)
        }
        .width(25)
        .justifyContent(FlexAlign.Center)
        Text(name)
          .fontColor($r('app.color.reverse'))
          .fontSize(Constants.FONT_SIZE_COMMON + 2)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .backgroundColor(Color.Transparent)
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .onClick(action)
  }
}
