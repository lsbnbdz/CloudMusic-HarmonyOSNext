import { LogUtil } from "@pura/harmony-utils"
import { User } from "../common/entities/User"
import { getApiUrl } from "../common/functions/commonFunction"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import PreferencesUtils from "../common/utils/app/PreferencesUtils"
import { StorageConstants } from "../common/constants/StorageConstants"

const TAG = '[loginApi] '
/**
 * 获取登录状态
 * @param cookie
 */
export async function getLoginStatus(cookie: string): Promise<boolean> {
  try {
    const rootUrl = await getApiUrl()
    const url: string = `${rootUrl}/login/status?timestamp=${new Date().getTime()}`
    const request = new HttpRequest(url, false)
    const userPref = StorageConstants.USER_PREF
    const data = await request.Request()
    const user: User = data.result as User
    LogUtil.info(TAG + 'login status result: ' + JSON.stringify(data.result))
    if (user.data.account.id) {
      PreferencesUtils.putPreferenceValue(userPref, 'user', user)
      PreferencesUtils.putPreferenceValue(userPref, 'cookie', cookie)
      AppStorage.setOrCreate(StorageConstants.VIP_TYPE, user.data.account.vipType)
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, true)
      AppStorage.setOrCreate(StorageConstants.USER, user)
      AppStorage.setOrCreate(StorageConstants.IS_LOGGED, true)
      LogUtil.info(TAG + '获取登录状态成功: 已登录')
      return true
    } else {
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
      AppStorage.setOrCreate(StorageConstants.IS_LOGGED, false)
      LogUtil.info(TAG + '获取登录状态成功: 未登录')
      return false
    }
  } catch (error) {
    LogUtil.error('获取登录状态失败: ', error.message)
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
      await PreferencesUtils.delPreferenceValue(StorageConstants.USER_PREF, 'user')
      await PreferencesUtils.delPreferenceValue(StorageConstants.USER_PREF, 'cookie')
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
      AppStorage.setOrCreate(StorageConstants.COOKIE, '')
      AppStorage.setOrCreate(StorageConstants.IS_LOGGED, false)
      return true
    } else {
      return false
    }
  } catch (e) {
    LogUtil.error(TAG + '退出登录失败：' + JSON.stringify(e))
    return false
  }
}