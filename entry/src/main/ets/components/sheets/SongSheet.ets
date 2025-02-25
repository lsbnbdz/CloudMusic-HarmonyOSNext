import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { PlayList, playListClass } from "../../common/entities/PlayList";
import { Song, SongClass } from "../../common/entities/SongsResult";
import { changeDuration } from "../../common/functions/commonFunction";
import { playMusicByUrl } from "../../common/functions/play/playControl";
import { playListToQueue } from "../../common/functions/play/playListOp";
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils";
import { DownloadDialog } from "../dialog/DownloadDialog";

@Component
export struct SongSheet {
  @State duration: string = 'null'
  @State qualitySelected: number = 3
  song: Song = SongClass
  picUrl: string = ''
  artists: string = ''
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: this.duration
    }),
  })

  @StorageProp("bottomRectHeight") bottomRectHeight: number = 0
  @StorageProp(StorageConstants.IS_LOGGED) isLogged: boolean = false
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @Link isShowSheet:boolean
  @State isPicLoading:boolean = true
  @State isPlayList:boolean = false
  @State playList:PlayList = playListClass
  @State index: number = -1
  @State showPlayButton:boolean = true

  aboutToAppear(): void {
    this.duration = changeDuration(this.song.duration)
  }

  build() {
    Column({ space: 30 }) {
      Column({ space: 15 }) {
        Stack() {
          // 图片加载动画
          if (this.isPicLoading) {
            LoadingProgress()
              .width(50)
              .height(50)
              .alignSelf(ItemAlign.Center);
          }
          Image(this.picUrl + '?param=256y256')
            .width(120)
            .borderRadius(5)
            .onComplete(() => {　this.isPicLoading = false　})
            .onError(() => {　this.isPicLoading = false　});
        }
        .width(120)
        .height(120); // Stack 大小与图片一致

        Text(this.song.name).textStyle(22)
        if(this.song.alias.length > 0) { Text(`${this.song.alias[0]}`).textStyle(14).fontColor(Color.Gray) }
        Text(this.artists).textStyle(14)
        Divider()
        Text(`时长 ${this.duration}`).textStyle(12)
      }.width('100%')
      // 按钮
      Column({ space:15 }) {
        if(this.isPlayerLoading) {
          Column({ space: 10 }) {
            LoadingProgress().width(40)
            Text('当前有正在加载的播放任务...').fontSize(14)
          }
          .padding({ bottom: 20 })
        }
        else {
          Row({ space: 10 }) {
            // 播放按钮
            if(this.showPlayButton) {
              Button() {
                Row({ space: 5 }) {
                  Image($r('app.media.ic_play_fill')).width(18).fillColor($r('app.color.reverse'))
                  Text('播放单首').fontSize(Constants.FONT_SIZE_COMMON).fontColor($r('app.color.reverse'))
                }
                .padding(15)
              }
              .clickButtonStyle()
              .onClick(async () => {
                AppStorage.setOrCreate('isPlayerLoading', true)
                this.isShowSheet = !this.isShowSheet
                playMusicByUrl(this.song, this.artists, this.isLogged).then(() => {
                  PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
                  PlayQueueUtils.setIndex(PlayQueueUtils.currentQueueIndex + 1)
                  AppStorage.setOrCreate('isPlayerLoading', false)
                })
              })

              if (this.isPlayList) {
                // 同时播放歌单
                Button() {
                  Row({ space: 5 }) {
                    Image($r('app.media.ic_play_fill')).width(18).fillColor($r('app.color.reverse'))
                    Text('播放歌单').fontSize(Constants.FONT_SIZE_COMMON).fontColor($r('app.color.reverse'))
                  }
                  .padding(15)
                }
                .clickButtonStyle()
                .onClick(async () => {
                  playListToQueue(this.playList.id, this.playList.trackCount, this.index)
                  this.isShowSheet = !this.isShowSheet
                })
              }
            }
          }
        }

        Row({ space: 5 }) {
          // 下载按钮
          Button() {
            Row({ space: 5 }) {
              Image($r('app.media.ic_public_download_filled')).width(20).fillColor($r('app.color.reverse'))
            }.padding(5)
          }
          .type(ButtonType.Circle)
          .borderRadius(20)
          .backgroundColor('transparent')
          .borderWidth(1)
          .borderColor(Color.Gray)
          .onClick(() => {
            this.dialogController.open()
            this.isShowSheet = false
          })
        }
      }.width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({left:30, right:30 ,top: 30, bottom:px2vp(this.bottomRectHeight)})
    .backgroundColor(Color.Transparent)
  }
}

@Extend(Button) function clickButtonStyle() {
  .type(ButtonType.Normal)
  .borderRadius(20)
  .backgroundColor('transparent')
  .borderWidth(1)
  .borderColor(Color.Gray)
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .textAlign(TextAlign.Center)
}