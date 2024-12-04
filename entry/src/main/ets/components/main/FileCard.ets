/**
 * 文件卡片
 */
import { playMusicWithFile } from "../../common/functions/playerControl"
import FileUtils from "../../common/utils/FileUtils"

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
        .onClick(() => {
          playMusicWithFile(this.fileName)
        })
      MenuItem({ startIcon: $r('app.media.ic_public_app_filled'), content:'预览'})
        .onClick(() => {
          FileUtils.previewFile(this.fileName)
        })
    }
  }
}