import { HttpRequest } from "../common/utils/HttpRequestUtil"
import { LogUtil } from "@pura/harmony-utils"
import { SongPlay } from "../common/entities/SongPlay"
import { getApiUrl } from "../common/functions/functions"

/**
 * 获取歌曲Url（播放Url）
 */
const TAG = '[getSongUrl] '
export async function getSongUrl(songId: number): Promise<SongPlay> {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/song/url/v1?id=${songId}&level=standard`
  const request = new HttpRequest(url)
  try {
    const data = await request.RequestWithVipType();
    LogUtil.info(TAG + JSON.stringify(data.result))
    const dataGot: SongPlay = data.result as SongPlay
    return dataGot
  } catch (e) {
    LogUtil.error('获取播放url失败: ' + JSON.stringify(e))
    throw new Error('获取播放Url失败')
  }
}