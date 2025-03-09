import { EmitterUtil, FileUtil, LogUtil, RandomUtil, ToastUtil } from "@pura/harmony-utils";
import { Song } from "../../entities/SongsResult";
import FileUtils from "../../utils/file/FileUtils";
import {getSongPicUrl, getSongUrl } from "../../../api/songApi";
import { fetchMetadata, fetchSongInfo, sanitizeFileName } from "../common/convert";
import PlayQueueUtils from "../../utils/play/PlayQueueUtils";
import AVSessionUtils from "../../utils/play/AVSessionUtils";
import PreferencesUtils from "../../utils/data/PreferencesUtils";
import { fileIo } from "@kit.CoreFileKit";
import { SongPlay } from "../../entities/SongPlay";
import LyricUtils from "../../utils/play/LyricUtils";
import { PlayConstants } from "../../constants/PlayConstants";
import { EmitterConstants } from "../../constants/EmitterConstants";
import { StorageConstants } from "../../constants/StorageConstants";
import { JSON } from "@kit.ArkTS";
import AVPlayerUtils from "../../utils/play/AVPlayerUtils";
import { isThisSongLiked } from "./songLike";


/**
 * 音频播放控制方法
 */
const TAG = '[playerControl] '
const pref = StorageConstants.QUEUE_PREF

export async function playMusicByUrl(song: Song, artists: string, isLogged: boolean, picUrl: string | ResourceStr = '') {
  try {
    isThisSongLiked(song.id)
    const quality:number | undefined = await AppStorage.get(StorageConstants.PLAY_QUALITY)
    const songPlay:SongPlay = await getSongUrl(song.id, quality ? PlayConstants.QUALITY[quality] : "standard", isLogged)
    setPlayData(1, song, artists)
    let localPath: string = ''
    let tempArtists: string = artists
    try {
      if(song.name.length + artists.length >= 103) {
        try { tempArtists = artists.slice(0, 100 - song.name.length) }
        catch (e) { artists = '未知' }
      }
      localPath = await FileUtils.accessLocalFile(sanitizeFileName(`${tempArtists} - ${song.name}`))
    } catch (e) {}

    if(localPath != '') { // 是否存在本地文件
      AppStorage.setOrCreate(StorageConstants.PLAY_IS_LOCALFILE, true)
      await AVPlayerUtils.setUrl(localPath)
    } else if(songPlay.data[0].url) {
      AppStorage.setOrCreate(StorageConstants.PLAY_IS_LOCALFILE, false)
      await AVPlayerUtils.setUrl(songPlay.data[0].url)
    } else {
      ToastUtil.showToast('获取播放资源失败')
      playNext()
    }
    if(!picUrl) {
      picUrl = await getSongPicUrl(song.id)
    }
    setPicUrl(picUrl)
    LyricUtils.setLyric(song).then(() => {
      AVSessionUtils.setMetadata(song, artists, picUrl)
      AVSessionUtils.activate()
    })
    saveCurrentSongInfo(1, song, artists, picUrl)
  } catch (e) {
    LogUtil.error(TAG + '播放Url出错: ' + e)
    playNext()
  }
}

export async function playMusicWithFile(fileName:string) {
  try {
    AppStorage.setOrCreate(StorageConstants.ISLIKED, true)
    const rootUrl = await FileUtils.getFilesDir()
    const fileUrl = rootUrl + `/${fileName}`
    let file = await fileIo.open(fileUrl)
    let fdPath = 'fd://' + file.fd
    const metadata = await fetchMetadata(fileUrl)
    let song = await fetchSongInfo(fileName)
    if(metadata) {
      song.duration = (metadata.duration) ? parseInt(metadata.duration) : 0
    }
    if(FileUtil.accessSync(fileUrl)) {
      setPlayData(0, song, song.artists[0].name, fileName)
      setPicUrl($r('app.media.ic_public_music'))
      await AVPlayerUtils.setUrl(fdPath)
      LyricUtils.setLyricArr([])
      LyricUtils.lyricString = ''
      AVSessionUtils.setMetadata(song,song.artists[0].name,`$r('app.media.ic_public_music.svg')`)
      AVSessionUtils.activate()
      saveCurrentSongInfo(0, song, song.artists[0].name, $r('app.media.ic_public_music'))
      EmitterUtil.post(EmitterConstants.EMITTER_LYRIC_UPDATE,'Lyric Updated')
    } else {
      ToastUtil.showToast('未找到文件')
      playNext()
    }
  } catch (e) {
    LogUtil.error(TAG + '播放File出错: ' + JSON.stringify(e))
    playNext()
  }
}

export async function stopMusic() {
  AVPlayerUtils.stop().then(() => {
    AppStorage.setOrCreate(StorageConstants.IS_PLAYING, false)
    AVPlayerUtils.release()
  })
}

export async function pauseMusic() {
  AVPlayerUtils.pause()
  AppStorage.setOrCreate(StorageConstants.IS_PAUSED, true)
}

export async function resumeMusic() {
  AVPlayerUtils.play()
  AppStorage.setOrCreate(StorageConstants.IS_PAUSED, false)
}

export async function seekMusic(time: number) {
  AVPlayerUtils.play()
  AVPlayerUtils.seek(time)
}

