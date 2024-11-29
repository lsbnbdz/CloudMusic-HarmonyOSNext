import Constants from "../common/constants/Constants"
import { HttpRequest } from "../common/utils/HttpRequestUtil"
import { LogUtil } from "@pura/harmony-utils"
import { SongPlay } from "../common/entities/SongPlay"

const TAG = '[getSongUrl] '
export async function getSongUrl(songId: number): Promise<SongPlay> {
  const url:string = `${Constants.ROOT_URL}/song/url/v1?id=${songId}&level=standard`
  const request = new HttpRequest(url)
  try {
    const data = await request.Request();
    LogUtil.info(TAG + JSON.stringify(data.result))
    const dataGot: SongPlay = data.result as SongPlay
    return dataGot
  } catch (e) {
    LogUtil.error('获取播放url失败: ' + JSON.stringify(e))
    throw new Error('获取播放Url失败')
  }
}