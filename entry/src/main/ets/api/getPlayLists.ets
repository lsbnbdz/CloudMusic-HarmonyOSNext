import Constants from "../common/constants/Constants"
import { playList, PlayListResult } from "../common/entities/PlayList"
import { User, UserClass } from "../common/entities/User"
import { getApiUrl } from "../common/functions/functions"
import { HttpRequest } from "../common/utils/HttpRequestUtil"
import PreferencesUtils from "../common/utils/PreferencesUtils"

/**
 * 获取歌单列表
 * @param usingCache 是否缓存
 * @returns list
 */
export async function getPlayLists(usingCache:boolean): Promise<Array<playList>> {
  let list:Array<playList> = new Array()
  const user = await PreferencesUtils.getPreferenceValue<User>(Constants.USER_PREF,'user',UserClass)
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/user/playlist?uid=${user.data.account.id}`
  const request = new HttpRequest(url,usingCache)
  await request.Request().then((data) => {
    const dataGot:PlayListResult = data.result as PlayListResult
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
  return list;
}