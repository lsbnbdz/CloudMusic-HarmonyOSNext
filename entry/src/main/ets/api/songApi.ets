import { LogUtil } from "@pura/harmony-utils"
import { SongDetail } from "../common/entities/SongDetail"
import { QualityType } from "../common/entities/SongDownload"
import { SongPlay } from "../common/entities/SongPlay"
import { Song, SongClass, SongsData } from "../common/entities/SongsResult"
import { getApiUrl, isUsePubCookie } from "../common/functions/functions"
import { HttpRequest } from "../common/utils/HttpRequestUtils"

const TAG = '[Song API - songApi] '
/**
 * 搜素歌曲列表
 * @param searchKeyword 搜索词
 * @returns SearchReturn
 */
export interface SearchReturn {
  list: Array<Song>
  hasMore: boolean
  songCount: number
}

export async function getSongsList(searchKeyword:string, offset:number): Promise<SearchReturn> {
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
 * 根据文件名，搜索歌曲信息，返回结果数组的第一个信息
 * @param searchName
 */
export async function getSongInfo(searchName: string): Promise<Song> {
  let song:Song = SongClass
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/search?keywords=${encodeURIComponent(searchName)}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:SongsData = data.result as SongsData
    song = dataGot.result.songs[0]
  })
  return song
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
  const url: string = `${rootUrl}/song/detail?ids=${song.id}`;
  const request = new HttpRequest(url);
  try {
    const data = await request.Request();
    const dataGot: SongDetail = data.result as SongDetail;
    const songPicUrl = dataGot.songs[0].al.picUrl;
    return songPicUrl;
  } catch (e) {
    LogUtil.error(TAG + 'Error fetching song picUrl:', JSON.stringify(e));
    throw new Error(e)
  }
}