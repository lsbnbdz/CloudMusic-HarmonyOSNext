import { common } from '@kit.AbilityKit'
import fileIo from '@ohos.file.fs'
import {  FileUtil, LogUtil, ToastUtil } from '@pura/harmony-utils'
import fs from '@ohos.file.fs'
import fileUri from '@ohos.file.fileuri'
import { picker } from '@kit.CoreFileKit'

/**
 * 文件管理
 */

const TAG = '[FileUtils] '

class FileUtils {
  context = getContext(this) as common.UIAbilityContext
  filesDir = this.context.filesDir

  async getFileName(): Promise<Array<string>> {
    let list = await fileIo.listFile(this.filesDir)
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
}

const fileUtils = new FileUtils()
export default fileUtils as FileUtils