import Constants from "../constants/Constants";
import { User, UserClass } from "../entities/User";
import PreferencesUtils from "../utils/PreferencesUtils";

export async function getLoginInfo() {
  const userPref:string = Constants.USER_PREF

  const cookie = await PreferencesUtils.getPreferenceValue<string>(userPref, 'cookie', '')
  const signTime = await PreferencesUtils.getPreferenceValue<number>(userPref, 'signTime', 0)
  const user = await PreferencesUtils.getPreferenceValue<User>(userPref, 'user', UserClass)

  const isValidCookie = cookie && signTime && (Date.now() - signTime) < Constants.COOKIE_EXPIRY_DAYS * 24 * 60 * 60 * 1000;

  AppStorage.setOrCreate('User', user)
  AppStorage.setOrCreate("cookie", cookie)
  AppStorage.setOrCreate("isValidCookie", isValidCookie)
}