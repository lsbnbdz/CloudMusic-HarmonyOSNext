import Constants from "../constants/Constants"
import PreferencesUtils from "../utils/PreferencesUtils"
import { promptAction } from "@kit.ArkUI"

const userPref = Constants.USER_PREF

export async function logOut() {
  await PreferencesUtils.delPreferenceValue(userPref,'user')
  await PreferencesUtils.delPreferenceValue(userPref,'cookie')
  await PreferencesUtils.delPreferenceValue(userPref,'signTime')
  AppStorage.set('ValidCookie', false)
  AppStorage.set('Profile', null)
  promptAction.showToast({ message: '成功退出登录' })
}