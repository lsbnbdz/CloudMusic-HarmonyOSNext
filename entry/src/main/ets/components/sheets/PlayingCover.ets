import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration } from "../../common/functions/commonFunction"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../../common/functions/play/playControl"
import { AddToPlayListCircleButton } from "../buttons/play/AddToPlayListButton"
import { LoopModeButton } from "../buttons/play/LoopModeButton"
import { PlayQueueButton } from "../buttons/play/PlayQueueButton"
import { DownloadDialog } from "../dialog/DownloadDialog"
import { LyricComponent } from "../play/LyricComponent"
import { AVCastPicker } from "@kit.AVSessionKit"
import { TimerButton } from "../buttons/play/TimerButton"
import { StorageConstants } from "../../common/constants/StorageConstants"
import Constants from "../../common/constants/Constants"
import { SetPlayQuality } from "../settings/SetPlayQuality"
import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { resourceManager } from "@kit.LocalizationKit"

@Component
export struct PlayingCover {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('player-mode') playmode: number = 1
  @StorageProp('player-song') song: Song = SongClass
  @StorageProp('player-artists') artists: string = ''
  @StorageProp('player-ispaused') isPaused: boolean = false
  @StorageProp('player-picurl') picUrl: string = ''
  @StorageProp('player-time') time: number = 0
  @StorageProp('player-lyric') lyricArr: string[] = []
  @StorageProp(StorageConstants.PLAY_COUNTDOWN_WORKING) isTimerWorking: boolean = false
  @StorageProp(StorageConstants.PLAY_IS_LOCALFILE) isLocalFile: boolean = false
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @Link isShow: boolean
  @State hasLoaded: boolean = false
  @State sliderThickness: number = 10
  @State isMovingSlider: boolean = false
  @State sliderMovingTime: number = 0
  @State tabPageIndex: number = 0
  @State totalOpacity: number = 0
  @State isShowPopup: boolean = false
  private artists1: string = ''
  private song1: Song = SongClass
  private picUrl1: string = ''
  private tabsController: TabsController = new TabsController()
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song1,
      picUrl: this.picUrl1,
      artists: this.artists1,
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
     // Background
     Stack() {
       Image(this.picUrl + '?param=512y512')
         .blur(100)
         .width('100%')
         .height('100%')
         .animation({
           duration: 300,
           curve: Curve.Linear
         })
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
       Column()
         .width('100%')
         .height('100%')
         .opacity(0.6)
         .backgroundColor(Color.Black)
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
     }
     .width('100%')
     .height('100%')

     /**
      * 主内容
      */
     if(this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_TABLET) {
       this.TabletUI()
     } else {
       this.PhoneUI()
     }

