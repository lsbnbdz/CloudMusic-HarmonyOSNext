import Constants from "../../common/constants/Constants"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration } from "../../common/functions/functions"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../../common/functions/playerControl"
import AudioPlayUtils from "../../common/utils/AudioPlayUtils"
import { AddToPlayListCircleButton } from "../buttons/AddToPlayListButton"
import { LoopModeButton } from "../buttons/LoopModeButton"
import { PlayQueueButton } from "../buttons/PlayQueueButton"
import { DownloadDialog } from "../dialog/DownloadDialog"

@Component
export struct PlayingCover {

  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0

  @StorageLink('player-isplaying') isPlaying:boolean = false
  @StorageProp('player-mode') playmode:number = 1
  @StorageProp('player-fileName') fileName:string = ''
  @StorageProp('player-song') song:Song = SongClass
  @StorageProp('player-artists') artists:string = ''
  @StorageProp('player-ispaused') isPaused:boolean = false
  @StorageProp('player-picurl') picUrl:string = ''
  @StorageProp('player-time') time:number = 0
  @StorageProp('set-playQuality') playQuality:number = 0
  @Link isShow: boolean
  @State qualitySelected:number = 3
  @State sliderThickness: number = 10
  @State isMovingSlider: boolean = false
  @State sliderMovingTime: number = 0
  @State isDarkMode: boolean = true

  artists1:string = ''
  song1:Song = SongClass
  picUrl1:string = ''

  dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song1,
      picUrl: this.picUrl1,
      artists: this.artists1,
      quality: Constants.QUALITY[this.qualitySelected],
      duration: changeDuration(this.song.duration)
    }),
  })

  build() {
   Stack({ alignContent: Alignment.Top }) {
     Column() {
     }
     .width('100%')
     .height('100%')
     .opacity(0.5)
     .backgroundColor($r('app.color.background'))

     Column({ space: 5 }) {
       // 收起
       Row() {
         Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_arrow_down_0')).width(40).padding(5).fillColor(Color.White) }
         .backgroundColor(Color.Transparent)
         .onClick(() => { this.isShow = false })
       }
       .width('100%')
       .justifyContent(FlexAlign.End)

       Column({ space: 20 }) {
         Tabs(){
           TabContent() {
             Column({ space: 20 }) {
               // 歌曲封面图片
               if (this.playmode == 0) {
                 Stack() {
                   Image($r('app.media.ic_public_music')).width(250).height(250).fillColor(Color.Gray).borderRadius(5)
                 }
                 .padding({ bottom: 30 })
               } else {
                 Stack() {
                   LoadingProgress().width(60)
                   Image(this.picUrl + '?param=512y512').width(250).height(250).borderRadius(5)
                 }
                 .padding({ bottom: 30 })
               }

               // 歌曲名称&艺术家
               Text(this.song.name)
                 .textStyle(22)
                 .fontWeight(FontWeight.Bold)
               Text(this.artists)
                 .textStyle(16)
             }
             .height('100%')
             .justifyContent(FlexAlign.Center)
           }

           TabContent() {
             Text('暂无歌词')
           }
           .height('100%')
         }
         .layoutWeight(1)

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
           }

           AddToPlayListCircleButton({ song: this.song })

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
           Button(){ Image($r('app.media.ic_public_play_next')).buttonImgStyle() }.onClick(() => { playNext() }).backgroundColor(Color.Transparent)
         }
         .padding({ top:30, bottom:50 })
         .justifyContent(FlexAlign.Center)
       }
     }
     .width('100%')
     .padding({left:15, right:15, top:px2vp(this.topRectHeight) + 10, bottom: px2vp(this.bottomRectHeight) + 10})
   }
   .height('100%')
   .backgroundImage(this.picUrl)
   .backgroundImageSize(ImageSize.Cover)
   .backdropBlur(100)
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