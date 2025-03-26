import { LyricResult, LyricResultClass } from "../common/entities/Lyric";
import { HttpRequest } from "../common/utils/request/HttpRequestUtils";
import LyricUtils from "../common/utils/play/LyricUtils";
import { getApiUrl } from "../common/functions/common/get";
import { LogUtil } from "@pura/harmony-utils";

/**
 * 歌词类API
 */
const TAG = '[LyricApi] '

/**
 * 获取歌词
 * @param songId - 歌曲id
 * @returns - string[]
 */
export async function getLyric(songId: number): Promise<LyricResult> {
  let result = LyricResultClass
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/lyric?id=${songId}`
  const request = new HttpRequest(url)
  await request.Request(false).then((data) => { // 不需要传入 cookie
    const dataGot: LyricResult = data.result as LyricResult
    if(dataGot.code == 200) {
      result.lrc = dataGot.lrc
      if(dataGot.tlyric) result.tlyric = dataGot.tlyric
      if(dataGot.romalrc) result.romalrc = dataGot.romalrc
      if(dataGot.klyric) result.klyric = dataGot.klyric
    }
  })
  return result
}

/**
 * 获取歌词完整string
 * @param songId
 * @return
 */
export async function getLyricString(songId: number): Promise<string> {
  let lyric: string = ''
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/lyric?id=${songId}`
  const request = new HttpRequest(url)
  const data = await request.Request(false)
  const dataGot = data.result as LyricResult
  if(dataGot.code == 200) {
    lyric = dataGot.lrc.lyric
  } else {
    lyric = '[00:00:00] 暂无歌词'
  }
  return lyric
}