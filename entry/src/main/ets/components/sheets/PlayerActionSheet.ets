import Constants from "../../common/constants/Constants"
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
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
  })

  build() {
    Column({ space: 10 }) {
      SetPlayQuality()
      Divider()
      if(this.playmode == 1) {
        this.Item(this.isLiked ? $r('app.media.ic_public_favor') : $r('app.media.ic_public_favor_filled'),
          this.isLiked ? '取消喜欢该歌曲' : '喜欢该歌曲', () => {
            this.isShow = false
            likeThisSong()
          }
        )
        this.Item($r('app.media.ic_public_view_list_filled'), '添加到歌单', () => {
          this.isShow = false
          setTimeout(() => {
            this.isShowAddSheet = true
          }, 300)

        })
        this.Item($r('app.media.ic_public_folder'), '缓存到本地', () => {
          this.isShow = false
          this.dialogController.open()
        })
      }
      this.Item($r('app.media.ic_clock'), '定时关闭', () => {
        this.isShow = false
        setTimeout(() => {
          this.isShowTimer = true
        }, 300)
      })
    }
    .width('100%')
    .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT, bottom: 100, top: Constants.PADDING_EDGE_DEFAULT })
  }

  @Builder Item(icon: ResourceStr, name: string, action: () => void) {
    Button() {
      Row({ space: 10 }) {
        Image(icon)
          .fillColor($r('app.color.reverse'))
          .width(Constants.FONT_SIZE_TITLE)
        Text(name)
          .fontColor($r('app.color.reverse'))
          .fontSize(Constants.FONT_SIZE_COMMON + 2)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
      }
    }
    .width('100%')
    .backgroundColor(Color.Transparent)
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .onClick(action)
  }
}
