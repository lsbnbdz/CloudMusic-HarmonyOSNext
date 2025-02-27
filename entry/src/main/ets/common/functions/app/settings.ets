import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../../constants/StorageConstants"
import PreferencesUtils from "../../utils/data/PreferencesUtils"
/**
 * 设置项
 */
const TAG = '[settings] '

/**
 * 初始化应用设置
 */
export async function initSettings() {
  LogUtil.info(TAG + '开始初始化设置')
  const SetPerf: string = StorageConstants.SET_PERF

  /**
   * Default HomePage Content
   */
  const isDefaultHomePageExist = await PreferencesUtils.hasPreferenceValue(SetPerf, StorageConstants.DEFAULT_PAGE_INDEX)
  if(!isDefaultHomePageExist) {
    await PreferencesUtils.putPreferenceValue(SetPerf, StorageConstants.DEFAULT_PAGE_INDEX, 0)
    AppStorage.setOrCreate(StorageConstants.DEFAULT_PAGE_INDEX, 0)
  } else {
    const defaultIndex: number = await PreferencesUtils.getPreferenceValue(SetPerf, StorageConstants.DEFAULT_PAGE_INDEX, 0)
    AppStorage.setOrCreate(StorageConstants.DEFAULT_PAGE_INDEX, defaultIndex)
  }

  /**
   * Custom api url
   */
  const isCustomApiUrlExist = await PreferencesUtils.hasPreferenceValue(SetPerf, 'isCustomApiUrl')
  if (!isCustomApiUrlExist) {
    await PreferencesUtils.putPreferenceValue(SetPerf, 'isCustomApiUrl', false)
    await PreferencesUtils.putPreferenceValue(SetPerf,'customApiUrl','http://example.com:8080')
    AppStorage.setOrCreate('set-isCustomApiUrl',false)
    AppStorage.setOrCreate('set-customApiUrl','http://example.com:8080')
  } else {
    const isCustomApiUrl = await PreferencesUtils.getPreferenceValue(SetPerf, 'isCustomApiUrl', false)
    const customApiUrl = await PreferencesUtils.getPreferenceValue(SetPerf, 'customApiUrl', 'http://example.com:8080')
    AppStorage.setOrCreate('set-isCustomApiUrl',isCustomApiUrl)
    AppStorage.setOrCreate('set-customApiUrl',customApiUrl)
  }

  /**
   * Use public cookie
   */
  const isUsePubCookieExist = await PreferencesUtils.hasPreferenceValue(SetPerf, StorageConstants.USE_PUBLIC_COOKIE)
  if (!isUsePubCookieExist) {
    await PreferencesUtils.putPreferenceValue(SetPerf, StorageConstants.USE_PUBLIC_COOKIE, false)
    AppStorage.setOrCreate(StorageConstants.USE_PUBLIC_COOKIE, false)
  } else {
    const isUsePubCookie = await PreferencesUtils.getPreferenceValue(SetPerf, StorageConstants.USE_PUBLIC_COOKIE, true)
    AppStorage.setOrCreate(StorageConstants.USE_PUBLIC_COOKIE, isUsePubCookie)
  }

  /**
   * Set play quality
   */
  const isPlayQualityExist = await PreferencesUtils.hasPreferenceValue(SetPerf, StorageConstants.PLAY_QUALITY)
  if (!isPlayQualityExist) {
    await PreferencesUtils.putPreferenceValue(SetPerf, StorageConstants.PLAY_QUALITY, 0)
    AppStorage.setOrCreate(StorageConstants.PLAY_QUALITY, 0)
  } else {
    const playQuality: number = await PreferencesUtils.getPreferenceValue(SetPerf, StorageConstants.PLAY_QUALITY, 0)
    AppStorage.setOrCreate(StorageConstants.PLAY_QUALITY, playQuality)
  }
}

export async function changeSettings(name: string, value: number | boolean) {
  try {
    await PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, name, value)
    AppStorage.setOrCreate(name, value)
  } catch (e) {
    ToastUtil.showToast('更改设置失败')
    LogUtil.error(TAG + 'Error while changing settings: ' + e.message)
  }
}