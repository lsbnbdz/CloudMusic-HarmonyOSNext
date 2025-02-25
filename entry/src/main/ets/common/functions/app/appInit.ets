import { AppUtil, LogUtil } from "@pura/harmony-utils"
import { getAnnouncement } from "../../../api/chenlvinApi"
import { Song, SongClass } from "../../entities/SongsResult"
import PlayQueueUtils from "../../utils/play/PlayQueueUtils"
import PreferencesUtils from "../../utils/app/PreferencesUtils"
import { StorageConstants } from "../../constants/StorageConstants"
import { notificationManager } from "@kit.NotificationKit"
import { resourceManager } from "@kit.LocalizationKit"
import { initSettings } from "./settings"

/**
 * App初始化
 */
const TAG = '[appInit] '

export async function appInit() {
  await initApp()
  await initSettings()
  await initBasicInfo()
  await initPlayQueue()
  await audioPlayerInit()
  await loadSavedSong()
  await getAnnouncement()
}

async function initApp() {
  notificationManager.requestEnableNotification(AppUtil.getContext()).then(() => {
    LogUtil.info(TAG + '成功请求通知权限')
  })
}

async function initBasicInfo() {
  let empty: string[] = []
  AppStorage.setOrCreate(StorageConstants.USER_LIKELIST, empty)
  let deviceType = await getDeviceTypeInfo()
  AppStorage.setOrCreate(StorageConstants.DEVICE_TYPE, deviceType)
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
 * 加载上一次的播放内容
 */
async function loadSavedSong() {
  let has = await PreferencesUtils.getPreferenceValue<boolean>('Play','hasCurrentSong', false)
  let song:Song = {
    id: 0,
    name: "暂无播放",
    artists: [],
    duration: 0,
    alias: []
  }
  let artists = '选择一首歌曲播放吧'
  let picUrl: string = ''
  let playMode: number = 0

  if(has) {
    song = await PreferencesUtils.getPreferenceValue<Song>('Play', 'CurrentSong', SongClass)
    playMode = await PreferencesUtils.getPreferenceValue<number>('Play', 'PlayMode', 1)
    artists = await PreferencesUtils.getPreferenceValue<string>('Play', 'CurrentArtists', '')
    picUrl = await PreferencesUtils.getPreferenceValue<string>('Play', 'CurrentImage', '')
    let currentIndex = await PreferencesUtils.getPreferenceValue<number>('Play', 'CurrentQueueIndex', 0)
    await PlayQueueUtils.setIndex(currentIndex)
  }
  AppStorage.setOrCreate(StorageConstants.PLAY_MODE, playMode)
  AppStorage.setOrCreate(StorageConstants.PLAY_SONG, song)
  AppStorage.setOrCreate(StorageConstants.PLAY_ARTISTS, artists)
  AppStorage.setOrCreate(StorageConstants.PIC_URL, picUrl)
}

/**
 * 获取当前设备类型
 */
async function getDeviceTypeInfo(): Promise<resourceManager.DeviceType> {
  let deviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  try {
    deviceType = getContext().resourceManager.getDeviceCapabilitySync().deviceType
  } catch (e) {
    LogUtil.error(TAG + 'Failed to get device type: ' + e.message)
  }
  return deviceType
}
