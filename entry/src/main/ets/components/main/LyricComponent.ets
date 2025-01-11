import { EmitterUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { seekMusic } from "../../common/functions/playerControl"
import LyricUtils from "../../common/utils/LyricUtils"
import { Lyric } from "../sheets/PlayingCover"

@Component
export struct LyricComponent {
  @State hasLoaded: boolean = false
  @State firstLoad: boolean = true
  @State isAutoScrolling: boolean = false
  @State isUserScrolling: boolean = false
  @State updateLyricInterval: number = 0
  @StorageProp('player-mode') playmode: number = 1
  @StorageProp('player-time') time: number = 0
  @StorageProp('player-lyric') lyricArr: string[] = []
  @State currentLyricIndex: number = 0;
  @State lyricObjects: Lyric[] = []

  private scroller: Scroller = new Scroller()

  async aboutToAppear(): Promise<void> {
    EmitterUtil.onSubscribe(Constants.EMITTER_LYRIC_UPDATE, () => {
      this.time = 0
      if (this.playmode == 1) {
        this.lyricObjects = LyricUtils.parseLyricArray(this.lyricArr)
      } else {
        this.lyricObjects = [{ time: 0, content: '正在播放本地文件' }]
      }
    })
    if (!this.hasLoaded) {
      if (this.playmode == 1) {
        this.lyricObjects = LyricUtils.parseLyricArray(this.lyricArr)
        await this.updateCurrentLyric()
        this.updateLyricInterval = setInterval(() => {
          this.updateCurrentLyric()
        }, 500)
      } else {
        this.lyricObjects = [{ time: 0, content: '正在播放本地文件' }]
      }
      this.hasLoaded = true
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.updateLyricInterval)
  }

  build() {
    Stack() {
      List({ scroller: this.scroller, space: 30 }) {
        ListItem().height('50%')
        ForEach(this.lyricObjects, (item: Lyric, index) => {
          ListItem() {
            Text(item.content)
              .width('100%')
              .maxFontScale(24)
              .textAlign(TextAlign.Center)
              .fontSize(20)
              .fontColor(index === this.currentLyricIndex ? '#ffff7777' : Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                seekMusic(item.time)
              })
              .animation({ duration: 500 })
          }
        })
        ListItem().height('50%')
      }
      .padding({ left: 20, right: 20 })
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
    .width('100%')
    .height('100%')
  }

  /**
   * 更新当前歌词位置
   */
  private async updateCurrentLyric(hasAnimation: boolean = true) {
    const newIndex = LyricUtils.updateCurrentLyricIndex(this.time, this.lyricObjects)
    if (this.firstLoad) {
      this.scroller.scrollToIndex(newIndex, false, ScrollAlign.CENTER)
      this.firstLoad = false
    } else if (this.currentLyricIndex !== newIndex) {
      this.currentLyricIndex = newIndex
      if (!this.isUserScrolling) {
        this.isAutoScrolling = true
        this.scroller.scrollToIndex(newIndex, hasAnimation, ScrollAlign.CENTER)
      }
    }
    setTimeout(() => {
      this.isAutoScrolling = false
    }, 100)
  }

}
