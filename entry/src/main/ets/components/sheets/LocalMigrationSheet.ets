import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { LocalSong } from "../../common/entities/local/LocalData";
import { fetchSongInfo, getArtists } from "../../common/functions/common/convert";
import RelationalStoreUtils from "../../common/utils/data/RelationalStoreUtils";
import FileUtils from "../../common/utils/file/FileUtils";

@Component
export struct LocalMigrationSheet {
  @StorageLink(StorageConstants.IS_MIGRATING_LOCALFILES) isMigrating: boolean = false
  @Link isShowMigration: boolean
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Column({ space: 20 }) {
      Text('本地文件迁移')
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.reverse'))
      Text('将旧版本的本地歌曲信息迁移至新版本')
        .fontColor($r('app.color.reverse'))
        .fontSize(Constants.FONT_SIZE_COMMON)
      Text('注意: 请勿在有下载任务的情况下进行迁移，否则会造成部分歌曲迁移失败')
        .fontColor(Color.Gray)
        .fontSize(Constants.FONT_SIZE_COMMON)
      if(this.isMigrating) {
        Row({ space: 10 }) {
          LoadingProgress().width(30)
          Text('正在迁移数据')
            .fontColor($r('app.color.reverse'))
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontWeight(FontWeight.Medium)
        }
      }
      Button('迁移')
        .padding(10)
        .width(100)
        .onClick(async () => {
          this.isMigrating = true
          await this.handleMigration()
          this.isShowMigration = false
          this.isMigrating = false
        })
    }
    .width('100%')
    .padding(Constants.PADDING_EDGE_TEXT)
  }

  private async handleMigration() {
    try {
      const fileList = await FileUtils.getFileName()
      for (let item of fileList) {
        let song = await fetchSongInfo(item)
        if(song.id != -1) {
          let localSong: LocalSong = {
            id: 0,
            songId: 0,
            name: song.name,
            artists: await getArtists(song.artists),
            picFile: "",
            songFile: item,
            lyricFile: ""
          }
          await RelationalStoreUtils.addSong(localSong)
        }
      }
      ToastUtil.showToast('数据迁移成功')
      this.pageInfos.pop()
    } catch (e) {
      ToastUtil.showToast('迁移失败: ' + e.message)
      LogUtil.error('Error handle migration: ' + e.message)
    }
  }
}