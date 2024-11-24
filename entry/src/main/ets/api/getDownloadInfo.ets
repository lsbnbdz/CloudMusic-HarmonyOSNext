import Constants from "../common/constants/Constants"
import { QualityType, SongDownload, SongDownloadClass } from "../common/entities/SongDownload"
import { HttpRequest } from "../common/utils/HttpRequestUtil"
import { promptAction } from "@kit.ArkUI"

export async function getDownloadInfo(songId: number, quality:QualityType): Promise<SongDownload> {
  const url:string = `${Constants.ROOT_URL}/song/download/url/v1?id=${songId}&level=${quality}`
  const request = new HttpRequest(url)
  try {
    const data = await request.Request();
    const dataGot: SongDownload = data.result as SongDownload;
    return dataGot
  } catch (e) {
    console.error('Error fetching download info: ' + JSON.stringify(e))
    promptAction.showToast({ message: `获取下载信息失败: + ${e.message}`, duration:5000 })
    return SongDownloadClass
  }
}