export async function playQueue(index: number) {
  const queue = PlayQueueUtils.getQueue()
  const playqueue = queue[index]
  PlayQueueUtils.setIndex(index)
  if(playqueue.playmode == 0) { // Play with file
    playMusicWithFile(playqueue.fileName)
  } else { // Play with url
    const isLogged: boolean | undefined = AppStorage.get(StorageConstants.IS_LOGGED)
    playMusicByUrl(playqueue.song, playqueue.artists, isLogged ? true : false, playqueue.picUrl)
  }
}

export async function playPre() {
  let isLogged: boolean | undefined = await AppStorage.get(StorageConstants.IS_LOGGED)
  let cycleMode = await getCycleMode()
  if(PlayQueueUtils.pre()) {
    const res = PlayQueueUtils.getQueueElement(PlayQueueUtils.currentQueueIndex)
    if(res.playmode == 0) {
      playMusicWithFile(res.fileName)
    } else {
      playMusicByUrl(res.song, res.artists, isLogged ? isLogged : false, res.picUrl)
    }
  } else {
    if(cycleMode == 2) { playQueue(PlayQueueUtils.getQueueLength() - 1) }
    else { ToastUtil.showToast('没有上一首了~') }
  }
}

/**
 * 播放下一首
 */
export async function playNext() {
  let isLogged:boolean | undefined = await AppStorage.get(StorageConstants.IS_LOGGED)
  let cycleMode = await getCycleMode()
  if(cycleMode == 3) {
    let queueLength = PlayQueueUtils.getQueueLength()
    let randomIndex = RandomUtil.getRandomInt(0, queueLength - 1)
    playQueue(randomIndex)
  }
  // 存在下一首歌曲
  else if(PlayQueueUtils.next()) {
    const res = PlayQueueUtils.getQueueElement(PlayQueueUtils.currentQueueIndex)
    if(res.playmode == 0) {
      playMusicWithFile(res.fileName)
    } else {
      playMusicByUrl(res.song, res.artists, isLogged ? isLogged:false, res.picUrl)
    }
  } else {
    if(cycleMode == 2) { playQueue(0) }
    else { ToastUtil.showToast('没有下一首了~') }
  }
}

/**
 * 本首歌曲播放完成后的操作
 */
export async function completeDo() {
  let cycleMode = await getCycleMode()
  // 顺序播放 & 顺序循环
  if(cycleMode == 0 || cycleMode == 2) {
    playNext()
  }
  // 单曲循环
  else if(cycleMode == 1) {
    let currentQueueIndex = PlayQueueUtils.currentQueueIndex
    playQueue(currentQueueIndex)
  }
  // 随机播放
  else if(cycleMode == 3) {
    let queueLength = PlayQueueUtils.getQueueLength()
    let randomIndex = RandomUtil.getRandomInt(0, queueLength - 1)
    playQueue(randomIndex)
  }
}

/**
 * 设置循环模式
 * 0-顺序播放, 1-单曲循环, 2-顺序循环, 3-随机播放
 * @param mode
 */
export async function changeCycleMode(mode: number) {
  AppStorage.setOrCreate(StorageConstants.CYCLE_MODE, mode)
  PreferencesUtils.putPreferenceValue(pref,StorageConstants.CYCLE_MODE, mode).then(async () => {
    AVSessionUtils.playState(await getPlayTime())
  })
}

/**
 * 获取循环模式
 * @returns number-mode
 */
export async function getCycleMode(): Promise<number> {
  const mode: number | undefined = await AppStorage.get(StorageConstants.CYCLE_MODE)
  if(mode) {
    return mode
  } else return 0
}

/**
 * 获取播放时间(ms)
 * @returns number 播放时间(ms)
 */
async function getPlayTime(): Promise<number> {
  let resTime = 0
  let elapsedTime:number | undefined = await AppStorage.get(StorageConstants.PLAY_TIME)
  if(elapsedTime) {
    resTime = elapsedTime
  }
  return resTime
}

/**
 * 设定播放歌曲信息
 * @param mode
 * @param song
 * @param artists
 * @param fileName
 */
async function setPlayData(mode: number, song:Song, artists: string, fileName: string = '') {
  AppStorage.setOrCreate(StorageConstants.IS_PLAYING ,true)
  AppStorage.setOrCreate(StorageConstants.IS_PAUSED, false)
  AppStorage.setOrCreate(StorageConstants.PLAY_MODE, mode)
  AppStorage.setOrCreate(StorageConstants.PLAY_FILE_NAME, fileName)
  AppStorage.setOrCreate(StorageConstants.PLAY_SONG, song)
  AppStorage.setOrCreate(StorageConstants.PLAY_ARTISTS, artists)
}

/**
 * 设定歌曲封面
 * @param picUrl
 */
async function setPicUrl(picUrl: string | ResourceStr) {
  AppStorage.setOrCreate('player-picurl', picUrl)
}

/**
 * 保存当前播放的歌曲信息
 */
export async function saveCurrentSongInfo(playMode: number, song: Song, artists: string, imgUrl: string | ResourceStr) {
  await PreferencesUtils.putPreferenceValue('Play','hasCurrentSong', true)
  await PreferencesUtils.putPreferenceValue('Play','PlayMode', playMode)
  await PreferencesUtils.putPreferenceValue('Play','CurrentSong', song)
  await PreferencesUtils.putPreferenceValue('Play','CurrentArtists', artists)
  await PreferencesUtils.putPreferenceValue('Play','CurrentImage', imgUrl)
  await PreferencesUtils.putPreferenceValue('Play','CurrentQueueIndex', PlayQueueUtils.currentQueueIndex)
}