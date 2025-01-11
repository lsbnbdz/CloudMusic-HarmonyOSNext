import { EmitterUtil, FileUtil, LogUtil, RandomUtil, ToastUtil } from "@pura/harmony-utils";
import { Song } from "../entities/SongsResult";
import AudioPlayUtils from "../utils/AudioPlayUtils";
import ContinuousTask from "../utils/ContinuousTask";
import Constants from "../constants/Constants";
import FileUtils from "../utils/FileUtils";
import { getSongPicUrl, getSongUrl } from "../../api/songApi";
import { fetchMetadata, fetchSongInfo, sanitizeFileName } from "./functions";
import PlayQueueUtils from "../utils/PlayQueueUtils";
import AVSessionUtils from "../utils/AVSessionUtils";
import { promptAction } from "@kit.ArkUI";
import PreferencesUtils from "../utils/PreferencesUtils";
import { fileIo } from "@kit.CoreFileKit";
import { SongPlay } from "../entities/SongPlay";
import { setLyric } from "../../api/LyricApi";

/**
 * 音频播放控制方法
 */
const TAG = '[playerControl] '
const pref = Constants.QUEUE_PREF

export async function playMusicByUrl(song:Song,artists:string,isLogged:boolean) {
  try {
    LogUtil.info(TAG + 'Play Music By Url: ' + `Song: ${JSON.stringify(song)}` + '\n' + `artists: ${JSON.stringify(artists)}`)
    const quality:number | undefined = await AppStorage.get('set-playQuality')
    const songPlay:SongPlay = await getSongUrl(song.id, quality ? Constants.QUALITY[quality] : "standard", isLogged)
    let fileNameFomatted = sanitizeFileName(`${artists} - ${song.name}`)
    let localPath = await FileUtils.accessLocalFile(fileNameFomatted)

    setLyric(song.id)
    AppStorage.setOrCreate('player-mode', 1)
    AppStorage.setOrCreate('player-ispaused',false)
    AppStorage.setOrCreate('player-song',song)
    AppStorage.setOrCreate('player-artists',artists)
    // 是否存在本地文件
    if(localPath != '') {
      promptAction.showToast({ message: '找到本地文件，将优先播放本地文件'})
      await AudioPlayUtils.setUrl(localPath)
    } else if(songPlay.data[0].url) {
      await AudioPlayUtils.setUrl(songPlay.data[0].url)
    } else {
      ToastUtil.showToast('获取播放资源失败')
      playNext()
    }
    AppStorage.setOrCreate('player-isplaying', true)
    const picUrl:string = await getSongPicUrl(song)
    AppStorage.setOrCreate('player-picurl', picUrl)
    AVSessionUtils.setMetadata(song, artists, picUrl)
    AVSessionUtils.activate()
    saveCurrentSongInfo(1, song, artists, picUrl)
  } catch (e) {
    LogUtil.error(TAG + '播放出错: ' + e)
    playNext()
  }
}

export async function playMusicWithFile(fileName:string) {
  try {
    const rootUrl = await FileUtils.getFilesDir()
    const fileUrl = rootUrl + `/${fileName}`
    let file = await fileIo.open(fileUrl)
    let fdPath = 'fd://' + file.fd

    const metadata = await fetchMetadata(fileUrl)
    let song = await fetchSongInfo(fileName)
    if(metadata) {
      song.duration = (metadata.duration) ? parseInt(metadata.duration) : 0
    }
    LogUtil.info(TAG + fileUrl)
    if(FileUtil.accessSync(fileUrl)) {
      AppStorage.setOrCreate('player-mode', 0)
      AppStorage.setOrCreate('player-fileName',fileName)
      AppStorage.setOrCreate('player-ispaused', false)
      AppStorage.setOrCreate('player-song', song)
      AppStorage.setOrCreate('player-artists', song.artists[0].name)
      AppStorage.setOrCreate('player-picurl','/resources/base/media/app.media.ic_public_music.svg')
      AppStorage.setOrCreate('player-lyric',[])
      await ContinuousTask.stopTask()
      await AudioPlayUtils.setUrl(fdPath)
      AVSessionUtils.setMetadata(song,song.artists[0].name,`$r('app.media.ic_public_music.svg')`)
      AVSessionUtils.activate()
      AppStorage.setOrCreate('player-isplaying',true)
      saveCurrentSongInfo(0, song, song.artists[0].name, '/resources/base/media/app.media.ic_public_music.svg')
      EmitterUtil.post(Constants.EMITTER_LYRIC_UPDATE,'Lyric Updated')
    } else {
      ToastUtil.showToast('未找到文件')
      playNext()
    }
  } catch (e) {
    LogUtil.error(TAG + '播放歌曲失败: ' + JSON.stringify(e))
    ToastUtil.showToast('播放失败: ' + JSON.stringify(e))
    playNext()
  }
}

