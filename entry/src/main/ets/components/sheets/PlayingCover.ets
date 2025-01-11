import { EmitterUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration } from "../../common/functions/functions"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../../common/functions/playerControl"
import { AddToPlayListCircleButton } from "../buttons/AddToPlayListButton"
import { LoopModeButton } from "../buttons/LoopModeButton"
import { PlayQueueButton } from "../buttons/PlayQueueButton"
import { DownloadDialog } from "../dialog/DownloadDialog"
import { LyricComponent } from "../main/LyricComponent"
import { AVCastPicker } from "@kit.AVSessionKit"

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
  @State tabPageIndex: number = 0
  @State totalOpacity: number = 0

  artists1:string = ''
  song1:Song = SongClass
  picUrl1:string = ''

  private tabsController: TabsController = new TabsController()

  private dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song1,
      picUrl: this.picUrl1,
      artists: this.artists1,
      quality: Constants.QUALITY[this.qualitySelected],
      duration: changeDuration(this.song.duration)
    }),
  })

  aboutToAppear(): void {
    setTimeout(() => {
      this.totalOpacity = 1
    }, 500)
  }

  build() {
   Stack() {
     // 遮罩
     Column()
     .width('100%')
     .height('100%')
     .opacity(0.5)
     .backgroundColor(Color.Black)

     Column() {
       Tabs({ controller: this.tabsController }) {
         TabContent() {
           this.SongInfo()
         }
         TabContent() {
           LyricComponent()
         }.height('100%')
       }
       .onChange((index) => { this.tabPageIndex = index })
       .layoutWeight(1)
       .barHeight(0)

       Column({ space: 20 }) {
         Column({ space: 5 }) {
           Row() {
             // 当前时间
             Text(`${changeDuration(this.time)}`)
               .fontSize(16)
               .layoutWeight(1)
               .textAlign(TextAlign.Start)
               .fontColor(Color.White)

             // 拖动进度条时，显示即将跳转的时间
             if (this.isMovingSlider) {
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
               .fontColor(Color.White)
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
               if (mode == SliderChangeMode.Begin) {
                 this.isMovingSlider = true
                 this.sliderThickness = 20
               } else if (mode == SliderChangeMode.Moving) {
                 this.sliderMovingTime = value
               } else if (mode == SliderChangeMode.End) {
                 this.time = value
                 this.isMovingSlider = false
                 this.sliderThickness = 10
                 seekMusic(value)
               }
             })
         }

         Row({ space: 20 }) {
           if (this.playmode == 1) {
             Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
               .fontColor(Color.White)
               .selected(3)
               .value('无损')
               .height(40)
               .onSelect((index: number) => {
                 this.qualitySelected = index
               })

             Button({ type: ButtonType.Circle }) {
               Image($r('app.media.ic_public_download_filled'))
                 .fillColor(Color.White)
                 .width(25)
             }
             .backgroundColor(Color.Transparent)
             .onClick(() => {
               this.song1 = this.song
               this.artists1 = this.artists
               this.picUrl1 = this.picUrl
               this.dialogController.open()
             })

             AddToPlayListCircleButton({ song: this.song, imgColor: Color.White })

           }

           LoopModeButton({ imgColor: Color.White })

           PlayQueueButton({ imgColor: Color.White })

         }

         Row({ space: 30 }) {
           // 上一首
           Button() {
             Image($r('app.media.ic_public_play_last')).buttonImgStyle()
           }.onClick(() => {
             playPre()
           }).backgroundColor(Color.Transparent)

           // 暂停、继续
           if (!this.isPaused) {
             Button() {
               Image($r('app.media.ic_public_pause')).buttonImgStyle()
             }.onClick(() => {
               pauseMusic()
             }).backgroundColor(Color.Transparent)
           } else {
             Button() {
               Image($r('app.media.ic_play_fill')).buttonImgStyle()
             }.onClick(() => {
               resumeMusic()
             }).backgroundColor(Color.Transparent)
           }
           // 下一首
           Button() {
             Image($r('app.media.ic_public_play_next')).buttonImgStyle()
           }.onClick(async () => {
             await playNext()
           }).backgroundColor(Color.Transparent)
         }
         .padding({ top: 30, bottom: 50 })
         .justifyContent(FlexAlign.Center)
       }
       .width('100%')
     }
     .height('100%')


     // Head
     Row() {
       Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_arrow_down_0')).fillColor(Color.White).width(35).height(35) }
       .backgroundColor(Color.Transparent)
       .opacity(this.totalOpacity)
       .animation({
         duration: 200
       })
       .onClick(() => { this.isShow = false })

       this.TabBar()

       Stack() {
         AVCastPicker({ normalColor: Color.White, activeColor: '#ff359bdb' })
           .opacity(this.totalOpacity)
           .animation({
             duration: 200
           })
           .width(30)
           .height(30)
           .backgroundColor(Color.Transparent)
       }
       .width(30)
       .height(30)
     }
     .backdropBlur(20)
     .position({ top: 0 })
     .width('100%')
     .justifyContent(FlexAlign.SpaceBetween)
     .linearGradientBlur(100, {
       fractionStops: [[0, 0],[1, 1]],
       direction: GradientDirection.Top
     })
     .padding({ top:px2vp(this.topRectHeight), left: 10, right: 10, bottom: 5 })

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
            .sharedTransition('CoverImg',{
              duration: 500,
              curve: Curve.Linear
            })
        }
        .padding({ bottom: 30 })
      } else {
        Stack() {
          LoadingProgress().width(60)
          if(this.picUrl != '') {
            Image(this.picUrl + '?param=512y512')
              .width('80%')
              .height(250)
              .borderRadius(5)
              .aspectRatio(1)
              .sharedTransition('CoverImg', {
                duration: 500,
                curve: Curve.Linear
              })
          }
          else {
            Column() {}
            .width('80%')
            .height(250)
            .borderRadius(5)
            .aspectRatio(1)
          }
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
   * TabBar
   */
  @Builder
  TabBar() {
    Row({ space: 5 }) {
      Button()
        .width(15)
        .height(8)
        .opacity(this.tabPageIndex == 0 ? 1.0 : 0.3)
        .animation({
          duration: 200
        })
        .backgroundColor(Color.White)
        .onClick(() => this.tabsController.changeIndex(0))
      Button()
        .width(15)
        .height(8)
        .opacity(this.tabPageIndex == 1 ? 1.0 : 0.3)
        .animation({
          duration: 200
        })
        .backgroundColor(Color.White)
        .onClick(() => this.tabsController.changeIndex(1))
    }
  }
}


@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor(Color.White)
  .maxLines(1)
  .padding({ left:20, right:20 })
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}

@Extend(Image) function buttonImgStyle() {
  .width(50)
  .fillColor(Color.White)
}