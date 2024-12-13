import { ToastUtil } from "@pura/harmony-utils"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { pauseMusic, playQueue, resumeMusic } from "../../common/functions/playerControl"
import playQueueUtils from "../../common/utils/PlayQueueUtils"
import { PlayQueueButton } from "../buttons/PlayQueueButton"
import { PlayingCover } from "../sheets/PlayingCover"

/**
 * 底部播控组件
 */
@Component
export struct BottomPlayController {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0

  @StorageLink('player-isplaying') isPlaying:boolean = false
  @StorageProp('player-mode') playmode:number = 1
  @StorageProp('player-fileName') fileName:string = ''
  @StorageProp('player-song') song:Song = SongClass
  @StorageProp('player-artists') artists:string = ''
  @StorageProp('player-ispaused') isPaused:boolean = true
  @StorageProp('player-picurl') picUrl:string = ''
  @StorageProp('player-time') time:number = 0

  @State componentOpacity:number = 0.8
  @State isShow: boolean = false

  // aboutToAppear(): void {
  //   setTimeout(() => {
  //     this.componentOpacity = 0.8
  //   },100)
  // }
  //
  // aboutToDisappear(): void {
  //   setTimeout(() => {
  //     this.componentOpacity = 0
  //   },100)
  // }

  build() {
    Row({ space: 10 }) {
      if(this.isPlaying) {
        Row() {
          if(this.playmode == 0) { Image($r('app.media.ic_public_music')).width(50).height(50).fillColor($r('app.color.reverse')) }
          else { Image(this.picUrl + '?param=256y256').width(50).height(50).borderRadius(10) }

          Column() {
            Text(this.song.name).textStyle(18)
            Text(this.artists).textStyle(14)
          }
          .layoutWeight(1)

          ControlButtons({ isPaused: this.isPaused, isPlaying: this.isPlaying })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
      }
      else {
        Row({ space: 10 }) {
          Text('未在播放')
            .textStyle(18)
          ControlButtons({ isPaused: this.isPaused, isPlaying: this.isPlaying })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .backdropBlur(50)
    .padding({ left:10, right:10 })
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('app.color.main'))
    .opacity(this.componentOpacity)
    .height(80)
    .sharedTransition('bottom_play_controller', {
      duration: 1,
      curve: Curve.Friction
    })
    // .animation({
    //   duration: 300,
    //   curve: Curve.Linear,
    // })
    .onClick(() => {
      if(this.isPlaying) { this.isShow = true }
      else { ToastUtil.showToast('暂无播放') }
    })
    .bindContentCover(this.isShow, this.Cover(), {
      modalTransition: ModalTransition.DEFAULT,
      backgroundColor: $r('app.color.background'),
      onDisappear: () => {
        this.isShow = false
      }
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
    Row({ space: 5 }) {
      if (!this.isPaused) {
        Button() {
          Image($r('app.media.ic_public_pause')).fillColor(Color.Gray).buttonImgStyle()
        }.onClick(() => {
          pauseMusic()
        }).backgroundColor(Color.Transparent)
      } else {
        Button() {
          Image($r('app.media.ic_play_fill')).fillColor(Color.Gray).buttonImgStyle()
        }.onClick(() => {
          if(!this.isPlaying) playQueue(0)
          else resumeMusic()
        }).backgroundColor(Color.Transparent)
      }
      PlayQueueButton()
    }
  }
}

@Extend(Image) function buttonImgStyle() {
  .width(30)
  .fillColor($r('app.color.reverse'))
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .padding({ left:20, right:20 })
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}