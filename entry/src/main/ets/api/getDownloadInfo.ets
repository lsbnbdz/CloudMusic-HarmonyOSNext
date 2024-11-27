import Constants from "../common/constants/Constants"
import { QualityType, SongDownload, SongDownloadClass } from "../common/entities/SongDownload"
import { HttpRequest } from "../common/utils/HttpRequestUtil"
import { promptAction } from "@kit.ArkUI"

export async function getDownloadInfo(songId: number, quality:QualityType, isLogged:boolean): Promise<SongDownload> {
  const url:string = isLogged ? `${Constants.ROOT_URL}/song/download/url/v1?id=${songId}&level=${quality}` :
    `${Constants.ROOT_URL}/song/url?id=${songId}`
  const request = new HttpRequest(url)
  try {
    const data = await request.Request();
    const dataGot: SongDownload = isLogged ? data.result as SongDownload :
      { data: data.result["data"][0] }
    return dataGot
  } catch (e) {
    console.error('Error fetching download info: ' + JSON.stringify(e))
    promptAction.showToast({ message: `获取下载信息失败: + ${e.message}`, duration:5000 })
    return SongDownloadClass
  }
}