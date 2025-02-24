import { LogUtil } from "@pura/harmony-utils"
import { TopList, TopListItem } from "../common/entities/TopList"
import { getApiUrl } from "../common/functions/commonFunction"
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
    })
  } catch (e) {
    LogUtil.error(TAG + 'getTopList Error: ' + e.message)
  }
  return list
}