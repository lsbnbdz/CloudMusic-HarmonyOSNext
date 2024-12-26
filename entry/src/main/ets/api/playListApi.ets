import { LogUtil } from "@pura/harmony-utils"
import Constants from "../common/constants/Constants"
import { playList, PlayListOperationRes } from "../common/entities/PlayList"
import { DailyListSongs, PlayListSongs } from "../common/entities/PlayListSongs"
import { PlayQueue } from "../common/entities/PlayQueue"
import { Song } from "../common/entities/SongsResult"
import { User, UserClass } from "../common/entities/User"
import { getApiUrl, getArtists } from "../common/functions/functions"
import { HttpRequest } from "../common/utils/HttpRequestUtils"
import PlayQueueUtils from "../common/utils/PlayQueueUtils"
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
    LogUtil.info(TAG + 'getPlayLists - dataGot: ' + JSON.stringify(dataGot))
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
  LogUtil.info(TAG + 'getPlayListSongs - dataGot => list: ' + JSON.stringify(list))
  return list;
}

/**
 * 将歌单歌曲添加至播放列表
 * @param listId - 歌单ID
 * @param trackCount - 歌单歌曲总数
 * @returns void
 */
export async function putPlayListInQueue(listId:number, trackCount:number): Promise<void> {
  let offset = 0
  const rootUrl = await getApiUrl()
  let queue:Array<PlayQueue> = []
  while(offset < trackCount) {
    const url: string = `${rootUrl}/playlist/track/all?id=${listId}&limit=500&offset=${offset}`
    const request = new HttpRequest(url)
    let data = await request.RequestInStream()
    let dataResult: PlayListSongs = data.result as PlayListSongs
    for (let item of dataResult.songs) {
      let artists = await getArtists(item.ar)
      let tempSong: Song = {
        id: item.id,
        name: item.name,
        artists: item.ar,
        duration: item.dt
      }
      queue.push({
        playmode: 1,
        song: tempSong,
        artists: artists,
        fileName: ''
      })
    }
    offset += 500
  }
  await PlayQueueUtils.cleanQueue()
  await PlayQueueUtils.queueAdd_array(queue)
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
        duration: item.dt
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



type OperationType = 'add' | 'del'
/**
 * 向歌单添加/删除歌曲
 * @param op - 操作 add/del
 * @param pid - 歌单id
 * @param tracks - 歌曲id(多个用,隔开)
 */
export async function PlayListOperation(op:OperationType, pid:number, tracks:number):Promise<boolean> {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/playlist/tracks?op=${op}&pid=${pid}&tracks=${tracks}`
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
 * 获取每日推荐歌单内歌曲
 * @returns
 */
export async function getDailySongs(): Promise<Array<DailySongRes>> {
  let list:Array<DailySongRes> = []
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/recommend/songs`
  const request = new HttpRequest(url)
  await request.RequestInStream().then((data) => {
    const dataGot: DailyListSongs = data.result as DailyListSongs
    for(let song of dataGot.data.dailySongs) {
      list.push({
        song: {
          id: song.id,
          name: song.name,
          artists: song.ar,
          duration: song.dt,
        },
        reason: song.reason
      })
    }
  })
  LogUtil.info(TAG + 'getDailySongs: ' + JSON.stringify(list))
  return list;
}