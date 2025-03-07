import { common } from '@kit.AbilityKit'
import fileIo from '@ohos.file.fs'
import {  FileUtil, LogUtil, PreviewUtil, ToastUtil } from '@pura/harmony-utils'
import fs from '@ohos.file.fs'
import { Environment, fileUri } from '@kit.CoreFileKit'
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

  async deleteFile(fileNames: string[]) {
    try {
      let successCount = 0
      for (const fileName of fileNames) {
        try {
          await FileUtil.unlink(this.filesDir + `/${fileName}`)
          successCount++
        } catch (e) {
          LogUtil.error(TAG + `删除文件 ${fileName} 失败: ${JSON.stringify(e)}`)
        }
      }
      ToastUtil.showToast(`成功删除 ${successCount}/${fileNames.length} 个文件`)
    } catch (e) {
      LogUtil.error(TAG + `Delete files error: ${JSON.stringify(e)}`)
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
      FileUtil.moveFile(from, to)
    } catch (e) {
      LogUtil.error(TAG + '移动文件时出错 move file error: ' + e.message())
    }
  }

  async saveFile(fileNames: string[]) {
    try {
      let filePicker = new picker.DocumentViewPicker()
      let saveOption = new picker.DocumentSaveOptions()
      saveOption.newFileNames = fileNames

      filePicker.save(saveOption).then((uris) => {
        uris.forEach(async (uri, index) => {
          try {
            let srcPath = this.filesDir + `/${fileNames[index]}`
            let descFile = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
            await fs.copyFile(srcPath, descFile.fd)
            fs.closeSync(descFile.fd)
          } catch (err) {
            LogUtil.error(TAG + `文件 ${fileNames[index]} 保存失败: ${err.message}`)
          }
        })
        ToastUtil.showToast(`成功保存 ${uris.length} 个文件`)
      }).catch((err: Error) => {
        LogUtil.error(TAG + 'File Picker 出错: ' + err.message)
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

  async saveFilesToDirectory(uris: string[]) {
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

  getUserDir() {
    let dir: string = ''
    try {
      if (canIUse('SystemCapability.FileManagement.File.Environment.FolderObtain')) {
        dir = Environment.getUserDownloadDir()
      } else {
        dir = this.context.filesDir
      }
    } catch (e) {
      ToastUtil.showToast('获取公共目录失败: ' + e.message)
    } finally {
      return dir
    }
  }
}

const fileUtils = new FileUtils()
export default fileUtils as FileUtils