import Constants from "../../common/constants/Constants"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { changeDuration } from "../../common/functions/functions"
import { pauseMusic, resumeMusic, stopMusic } from "../../common/functions/playerControl"
import { DownloadDialog } from "../dialog/DownloadDialog"

/**
 * 播控组件（右上角）
 */
@Component
export struct PlayController {
  @StorageLink('player-isplaying') isPlaying:boolean = false
  @StorageProp('player-mode') playmode:number = 1
  @StorageProp('player-fileName') fileName:string = ''
  @StorageProp('player-song') song:Song = SongClass
  @StorageProp('player-artists') artists:string = ''
  @StorageProp('player-ispaused') isPaused:boolean = false
  @StorageProp('player-picurl') picUrl:string = ''
  @StorageProp('player-time') time:number = 0
  @StorageProp('set-playQuality') playQuality:number = 0
  @State isShowPopup:boolean = false
  @State qualitySelected:number = 3
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

  aboutToAppear(): void {
    this.song1 = this.song
    this.artists1 = this.artists
    this.picUrl1 = this.picUrl
  }

  build() {
    if(this.isPlaying) {
      Button({type:ButtonType.Circle}) {
        Image($r('app.media.ic_music_fill')).width(20).fillColor(Color.White).margin(10)
      }
      .backgroundColor('#ffd25959')
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
      .backgroundColor(Color.Gray)
      .onClick(() => { this.isShowPopup = !this.isShowPopup})
      .bindPopup(this.isShowPopup,{
        builder: this.ControllerPopupNotPlaying(),
        placement: Placement.Bottom,
        enableArrow: true,
        onStateChange: (e) => {
          if (!e.isVisible) {
            this.isShowPopup = false;
          }
        }
      })
    }
  }

  @Builder
  ControllerPopup() {
    Column({ space: 5 }) {
      Column({ space: 10 }) {
        if(this.playmode == 0) { Text(`正在播放本地文件`).textStyle(12).padding({ bottom: 10 }) }
        else {
          Text(`正在播放 [${Constants.QUALITY_NAME[this.playQuality]}]`).textStyle(12).padding({ bottom: 10 })
          Image(this.picUrl + '?param=256y256').width(120).height(120)
        }
        Text(this.song.name).textStyle(20)
        Text(this.artists).textStyle(15)
        Text(`${changeDuration(this.time)} / ${changeDuration(this.song.duration)}`).textStyle(16)
        Progress({ value: this.time, total: this.song.duration })
          .width('80%')
        if(this.playmode == 1) {
          Row({ space: 5 }) {
            Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
              .selected(3)
              .value('无损')
              .height(40)
              .onSelect((index: number) => {
                this.qualitySelected = index
              })
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_public_download_filled'))
                .width(40)
                .padding({
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 8
                })
            }
            .backgroundColor(Color.Gray)
            .onClick(() => {
              this.song1 = this.song
              this.artists1 = this.artists
              this.picUrl1 = this.picUrl
              this.dialogController.open()
            })
          }
        }

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
    .padding({left:15, right:15, top:10, bottom:10})
    .backgroundColor(Color.Transparent)
    .backdropBlur(1)
  }

  @Builder
  ControllerPopupNotPlaying() {
    Column({ space: 5 }) {
      Text('暂无播放曲目').textStyle(16)
    }
    .padding({left:10, right:10, top:10, bottom:10})
    .backgroundColor(Color.Transparent)
    .backdropBlur(1)
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