export async function stopMusic() {
  AudioPlayUtils.stop().then(() => {
    AppStorage.setOrCreate('player-isplaying',false)
    AudioPlayUtils.mPlayer.release()
  })
}

export async function pauseMusic() {
  AudioPlayUtils.pause()
  AppStorage.setOrCreate('player-ispaused',true)
}

export async function resumeMusic() {
  AudioPlayUtils.resume()
  AppStorage.setOrCreate('player-ispaused',false)
}

export async function seekMusic(time: number) {
  AudioPlayUtils.play()
  AudioPlayUtils.seek(time)
}

export async function playQueue(index:number) {
  const queue = PlayQueueUtils.getQueue()
  const playqueue = queue[index]
  const isLogged:boolean | undefined = AppStorage.get('isValidCookie')
  if(playqueue.playmode == 0) { // Play with file
    playMusicWithFile(playqueue.fileName).then(() => {
      PlayQueueUtils.setIndex(index)
    })
  } else { // Play with url
    playMusicByUrl(playqueue.song, playqueue.artists, isLogged ? true : false).then(() => {
      PlayQueueUtils.setIndex(index)
    })
  }
}

export async function playPre() {
  let isValidCookie:boolean | undefined = await AppStorage.get('isValidCookie')
  let cycleMode = await getCycleMode()
  if(PlayQueueUtils.pre()) {
    const res = PlayQueueUtils.getQueueElement(PlayQueueUtils.currentQueueIndex)
    if(res.playmode == 0) {
      playMusicWithFile(res.fileName)
    } else {
      playMusicByUrl(res.song, res.artists, isValidCookie?isValidCookie:false)
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
  let isValidCookie:boolean | undefined = await AppStorage.get('isValidCookie')
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
      playMusicByUrl(res.song, res.artists, isValidCookie ? isValidCookie:false)
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
  AppStorage.setOrCreate('cycleMode', mode)
  PreferencesUtils.putPreferenceValue(pref,'cycleMode', mode).then(async () => {
    promptAction.showToast({ message: `${Constants.CYCLE_MODE[mode]}` })
    AVSessionUtils.playState(await getPlayTime())
  })
}

/**
 * 获取循环模式
 * @returns number-mode
 */
export async function getCycleMode(): Promise<number> {
  const mode: number | undefined = await AppStorage.get('cycleMode')
  if(mode) {
    return mode
  } else return 0
}

/**
 * 保存当前播放的歌曲信息
 */
export async function saveCurrentSongInfo(playMode: number, song: Song, artists: string, imgUrl: string) {
  await PreferencesUtils.putPreferenceValue('Play','hasCurrentSong', true)
  await PreferencesUtils.putPreferenceValue('Play','PlayMode', playMode)
  await PreferencesUtils.putPreferenceValue('Play','CurrentSong', song)
  await PreferencesUtils.putPreferenceValue('Play','CurrentArtists', artists)
  await PreferencesUtils.putPreferenceValue('Play','CurrentImage', imgUrl)
  await PreferencesUtils.putPreferenceValue('Play','CurrentQueueIndex', PlayQueueUtils.currentQueueIndex)
}

/**
 * 获取播放时间(ms)
 * @returns number 播放时间(ms)
 */
async function getPlayTime(): Promise<number> {
  let resTime = 0
  let elapsedTime:number | undefined = await AppStorage.get('player-time')
  if(elapsedTime) {
    resTime = elapsedTime
  }
  return resTime
}