     /**
      * Head栏
      */
     this.Head()

   }
   .height('100%')
   .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  /**
   * 功能栏
   */
  @Builder
  ToolBar() {
    Column() {
      Row() {
        /**
         * AVCastPicker
         */
        Column() {
          AVCastPicker({ normalColor: Color.White })
            .width(25)
            .height(25)
            .backgroundColor(Color.Transparent)
        }
        .width(30)
        .height(30)

        /**
         * Clock-Timer
         */
        TimerButton({ isTimerWorking: this.isTimerWorking })
        if (this.playmode == 1) {
          /**
           * Download
           */
          Column() {
            Image($r('app.media.ic_public_cloud_download'))
              .fillColor(Color.White)
              .width(25)
              .draggable(false)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.song1 = this.song
                this.artists1 = this.artists
                this.picUrl1 = this.picUrl
                this.dialogController.open()
              })
          }
          .width(30)
          .height(30)

          /**
           * AddToPlayList
           */
          Column() {
            AddToPlayListCircleButton({ song: this.song, imgColor: Color.White, imgWidth: 24 })
          }
          .width(30)
          .height(30)
        }
      }
      .opacity(this.totalOpacity)
      .animation({
        duration: 200,
        curve: Curve.Linear
      })
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('90%')
      .height(30)
    }
  }

  /**
   * 进度条组件
   */
  @Builder
  SliderContent() {
    Column({ space: 5 }) {
      Row() {
        // 当前时间
        Text(`${changeDuration(this.time)}`)
          .fontSize(Constants.FONT_SIZE_COMMON)
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
              .fontSize(Constants.FONT_SIZE_COMMON)
              .textAlign(TextAlign.Center)
              .padding({ left: 10, right: 10 })
          }
          .layoutWeight(1)
        }

        // 总时间
        Text(`${changeDuration(this.song.duration)}`)
          .fontSize(Constants.FONT_SIZE_COMMON)
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
  }

  /**
   * PlayButton
   * 控制上一首、下一首、播放和暂停
   */
  @Builder
  PlayButton() {
    // 上一首
    Button() {
      Image($r('app.media.ic_public_play_last')).buttonImgStyle()
    }
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      playPre()
    })

    // 暂停、继续
    if (!this.isPaused) {
      Button() {
        Image($r('app.media.ic_public_pause')).buttonImgStyle()
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        pauseMusic()
      })
    } else {
      Button() {
        Image($r('app.media.ic_play_fill')).buttonImgStyle()
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        resumeMusic()
      })
    }
    // 下一首
    Button() {
      Image($r('app.media.ic_public_play_next')).buttonImgStyle()
    }
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      playNext()
    })
  }

  /**
   * Head
   */
  @Builder
  Head() {
    Row() {
      Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_arrow_down_0')).draggable(false).fillColor(Color.White).width(Constants.SIZE_ICON_BUTTON_COMMON).aspectRatio(1) }
      .backgroundColor(Color.Transparent)
      .onClick(() => { this.isShow = false })
      Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_more_list')).draggable(false).fillColor(Color.White).width(Constants.SIZE_ICON_BUTTON_COMMON).aspectRatio(1) }
      .backgroundColor(Color.Transparent)
      .bindPopup(this.isShowPopup, {
        builder: this.MorePopup(),
        onWillDismiss: () => {
          this.isShowPopup = false
        }
      })
      .onClick(() => {
        this.isShowPopup = true
      })
    }
    .position({ top: 0 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: px2vp(this.topRectHeight), left: 10, right: 10, bottom: 5 })
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
          Column() {
          }
          .height('60%')
          .borderRadius(5)
          .aspectRatio(1)
          Image($r('app.media.ic_public_music'))
            .height('30%').fillColor(Color.Gray)
            .borderRadius(5)
            .aspectRatio(1)
        }
        .padding({ bottom: 30 })
      } else {
        Stack() {
          LoadingProgress().width(60)
          if(this.picUrl != '') {
            Image(this.picUrl + '?param=512y512')
              .height('60%')
              .borderRadius(5)
              .aspectRatio(1)
              .onClick(() => {
                this.tabsController.changeIndex(1)
              })
          }
          else {
            Column()
            .height('60%')
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
        .onClick(() => {
          PasteboardUtil.setDataText(this.song.name)
          ToastUtil.showToast('已复制歌名到剪贴板', { duration: 3000 })
        })
      Text(this.artists)
        .textStyle(16)
        .onClick(() => {
          PasteboardUtil.setDataText(this.artists)
          ToastUtil.showToast('已复制歌手名到剪贴板', { duration: 3000 })
        })
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 15, right: 15, top:px2vp(this.topRectHeight) + 40 })
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .gesture(
      SwipeGesture({
        fingers: 1,
        direction: SwipeDirection.Vertical
      }).onAction(() => { this.isShow = false })
    )
  }

  /**
   * Menu
   */
  @Builder
  MorePopup() {
    Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
      SetPlayQuality()
    }
    .constraintSize({
      minWidth: 200,
      maxWidth: 400
    })
    .width('80%')
    .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT, top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
  }

  @Builder PhoneUI() {
    Column() {
      Swiper() {
        this.SongInfo()
        LyricComponent()
          .padding({ top: px2vp(this.topRectHeight) })
          .width('100%')
      }
      .indicator(
        new DotIndicator()
          .top(px2vp(this.topRectHeight) + 5)
          .selectedColor(Color.White)
          .color(Color.Gray)
      )
      .clip(false)
      .loop(false)
      .layoutWeight(1)

      Column({ space: 10 }) {
        this.SliderContent()
        this.ToolBar()
        Row() {
          LoopModeButton({ imgColor: Color.White }).opacity(0.8)
          this.PlayButton()
          PlayQueueButton({ imgColor: Color.White }).opacity(0.8)
        }
        .padding({ top: 20, bottom: 15 })
        .justifyContent(FlexAlign.SpaceEvenly)
        .width('90%')
        Row({ space: 15 }) {
          if(this.isLocalFile) { Text('本地文件播放中').fontSize(10).fontColor(Color.Gray) }
          if(this.isTimerWorking) { Text('已设置定时关闭').fontSize(10).fontColor(Color.Gray) }
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(30)
        .backgroundColor(Color.Transparent)
      }
      .constraintSize({
        minWidth: 200,
        maxWidth: 500
      })
      .width('100%')
    }
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder TabletUI() {
    Row() {
      Column() {
        this.SongInfo()
        Column({ space: 10 }) {
          this.SliderContent()
          this.ToolBar()
          Row() {
            LoopModeButton({ imgColor: Color.White }).opacity(0.8)
            this.PlayButton()
            PlayQueueButton({ imgColor: Color.White }).opacity(0.8)
          }
          .padding({ top: 20, bottom: 15 })
          .justifyContent(FlexAlign.SpaceEvenly)
          .width('90%')
          Row({ space: 15 }) {
            if(this.isLocalFile) { Text('本地文件播放中').fontSize(10).fontColor(Color.Gray) }
            if(this.isTimerWorking) { Text('已设置定时关闭').fontSize(10).fontColor(Color.Gray) }
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(30)
          .backgroundColor(Color.Transparent)
        }
        .width('100%')
      }
      .layoutWeight(1.5)

      LyricComponent()
        .padding({ top: px2vp(this.topRectHeight) })
        .width('100%')
        .layoutWeight(2)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
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
  .draggable(false)
}