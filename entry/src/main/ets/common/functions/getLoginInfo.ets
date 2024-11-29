import { LogUtil } from "@pura/harmony-utils"
import { getPubCookie } from "../../api/getPubCookie"
import Constants from "../constants/Constants"
import { User, UserClass } from "../entities/User"
import { HttpRequest } from "../utils/HttpRequestUtil"
import PreferencesUtils from "../utils/PreferencesUtils"

export async function getLoginInfo() {
  const userPref:string = Constants.USER_PREF

  const cookie = await PreferencesUtils.getPreferenceValue<string>(userPref, 'cookie', '')
  const signTime = await PreferencesUtils.getPreferenceValue<number>(userPref, 'signTime', 0)
  const user = await PreferencesUtils.getPreferenceValue<User>(userPref, 'user', UserClass)

  const isValidCookie = cookie && signTime && (Date.now() - signTime) < Constants.COOKIE_EXPIRY_DAYS * 24 * 60 * 60 * 1000;

  const url:string = `${Constants.ROOT_URL}/login/status`
  const request = new HttpRequest(url)

  AppStorage.setOrCreate('User', user)
  AppStorage.setOrCreate("cookie", cookie)
  AppStorage.setOrCreate("isValidCookie", isValidCookie)
  getPubCookie()

  request.Request().then((data) => {
    try {
      const vipType:number = data.result["data"]["account"]["vipType"]
      AppStorage.setOrCreate('vipType', vipType)
      LogUtil.info('Get vipType: ' + vipType)
    } catch (e) {
      AppStorage.setOrCreate('vipType', -1)
      LogUtil.error('Get vipType Error: ' + e.message())
    }
  })
}