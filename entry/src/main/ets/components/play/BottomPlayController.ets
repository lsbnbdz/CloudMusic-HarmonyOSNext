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
  @StorageLink('player-isplaying') isPlaying: boolean = false
  @StorageProp('player-mode') playmode: number = 1
  @StorageProp('player-fileName') fileName: string = ''
  @StorageProp('player-song') song: Song = SongClass
  @StorageProp('player-artists') artists: string = ''
  @StorageProp('player-ispaused') isPaused: boolean = true
  @StorageProp('player-picurl') picUrl: string = ''
  @StorageProp('player-time') time: number = 0
  @StorageProp('player-currentLyric') currentLyric: string = ''

  @State componentOpacity: number = 0.8
  @State isShow: boolean = false

  build() {
    Row({ space: 10 }) {
      Row() {
        if(this.playmode == 0) { Image($r('app.media.ic_public_music')).fillColor($r('app.color.reverse')).songImg() }
        else { Image(this.picUrl + '?param=256y256').songImg() }

        Column({ space: 5 }) {
          Text(this.song.name).textStyle(18)
          if(!this.currentLyric) {
            Text(this.artists).textStyle(14).layoutWeight(1)
          }
          else {
            Text(this.currentLyric).textStyle(14).textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
          }
        }
        .padding({ top: 15, bottom: 15 })
        .layoutWeight(1)

        ControlButtons({ isPaused: this.isPaused, isPlaying: this.isPlaying })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
    }
    .backdropBlur(50)
    .padding({ left:10, right:10 })
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('app.color.main'))
    .opacity(this.isShow ? this.componentOpacity : this.componentOpacity)
    .height(80)
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
        }
        .onClick(() => {
          if(!this.isPlaying) playQueue(playQueueUtils.currentQueueIndex)
          else resumeMusic()
        })
        .backgroundColor(Color.Transparent)
      }
      PlayQueueButton()
    }
  }
}

@Extend(Image) function buttonImgStyle() {
  .aspectRatio(1)
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

@Extend(Image) function songImg() {
  .width(50)
  .height(50)
  .borderRadius(10)
}