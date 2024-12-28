import { EmitterUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration } from "../../common/functions/functions"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../../common/functions/playerControl"
import { AddToPlayListCircleButton } from "../buttons/AddToPlayListButton"
import { LoopModeButton } from "../buttons/LoopModeButton"
import { PlayQueueButton } from "../buttons/PlayQueueButton"
import { DownloadDialog } from "../dialog/DownloadDialog"

const TAG = '[PlayingCover] '
export interface Lyric {
  time: number;
  content: string;
}
@Component
export struct PlayingCover {

  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0

  @StorageProp('player-mode') playmode:number = 1
  @StorageProp('player-song') song:Song = SongClass
  @StorageProp('player-artists') artists:string = ''
  @StorageProp('player-ispaused') isPaused:boolean = false
  @StorageProp('player-picurl') picUrl:string = ''
  @StorageProp('player-time') time:number = 0
  @StorageProp('player-lyric') lyricArr: string[] = []

  @Link isShow: boolean
  @State hasLoaded: boolean = false
  @State qualitySelected:number = 3
  @State sliderThickness: number = 10
  @State isMovingSlider: boolean = false
  @State sliderMovingTime: number = 0
  @State isAutoScrolling: boolean = false
  @State isUserScrolling: boolean = false

  artists1:string = ''
  song1:Song = SongClass
  picUrl1:string = ''

  private scroller: Scroller = new Scroller()

  dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song1,
      picUrl: this.picUrl1,
      artists: this.artists1,
      quality: Constants.QUALITY[this.qualitySelected],
      duration: changeDuration(this.song.duration)
    }),
  })

  @State currentLyricIndex: number = 0;
  @State lyricObjects: Lyric[] = []

  aboutToAppear(): void {
    EmitterUtil.onSubscribe('1', () => {
      this.time = 0
      this.scroller.scrollToIndex(0, false, ScrollAlign.CENTER)
      this.parseLyricArray()
    })
    if (!this.hasLoaded) {
      this.parseLyricArray()
      this.updateCurrentLyric()
      setInterval(() => {
        this.updateCurrentLyric()
      }, 500)
      this.hasLoaded = true
    }
  }

  build() {
   Stack({ alignContent: Alignment.Top }) {
     Column()
     .width('100%')
     .height('100%')
     .opacity(0.5)
     .backgroundColor($r('app.color.background'))

     Column({ space: 10 }) {
       Tabs() {
         TabContent() { this.SongInfo() }
         TabContent() { this.LyricComponent() }.height('100%')
       }
       .barHeight(0)
       .layoutWeight(1)

       Column({ space: 20 }) {
         Column({ space: 5 }) {
           Row() {
             // 当前时间
             Text(`${changeDuration(this.time)}`)
               .fontSize(16)
               .layoutWeight(1)
               .textAlign(TextAlign.Start)

             // 拖动进度条时，显示即将跳转的时间
             if(this.isMovingSlider) {
               Column() {
                 Text(`${changeDuration(this.sliderMovingTime)}`)
                   .fontColor(Color.White)
                   .backgroundColor(Color.Gray)
                   .borderRadius(15)
                   .fontSize(16)
                   .textAlign(TextAlign.Center)
                   .padding({ left: 10, right: 10 })
               }
               .layoutWeight(1)
             }

             // 总时间
             Text(`${changeDuration(this.song.duration)}`)
               .fontSize(16)
               .layoutWeight(1)
               .textAlign(TextAlign.End)
           }
           .width('90%')
           .justifyContent(FlexAlign.SpaceAround)

           // 进度条
           Slider({
             value: this.time,
             max: this.song.duration,
             style: SliderStyle.InSet
           })
             .width('90%')
             .blockColor(Color.White)
             .trackColor(Color.Gray)
             .trackThickness(this.sliderThickness)
             .selectedColor(Color.White)
             .showSteps(false)
             .showTips(false)
             .animation({
               duration: 600,
               curve: Curve.LinearOutSlowIn,
             })
             .onChange((value: number, mode: SliderChangeMode) => {
               if(mode == SliderChangeMode.Begin) {
                 this.isMovingSlider = true
                 this.sliderThickness = 20
               }
               else if(mode == SliderChangeMode.Moving) {
                 this.sliderMovingTime = value
               } else if(mode == SliderChangeMode.End) {
                 this.time = value
                 this.isMovingSlider = false
                 this.sliderThickness = 10
                 seekMusic(value)
               }
             })
         }

         Row({ space: 20 }) {
           if(this.playmode == 1) {
             Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
               .selected(3)
               .value('无损')
               .height(40)
               .onSelect((index: number) => {
                 this.qualitySelected = index
               })

             Button({ type: ButtonType.Circle }) {
               Image($r('app.media.ic_public_download_filled'))
                 .fillColor($r('app.color.reverse'))
                 .width(25)
             }
             .backgroundColor(Color.Transparent)
             .onClick(() => {
               this.song1 = this.song
               this.artists1 = this.artists
               this.picUrl1 = this.picUrl
               this.dialogController.open()
             })

             AddToPlayListCircleButton({ song: this.song })

           }

           LoopModeButton()

           PlayQueueButton()

         }

         Row({ space: 30 }) {
           // 上一首
           Button(){ Image($r('app.media.ic_public_play_last')).buttonImgStyle() }.onClick(() => { playPre() }).backgroundColor(Color.Transparent)
           // 暂停、继续
           if (!this.isPaused) {
             Button(){ Image($r('app.media.ic_public_pause')).buttonImgStyle() }.onClick(() => { pauseMusic() }).backgroundColor(Color.Transparent)
           } else {
             Button(){ Image($r('app.media.ic_play_fill')).buttonImgStyle() }.onClick(() => { resumeMusic() }).backgroundColor(Color.Transparent)
           }
           // 下一首
           Button(){ Image($r('app.media.ic_public_play_next')).buttonImgStyle() }.onClick(async () => { await playNext() }).backgroundColor(Color.Transparent)
         }
         .padding({ top:30, bottom:50 })
         .justifyContent(FlexAlign.Center)
       }
     }
     .height('100%')

     // 收起
     Row() {
       // Text(`isAuto: ${this.isAutoScrolling}; isUser: ${this.isUserScrolling}`)
       Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_arrow_down_0')).width(40).padding(5).fillColor(Color.White) }
       .backgroundColor(Color.Transparent)
       .onClick(() => { this.isShow = false })
     }
     .width('100%')
     .justifyContent(FlexAlign.End)
     .backdropBlur(50)
     .padding({ top:px2vp(this.topRectHeight), left: 10, right: 10 })

   }
   .height('100%')
   .backgroundImage(this.picUrl)
   .backgroundImageSize(ImageSize.Cover)
   .backdropBlur(100)
  }

  /**
   * Information
   */
  @Builder
  SongInfo() {
    Column({ space: 20 }) {
      // 歌曲封面图片
      if (this.playmode == 0) {
        Stack() {
          Image($r('app.media.ic_public_music')).width('80%').fillColor(Color.Gray).borderRadius(5).aspectRatio(1)
        }
        .padding({ bottom: 30 })
      } else {
        Stack() {
          LoadingProgress().width(60)
          Image(this.picUrl + '?param=512y512').width('80%').height(250).borderRadius(5).aspectRatio(1)
        }
        .padding({ bottom: 30 })
      }

      // 歌曲名称&艺术家
      Text(this.song.name)
        .textStyle(24)
        .fontWeight(FontWeight.Bold)
      Text(this.artists)
        .textStyle(16)
    }
    .padding({ left: 15, right: 15, top:px2vp(this.topRectHeight) + 40 })
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Lyric
   */
  @Builder
  LyricComponent() {
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
  }

  /**
   * 更新当前歌词位置
   */
  private updateCurrentLyric() {
    for (let i = 0; i < this.lyricObjects.length; i++) {
      if (this.time >= this.lyricObjects[i].time &&
        (i === this.lyricObjects.length - 1 || this.time < this.lyricObjects[i + 1].time)) {
        if(this.currentLyricIndex != i) {
          this.currentLyricIndex = i
          if(!this.isUserScrolling) {
            this.isAutoScrolling = true
            this.scroller.scrollToIndex(i, true, ScrollAlign.CENTER)
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

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .padding({ left:20, right:20 })
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}

@Extend(Image) function buttonImgStyle() {
  .width(50)
  .fillColor($r('app.color.reverse'))
}