import Constants from "../common/constants/Constants"
import PreferencesUtils from "../common/utils/app/PreferencesUtils"
import { promptAction } from "@kit.ArkUI"
import { getApiUrl } from "../common/functions/commonFunction"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
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
      AppStorage.setOrCreate('isValidCookie', false)
      AppStorage.setOrCreate('vipType', -1)
      AppStorage.setOrCreate('cookie', '')
      promptAction.showToast({ message: '成功退出登录' })
    })
  } catch (e) {
    LogUtil.error(TAG + '退出登录失败：' + JSON.stringify(e))
    ToastUtil.showToast('退出登录失败，请检查API服务器是否正常')
  }


}