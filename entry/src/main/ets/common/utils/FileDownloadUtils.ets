import { common } from '@kit.AbilityKit'
import { BusinessError, request } from '@kit.BasicServicesKit'
import { SongDownload } from '../entities/SongDownload'
import { Song } from '../entities/SongsResult'
import { DialogUtil, FileUtil, LogUtil, ToastUtil } from '@pura/harmony-utils'
import { promptAction } from '@kit.ArkUI'
import { changeb2Mb, sanitizeFileName } from '../functions/functions'
import FileUtils from './FileUtils'

/**
 * 文件下载
 */

const TAG = '[FileDownload] '

class FileDownloadUtils {
  context = getContext(this) as common.UIAbilityContext
  filesDir = this.context.filesDir
  cacheDir = this.context.cacheDir

  async download(songDownload:SongDownload, song:Song, artists:string) {
    let fileName = sanitizeFileName(`${artists} - ${song.name}.${songDownload.data.type}`)
    let cachePath = this.cacheDir + `/${fileName}`
    let descPath = this.filesDir + `/${fileName}`
    if(await FileUtil.access(descPath)) {
      DialogUtil.showConfirmDialog({ title:'提示', message:'文件已存在'})
      return
    }
    else {
      try {
        request.downloadFile(this.context, {
          url: songDownload.data.url,
          filePath: cachePath
        }).then(async (downloadTask: request.DownloadTask) => {
          downloadTask.on('progress', async (received, total) => {
            promptAction.showToast({ message: `下载中: ${changeb2Mb(received)} / ${changeb2Mb(total)} MB` })
          })
          downloadTask.on('complete', () => {
            FileUtils.moveFile(cachePath, descPath).then(() => {
              DialogUtil.showConfirmDialog({
                title: '下载完成',
                message: `${artists} - ${song.name}.${songDownload.data.type}`
              })
              promptAction.showToast({ message: `下载完成: ${song.name}` })
              LogUtil.info(TAG + '下载完成: ' + `${artists} - ${song.name}.${songDownload.data.type}`)
            })
          })
        }).catch((err: BusinessError) => {
          ToastUtil.showToast('下载出错: ' + err.message)
          LogUtil.error(TAG + `下载出错: ${JSON.stringify(err)}`)
          FileUtils.deleteFile(`${artists} - ${song.name}.${songDownload.data.type}`)
        });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        if (err.code == 13400002) {
          DialogUtil.showConfirmDialog({ title: '提示', message: `文件已存在` })
        } else {
          DialogUtil.showConfirmDialog({ title: '下载失败', message: `${err.message}` })
        }
        console.error(`Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`);
      }
    }
  }
}

const fileDownload = new FileDownloadUtils()
export default fileDownload as FileDownloadUtils
