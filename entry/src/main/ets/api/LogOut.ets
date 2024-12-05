import Constants from "../common/constants/Constants"
import PreferencesUtils from "../common/utils/PreferencesUtils"
import { promptAction } from "@kit.ArkUI"
import { getApiUrl } from "../common/functions/functions"
import { HttpRequest } from "../common/utils/HttpRequestUtils"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"

/**
 * 退出登录
 */
const TAG = '[LogOut] '
const userPref = Constants.USER_PREF

export async function logOut() {
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/logout`
  const request = new HttpRequest(url)
  try {
    await request.Request().then(async () => {
      await PreferencesUtils.delPreferenceValue(userPref, 'user')
      await PreferencesUtils.delPreferenceValue(userPref, 'cookie')
      await PreferencesUtils.delPreferenceValue(userPref, 'signTime')
      AppStorage.set('isValidCookie', false)
      AppStorage.set('vipType', -1)
      AppStorage.set('cookie', '')
      promptAction.showToast({ message: '成功退出登录' })
    })
  } catch (e) {
    LogUtil.error(TAG + '退出登录失败：' + JSON.stringify(e))
    ToastUtil.showToast('退出登录失败，请检查API服务器是否正常')
  }


}