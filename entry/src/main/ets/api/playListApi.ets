import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayList, PlayListOperationRes, PlayListSearchResult } from "../common/entities/PlayList"
import { CloudSongs, DailyListSongs, PlayListSongs } from "../common/entities/PlayListSongs"
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
 * 获取歌单列表
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
export async function getPlayListSongs(listId: number, trackCount: number, offset: number): Promise<Array<Song>> {
  let list: Array<Song> = []
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/playlist/track/all?id=${listId}&limit=100&offset=${offset}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot: PlayListSongs = data.result as PlayListSongs
    list = dataGot.songs.map(song => new SongC(
      song.id,
      song.name,
      song.ar,
      song.dt,
      []
    ))
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
    const url: string = `${rootUrl}/playlist/track/all?id=${listId}&limit=${limit}&offset=${offset}`
    const request = new HttpRequest(url)
    let data = await request.RequestInStream()
    let dataResult: PlayListSongs = data.result as PlayListSongs
    for (let item of dataResult.songs) {
      let artists = await getArtists(item.ar)
      let tempSong: Song = {
        id: item.id,
        name: item.name,
        artists: item.ar,
        duration: item.dt,
        alias: []
      }
      tempQueue.push({
        playmode: 1,
        song: tempSong,
        artists: artists,
        fileName: ''
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
        alias: []
      }
      queue.push({
        playmode: 1,
        song: tempSong,
        artists: artists,
        fileName: ''
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
export async function PlayListOperation(op:OperationType, pid:number, tracks:number):Promise<boolean> {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/playlist/tracks?op=${op}&pid=${pid}&tracks=${tracks}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:PlayListOperationRes = data.result as PlayListOperationRes
    if(dataGot.body) {
      if (dataGot.body.code == 200) {
        return true
      } else {
        LogUtil.error(TAG + 'PlayListOperation Error: ' + dataGot.body.message)
        throw new Error(dataGot.body.message.toString())
      }
    }
    else {
      LogUtil.error(TAG + 'PlayListOperation Error: ' + data.result["message"])
      throw new Error(data.result["message"])
    }
  })
  return false
}

export interface DailySongRes {
  song:Song
  reason:string
}

/**
 * 获取云盘歌曲列表
 * @param offset 偏移
 * @returns list 歌曲列表
 */
export async function getCloudList(offset:number): Promise<Array<Song>> {
  let list:Array<Song> = new Array()
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/user/cloud?limit=50&offset=${offset}`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot:CloudSongs = data.result as CloudSongs
    for(let song of dataGot.data) {
      list.push({
        id: song.simpleSong.id,
        name: song.simpleSong.name,
        artists: song.simpleSong.ar,
        duration: song.simpleSong.dt,
        alias: []
      })
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

export async function getPersonalizedList(): Promise<Array<PersonalListItem>> {
  let list: Array<PersonalListItem> = []
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/personalized?limit=10`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot = data.result as Personalized
    list = dataGot.result
    AppStorage.setOrCreate(StorageConstants.PERSONALIZED_LIST, list)
    PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.PERSONALIZED_LIST, list)
  })
  return list
}