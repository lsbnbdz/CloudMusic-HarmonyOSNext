import { getDownloadInfo } from "../../api/getDownloadInfo"
import { QualityType, SongDownload, SongDownloadClass } from "../../common/entities/SongDownload"
import { Song, SongClass } from "../../common/entities/SongsResult"
import { pasteboard } from "@kit.BasicServicesKit"
import { promptAction } from "@kit.ArkUI"
import { SpinKit, SpinType } from "@pura/spinkit"
import FileDownloadUtils from "../../common/utils/FileDownloadUtils"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"

@CustomDialog
export struct DownloadDialog {
  controller: CustomDialogController
  @State isLoading:boolean = true

  song:Song = SongClass
  picUrl:string = ''
  artists:string = ''
  duration:string = ''
  quality:QualityType = 'lossless'
  fileSize:number = -1

  @State songDownload:SongDownload = SongDownloadClass
  @StorageProp('isValidCookie') isValidCookie:boolean = false
  @State succ:boolean = true

  async aboutToAppear(): Promise<void> {
    try {
      const gotDownloadData: SongDownload = await getDownloadInfo(this.song.id, this.quality, this.isValidCookie)
      this.songDownload = gotDownloadData
      if(this.songDownload.data.url == null) { this.succ = false }
      this.fileSize = await convertSize(this.songDownload.data.size)
      setTimeout(() => {
        this.isLoading = false
      },500)
    } catch (e) {
      this.succ = false
      LogUtil.error('Download Dialog Error: ' + JSON.stringify(e.message))
    }
  }

  build() {
    Column({ space: 10 }) {
      Text('下载').textStyle(24)
      Divider()
      if(this.succ) {
        Stack() {
          if (this.isLoading) {
            SpinKit({ spinType: SpinType.spinB, spinSize: 40, spinColor: $r('app.color.reverse') }).width(40)
          }
          Column({ space: 10 }) {
            Image(this.picUrl).width(128)
            Text(this.song.name).textStyle(20)
            Text(this.artists).textStyle(14)
            Divider()
            Text(`时长 ${this.duration}`).textStyle(12)
            Text(`音质: ${this.songDownload.data.level}     格式: ${this.songDownload.data.type}     大小: ${this.fileSize}MB`)
              .textStyle(12)
            Button('获取下载地址').ButtonStyle()
              .onClick(() => {
                copyDownloadUrl(this.songDownload.data.url)
              })
            Button('下载到本地').ButtonStyle()
              .onClick(() => {
                ToastUtil.showToast(`开始下载：${this.song.name}.${this.songDownload.data.type}`)
                this.controller.close()
                FileDownloadUtils.download(this.songDownload,this.song,this.artists)
              })
            if (!this.isValidCookie) {
              Text('你尚未登录，将无法完整获取部分会员歌曲')
            }
          }
          .opacity(this.isLoading ? 0 : 1)
        }
      } else {
        Text('获取下载内容失败，原因可能如下：').textStyle(18)
        Text('- 此歌曲需要单曲付费或为数字专辑曲目\n' +
          '- 当前未登录账号，无法获取试听链接\n' +
          '- 当前登录账号非会员，公共Cookie失效').textStyle(14)
      }
    }
    .backgroundColor(Color.Transparent)
    .backdropBlur(20)
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