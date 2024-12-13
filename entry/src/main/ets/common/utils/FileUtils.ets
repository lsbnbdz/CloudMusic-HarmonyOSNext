import { common } from '@kit.AbilityKit'
import fileIo from '@ohos.file.fs'
import {  FileUtil, LogUtil, PreviewUtil, ToastUtil } from '@pura/harmony-utils'
import fs from '@ohos.file.fs'
import fileUri from '@ohos.file.fileuri'
import { picker } from '@kit.CoreFileKit'
import File from '@system.file'
import { media } from '@kit.MediaKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { sanitizeFileName } from '../functions/functions'

/**
 * 文件管理
 */

const TAG = '[FileUtils] '

class FileUtils {
  context = getContext(this) as common.UIAbilityContext
  filesDir = this.context.filesDir
  cacheDir = this.context.cacheDir

  async getFilesDir() {
    return this.filesDir
  }

  async getFileName(): Promise<Array<string>> {
    let list = await fileIo.listFile(this.filesDir)
    return list
  }

  async accessLocalFile(fileName: string): Promise<string> {
    const fileUrl_flac = this.filesDir + `/${fileName}.flac`
    const fileUrl_mp3 = this.filesDir + `/${fileName}.mp3`

    if(await FileUtil.access(fileUrl_flac)) {
      let file = await fileIo.open(fileUrl_flac)
      let fdPath = 'fd://' + file.fd
      return fdPath
    } else if(await FileUtil.access(fileUrl_mp3)) {
      let file = await fileIo.open(fileUrl_mp3)
      let fdPath = 'fd://' + file.fd
      return fdPath
    } else {
      return ''
    }
  }

  async getCacheName(): Promise<Array<string>> {
    let list = await fileIo.listFile((this.cacheDir))
    return list
  }

  async getFileStat() {
    let list = await this.getFileName()
    let result = await fileIo.stat(this.filesDir + `/${list[0]}`)
    return result
  }

  async deleteFile(fileName:string) {
    try {
      await FileUtil.unlink(this.filesDir + `/${fileName}`)
      LogUtil.info(TAG + `成功删除文件: ${fileName}`)
      ToastUtil.showToast(`成功删除文件: ${fileName}`)
    } catch (e) {
      LogUtil.error(TAG + `Delete file error: ${JSON.stringify(e)}`)
    }
  }

  async getFileUri(fileName:string): Promise<fileUri.FileUri | null> {
    try {
      let uri = FileUtil.getFileUri(this.filesDir + `/${fileName}`)
      return uri
    } catch (e) {
      LogUtil.error(TAG + '获取文件Uri失败: ' + e.message())
      return null
    }
  }

  async moveFile(from:string, to:string) {
    try {
      FileUtil.moveFile(from, to).then(() => {
        LogUtil.info(TAG + '成功移动文件')
      })
    } catch (e) {
      LogUtil.error(TAG + '移动文件时出错 move file error: ' + e.message())
    }
  }

  async saveFile(fileName:string) {
    try {
      let thisFilePath = this.filesDir + `/${fileName}`
      let saveOption = new picker.DocumentSaveOptions()
      saveOption.newFileNames = [fileName]
      let filePicker = new picker.DocumentViewPicker()
      filePicker.save(saveOption).then((uris) => {
        let uri = uris[0]
        let descFile = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        fs.copyFile(thisFilePath, descFile.fd).then(() => {
          fs.closeSync(descFile.fd)
          ToastUtil.showToast('保存文件成功')
        }).catch((err: Error) => {
          LogUtil.error(TAG + '拷贝文件失败: ' + err.message)
        }).catch((err: Error) => {
          LogUtil.error(TAG + 'File Picker 出错: ' + err.message)
        })
      })
    } catch (e) {
      LogUtil.error(TAG + '保存文件出错: ' + e.message())
    }
  }

  async previewFile(fileName: string) {
    let uri = FileUtil.getUriFromPath(this.filesDir + `/${fileName}`)
    let info = PreviewUtil.generatePreviewInfo(uri)
    PreviewUtil.openPreview(info).catch((error: BusinessError) => {
      LogUtil.error(TAG + 'preview file error: ' + error.message)
    })

  }

  async removeCache() {
    try {
      await FileUtil.rmdir(this.cacheDir).then(() => {
        ToastUtil.showToast('清除缓存成功')
      })
    } catch (e) {
      LogUtil.error(TAG + '清除缓存 remove cache 失败: ' + e.message())
      ToastUtil.showToast('清除缓存失败')
    }
  }

}

const fileUtils = new FileUtils()
export default fileUtils as FileUtils