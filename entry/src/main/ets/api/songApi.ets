import { LogUtil } from "@pura/harmony-utils"
import { DailyListSongs } from "../common/entities/PlayListSongs"
import { SongDetail } from "../common/entities/SongDetail"
import { QualityType } from "../common/entities/SongDownload"
import { SongPlay } from "../common/entities/SongPlay"
import { Song, SongsData } from "../common/entities/SongsResult"
import { getApiUrl, isUsePubCookie } from "../common/functions/commonFunction"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import { DailySongRes } from "./playListApi"

const TAG = '[Song API - songApi] '

export interface SearchReturn {
  list: Array<Song>
  hasMore: boolean
  songCount: number
}
/**
 * 搜素歌曲列表
 * @param searchKeyword 搜索词
 * @returns SearchReturn
 */
export async function searchSongs(searchKeyword:string, offset:number): Promise<SearchReturn> {
  let list:Array<Song> = new Array()
  let hasMore:boolean = false
  let songCount:number = 0

  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/search?keywords=${encodeURIComponent(searchKeyword)}&limit=30&offset=${offset}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:SongsData = data.result as SongsData
    hasMore = dataGot.result.hasMore
    songCount = dataGot.result.songCount
    for(let song of dataGot.result.songs) {
      list.push({
        id: song.id,
        name: song.name,
        artists: song.artists,
        duration: song.duration,
        alias: song.alias
      })
    }
  })
  let searchReturn:SearchReturn = {
    list: list,
    hasMore: hasMore,
    songCount: songCount
  }

  return searchReturn;
}

/**
 * 获取歌曲播放Url
 */
export async function getSongUrl(songId: number, quality:QualityType, isLogged:boolean): Promise<SongPlay> {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/song/url/v1?id=${songId}&level=${quality}`
  let usePubCookie:boolean = false
  if(isLogged) { usePubCookie = await isUsePubCookie() }
  const request = new HttpRequest(url)
  try {
    const data = usePubCookie ? await request.RequestWithVipType() : await request.Request()
    LogUtil.info(TAG + JSON.stringify(data.result))
    if(data.result["code"] == 200) {
      const dataGot: SongPlay = data.result as SongPlay
      return dataGot
    } else {
      LogUtil.info(TAG + 'code: ' + data.result["code"])
      throw new Error(`${data.result["code"]} - ${data.result["message"]}`)
    }
  } catch (e) {
    LogUtil.error(TAG + '获取播放url失败: ' + e)
    throw new Error(e)
  }
}

/**
 * 获取歌曲图片Url
 * @param song 歌曲类
 * @returns string 歌曲Url
 */
export async function getSongPicUrl(song: Song): Promise<string> {
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/song/detail?ids=${song.id}`
  const request = new HttpRequest(url)
  try {
    const data = await request.Request()
    const dataGot: SongDetail = data.result as SongDetail
    const songPicUrl = dataGot.songs[0].al.picUrl
    return songPicUrl
  } catch (e) {
    LogUtil.error(TAG + 'Error fetching song picUrl:', JSON.stringify(e))
    throw new Error(e)
  }
}

/**
 * 获取每日推荐歌单
 * @param useCookie
 * @returns
 */
export async function getDailySongs(useCookie: boolean = true): Promise<Array<DailySongRes>> {
  let list:Array<DailySongRes> = []
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/recommend/songs`
  const request = new HttpRequest(url)
  await request.RequestInStream(useCookie).then((data) => {
    const dataGot: DailyListSongs = data.result as DailyListSongs
    if(dataGot.data) {
      for (let song of dataGot.data.dailySongs) {
        list.push({
          song: {
            id: song.id,
            name: song.name,
            artists: song.ar,
            duration: song.dt,
            alias: []
          },
          reason: song.reason
        })
      }
    }
  })
  return list
}

/**
 * 获取喜欢列表(songId 数组)
 * @param uid
 * @returns
 */
export async function getLikeList(uid: number): Promise<string[]> {
  let list:Array<string> = []
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/likelist?uid=${uid}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:string[] = data.result['ids'] as string[]
    list = dataGot
  })
  return list
}

/**
 * 喜欢歌曲
 * @param songId
 * @returns
 */
export async function likeMusic(sid: number): Promise<boolean> {
  let code = -1
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/like?id=${sid}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    code = data.result['code'] as number
  })
  return code == 200 ? true : false
}