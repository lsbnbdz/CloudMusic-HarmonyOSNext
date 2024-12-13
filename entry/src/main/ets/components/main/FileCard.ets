/**
 * 文件卡片
 */
import { Song, SongClass } from "../../common/entities/SongsResult"
import { fetchMetadata, fetchSongInfo } from "../../common/functions/functions"
import { playMusicWithFile } from "../../common/functions/playerControl"
import FileUtils from "../../common/utils/FileUtils"
import PlayQueueUtils from "../../common/utils/PlayQueueUtils"

@Component
export struct FileCard {
  @State fileName: string = ''
  @State song:Song = SongClass

  async aboutToAppear(): Promise<void> {
    this.song = await fetchSongInfo(this.fileName)
  }

  build() {
    Button() {
      Column({ space: 5 }) {
        Text(this.song.name)
          .textStyle(16)
        Text(this.song.artists[0].name)
          .textStyle(12)
      }
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
      MenuItem(this.MenuItem($r('app.media.ic_play_fill'), '播放'))
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

      MenuItem(this.MenuItem($r('app.media.ic_public_app_filled'), '预览'))
        .onClick(() => {
          FileUtils.previewFile(this.fileName)
        })
    }
  }

  @Builder
  MenuItem(image:ResourceStr, title:string) {
    Row({ space: 10 }) {
      Column() {
        Image(image)
          .fillColor($r('app.color.reverse'))
          .width(20)
      }
      .width(22)
      Text(title)
        .fontColor($r('app.color.reverse'))
        .fontSize(16)
    }
    .padding({ left: 15, right: 15, top: 5, bottom: 5 })
    .height(40)
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