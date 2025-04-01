import { LogUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../common/constants/StorageConstants"
import { DjProgramResult } from "../common/entities/dj/DjProgramResult"
import { DjRecommendResult, RecommendDjRadio } from "../common/entities/dj/DjRecommend"
import { DjResult } from "../common/entities/dj/DjResult"
import { getApiUrl } from "../common/functions/common/get"
import PreferencesUtils from "../common/utils/data/PreferencesUtils"
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