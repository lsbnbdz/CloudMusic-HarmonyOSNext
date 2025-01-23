import { DialogUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { DialogAction } from "@pura/harmony-utils/src/main/ets/entity/constraint"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { fetchMetadata, fetchSongInfo } from "../../common/functions/commonFunction"
import { playMusicWithFile } from "../../common/functions/playControl"
import FileUtils from "../../common/utils/file/FileUtils"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"

/**
 * 文件卡片组件
 */
@Component
export struct FileCard {
  @State fileName: string = ''
  @State song: Song = SongClass
  @Prop columnEnd: number = 0
  @Link list: string[]

  async aboutToAppear(): Promise<void> {
    this.song = await fetchSongInfo(this.fileName)
  }

  build() {
    Button() {
      Column({ space: 5 }) {
        Text() {
          if(this.columnEnd == 0) {
            Span(this.song.artists[0].name).fontColor(Color.Gray)
            Span(' - ')
          }
          Span(this.song.name)
        }
        .textStyle(16)
      }
    }
    .type(ButtonType.Normal)
    .backgroundColor($r('app.color.main'))
    .borderRadius(10)
    .width('100%')
    .height(60)
    .bindMenu(this.ClickMenu())
  }

  @Builder
  ClickMenu() {
    Menu() {
      MenuItem({ content: this.fileName }).width('80%')
        .onClick(() => {
          PasteboardUtil.setDataText(`${this.song.name}`)
          ToastUtil.showToast('已复制歌名至剪切板')
        })
      MenuItem(this.MenuItem($r('app.media.ic_play_fill'), '播放', $r('app.color.reverse')))
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

      MenuItem(this.MenuItem($r('app.media.ic_public_download_filled'), '保存至本地'))
        .onClick(() => {
          FileUtils.saveFile(this.fileName)
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_app_filled'), '文件预览'))
        .onClick(() => {
          FileUtils.previewFile(this.fileName)
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_delete_filled'), '删除歌曲', $r('app.color.app_red')))
        .onClick(async () => {
          DialogUtil.showPrimaryDialog({
            title: '删除文件',
            message:`确定删除 "${this.fileName}" ?`,
            primaryButton: "取消",
            secondaryButton: "删除",
            onAction: async (action) => {
              if(action == DialogAction.TWO) {
                await FileUtils.deleteFile(this.fileName).then(async () => {
                  this.list = await FileUtils.getFileName()
                })
              }
            }
          })
        })
    }
  }

  @Builder
  MenuItem(image: ResourceStr, title: string, contentColor: string | Color | ResourceStr = $r('app.color.reverse'), isBold: boolean = false) {
    Row({ space: 10 }) {
      Column() {
        Image(image)
          .fillColor(contentColor)
          .width(20)
      }
      .width(22)
      Text(title)
        .fontColor(contentColor)
        .fontSize(16)
        .fontWeight(isBold ? FontWeight.Bold : FontWeight.Normal)
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