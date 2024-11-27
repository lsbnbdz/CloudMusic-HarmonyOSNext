import { getSongPicUrl } from "../../api/getSongDetails"
import { Artist, Song, SongClass } from "../../common/entities/SongsResult"
import { SongSheet } from "../sheets/SongSheet"

@Preview
@Component
export struct SongCard {
  @State isShowSheet:boolean = false

  @State picUrl:string = ''
  song:Song = SongClass
  sid:number = -1
  artists:string = ''


  async aboutToAppear(): Promise<void> {
    const artistsStr = await getArtists(this.song.artists)
    this.artists = artistsStr

    const picUrl = await getSongPicUrl(this.song)
    this.picUrl = picUrl
    console.log('SongPicUrl: ' + this.picUrl)
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
      .width('100%')
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .bindSheet(this.isShowSheet, this.Sheet(), {
      height: '80%',
      dragBar: true,
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
    console.log('artist += ' + artist.name)
    artistStr = artistStr + artist.name + ', '
  }
  return artistStr.slice(0,-2)
}



