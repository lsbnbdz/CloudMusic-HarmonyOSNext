import { LogUtil } from "@pura/harmony-utils"
import Constants from "../constants/Constants"
import AudioPlayUtils from "../utils/AudioPlayUtils"
import PreferencesUtils from "../utils/PreferencesUtils"

const TAG = '[appInit] '

export async function appInit() {
  await initSettings()
  await audioPlayerInit()
}

async function audioPlayerInit() {
  try {
    AppStorage.setOrCreate('player-isplaying',false)
  } catch (e) {
    LogUtil.error(JSON.stringify(e))
  }
}

async function initSettings() {
  LogUtil.info(TAG + 'initSettings - 开始初始化设置')
  const SetPerf: string = Constants.SET_PERF

  // hasAnimation
  const hasAnimationExist = await PreferencesUtils.hasPreferenceValue(SetPerf, 'hasAnimation')
  if (!hasAnimationExist) {
    await PreferencesUtils.putPreferenceValue(SetPerf, 'hasAnimation', true)
    const hasAnimation = true
    AppStorage.setOrCreate('set-hasAnimation',hasAnimation)
  } else {
    const hasAnimation = await PreferencesUtils.getPreferenceValue(SetPerf, 'hasAnimation', true)
    AppStorage.setOrCreate('set-hasAnimation',hasAnimation)
  }

  // setQuality

}
