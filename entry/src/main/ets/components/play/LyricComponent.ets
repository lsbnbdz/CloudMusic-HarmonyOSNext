import { EmitterUtil } from "@pura/harmony-utils"
import { Lyric } from "../../common/entities/Lyric"
import { getLyricObjects } from "../../common/functions/play/lyric"
import { seekMusic } from "../../common/functions/play/playControl"
import { LengthUnit } from "@kit.ArkUI"
import { EmitterConstants } from "../../common/constants/EmitterConstants"

@Component
export struct LyricComponent {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('player-currentLyricIndex') @Watch('ToCurrentLyric') currentLyricIndex: number = 0
  @State firstLoad: boolean = true
  @State userScrolling: number = 0
  @State userScrollingInterval: number = 0
  @State lyricObjects: Lyric[] = []

  private scroller: Scroller = new Scroller()

  async aboutToAppear(): Promise<void> {
    this.lyricObjects = getLyricObjects()
    setTimeout(() => {
      this.scroller.scrollToIndex(this.currentLyricIndex, false, ScrollAlign.CENTER)
    }, 10)
    this.userScrollingInterval = setInterval(() => {
      if(this.userScrolling > 0) this.userScrolling -= 1
    }, 1000)
    EmitterUtil.onSubscribe(EmitterConstants.EMITTER_LYRIC_UPDATE, () => {
      this.lyricObjects = getLyricObjects()
      this.currentLyricIndex = 0
    })
  }

  aboutToDisappear(): void {
    clearInterval(this.userScrollingInterval)
  }

  ToCurrentLyric() {
    if(!this.userScrolling) {
      this.scroller.scrollToIndex(this.currentLyricIndex, true, ScrollAlign.CENTER)
    }
  }

  build() {
    Stack() {
      List({ scroller: this.scroller, space: 30 }) {
        ForEach(this.lyricObjects, (item: Lyric, index) => {
          ListItem() {
            Text(item.content)
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(20)
              .fontColor(Color.White)
              .opacity(index == this.currentLyricIndex ? 1 : 0.35)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.userScrolling = 0
                seekMusic(item.time)
              })
              .animation({
                duration: 300,
                curve: Curve.LinearOutSlowIn
              })
          }
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
          .padding({ left: 20, right: 20 })
        })
      }
      .fadingEdge(true, {
        fadingEdgeLength: {
        unit: LengthUnit.PERCENT,
        value: 40
        }
      })
      .padding({ top: 30 })
      .edgeEffect(EdgeEffect.None)
      .scrollSnapAlign(ScrollSnapAlign.CENTER)
      .scrollBar(BarState.Off)
      .width('90%')
      .height('100%')
      .onTouch(() => {
        this.userScrolling = 2
      })
    }
    .width('100%')
    .height('100%')
  }
}
