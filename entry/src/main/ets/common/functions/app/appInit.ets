import { LogUtil } from "@pura/harmony-utils"
import { getAnnouncement } from "../../../api/chenlvinApi"
import { Song, SongClass } from "../../entities/SongsResult"
import PlayQueueUtils from "../../utils/play/PlayQueueUtils"
import PreferencesUtils from "../../utils/app/PreferencesUtils"
import { StorageConstants } from "../../constants/StorageConstants"

/**
 * App初始化
 */
const TAG = '[appInit] '

export async function appInit() {
  await initSettings()
  await initPlayQueue()
  await audioPlayerInit()
  await loadSavedSong()
  await getAnnouncement()
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
  const SetPerf: string = StorageConstants.SET_PERF

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
    await PreferencesUtils.putPreferenceValue(SetPerf, 'isUsePubCookie', false)
    AppStorage.setOrCreate('set-isUsePubCookie', false)
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
  AppStorage.setOrCreate('player-mode', playMode)
  AppStorage.setOrCreate('player-song',song)
  AppStorage.setOrCreate('player-artists',artists)
  AppStorage.setOrCreate('player-picurl',picUrl)
}
