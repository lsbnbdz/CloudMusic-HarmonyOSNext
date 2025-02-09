import { promptAction, router } from "@kit.ArkUI"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { User } from "../common/entities/User"
import { getApiUrl } from "../common/functions/commonFunction"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import PreferencesUtils from "../common/utils/app/PreferencesUtils"
import { StorageConstants } from "../common/constants/StorageConstants"

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
    const userPref = StorageConstants.USER_PREF

    request.Request().then((data) => {
      const user:User = data.result as User
      if(user.data.account.id) {
        PreferencesUtils.putPreferenceValue(userPref, 'user', user)
        PreferencesUtils.putPreferenceValue(userPref, 'cookie', cookie)
        PreferencesUtils.putPreferenceValue(userPref, 'signTime', Date.now())
        AppStorage.setOrCreate(StorageConstants.VIP_TYPE, user.data.account.vipType)
        AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, true)
        AppStorage.setOrCreate(StorageConstants.USER, user)
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
