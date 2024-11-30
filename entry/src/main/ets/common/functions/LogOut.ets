import Constants from "../constants/Constants"
import PreferencesUtils from "../utils/PreferencesUtils"
import { promptAction } from "@kit.ArkUI"

/**
 * 退出登录
 */
const userPref = Constants.USER_PREF

export async function logOut() {
  await PreferencesUtils.delPreferenceValue(userPref,'user')
  await PreferencesUtils.delPreferenceValue(userPref,'cookie')
  await PreferencesUtils.delPreferenceValue(userPref,'signTime')
  AppStorage.set('isValidCookie', false)
  AppStorage.set('vipType', -1)
  promptAction.showToast({ message: '成功退出登录' })
}