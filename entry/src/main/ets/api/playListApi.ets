import { LogUtil } from "@pura/harmony-utils"
import Constants from "../common/constants/Constants"
import { playList } from "../common/entities/PlayList"
import { PlayListSongs } from "../common/entities/PlayListSongs"
import { Song } from "../common/entities/SongsResult"
import { User, UserClass } from "../common/entities/User"
import { getApiUrl } from "../common/functions/functions"
import { HttpRequest } from "../common/utils/HttpRequestUtils"
import PreferencesUtils from "../common/utils/PreferencesUtils"

/**
 * 歌单类API
 */

const TAG = '[playListApi] '

/**
 * 获取歌单列表
 * @param usingCache 是否缓存
 * @returns list
 */
export interface PlayListsResult {
  more:boolean
  playlist:playList[]
}

export async function getPlayLists(offset:number): Promise<PlayListsResult> {
  let list:Array<playList> = new Array()
  let hasMore:boolean = false
  const user = await PreferencesUtils.getPreferenceValue<User>(Constants.USER_PREF,'user',UserClass)
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/user/playlist?uid=${user.data.account.id}&limit=10&offset=${offset}`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot:PlayListsResult = data.result as PlayListsResult
    LogUtil.info('dataGot: ' + JSON.stringify(dataGot))
    hasMore = dataGot.more
    for(let item of dataGot.playlist) {
      list.push({
        coverImgUrl: item.coverImgUrl,
        name: item.name,
        id: item.id,
        playCount: item.playCount,
        subscribedCount: item.subscribedCount,
        userId: item.userId,
        trackCount: item.trackCount
      })
    }
  })

  const result: PlayListsResult = {
    more: hasMore,
    playlist: list
  }
  return result
}

/**
 * 获取歌单内歌曲列表
 * @param listId 歌单ID
 * @param trackCount 歌曲总数
 * @param offset 偏移
 * @returns list 歌曲列表
 */
export async function getPlayListSongs(listId:number, offset:number): Promise<Array<Song>> {
  let list:Array<Song> = new Array()
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/playlist/track/all?id=${listId}&limit=30&offset=${offset}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:PlayListSongs = data.result as PlayListSongs
    for(let song of dataGot.songs) {
      list.push({
        id: song.id ,
        name: song.name,
        artists: song.ar,
        duration: song.dt,
      })
    }
  })
  console.log('getPlayListSongs: ' + JSON.stringify(list))
  return list;
}