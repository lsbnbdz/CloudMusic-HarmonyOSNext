import { QualityType, SongDownload } from "../common/entities/SongDownload"
import { HttpRequest } from "../common/utils/HttpRequestUtils"
import { LogUtil } from "@pura/harmony-utils"
import { getApiUrl, isUsePubCookie } from "../common/functions/functions"

/**
 * 获取音乐下载地址
 * @param songId 歌曲ID
 * @param quality 音质
 * @param isLogged 是否登录
 * @returns data:SongDownload
 */
export async function getDownloadInfo(songId: number, quality:QualityType, isLogged:boolean): Promise<SongDownload> {
  const rootUrl = await getApiUrl()
  const url:string = isLogged ? `${rootUrl}/song/download/url/v1?id=${songId}&level=${quality}` :
    `${rootUrl}/song/url?id=${songId}`
  const request = new HttpRequest(url)
  try {
    let usePubCookie:boolean = await isUsePubCookie()
    const data = usePubCookie ? await request.RequestWithVipType() : await request.Request()
    const dataGot: SongDownload = isLogged ? data.result as SongDownload :
      { data: data.result["data"][0] }
    return dataGot
  } catch (e) {
    LogUtil.error('Error fetching download info: ' + JSON.stringify(e))
    throw new Error('获取下载链接失败')
  }
}