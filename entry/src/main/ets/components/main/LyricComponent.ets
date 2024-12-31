import { EmitterUtil, ToastUtil } from "@pura/harmony-utils"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { seekMusic } from "../../common/functions/playerControl"
import { Lyric } from "../sheets/PlayingCover"

@Component
export struct LyricComponent {
  @State hasLoaded: boolean = false
  @State firstLoad: boolean = true
  @State isAutoScrolling: boolean = false
  @State isUserScrolling: boolean = false
  @State updateLyricInterval: number = 0
  @StorageProp('player-mode') playmode:number = 1
  @StorageProp('player-song') song:Song = SongClass
  @StorageProp('player-artists') artists:string = ''
  @StorageProp('player-ispaused') isPaused:boolean = false
  @StorageProp('player-picurl') picUrl:string = ''
  @StorageProp('player-time') time:number = 0
  @StorageProp('player-lyric') lyricArr: string[] = []
  @State currentLyricIndex: number = 0;
  @State lyricObjects: Lyric[] = []

  private scroller: Scroller = new Scroller()

  async aboutToAppear(): Promise<void> {
    EmitterUtil.onSubscribe('1', () => {
      this.time = 0
      this.parseLyricArray()
    })
    if (!this.hasLoaded) {
      this.parseLyricArray()
      await this.updateCurrentLyric()
      this.updateLyricInterval = setInterval(() => {
        this.updateCurrentLyric()
      }, 500)
      this.hasLoaded = true
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.updateLyricInterval)
  }

  build() {
    Column() {
      if(this.playmode == 1) {
        List({ scroller: this.scroller, space: 30 }) {
          ListItem().height('50%')
          ForEach(this.lyricObjects, (item: Lyric, index) => {
            ListItem() {
              Text(item.content)
                .width('100%')
                .textAlign(TextAlign.Center)
                .fontSize(20)
                .fontColor(index === this.currentLyricIndex ? '#ffd05f5f' : Color.White)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  seekMusic(item.time)
                })
            }
          })
          ListItem().height('50%')
        }
        .scrollBar(BarState.Off)
        .width('90%')
        .height('100%')
        .onScrollStart(() => {
          if(!this.isAutoScrolling) {
            this.isUserScrolling = true
          }
        })
        .onScrollStop(() => {
          if(!this.isAutoScrolling) {
            setTimeout(() => {
              this.isUserScrolling = false
            }, 3000)
          }
        })
      }
      else {
        Text('正在播放本地文件')
      }
    }
    .padding({ left: 20, right: 20 })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center);
  }

  /**
   * 转换歌词 String Array
   */
  private parseLyricArray() {
    if (this.lyricArr.length > 1) {
      this.lyricObjects = this.lyricArr.map(item => {
        const match = item.match(/\[(\d+):(\d+)[.:](\d+)\](.*)/)
        if (match) {
          const minutes = parseInt(match[1], 10) * 60 * 1000
          const seconds = parseInt(match[2], 10) * 1000
          const milliseconds = parseInt(match[3], 10)
          const content = match[4]?.trim() || ""
          return { time: minutes + seconds + milliseconds, content } as Lyric
        }
        return { time: 0, content: "" }
      }).filter(lyric => lyric.content)
    } else { this.lyricObjects = [{ time: 0, content: '暂无歌词' }]}
  }

  /**
   * 更新当前歌词位置
   */
  private async updateCurrentLyric(hasAnimation: boolean = true) {
    for (let i = 0; i < this.lyricObjects.length; i++) {
      if (this.time >= this.lyricObjects[i].time &&
        (i === this.lyricObjects.length - 1 || this.time < this.lyricObjects[i + 1].time)) {
        if(this.firstLoad) {
          this.scroller.scrollToIndex(i, false, ScrollAlign.CENTER)
          this.firstLoad = false
        }
        else if(this.currentLyricIndex != i) {
          this.currentLyricIndex = i
          if(!this.isUserScrolling) {
            this.isAutoScrolling = true
            this.scroller.scrollToIndex(i, hasAnimation, ScrollAlign.CENTER)
          }
        }
        setTimeout(() => {
          this.isAutoScrolling = false
        }, 100)
        break
      }
    }
  }

}