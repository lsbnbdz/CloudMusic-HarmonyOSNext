import { EmitterUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { getLyricObjects } from "../../common/functions/lyric"
import { seekMusic } from "../../common/functions/playerControl"
import LyricUtils from "../../common/utils/LyricUtils"
import { Lyric } from "../sheets/PlayingCover"

@Component
export struct LyricComponent {
  @State firstLoad: boolean = true
  @State isAutoScrolling: boolean = false
  @State isUserScrolling: boolean = false
  @State updateLyricInterval: number = 0
  @State currentLyricIndex: number = 0
  @State lyricObjects: Lyric[] = []

  private scroller: Scroller = new Scroller()



  async aboutToAppear(): Promise<void> {
    this.lyricObjects = getLyricObjects()
    this.currentLyricIndex = LyricUtils.currentLyricIndex
    setTimeout(() => {
      this.scroller.scrollToIndex(this.currentLyricIndex, false, ScrollAlign.CENTER)
    }, 10)
    this.updateLyricInterval = setInterval(() => {
      this.updateCurrentLyric(LyricUtils.currentLyricIndex)
    }, 500)

    EmitterUtil.onSubscribe(Constants.EMITTER_LYRIC_UPDATE, () => {
      this.lyricObjects = getLyricObjects()
    })
  }

  aboutToDisappear(): void {
    clearInterval(this.updateLyricInterval)
  }

  build() {
    Stack() {
      List({ scroller: this.scroller, space: 30 }) {
        ListItem()
        ForEach(this.lyricObjects, (item: Lyric, index) => {
          ListItem() {
            Text(item.content)
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(20)
              .fontColor(index == this.currentLyricIndex ? Color.White : '#8dffffff')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.isAutoScrolling = true
                seekMusic(item.time)
                setTimeout(() => {
                  this.isAutoScrolling = false
                }, 100)
              })
              .animation({
                duration: 500,
                curve: Curve.Friction
              })
          }
          .padding({ left: 20, right: 20 })
        })
      }
      .edgeEffect(EdgeEffect.None)
      .scrollSnapAlign(ScrollSnapAlign.CENTER)
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
  private async updateCurrentLyric(newIndex: number) {
    if (this.currentLyricIndex != newIndex) {
      this.currentLyricIndex = newIndex
      if (!this.isUserScrolling) {
        this.isAutoScrolling = true
        this.scroller.scrollToIndex(newIndex, true, ScrollAlign.CENTER)
      }
    }
    setTimeout(() => {
      this.isAutoScrolling = false
    }, 100)
  }

}
