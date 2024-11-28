import { promptAction, router } from "@kit.ArkUI"
import { LogUtil } from "@pura/harmony-utils"
import Constants from "../common/constants/Constants"
import { User } from "../common/entities/User"
import { HttpRequest } from "../common/utils/HttpRequestUtil"
import PreferencesUtils from "../common/utils/PreferencesUtils"

export async function getLoginStatus(cookie: string) {
  try {
    const url:string = `${Constants.ROOT_URL}/login/status`
    const request = new HttpRequest(url)
    const userPref = Constants.USER_PREF

    request.Request().then((data) => {
      const user:User = data.result as User
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
    })

  } catch (error) {
    promptAction.showToast({ message:`获取登录状态失败: ${error}` })
    LogUtil.error('获取登录状态失败', error.message)
  }
}
