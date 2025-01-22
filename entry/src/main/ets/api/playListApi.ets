import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayList, PlayListOperationRes, PlayListSearchResult } from "../common/entities/PlayList"
import { CloudSongs, DailyListSongs, PlayListSongs } from "../common/entities/PlayListSongs"
import { PlayQueue } from "../common/entities/PlayQueue"
import { Song } from "../common/entities/SongsResult"
import { User, UserClass } from "../common/entities/User"
import { getApiUrl, getArtists } from "../common/functions/commonFunction"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import PlayQueueUtils from "../common/utils/play/PlayQueueUtils"
import PreferencesUtils from "../common/utils/app/PreferencesUtils"
import { JSON } from "@kit.ArkTS"
import { StorageConstants } from "../common/constants/StorageConstants"

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
    LogUtil.info(TAG + 'getPlayLists - dataGot: ' + JSON.stringify(dataGot))
    hasMore = dataGot.more
    list = dataGot.playlist
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
  const url:string = `${rootUrl}/playlist/track/all?id=${listId}&limit=30&offset=${offset}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:PlayListSongs = data.result as PlayListSongs
    for(let song of dataGot.songs) {
      list.push({
        id: song.id ,
        name: song.name,
        artists: song.ar,
        duration: song.dt,
        alias: []
      })
    }
  })
  LogUtil.info(TAG + 'getPlayListSongs - dataGot => list: ' + JSON.stringify(list))
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

    LogUtil.info(TAG + JSON.stringify(dataGot))
    if(dataGot.body) {
      if (dataGot.body.code == 200) {
        LogUtil.info(TAG + 'PlayListOperation Success')
        return true
      } else {
        LogUtil.info(TAG + 'PlayListOperation Error: ' + dataGot.body.message)
        throw new Error(dataGot.body.message.toString())
      }
    }
    else {
      LogUtil.info(TAG + 'PlayListOperation Error: ' + data.result["message"])
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
  const url:string = `${rootUrl}/user/cloud?limit=20&offset=${offset}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    LogUtil.info(TAG + 'got data: ' + JSON.stringify(data.result))
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
    LogUtil.info(TAG + 'searchPlayLists - dataGot: ' + JSON.stringify(dataGot))
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
    LogUtil.info(TAG + 'subscribe playlist result: ' + JSON.stringify(data.result))
    if(data.responseCode == 200) {
      res = true
    } else if(data.responseCode == 401) {
      ToastUtil.showToast('无法操作当前歌单')
    } else {
      ToastUtil.showToast('操作失败')
    }
  })
  return res
}