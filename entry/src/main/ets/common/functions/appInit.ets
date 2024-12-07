import { LogUtil } from "@pura/harmony-utils"
import Constants from "../constants/Constants"
import PlayQueueUtils from "../utils/PlayQueueUtils"
import PreferencesUtils from "../utils/PreferencesUtils"

/**
 * App初始化
 */
const TAG = '[appInit] '

export async function appInit() {
  await initSettings()
  await initPlayQueue()
  await audioPlayerInit()
}

async function audioPlayerInit() {
  try {
    AppStorage.setOrCreate('player-isplaying',false)
  } catch (e) {
    LogUtil.error(JSON.stringify(e))
  }
}

/**
 * 初始化播放列表
 */
async function initPlayQueue() {
  await PlayQueueUtils.init()
}

/**
 * 初始化设置
 */
async function initSettings() {
  LogUtil.info(TAG + 'initSettings - 开始初始化设置')
  const SetPerf: string = Constants.SET_PERF

  // hasAnimation
  const hasAnimationExist = await PreferencesUtils.hasPreferenceValue(SetPerf, 'hasAnimation')
  if (!hasAnimationExist) {
    await PreferencesUtils.putPreferenceValue(SetPerf, 'hasAnimation', true)
    AppStorage.setOrCreate('set-hasAnimation',true)
  } else {
    const hasAnimation = await PreferencesUtils.getPreferenceValue(SetPerf, 'hasAnimation', true)
    AppStorage.setOrCreate('set-hasAnimation',hasAnimation)
  }

  // customApiUrl
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

  // usePublicCookie
  const isUsePubCookieExist = await PreferencesUtils.hasPreferenceValue(SetPerf, 'isUsePubCookie')
  if (!isUsePubCookieExist) {
    await PreferencesUtils.putPreferenceValue(SetPerf, 'isUsePubCookie', true)
    AppStorage.setOrCreate('set-isUsePubCookie', true)
  } else {
    const isUsePubCookie = await PreferencesUtils.getPreferenceValue(SetPerf, 'isUsePubCookie', true)
    AppStorage.setOrCreate('set-isUsePubCookie', isUsePubCookie)
  }

  // setPlayQuality
  const isPlayQualityExist = await PreferencesUtils.hasPreferenceValue(SetPerf, 'playQuality')
  if (!isPlayQualityExist) {
    await PreferencesUtils.putPreferenceValue(SetPerf, 'playQuality', 0)
    AppStorage.setOrCreate('set-playQuality', 0)
  } else {
    const playQuality:number = await PreferencesUtils.getPreferenceValue(SetPerf, 'playQuality', 0)
    AppStorage.setOrCreate('set-playQuality', playQuality)
  }
}
