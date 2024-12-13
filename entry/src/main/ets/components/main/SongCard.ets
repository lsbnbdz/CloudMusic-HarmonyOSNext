import { getSongPicUrl } from "../../api/songApi"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { getArtists } from "../../common/functions/functions"
import PlayQueueUtils from "../../common/utils/PlayQueueUtils"
import { SongSheet } from "../sheets/SongSheet"
import { promptAction } from "@kit.ArkUI"
import { playList, playListClass } from "../../common/entities/PlayList"

@Preview
@Component
export struct SongCard {
  @State hasAnimation:boolean = false
  @State isShowSheet:boolean = false
  @State startHeight:number = 60
  @State startOpacity:number = 1
  @State picUrl:string = ''
  @State isPlayList:boolean = false
  @State playList:playList = playListClass
  @State index:number = 0

  song:Song = SongClass
  sid:number = -1
  artists:string = ''


  async aboutToAppear(): Promise<void> {
    if(this.hasAnimation) { this.startHeight = 120; this.startOpacity = 0.1}
    const artistsStr = await getArtists(this.song.artists)
    this.artists = artistsStr

    const picUrl = await getSongPicUrl(this.song)
    this.picUrl = picUrl
  }

  build() {
    Button() {
      Row() {
        Row() {
          Text(`${this.sid + 1}`).width(40).fontWeight(FontWeight.Bold)
          Image(this.picUrl + '?param=100y100').width(50).padding({ right: 10 }).borderRadius(5)
          Column() {
            Text(this.song.name).textStyle(16)
            Text(this.artists).textStyle(12)
          }
          .layoutWeight(1)
          .width(`100%`)
        }
        .layoutWeight(1)

        Button() { Image($r('app.media.ic_public_add_norm')).fillColor($r('app.color.reverse')).width(15) }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
          promptAction.showToast({ message: '成功添加至播放列表' })
        })
      }
      .height(this.startHeight)
      .opacity(this.startOpacity)
      .onAppear( () => {
        this.startHeight = 60
        this.startOpacity = 1
      })
      .animation({
        duration: 600,
        curve: Curve.LinearOutSlowIn,
      })
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .bindSheet(this.isShowSheet, this.Sheet(), {
      height: '70%',
      dragBar: true,
      onDisappear: () => { this.isShowSheet = false }
    })
    .onClick(() => { this.isShowSheet = !this.isShowSheet })
  }

  @Builder
  Sheet() {
    SongSheet({ song: this.song, isShowSheet: this.isShowSheet, artists:this.artists, picUrl:this.picUrl,
      isPlayList:this.isPlayList, playList: this.playList, index: this.index})
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .alignSelf(ItemAlign.Start)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}




