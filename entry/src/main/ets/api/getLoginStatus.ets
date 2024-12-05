import { promptAction, router } from "@kit.ArkUI"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../common/constants/Constants"
import { User } from "../common/entities/User"
import { getApiUrl } from "../common/functions/functions"
import { HttpRequest } from "../common/utils/HttpRequestUtils"
import PreferencesUtils from "../common/utils/PreferencesUtils"

/**
 * 获取登录状态
 * @param cookie
 */
export async function getLoginStatus(cookie: string) {
  try {
    const timestamp = new Date().getTime()
    const rootUrl = await getApiUrl()
    const url:string = `${rootUrl}/login/status?timestamp=${timestamp}`
    const request = new HttpRequest(url,false)
    const userPref = Constants.USER_PREF

    request.Request().then((data) => {
      const user:User = data.result as User
      if(user.data.account.id) {
        PreferencesUtils.putPreferenceValue(userPref, 'user', user)
        PreferencesUtils.putPreferenceValue(userPref, 'cookie', cookie)
        PreferencesUtils.putPreferenceValue(userPref, 'signTime', Date.now())
        AppStorage.setOrCreate('vipType', user.data.account.vipType)
        AppStorage.setOrCreate('isValidCookie', true)
        AppStorage.setOrCreate('User', user)
        promptAction.showToast({
          message: '登录成功！'
        })
        router.back()
      }
      else {
        ToastUtil.showToast('登录失败')
      }
    })
  } catch (error) {
    promptAction.showToast({ message:`获取登录状态失败: ${error}` })
    LogUtil.error('获取登录状态失败', error.message)
  }
}
