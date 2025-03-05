import { LogUtil } from "@pura/harmony-utils"
import { User } from "../common/entities/User"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import PreferencesUtils from "../common/utils/data/PreferencesUtils"
import { StorageConstants } from "../common/constants/StorageConstants"
import { getApiUrl } from "../common/functions/common/get"

const TAG = '[loginApi] '
/**
 * 获取登录状态
 * @param cookie
 */
export async function getLoginStatus(cookie: string): Promise<boolean> {
  let code: number = -1
  try {
    const rootUrl = await getApiUrl()
    const url: string = `${rootUrl}/login/status?timestamp=${new Date().getTime()}`
    const request = new HttpRequest(url, false)
    const userPref = StorageConstants.USER_PREF
    const data = await request.Request()
    code = data.responseCode
    const user: User = data.result as User
    AppStorage.setOrCreate(StorageConstants.VALID_API_URL, true)
    if (user.data.account.id) {
      PreferencesUtils.putPreferenceValue(userPref, StorageConstants.USER, user)
      PreferencesUtils.putPreferenceValue(userPref, StorageConstants.COOKIE, cookie)
      AppStorage.setOrCreate(StorageConstants.VIP_TYPE, user.data.account.vipType)
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, true)
      AppStorage.setOrCreate(StorageConstants.USER, user)
      AppStorage.setOrCreate(StorageConstants.IS_LOGGED, true)
      return true
    } else {
      await PreferencesUtils.delPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER)
      await PreferencesUtils.delPreferenceValue(StorageConstants.USER_PREF, StorageConstants.COOKIE)
      await PreferencesUtils.delPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS)
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
      AppStorage.setOrCreate(StorageConstants.COOKIE, '')
      AppStorage.setOrCreate(StorageConstants.IS_LOGGED, false)
      AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, [])
      return false
    }
  } catch (error) {
    LogUtil.error('获取登录状态失败: ', error.message)
    if(code == 200) {
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
      AppStorage.setOrCreate(StorageConstants.VALID_API_URL, true)
    } else {
      AppStorage.setOrCreate(StorageConstants.VALID_API_URL, false)
    }
    return false
  }
}

export async function logOut(): Promise<boolean> {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/logout?timestamp=${new Date().getTime()}`
  const request = new HttpRequest(url)
  try {
    let data = await request.Request()
    if(data.responseCode == 200) {
      await PreferencesUtils.delPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER)
      await PreferencesUtils.delPreferenceValue(StorageConstants.USER_PREF, StorageConstants.COOKIE)
      await PreferencesUtils.delPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS)
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
      AppStorage.setOrCreate(StorageConstants.COOKIE, '')
      AppStorage.setOrCreate(StorageConstants.IS_LOGGED, false)
      AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, [])
      return true
    } else {
      return false
    }
  } catch (e) {
    LogUtil.error(TAG + '退出登录失败：' + JSON.stringify(e))
    return false
  }
}