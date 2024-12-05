import { ToastUtil } from "@pura/harmony-utils"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { pauseMusic, resumeMusic } from "../../common/functions/playerControl"

/**
 * 底部播控组件
 */
@Component
export struct BottomPlayController {
  @StorageLink('player-isplaying') isPlaying:boolean = false
  @StorageProp('player-mode') playmode:number = 1
  @StorageProp('player-fileName') fileName:string = ''
  @StorageProp('player-song') song:Song = SongClass
  @StorageProp('player-artists') artists:string = ''
  @StorageProp('player-ispaused') isPaused:boolean = true
  @StorageProp('player-picurl') picUrl:string = ''
  @StorageProp('player-time') time:number = 0

  build() {
    Row({ space: 10 }) {
      if(this.isPlaying) {
        Row() {
          Image(this.picUrl + '?param=256y256').width(50).height(50).borderRadius(10)
          Column() {
            Text(this.song.name).textStyle(18)
            Text(this.artists).textStyle(14)
          }
          .layoutWeight(1)
          Row({ space: 5 }) {
            // 暂停、继续
            if (!this.isPaused) {
              Button(){ Image($r('app.media.ic_public_pause')).fillColor(Color.Gray).buttonImgStyle() }.onClick(() => { pauseMusic() }).backgroundColor(Color.Transparent)
            } else {
              Button(){ Image($r('app.media.ic_play_fill')).fillColor(Color.Gray).buttonImgStyle() }.onClick(() => { resumeMusic() }).backgroundColor(Color.Transparent)
            }
          }
          .justifyContent(FlexAlign.Center)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
      }
      else {
        Row({ space: 10 }) {
          Text('未在播放')
            .textStyle(18)
          Row({ space: 5 }) {
            // 暂停、继续
            if (!this.isPaused) {
              Button(){ Image($r('app.media.ic_public_pause')).fillColor(Color.Gray).buttonImgStyle() }.onClick(() => { pauseMusic() }).backgroundColor(Color.Transparent)
            } else {
              Button(){ Image($r('app.media.ic_play_fill')).fillColor(Color.Gray).buttonImgStyle() }.onClick(() => { resumeMusic() }).backgroundColor(Color.Transparent)
            }
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .onClick(() => {
      ToastUtil.showToast('该功能正在开发中，敬请期待！')
    })
    .backdropBlur(30)
    .padding({ left:10, right:10 })
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('app.color.main'))
    .opacity(0.8)
    .height(80)
  }
}

@Extend(Image) function buttonImgStyle() {
  .width(40)
  .fillColor($r('app.color.reverse'))
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .padding({ left:20, right:20 })
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}