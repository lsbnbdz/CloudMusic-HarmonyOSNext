import { common } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { buffer } from '@kit.ArkTS';

/**
 * DownloadUtils 封装文件下载和内容读取的功能
 */
export class DownloadUtils {
  /**
   * 下载文件到指定路径，并读取文件内容
   * @param context 应用上下文
   * @param url 文件的下载链接
   * @param fileName 文件保存的名称
   * @returns 返回文件内容的 Promise
   */
  static async downloadFile(context: common.UIAbilityContext, url: string, fileName: string): Promise<string> {
    let filesDir = context.filesDir;
    let filePath = `${filesDir}/${fileName}`;

    return new Promise((resolve, reject) => {
      try {
        request
          .downloadFile(context, {
            url,
            filePath,
          })
          .then((downloadTask: request.DownloadTask) => {
            downloadTask.on('complete', () => {
              console.info(`Download complete: ${filePath}`);
              try {
                let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE);
                let arrayBuffer = new ArrayBuffer(1024);
                let readLen = fs.readSync(file.fd, arrayBuffer);
                let buf = buffer.from(arrayBuffer, 0, readLen);
                fs.closeSync(file);
                resolve(buf.toString());
              } catch (fileError) {
                console.error(`Error reading file: ${fileError.message}`);
                reject(fileError);
              }
            });
          })
          .catch((err: BusinessError) => {
            console.error(
              `Invoke downloadTask failed, code: ${err.code}, message: ${err.message}`
            );
            reject(err);
          });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        console.error(
          `Invoke downloadFile failed, code: ${err.code}, message: ${err.message}`
        );
        reject(err);
      }
    });
  }
}
