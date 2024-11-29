import { ToastUtil } from "@pura/harmony-utils"
import { pauseMusic, resumeMusic, stopMusic } from "../../common/functions/playerControl"
import { CommonCircleButton } from "../buttons/CommonCircleButton"

@Component
export struct PlayController {
  @StorageLink('player-isplaying') isPlaying:boolean = false
  @State isShowPopup:boolean = false

  @StorageProp('player-songname') songName:string = ''
  @StorageProp('player-artists') artists:string = ''
  @StorageProp('player-ispaused') isPaused:boolean = false
  @StorageProp('player-picurl') picUrl:string = ''

  build() {
    if(this.isPlaying) {
      Button({type:ButtonType.Circle}) {
        Image($r('app.media.ic_music_fill')).width(20).fillColor(Color.White).margin(10)
      }
      .backgroundColor(Color.Red)
      .opacity(0.5)
      .onClick(() => { this.isShowPopup = !this.isShowPopup})
      .bindPopup(this.isShowPopup,{
        builder: this.ControllerPopup(),
        placement: Placement.LeftBottom,
        enableArrow: true,
        onStateChange: (e) => {
          if (!e.isVisible) {
            this.isShowPopup = false;
          }
        }
      })
    } else {
      Button({type:ButtonType.Circle}) {
        Image($r('app.media.ic_music_fill')).width(20).fillColor($r('app.color.reverse')).margin(10)
      }
      .backgroundColor(Color.Transparent)
      .opacity(0.5)
      .backgroundColor(Color.Gray)
      .onClick(() => {
        ToastUtil.showToast('暂未播放')
      })
    }
  }

  @Builder
  ControllerPopup() {
    Column({ space: 5 }) {
      Column({ space: 10 }) {
        Text('正在播放').textStyle(12).padding({ bottom: 10 })
        Image(this.picUrl + '?param=128y128').width(80)
        Text(this.songName).textStyle(18)
        Text(this.artists).textStyle(12)
        Row({ space: 5 }) {
          // 暂停、继续
          if (!this.isPaused) {
            Button(){ Image($r('app.media.ic_public_pause')).buttonImgStyle() }.onClick(() => { pauseMusic() }).backgroundColor(Color.Transparent)
          } else {
            Button(){ Image($r('app.media.ic_play_fill')).buttonImgStyle() }.onClick(() => { resumeMusic() }).backgroundColor(Color.Transparent)
          }
        }
        .padding({ top:20, bottom:30 })
        .justifyContent(FlexAlign.Center)
      }
      Text('结束播放').textStyle(10).onClick(() => { stopMusic() })
    }
    .width('100%')
    .padding({left:10, right:10, top:10, bottom:10})
    .backgroundColor(Color.Transparent)
    .backdropBlur(200)
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
  .width(40)
  .fillColor($r('app.color.reverse'))
}