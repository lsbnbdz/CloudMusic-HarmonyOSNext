import { EmitterUtil, LogUtil } from "@pura/harmony-utils";
import Constants from "../common/constants/Constants";
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
 * @returns - string[]
 */
export async function getLyric(songId: number): Promise<string[]> {
  let lyricArr:string[] = []
  let lyric:string = ''
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/lyric?id=${songId}`
  const request = new HttpRequest(url)
  await request.Request(false).then((data) => { // 不需要传入 cookie
    const dataGot:LyricResult = data.result as LyricResult
    if(dataGot.code == 200) {
      lyric = dataGot.lrc.lyric
    }
  })
  lyricArr = lyric.split('\n')
  return lyricArr
}

export async function setLyric(songId: number) {
  let lyricArr = await getLyric(songId)
  AppStorage.setOrCreate('player-lyric',lyricArr)
  EmitterUtil.post(Constants.EMITTER_LYRIC_UPDATE,'Lyric Updated')
}