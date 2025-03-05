import { QualityType, SongDownload } from "../common/entities/SongDownload"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import { LogUtil } from "@pura/harmony-utils"
import { getApiUrl } from "../common/functions/common/get"

/**
 * 获取音乐地址
 * @param songId 歌曲ID
 * @param quality 音质
 * @param isLogged 是否登录
 * @returns data:SongDownload
 */
export async function getDownloadInfo(songId: number, quality:QualityType, isLogged:boolean): Promise<SongDownload> {
  const rootUrl = await getApiUrl()
  const url: string = isLogged ?
    `${rootUrl}/song/url/v1?id=${songId}&level=${quality}` :
    `${rootUrl}/song/url?id=${songId}`
  const request = new HttpRequest(url)
  try {
    const data = await request.Request()
    const dataGot: SongDownload = isLogged ? data.result as SongDownload :
      { data: data.result["data"] }
    return dataGot
  } catch (e) {
    LogUtil.error('Error fetching download info: ' + JSON.stringify(e))
    throw new Error('获取歌曲链接失败')
  }
}