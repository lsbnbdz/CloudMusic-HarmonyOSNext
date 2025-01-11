import { getSongPicUrl } from "../../api/songApi"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { getArtists } from "../../common/functions/functions"
import PlayQueueUtils from "../../common/utils/PlayQueueUtils"
import { SongSheet } from "../sheets/SongSheet"
import { promptAction } from "@kit.ArkUI"
import { PlayList, playListClass } from "../../common/entities/PlayList"

@Preview
@Component
export struct SongCard {
  @State hasAnimation:boolean = false
  @State isShowSheet:boolean = false
  @State showPlayButton:boolean = true
  @State showAddQueueButton:boolean = true
  @State startHeight:number = 60
  @State startOpacity:number = 1
  @State picUrl:string = ''
  @State isPlayList:boolean = false
  @State playList:PlayList = playListClass
  @State index:number = 0
  @State reason:string = ''

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
          Column({ space: 3 }) {
            Text(this.song.name).textStyle(16)
            Row({ space: 5 }) {
              if(this.reason) {
                Text(this.reason).reasonText()
              }
              Text(this.artists).textStyle(12)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width(`100%`)
        }
        .layoutWeight(1)

        /**
         * 添加到播放列表
         */
        if(this.showAddQueueButton) {
          Button() {
            Image($r('app.media.ic_public_add_norm'))
              .fillColor($r('app.color.reverse'))
              .width(15)
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
            promptAction.showToast({ message: '成功添加至播放列表' })
          })
        }
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
      preferType: SheetType.CENTER,
      height: '70%',
      dragBar: true,
      onDisappear: () => { this.isShowSheet = false }
    })
    .onClick(() => { this.isShowSheet = !this.isShowSheet })
  }

  @Builder
  Sheet() {
    SongSheet({ song: this.song, isShowSheet: this.isShowSheet, artists:this.artists, picUrl:this.picUrl,
      isPlayList:this.isPlayList, playList: this.playList, index: this.index, showPlayButton: this.showPlayButton})
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




