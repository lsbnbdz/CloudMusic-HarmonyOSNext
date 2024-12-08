/**
 * 文件卡片
 */
import { fetchMetadata, fetchSongInfo } from "../../common/functions/functions"
import { playMusicWithFile } from "../../common/functions/playerControl"
import FileUtils from "../../common/utils/FileUtils"
import PlayQueueUtils from "../../common/utils/PlayQueueUtils"

@Component
export struct FileCard {
  @State fileName: string = ''
  build() {
    Button() {
      Text(this.fileName)
        .width('100%')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize(15)
        .fontColor($r('app.color.reverse'))
        .padding({ left: 10, right: 10 })
    }
    .type(ButtonType.Normal)
    .backgroundColor($r('app.color.main'))
    .borderRadius(15)
    .width('100%')
    .height(60)
    .bindMenu(this.ClickMenu())
  }

  @Builder
  ClickMenu() {
    Menu() {
      MenuItem({ content: this.fileName }).width('80%')
      MenuItem({ startIcon: $r('app.media.ic_play_fill'), content:'播放'})
        .onClick(async () => {
          const rootUrl = await FileUtils.getFilesDir()
          const fileUrl = rootUrl + `/${this.fileName}`
          const metadata = await fetchMetadata(fileUrl)
          let song = await fetchSongInfo(this.fileName)
          if(metadata) {
            song.duration = (metadata.duration) ? parseInt(metadata.duration) : 0
          }
          playMusicWithFile(this.fileName).then(() => {
            PlayQueueUtils.queueAdd(0, song, song.artists[0].name, this.fileName)
            PlayQueueUtils.setIndex(PlayQueueUtils.currentQueueIndex + 1)
          })
        })
      MenuItem({ startIcon: $r('app.media.ic_public_app_filled'), content:'预览'})
        .onClick(() => {
          FileUtils.previewFile(this.fileName)
        })
    }
  }
}