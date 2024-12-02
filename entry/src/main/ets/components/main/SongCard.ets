import { getSongPicUrl } from "../../api/getSongDetails"
import { Artist, Song, SongClass } from "../../common/entities/SongsResult"
import { SongSheet } from "../sheets/SongSheet"

@Preview
@Component
export struct SongCard {
  @State hasAnimation:boolean = false
  @State isShowSheet:boolean = false
  @State startWidth:string = '100%'

  @State picUrl:string = ''
  song:Song = SongClass
  sid:number = -1
  artists:string = ''


  async aboutToAppear(): Promise<void> {
    if(this.hasAnimation) { this.startWidth = '30%'}
    const artistsStr = await getArtists(this.song.artists)
    this.artists = artistsStr

    const picUrl = await getSongPicUrl(this.song)
    this.picUrl = picUrl
  }

  build() {
    Button() {
      Row() {
        Text(`${this.sid + 1}`).width(40).fontWeight(FontWeight.Bold)
        Image(this.picUrl + '?param=100y100').width(50).padding({right:10}).borderRadius(5)
        Column() {
          Text(this.song.name).textStyle(16)
          Text(this.artists).textStyle(12)
        }
        .layoutWeight(1)
        .width(`100%`)
      }
      .width(this.startWidth)
      .onAppear( () => { this.startWidth = '100%' })
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
    SongSheet({ song: this.song, isShowSheet: this.isShowSheet, artists:this.artists, picUrl:this.picUrl })
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .alignSelf(ItemAlign.Start)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

async function getArtists(artists:Artist[]): Promise<string> {
  let artistStr:string = ''
  for(let artist of artists) {
    artistStr = artistStr + artist.name + ', '
  }
  return artistStr.slice(0,-2)
}



