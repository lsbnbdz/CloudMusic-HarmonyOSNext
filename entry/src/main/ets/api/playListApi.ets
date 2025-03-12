import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayList, PlayListOperationRes, PlayListSearchResult } from "../common/entities/PlayList"
import { CloudSongs, DailyListSongs, PlayListSongItem, PlayListSongs } from "../common/entities/PlayListSongs"
import { PlayQueue } from "../common/entities/PlayQueue"
import { Artist, Song } from "../common/entities/SongsResult"
import { User, UserClass } from "../common/entities/User"
import { getArtists } from "../common/functions/common/convert"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import PlayQueueUtils from "../common/utils/play/PlayQueueUtils"
import PreferencesUtils from "../common/utils/data/PreferencesUtils"
import { StorageConstants } from "../common/constants/StorageConstants"
import { Personalized, PersonalListItem } from "../common/entities/Personalized"
import { getApiUrl } from "../common/functions/common/get"
import { JSON } from "@kit.ArkTS"

/**
 * 歌单类API
 */
const TAG = '[playListApi] '

/**
 * 歌单列表返回类
 */
export interface PlayListsResult {
  more:boolean
  playlist:PlayList[]
}
/**
 * 获取用户歌单列表
 * @param offset - 偏移量
 * @returns list
 */
export async function getPlayLists(offset:number): Promise<PlayListsResult> {
  let list:Array<PlayList> = new Array()
  let hasMore:boolean = false
  const user = await PreferencesUtils.getPreferenceValue<User>(StorageConstants.USER_PREF,'user',UserClass)
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/user/playlist?uid=${user.data.account.id}&limit=10&offset=${offset}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot:PlayListsResult = data.result as PlayListsResult
    hasMore = dataGot.more
    list = dataGot.playlist
    AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, list)
    PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, list)
  })

  const result: PlayListsResult = {
    more: hasMore,
    playlist: list
  }
  return result
}

class SongC {
  id: number
  name: string
  artists: Artist[]
  duration: number
  alias: string[]

  constructor(id: number, name: string, artists: Artist[], duration: number, alias: string[]) {
    this.id = id
    this.name = name
    this.artists = artists
    this.duration = duration
    this.alias = alias
  }
}

/**
 * 获取歌单内歌曲列表
 * @param listId 歌单ID
 * @param trackCount 歌曲总数
 * @param offset 偏移
 * @returns list 歌曲列表
 */
export async function getPlayListSongs(listId: number, trackCount: number, offset: number, timestamp: boolean = true): Promise<Array<PlayListSongItem>> {
  let list: PlayListSongItem[] = []
  const rootUrl = await getApiUrl()
  const suffix = timestamp ? `&timestamp=${new Date().getTime()}` : ''
  const url:string = `${rootUrl}/playlist/track/all?id=${listId}&limit=100&offset=${offset}${suffix}`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot: PlayListSongs = data.result as PlayListSongs
    list = dataGot.songs
  })
  return list
}

/**
 * 将歌单歌曲添加至播放列表
 * @param listId - 歌单ID
 * @param trackCount - 歌单歌曲总数
 * @returns void
 */
export async function putPlayListInQueue(listId: number, trackCount: number, limit: number, offset: number = 0, first: boolean = true): Promise<void> {
  const rootUrl = await getApiUrl()
  let tempQueue:Array<PlayQueue> = []
  while(offset < trackCount) {
    const url: string = `${rootUrl}/playlist/track/all?id=${listId}&limit=${limit}&offset=${offset}&timestamp=${new Date().getTime()}`
    const request = new HttpRequest(url)
    let data = await request.RequestInStream()
    let dataResult: PlayListSongs = data.result as PlayListSongs
    for (let item of dataResult.songs) {
      let artists = await getArtists(item.ar)
      tempQueue.push({
        playmode: 1,
        song: {
          id: item.id,
          name: item.name,
          artists: item.ar,
          duration: item.dt,
          alias: [],
          fee: item.fee
        },
        artists: artists,
        fileName: '',
        picUrl: item.al.picUrl ?? $r('app.media.ic_public_music')
      })
    }
    if(first) {
      await PlayQueueUtils.cleanQueue()
      first = false
    }
    await PlayQueueUtils.queueAdd_array(tempQueue)
    tempQueue = []
    offset += limit
  }
}

/**
 * 播放每日推荐歌单
 * @param list:Array<Songs>
 * @returns
 */
