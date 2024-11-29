import Constants from "../common/constants/Constants"
import { QualityType, SongDownload } from "../common/entities/SongDownload"
import { HttpRequest } from "../common/utils/HttpRequestUtil"
import { LogUtil } from "@pura/harmony-utils"

export async function getDownloadInfo(songId: number, quality:QualityType, isLogged:boolean): Promise<SongDownload> {
  const url:string = isLogged ? `${Constants.ROOT_URL}/song/download/url/v1?id=${songId}&level=${quality}` :
    `${Constants.ROOT_URL}/song/url?id=${songId}`
  const request = new HttpRequest(url)
  try {
    const data = await request.RequestWithVipType();
    const dataGot: SongDownload = isLogged ? data.result as SongDownload :
      { data: data.result["data"][0] }
    return dataGot
  } catch (e) {
    LogUtil.error('Error fetching download info: ' + JSON.stringify(e))
    throw new Error('获取下载链接失败')
  }
}