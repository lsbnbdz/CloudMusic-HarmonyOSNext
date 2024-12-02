import { common } from '@kit.AbilityKit'
import { BusinessError, request } from '@kit.BasicServicesKit'
import { SongDownload } from '../entities/SongDownload'
import { Song } from '../entities/SongsResult'
import { DialogUtil, LogUtil, ToastUtil } from '@pura/harmony-utils'
import Constants from '../constants/Constants'
import { promptAction } from '@kit.ArkUI'
import { changeb2Mb } from '../functions/functions'
import FileUtils from './FileUtils'

/**
 * 文件下载
 */

const TAG = '[FileDownload] '

class FileDownloadUtils {
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;
  filePref = Constants.FILE_PREF

  download(songDownload:SongDownload, song:Song, artists:string) {
    try {
      request.downloadFile(this.context, {
        url: songDownload.data.url,
        filePath: this.filesDir + `/${artists} - ${song.name}.${songDownload.data.type}`
      }).then((downloadTask: request.DownloadTask) => {
        downloadTask.on('progress', async (received, total) => {
          promptAction.showToast({ message: `下载中: ${changeb2Mb(received)} / ${changeb2Mb(total)} MB` })
        })
        downloadTask.on('complete', () => {
          DialogUtil.showConfirmDialog({ title: '下载完成', message: `(${artists} - ${song.name}.${songDownload.data.type})`})
          LogUtil.info(TAG + '下载完成: ' + song.name)
        })
      }).catch((err: BusinessError) => {
        ToastUtil.showToast('下载出错: ' + err.message)
        LogUtil.error(TAG + `下载出错: ${JSON.stringify(err)}`)
        FileUtils.deleteFile(`${artists} - ${song.name}.${songDownload.data.type}`)
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      if(err.code == 13400002) DialogUtil.showConfirmDialog({ title: '下载失败', message: `文件已存在`})
      else DialogUtil.showConfirmDialog({ title: '下载失败', message: `${err.message}`})
      console.error(`Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`);
    }
  }
}

const fileDownload = new FileDownloadUtils()
export default fileDownload as FileDownloadUtils