export async function PlayDailySongs(): Promise<void> {
  let queue:Array<PlayQueue> = []
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/recommend/songs`
  const request = new HttpRequest(url)
  await request.RequestInStream().then(async (data) => {
    const dataGot: DailyListSongs = data.result as DailyListSongs
    for (let item of dataGot.data.dailySongs) {
      let artists = await getArtists(item.ar)
      let tempSong: Song = {
        id: item.id,
        name: item.name,
        artists: item.ar,
        duration: item.dt,
        alias: [],
        fee: item.fee
      }
      queue.push({
        playmode: 1,
        song: tempSong,
        artists: artists,
        fileName: '',
        picUrl: item.al?.picUrl ?? $r('app.media.ic_public_music')
      })
    }
  })
  await PlayQueueUtils.cleanQueue()
  await PlayQueueUtils.queueAdd_array(queue)
}

/**
 * 歌单操作
 */
type OperationType = 'add' | 'del'
/**
 * 向歌单添加/删除歌曲
 * @param op - 操作 add/del
 * @param pid - 歌单id
 * @param tracks - 歌曲id(多个用,隔开)
 */
export async function PlayListOperation(op:OperationType, pid:number, tracks:number): Promise<boolean> {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/playlist/tracks?op=${op}&pid=${pid}&tracks=${tracks}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  return request.Request().then((data) => {
    const dataGot: PlayListOperationRes = data.result as PlayListOperationRes
    LogUtil.info(TAG + 'data result: ' + JSON.stringify(data.result))
    if(dataGot.body.code === 200) {
      return true
    }
    else {
      LogUtil.error(TAG + `Error code: ${dataGot.body.code}, Message: ${dataGot.body.message}`)
      ToastUtil.showToast(`${dataGot.body.message}`)
      return false
    }
  }).catch((err: Error) => {
    LogUtil.error(TAG + 'Operation failed: ' + err.message)
    return false
  })
}


export interface DailySongRes {
  song: Song
  reason: string
  picUrl: string
}

/**
 * 获取云盘歌曲列表
 * @param offset 偏移
 * @returns list 歌曲列表
 */
export async function getCloudList(offset: number): Promise<Array<PlayListSongItem>> {
  let list:Array<PlayListSongItem> = new Array()
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/user/cloud?limit=50&offset=${offset}`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot:CloudSongs = data.result as CloudSongs
    for(let item of dataGot.data) {
      list.push(item.simpleSong)
    }
  })
  return list
}

/**
 * 搜索歌单
 * @returns list
 */
export async function searchPlayLists(keyword: string, offset:number): Promise<PlayListsResult> {
  let list:Array<PlayList> = new Array()
  let hasMore:boolean = false
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/search?type=1000&keywords=${encodeURIComponent(keyword)}&limit=15&offset=${offset}`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot:PlayListSearchResult = data.result as PlayListSearchResult
    hasMore = dataGot.result.hasMore
    list = dataGot.result.playlists
  })
  const result: PlayListsResult = {
    more: hasMore,
    playlist: list
  }
  return result
}

/**
 * 收藏/取消收藏歌单
 * @param mode - 1:收藏, 2:取消收藏
 * @returns
 */
export async function subscribePlayList(id: number, mode: number): Promise<boolean> {
  let res: boolean = false
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/playlist/subscribe?t=${mode}&id=${id}&timestamps=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.Request(true).then((data) => {
    if(data.responseCode == 200) {
      res = true
    } else if(data.responseCode == 401) {
      ToastUtil.showToast('无法操作当前歌单')
    } else {
      ToastUtil.showToast('操作失败')
      LogUtil.error(TAG + 'Error: ' + JSON.stringify(data.result))
    }
  })
  return res
}

/**
 * Get personalized list
 * @returns Array<PersonalListItem>
 */
export async function getPersonalizedList(): Promise<Array<PersonalListItem>> {
  let list: Array<PersonalListItem> = []
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/personalized?timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot = data.result as Personalized
    list = dataGot.result
    AppStorage.setOrCreate(StorageConstants.PERSONALIZED_LIST, list)
    PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.PERSONALIZED_LIST, list)
  })
  return list
}

/**
 * 删除歌单
 * @param pid
 */
export async function deletePlayList(pid: number): Promise<boolean>{
  try {
    const rootUrl = await getApiUrl()
    const url: string = `${rootUrl}/playlist/delete?id=${pid}&timestamp=${new Date().getTime()}`
    const request = new HttpRequest(url)
    const data = await request.Request()
    if(data.result["code"] == 200) {
      return true
    } else return false
  } catch (e) {
    LogUtil.error(TAG + 'deletePlayList Error: ' + e.message)
    return false
  }
}

/**
 * 创建歌单 —— 不可用 illegal
 * @param name
 * @param isPrivacy
 */
export async function createPlayList(name: string, isPrivacy: boolean) {
  try {
    const rootUrl = await getApiUrl()
    const url: string = `${rootUrl}/playlist/create?name=${encodeURIComponent(name)}${isPrivacy ? '&privacy=10' : ''}&timestamp=${new Date().getTime()}`
    LogUtil.info(TAG + 'request Url: ' + url)
    const request = new HttpRequest(url)
    const data = await request.Request()
    LogUtil.info(TAG + JSON.stringify(data.result))
  } catch (e) {
    LogUtil.error(TAG + 'createPlayList Error: ' + e.message)

  }
}