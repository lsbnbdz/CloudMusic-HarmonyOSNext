import Constants from "../../common/constants/Constants"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration } from "../../common/functions/functions"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../../common/functions/playerControl"
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
     Column({ space: 5 }) {
       // 收起
       Row() {
         Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_arrow_down_0')).width(40).padding(5).fillColor(Color.Gray) }
         .backgroundColor(Color.Transparent)
         .onClick(() => { this.isShow = false })
       }
       .width('100%')
       .justifyContent(FlexAlign.End)

       Column({ space: 20 }) {
         Column({ space: 20 }) {
           if (this.playmode == 0) {
             Text(`正在播放本地文件`)
               .textStyle(14)
               .padding({ bottom: 30 })
             Stack() {
               Image($r('app.media.ic_public_music')).width(100).height(100).fillColor(Color.Gray).borderRadius(5)
             }
             .width(200)
             .height(200)
             .padding({ bottom: 30 })
           } else {
             Text(`正在播放 [${Constants.QUALITY_NAME[this.playQuality]}]`)
               .textStyle(14)
               .padding({ bottom: 30 })

             Stack() {
               LoadingProgress().width(60)
               Image(this.picUrl + '?param=512y512').width(200).height(200).borderRadius(5)
             }
             .width(200)
             .height(200)
             .padding({ bottom: 30 })
           }

           Text(this.song.name)
             .textStyle(22)
             .fontWeight(FontWeight.Bold)

           Text(this.artists)
             .textStyle(18)
             .fontColor(Color.Gray)
         }
         .layoutWeight(1)
         .justifyContent(FlexAlign.Center)

         Column({ space: 5 }) {
           Row() {
             Text(`${changeDuration(this.time)}`).fontSize(16).layoutWeight(1).textAlign(TextAlign.Start)
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
             Text(`${changeDuration(this.song.duration)}`).fontSize(16).layoutWeight(1).textAlign(TextAlign.End)
           }
           .width('90%')
           .justifyContent(FlexAlign.SpaceAround)

           // Progress({ value: this.time, total: this.song.duration })
           //   .width('90%')

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
     .padding({left:15, right:15, top:10, bottom:10})
   }
    .padding({ top: px2vp(this.topRectHeight), bottom: px2vp(this.bottomRectHeight) })
    .height('100%')
    .backgroundColor($r('app.color.background'))
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