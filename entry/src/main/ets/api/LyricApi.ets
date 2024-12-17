import { LogUtil } from "@pura/harmony-utils";
import { LyricResult } from "../common/entities/Lyric";
import { getApiUrl } from "../common/functions/functions";
import { HttpRequest } from "../common/utils/HttpRequestUtils";

/**
 * 歌词类API
 */
const TAG = '[LyricApi] '

/**
 * 获取歌词
 * @param songId - 歌曲id
 * @returns - string 歌词字符串
 */
export async function getLyric(songId: number): Promise<string> {
  const rootUrl = getApiUrl()
  const url = `${rootUrl}/lyric?id=${songId}`
  const request = new HttpRequest(url)
  await request.Request(false).then((data) => { // 不需要传入 cookie
    const dataGot:LyricResult = data.result as LyricResult
    LogUtil.info(TAG + 'dataGot: ' + JSON.stringify(dataGot))
    if(dataGot.code == 200) {
      return dataGot.lrc.lyric
    }
    else return ''
  })
  return ''
}