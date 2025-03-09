import { LogUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../common/constants/StorageConstants"
import { TopList, TopListItem } from "../common/entities/TopList"
import { getApiUrl } from "../common/functions/common/get"
import PreferencesUtils from "../common/utils/data/PreferencesUtils"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"

const TAG = '[topListApi] '

export async function getTopList(): Promise<TopListItem[]> {
  let list: TopListItem[] = []
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/toplist`
  const request = new HttpRequest(url, true)
  try {
    await request.RequestInStream(true).then((data) => {
      const dataGot: TopList = data.result as TopList
      list = dataGot.list
      AppStorage.setOrCreate(StorageConstants.TOPLISTS, list)
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.TOPLISTS, list)
    })
  } catch (e) {
    LogUtil.error(TAG + 'getTopList Error: ' + e.message)
  }
  return list
}