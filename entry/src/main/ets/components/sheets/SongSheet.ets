import { ToastUtil } from "@pura/harmony-utils";
import { putPlayListInQueue } from "../../api/playListApi";
import Constants from "../../common/constants/Constants";
import { playList, playListClass } from "../../common/entities/PlayList";
import { Song, SongClass } from "../../common/entities/SongsResult";
import { changeDuration, getArtists } from "../../common/functions/functions";
import { playMusicByUrl, playQueue } from "../../common/functions/playerControl";
import PlayQueueUtils from "../../common/utils/PlayQueueUtils";
import { DownloadDialog } from "../dialog/DownloadDialog";

@Component
export struct SongSheet {
  song:Song = SongClass
  picUrl:string = ''
  artists:string = ''

  @State duration:string = 'null'
  @State qualitySelected:number = 3

  dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: this.duration,
      quality: Constants.QUALITY[this.qualitySelected]
    }),
  })

  @StorageProp("bottomRectHeight") bottomRectHeight: number = 0;
  @StorageProp('isValidCookie') isValidCookie:boolean = false
  @StorageProp('isPlayerLoading') isPlayerLoading:boolean = false
  @Link isShowSheet:boolean
  @State isPicLoading:boolean = true
  @State isPlayList:boolean = false
  @State playList:playList = playListClass
  @State index: number = -1

  aboutToAppear(): void {
    this.duration = changeDuration(this.song.duration)
  }

  build() {
    Column({ space: 30 }) {
      Column({ space:10 }) {
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
            Button() {
              Row({ space: 5 }) {
                Image($r('app.media.ic_play_fill')).width(18).fillColor($r('app.color.reverse'))
                Text('播放单首').fontSize(16).fontColor($r('app.color.reverse'))
              }
              .padding(15)
            }
            .clickButtonStyle()
            .onClick(async () => {
              AppStorage.setOrCreate('isPlayerLoading', true)
              this.isShowSheet = !this.isShowSheet
              playMusicByUrl(this.song, this.artists, this.picUrl, this.isValidCookie).then(() => {
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
                  Text('播放歌单').fontSize(16).fontColor($r('app.color.reverse'))
                }
                .padding(15)
              }
              .clickButtonStyle()
              .onClick(async () => {
                AppStorage.setOrCreate('isPlayerLoading', true)
                this.isShowSheet = !this.isShowSheet
                await putPlayListInQueue(this.playList.id, this.playList.trackCount)
                AppStorage.setOrCreate('isPlayerLoading', false)
                playQueue(this.index)
              })
            }
          }
        }

        Row({ space: 5 }) {
          // 音质选择框
          Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
            .selected(3)
            .value('无损')
            .onSelect((index: number) => {
              this.qualitySelected = index
            })

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