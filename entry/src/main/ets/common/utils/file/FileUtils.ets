import { common } from '@kit.AbilityKit'
import fileIo from '@ohos.file.fs'
import {  FileUtil, LogUtil, PreviewUtil, ToastUtil } from '@pura/harmony-utils'
import fs from '@ohos.file.fs'
import { fileUri } from '@kit.CoreFileKit'
import { picker } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit'

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

  /**
   * 是否存在本地文件
   * @param fileName
   * @returns string - fdPath
   */
  async accessLocalFile(fileName: string): Promise<string> {
    const fileType: Array<string> = ['flac', 'FLAC', 'mp3', 'MP3']
    for(let type of fileType) {
      let filePath = this.filesDir + `/${fileName}.${type}`
      if(await(FileUtil.access(filePath))) {
        let file = await fileIo.open(filePath)
        let fdPath = 'fd://' + file.fd
        return fdPath
      }
    }
    return ''
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

  async removeCache(): Promise<boolean> {
    try {
      await FileUtil.rmdir(this.cacheDir)
      return true
    } catch (e) {
      LogUtil.error(TAG + e.message())
      ToastUtil.showToast('清除缓存失败')
    }
    return false
  }

  getCacheSize(): number {
    try {
      let size = FileUtil.getFileDirSize(this.cacheDir)
      return size
    } catch (e) {
      LogUtil.error(TAG + '获取缓存大小失败: ' + e.message())
      return -1
    }
  }

  async saveFilesToDirectory(uris: string[]): Promise<boolean> {
    let result: boolean = false
    try {
      for (const uri of uris) {
        let fileUriObject = new fileUri.FileUri(uri)
        let file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        let file2 = fs.openSync(this.filesDir + `/${fileUriObject.name}`, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        fs.copyFileSync(file.fd, file2.fd)
        fs.closeSync(file)
        fs.closeSync(file2)
        result = true
      }
    } catch (e) {
      ToastUtil.showToast('上传失败')
    } finally {
      return result
    }
  }
}

const fileUtils = new FileUtils()
export default fileUtils as FileUtils