import { Song, SongClass } from "../../common/entities/SongsResult";
import { DownloadDialog } from "../dialog/DownloadDialog";

@Component
export struct SongSheet {
  song:Song = SongClass
  picUrl:string = ''
  artists:string = ''

  @State duration:string = 'null'

  dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: this.duration
    }),
  })

  @StorageProp("bottomRectHeight") bottomRectHeight: number = 0;
  @Link isShowSheet:boolean
  @State isLoadingPic:boolean = true

  aboutToAppear(): void {
    this.duration = changeDuration(this.song.duration)
  }

  build() {
    Column({ space: 30 }) {
      Column({ space:10 }) {
        Stack() {
          // 图片加载动画
          if (this.isLoadingPic) {
            LoadingProgress()
              .width(50)
              .height(50)
              .alignSelf(ItemAlign.Center);
          }
          Image(this.picUrl + '?param=256y256')
            .width(120)
            .borderRadius(5)
            .onComplete(() => {　this.isLoadingPic = false　})
            .onError(() => {　this.isLoadingPic = false　});
        }.width(120).height(120); // Stack 大小与图片一致

        Text(this.song.name).textStyle(22)
        Text(this.artists).textStyle(14)
        Divider()
        Text(`时长 ${this.duration}`).textStyle(12)
      }.width('100%')
      // 按钮
      Column({ space:5 }) {
        Button() {
          Row({ space:5 }) {
            Image($r('app.media.ic_public_download_filled')).width(24).fillColor($r('app.color.reverse'))
            Text('下载').fontSize(20)
          }.padding({ left: 15, right: 15, top: 10, bottom: 10 })
        }.type(ButtonType.Normal).borderRadius(20).backgroundColor('#ff9ca0a0')
        .onClick(() => {
          this.dialogController.open()
          this.isShowSheet = false
        })
      }.width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({left:30, right:30 ,top: 30, bottom:px2vp(this.bottomRectHeight)})
    .backgroundColor(Color.Transparent)
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .textAlign(TextAlign.Center)
}

function changeDuration(dur: number): string {
  const seconds = Math.floor(dur / 1000);
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}:${remainingSeconds < 10 ? '0' + remainingSeconds : remainingSeconds}`;
}