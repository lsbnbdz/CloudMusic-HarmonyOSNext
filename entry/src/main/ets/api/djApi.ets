import { LogUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../common/constants/StorageConstants"
import { DjProgramResult } from "../common/entities/dj/DjProgramResult"
import { DjRecommendResult, RecommendDjRadio } from "../common/entities/dj/DjRecommend"
import { DjRadio, DjResult } from "../common/entities/dj/DjResult"
import { PlayQueue } from "../common/entities/local/PlayQueue"
import { Song } from "../common/entities/song/SongsResult"
import { getArtists } from "../common/functions/common/convert"
import { getApiUrl } from "../common/functions/common/get"
import PreferencesUtils from "../common/utils/data/PreferencesUtils"
import PlayQueueUtils from "../common/utils/play/PlayQueueUtils"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"

const TAG = '[djApi] '

/**
 * 获取用户电台 Sublist
 * @returns DjResult
 */
export async function getDjSublist(): Promise<DjResult> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/dj/sublist?timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  const data = await request.RequestInStream(true)
  const dataGot = data.result as DjResult
  AppStorage.setOrCreate(StorageConstants.USER_DJRADIO_LIST, dataGot.djRadios)
  PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_DJRADIO_LIST, dataGot.djRadios)
  return dataGot
}

/**
 * 获取电台歌曲列表
 * @param rid
 * @param limit
 * @param offset
 * @returns DjProgramResult
 */
export async function getDjPrograms(rid: number, limit: number, offset: number): Promise<DjProgramResult> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/dj/program?rid=${rid}&limit=${limit}&offset=${offset}&timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  const data = await request.RequestInStream(true)
  const dataGot = data.result as DjProgramResult
  return dataGot
}

/**
 * 获取推荐电台
 * @returns
 */
export async function getRecommendDj(): Promise<Array<RecommendDjRadio>> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/personalized/djprogram`
  const request = new HttpRequest(url)
  const data = await request.RequestInStream(true)
  const dataGot = data.result as DjRecommendResult
  LogUtil.info(TAG + 'result: ' + JSON.stringify(dataGot))
  PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.RECOMMENDED_DJ, dataGot.djRadios ?? [])
  return dataGot.djRadios ?? []
}

/**
 * Put DjRadioProgramsInQueue
 * @param rid
 * @param trackCount
 * @param limit
 * @param offset
 * @param first
 * @returns
 */
export async function putDjRadioInQueue(rid: number, trackCount: number, limit: number = 100, offset: number = 0, first: boolean = true): Promise<void> {
  const rootUrl = await getApiUrl()
  const allQueue: PlayQueue[] = []

  while (offset < trackCount) {
    const url = `${rootUrl}/dj/program?rid=${rid}&limit=${limit}&offset=${offset}`
    const data = await new HttpRequest(url).RequestInStream()
    const dataResult = data.result as DjProgramResult

    allQueue.push(...dataResult.programs.map((item): PlayQueue => ({
      playmode: 3,
      song: item.mainSong as Song,
      fileName: '',
      picUrl: item.coverUrl || $r('app.media.ic_public_music')
    })))

    offset += limit
  }

  if (first) await PlayQueueUtils.cleanQueue()
  await PlayQueueUtils.queueAdd_array(allQueue)
}

/**
 * 搜索播客电台
 * @param keyword
 * @returns
 */
export async function getDjRadioList(keyword: string): Promise<DjRadio[]> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/search?keywords=${encodeURIComponent(keyword)}&type=1009`
  const request = new HttpRequest(url)
  const data = await request.RequestInStream()
  const dataGot: DjRadio[] = data.result["result"]["djRadios"] as DjRadio[]
  return dataGot ?? []
}