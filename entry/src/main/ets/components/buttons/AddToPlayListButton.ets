import { Song, SongClass } from "../../common/entities/SongsResult"
import { PlayListAddSheet } from "../sheets/PlayListAddSheet"

@Component
export struct AddToPlayListButton {
  @State isShowAddSheet: boolean = false
  @State song: Song = SongClass

  build() {
    Button() {
      Row() {
        Text('添加到歌单')
          .height('100%')
          .fontColor(Color.White)
          .padding({ left: 10, right: 10 })
          .textAlign(TextAlign.Center)
      }
    }
    .type(ButtonType.Normal)
    .height('100%')
    .backgroundColor('#ff176b81')
    .onClick(() => {
      this.isShowAddSheet = !this.isShowAddSheet
    })
    .bindSheet(this.isShowAddSheet, this.Sheet(), {
      preferType: SheetType.CENTER,
      height: '80%',
      dragBar: false,
      showClose: false,
      backgroundColor: $r('app.color.background'),
      onDisappear: () => { this.isShowAddSheet = false }
    })
  }

  @Builder Sheet() {
    PlayListAddSheet({ isShow: this.isShowAddSheet, songId: this.song.id })
  }
}

@Component
export struct AddToPlayListCircleButton {
  @State isShowAddSheet: boolean = false
  @State song: Song = SongClass
  @State imgColor: Color | ResourceStr = $r('app.color.reverse')

  build() {
    Button(){
      Image($r('app.media.ic_files_new_folder'))
        .width(30)
        .fillColor(this.imgColor)
    }
    .backgroundColor(Color.Transparent)
    .onClick(() => { this.isShowAddSheet = !this.isShowAddSheet })
    .bindSheet(this.isShowAddSheet, this.Sheet(), {
      preferType: SheetType.CENTER,
      height: '80%',
      dragBar: false,
      showClose: false,
      backgroundColor: $r('app.color.background'),
      onDisappear: () => { this.isShowAddSheet = false }
    })
  }

  @Builder Sheet() {
    PlayListAddSheet({ isShow: this.isShowAddSheet, songId: this.song.id })
  }
}