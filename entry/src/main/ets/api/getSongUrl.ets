import { HttpRequest } from "../common/utils/HttpRequestUtil"
import { LogUtil } from "@pura/harmony-utils"
import { SongPlay } from "../common/entities/SongPlay"
import { getApiUrl, isUsePubCookie } from "../common/functions/functions"
import { QualityType } from "../common/entities/SongDownload"

/**
 * 获取歌曲播放Url
 */
const TAG = '[getSongUrl] '

export async function getSongUrl(songId: number, quality:QualityType, isLogged:boolean): Promise<SongPlay> {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/song/url/v1?id=${songId}&level=${quality}`
  let usePubCookie:boolean = false
  if(isLogged) { usePubCookie = await isUsePubCookie() }
  const request = new HttpRequest(url)
  try {
    const data = usePubCookie ? await request.RequestWithVipType() : await request.Request()
    LogUtil.info(TAG + JSON.stringify(data.result))
    const dataGot: SongPlay = data.result as SongPlay
    return dataGot
  } catch (e) {
    LogUtil.error(TAG + '获取播放url失败: ' + JSON.stringify(e))
    throw new Error(TAG + '获取播放Url失败')
  }
}