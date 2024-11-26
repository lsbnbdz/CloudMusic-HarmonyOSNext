import { getDownloadInfo } from "../../api/getDownloadInfo"
import { QualityType, SongDownload, SongDownloadClass } from "../../common/entities/SongDownload"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { pasteboard } from "@kit.BasicServicesKit"
import { promptAction } from "@kit.ArkUI"
import { SpinKit, SpinType } from "@pura/spinkit"

@CustomDialog
export struct DownloadDialog {
  controller: CustomDialogController
  @State isLoading:boolean = true

  song:Song = SongClass
  picUrl:string = ''
  artists:string = ''
  duration:string = ''
  quality:QualityType = 'hires'
  fileSize:number = -1

  @State songDownload:SongDownload = SongDownloadClass

  async aboutToAppear(): Promise<void> {
    try {
      const gotDownloadData: SongDownload = await getDownloadInfo(this.song.id, 'hires')
      this.songDownload = gotDownloadData
      this.fileSize = await convertSize(this.songDownload.data.size)
      setTimeout(() => {
        this.isLoading = false
      },500)
    } catch (e) {
      console.error('Download Dialog Error: ' + JSON.stringify(e.message))
    }
  }

  build() {
    Column({ space: 10 }) {
      Text('下载').textStyle(24)
      Divider()
      Stack() {
        if(this.isLoading) {
          SpinKit({ spinType: SpinType.spinB, spinSize:40, spinColor:$r('app.color.reverse') }).width(40)
        }
        Column({ space:10 }) {
          Image(this.picUrl).width(128)
          Text(this.song.name).textStyle(20)
          Text(this.artists).textStyle(14)
          Divider()
          Text(`时长 ${this.duration}`).textStyle(12)
          Text(`音质: ${this.songDownload.data.level}     格式: ${this.songDownload.data.type}     大小: ${this.fileSize}MB`).textStyle(12)
          Button('获取下载地址').ButtonStyle()
            .onClick(() => { copyDownloadUrl(this.songDownload.data.url) })
          Button('下载到本地').ButtonStyle()
            .onClick(() => { promptAction.showToast({ message: '该功能正在开发中，敬请期待。', duration: 3000})})
        }
        .opacity(this.isLoading ? 0 : 1)
      }
    }
    .margin({ left:10, right:10, top:20, bottom:20})
    .borderRadius(5)
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .textAlign(TextAlign.Center)
}

@Extend(Button) function ButtonStyle() {
  .backgroundColor(Color.Transparent)
  .borderWidth(2)
  .borderColor(Color.Gray)
  .fontColor($r('app.color.reverse'))
}

async function convertSize(size: number): Promise<number> {
  if (size < 0) {
    throw new Error("输入值不能为负数");
  }
  const mb = size / 1024 / 1024;
  return parseFloat(mb.toFixed(2));
}

function copyDownloadUrl(url:string) {
  const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, url)
  const systemPasteboard = pasteboard.getSystemPasteboard()
  systemPasteboard.setData(pasteboardData)
  promptAction.showToast({ message: '成功复制到剪切板' })
}