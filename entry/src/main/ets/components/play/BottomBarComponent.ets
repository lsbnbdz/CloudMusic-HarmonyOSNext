import { Song, SongItem } from "../../common/entities/song/Song"
import { pauseMusic, playNext, playPre, playQueue, resumeMusic } from "../../common/functions/play/playControl"
import playQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { PlayQueueButton } from "../buttons/play/PlayQueueButton"
import { PlayingCover } from "../sheets/PlayingCover"
import { StorageConstants } from "../../common/constants/StorageConstants"
import Constants from "../../common/constants/Constants"
import { ClickUtil } from "@pura/harmony-utils"

/**
 * 底部播控组件
 */
@Component
export struct BottomBarComponent {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageLink(StorageConstants.IS_PLAYING) isPlaying: boolean = false
  @StorageProp(StorageConstants.PLAY_MODE) playmode: number = 1
  @StorageProp(StorageConstants.PLAY_FILE_NAME) fileName: string = ''
  @StorageProp(StorageConstants.PLAY_SONG) song: Song = SongItem
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = ''
  @StorageProp(StorageConstants.IS_PAUSED) isPaused: boolean = true
  @StorageProp(StorageConstants.PIC_URL) picUrl: string = ''
  @StorageProp(StorageConstants.PLAY_TIME) time: number = 0
  @StorageProp(StorageConstants.CURRENT_LYRIC) currentLyric: string = ''
  @State isShow: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Row() {
      Image(this.playmode == 0 ? this.picUrl : this.picUrl + '?param=512y512')
        .songImg()
        // .geometryTransition('coverImg')

      Column({ space: 5 }) {
        Text(this.song.name).textStyle(16).fontWeight(FontWeight.Medium)
        if(!this.currentLyric || this.currentLyric === '暂无歌词') {
          Text(this.artists).textStyle(12).textOverflow({ overflow: TextOverflow.MARQUEE }).layoutWeight(1).fontColor(Color.Gray)
        }
        else {
          Text(this.currentLyric).textStyle(12).textOverflow({ overflow: TextOverflow.MARQUEE }).layoutWeight(1).fontColor(Color.Gray)
        }
      }
      .padding({ top: 10, bottom: 10 })
      .layoutWeight(1)

      ControlButtons({ isPaused: this.isPaused, isPlaying: this.isPlaying })
        .padding({ right: 5 })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .constraintSize({
      minWidth: 100,
      maxWidth: 500
    })
    .backdropBlur(BlurStyle.Regular)
    .borderRadius(Constants.RADIUS_IMG)
    .backgroundColor($r('app.color.main'))
    .opacity(0.9)
    .height(Constants.HEIGHT_MINI)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(async () => {
      if(!this.isPlaying) {
        await playQueue(playQueueUtils.currentQueueIndex)
      }
      animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
        this.isShow = true
      })
    })
    .bindContentCover($$this.isShow, this.Cover(), {
      modalTransition: ModalTransition.DEFAULT
    })
  }

  @Builder
  Cover() {
    PlayingCover({ isShow: this.isShow })
      .height('100%')
  }
}

@Component
struct ControlButtons {
  @Link isPaused: boolean
  @Link isPlaying: boolean
  build() {
    Row({ space: 10 }) {
      // Last
      Image($r('app.media.ic_public_play_last')).buttonImgStyle()
        .fillColor($r('app.color.app_red'))
        .onClick(() => {
          ClickUtil.throttle(() => {
            playPre()
          }, 500)
        })

      // Play & Pause
      Image(this.isPaused ? $r('app.media.ic_public_play_norm') : $r('app.media.ic_public_pause_norm')).buttonImgStyle()
        .fillColor($r('app.color.app_red'))
        .onClick(() => {
          if(!this.isPlaying) {
            setTimeout(() => {
              playQueue(playQueueUtils.currentQueueIndex)
            }, 100)
          } else {
            if(this.isPaused) resumeMusic()
            else pauseMusic()
          }
        })


      // Next
      Image($r('app.media.ic_public_play_next')).buttonImgStyle()
        .fillColor($r('app.color.app_red'))
        .onClick(() => {
          ClickUtil.throttle(() => {
            playNext()
          }, 500)
        })

      PlayQueueButton({ imgWidth: 25, imgColor: $r('app.color.app_red') })
    }
  }
}

@Extend(Image) function buttonImgStyle() {
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.6 })
  .aspectRatio(1)
  .width(30)
  .fillColor($r('app.color.reverse'))
  .draggable(false)
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .textAlign(TextAlign.Start)
  .layoutWeight(1)
  .width('100%')
  .maxLines(1)
  .padding({ left: 10, right: 10 })
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Image) function songImg() {
  .height(Constants.HEIGHT_MINI)
  .aspectRatio(1)
  .borderRadius(Constants.RADIUS_IMG)
  .padding(5)
}
