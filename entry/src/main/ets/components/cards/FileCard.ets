import { DialogUtil, EmitterUtil, LogUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { LocalSong, LocalSongClass } from "../../common/entities/local/LocalData"
import { Song } from "../../common/entities/song/SongsResult"
import { fetchMetadata } from "../../common/functions/common/convert"
import { playQueue } from "../../common/functions/play/playControl"
import FileUtils from "../../common/utils/file/FileUtils"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { promptAction } from "@kit.ArkUI"
import { MatchSongSheet } from "../sheets/MatchSongSheet"
import { getLocalSongArtists, getLocalSongArtistsString } from "../../common/functions/common/get"

/**
 * 文件卡片组件
 */
@Component
export struct FileCard {
  @State localSong: LocalSong = LocalSongClass
  @State showMatchSheet: boolean = false
  @State filesDir: string = ''
  @State artistsString: string = ''

  async aboutToAppear() {
    this.filesDir = FileUtils.getFilesDir()
    this.artistsString = await getLocalSongArtistsString(this.localSong.artists)
  }

  build() {
    Button() {
      Row({ space: 5 }) {
        Image(this.localSong.songId == 0 ? $r('app.media.ic_files_audio') : `file://${this.filesDir}/pic/${this.localSong.songId}.jpg`)
          .width(Constants.SIZE_IMG_CARD)
          .borderRadius(Constants.RADIUS_IMG)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT })
        Column({ space: 5 }) {
          Text(this.localSong.name)
            .textStyle(16)
            .fontWeight(FontWeight.Medium)
          Text(this.artistsString)
            .textStyle(12)
            .fontColor(Color.Gray)
        }
        .layoutWeight(1)
      }
    }
    .type(ButtonType.Normal)
    .backgroundColor($r('app.color.main'))
    .borderRadius(10)
    .width('100%')
    .height(60)
    .bindMenu(this.ClickMenu())
    .bindSheet(this.showMatchSheet, this.MatchSheet, {
      preferType: SheetType.CENTER,
      height: '70%',
      dragBar: false,
      showClose: false,
      backgroundColor: $r('app.color.background'),
      onDisappear: () => { this.showMatchSheet = false }
    })
  }

  @Builder
  ClickMenu() {
    Menu() {
      MenuItem({ content: this.localSong.songFile }).width('80%')
        .onClick(() => {
          PasteboardUtil.setDataText(`${this.localSong.name}`)
          ToastUtil.showToast('已复制歌名至剪切板')
        })
      MenuItem(this.MenuItem($r('app.media.ic_play_fill'), '播放', $r('app.color.reverse')))
        .onClick(async () => {
          try {
            const rootUrl = FileUtils.getFilesDir()
            const fileUrl = rootUrl + `/${this.localSong.songFile}`
            const metadata = await fetchMetadata(fileUrl)
            let artists = await getLocalSongArtists(this.localSong.artists)
            let song: Song = {
              id: this.localSong.songId,
              name: this.localSong.name,
              artists: artists,
              duration: metadata ? ((metadata.duration) ? parseInt(metadata.duration) : 0) : 0,
              alias: [],
              fee: 0
            }
            PlayQueueUtils.queueAdd(0, song, this.artistsString, this.localSong.songFile)
            playQueue(PlayQueueUtils.currentQueueIndex + 1)
          } catch (e) {
            LogUtil.error('Play local song error: ' + e.message)
            ToastUtil.showToast('播放失败')
          }
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_search_filled'), '匹配歌曲'))
        .onClick(() => {
          this.showMatchSheet = true
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_folder_filled'), '保存歌曲至本地'))
        .onClick(() => {
          FileUtils.saveFile([this.localSong])
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_app_filled'), '文件预览'))
        .onClick(() => {
          FileUtils.previewFile(this.localSong.songFile)
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_delete_filled'), '删除歌曲', $r('app.color.app_red')))
        .onClick(async () => {
          DialogUtil.showPrimaryDialog({
            title: '删除文件',
            message: `确定删除 "${this.localSong.songFile}" ?`,
            primaryButton: "取消",
            secondaryButton: {
              value: '删除',
              fontColor: Color.Red,
              action: async () => {
                try {
                  await FileUtils.deleteFile([this.localSong])
                  EmitterUtil.post('refreshLocalSongs',() => {})
                } catch (e) {
                  ToastUtil.showToast('删除时出错')
                  LogUtil.error('Delete local song error: ' + e.message)
                }
              }
            }
          })
        })
    }
    .constraintSize({
      minWidth: 100,
      maxWidth: 500
    })
  }

  @Builder
  MenuItem(image: ResourceStr, title: string, contentColor: string | Color | ResourceStr = $r('app.color.reverse')) {
    Row({ space: 10 }) {
      Column() {
        Image(image)
          .fillColor(contentColor)
          .width(20)
      }
      .width(22)
      Text(title)
        .fontColor(contentColor)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 15, right: 15, top: 5, bottom: 5 })
    .height(40)
  }

  @Builder
  MatchSheet() {
    MatchSongSheet({ showMatchSheet: this.showMatchSheet, localSong: this.localSong })
  }
}

@Extend(Text) function textStyle(size: number) {
  .width('100%')
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .padding({ left: 10, right: 10 })
}