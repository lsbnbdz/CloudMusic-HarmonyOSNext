import { FileUtil, LogUtil, RandomUtil, ToastUtil } from "@pura/harmony-utils";
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

/**
 * 音频播放控制方法
 */
const TAG = '[playerControl] '
const pref = Constants.QUEUE_PREF

export async function playMusicByUrl(song:Song,artists:string,picUrl:string,isLogged:boolean) {
  try {
    const quality:number | undefined = await AppStorage.get('set-playQuality')
    const songPlay = await getSongUrl(song.id, quality ? Constants.QUALITY[quality] : "standard", isLogged)
    if(songPlay.data[0].url) {
      AppStorage.setOrCreate('player-mode', 1)
      AppStorage.setOrCreate('player-ispaused',false)
      AppStorage.setOrCreate('player-isplaying',false)
      AppStorage.setOrCreate('player-song',song)
      AppStorage.setOrCreate('player-artists',artists)
      AppStorage.setOrCreate('player-picurl',picUrl)
      await ContinuousTask.stopTask()
      // 是否存在本地文件
      let fileNameFomatted = sanitizeFileName(`${artists} - ${song.name}`)
      let localPath = await FileUtils.accessLocalFile(fileNameFomatted)
      if(localPath != '') {
        promptAction.showToast({ message: '找到本地文件，将优先播放本地文件'})
        await AudioPlayUtils.setUrl(localPath)
      }
      else { await AudioPlayUtils.setUrl(songPlay.data[0].url) }
      AVSessionUtils.setMetadata(song,artists,picUrl)
      ContinuousTask.startTask().then(() => {
        AudioPlayUtils.play().then(() => {
          AVSessionUtils.activate()
          AppStorage.setOrCreate('player-isplaying',true)
        })
      })
    } else {
      ToastUtil.showToast('获取播放资源失败')
    }
  } catch (e) {
    LogUtil.error(TAG + '播放歌曲失败: ' + e)
    ToastUtil.showToast('播放失败: ' + e)
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
      AppStorage.setOrCreate('player-isplaying', false)
      AppStorage.setOrCreate('player-song', song)
      AppStorage.setOrCreate('player-artists', song.artists[0].name)
      AppStorage.setOrCreate('player-picurl','/resources/base/media/app.media.ic_public_music.svg')
      await ContinuousTask.stopTask()
      await AudioPlayUtils.setUrl(fdPath)
      AVSessionUtils.setMetadata(song,song.artists[0].name,`$r('app.media.ic_public_music.svg')`)
      ContinuousTask.startTask().then(() => {
        AudioPlayUtils.play().then(() => {
          AVSessionUtils.activate()
          AppStorage.setOrCreate('player-isplaying',true)
        })
      })
    } else {
      ToastUtil.showToast('未找到文件')
    }
  } catch (e) {
    LogUtil.error(TAG + '播放歌曲失败: ' + JSON.stringify(e))
    ToastUtil.showToast('播放失败: ' + JSON.stringify(e))
  }
}

export async function stopMusic() {
  await AudioPlayUtils.stop().then(() => {
    AppStorage.setOrCreate('player-isplaying',false)
    AudioPlayUtils.mPlayer.release()
  })
}

export async function pauseMusic() {
  await AudioPlayUtils.pause().then(() => {
    AppStorage.setOrCreate('player-ispaused',true)
  })
}

export async function resumeMusic() {
  await AudioPlayUtils.resume().then(() => {
    AppStorage.setOrCreate('player-ispaused',false)
  })
}

export async function seekMusic(time: number) {
  await AudioPlayUtils.seek(time)
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
    const picUrl = await getSongPicUrl(playqueue.song)
    playMusicByUrl(playqueue.song, playqueue.artists, picUrl, isLogged ? true : false).then(() => {
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
      let picUrl = await getSongPicUrl(res.song)
      playMusicByUrl(res.song, res.artists, picUrl, isValidCookie?isValidCookie:false)
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
      let picUrl = await getSongPicUrl(res.song)
      playMusicByUrl(res.song, res.artists, picUrl, isValidCookie?isValidCookie:false)
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
  PreferencesUtils.putPreferenceValue(pref,'cycleMode', mode).then(() => {
    promptAction.showToast({ message: `${Constants.CYCLE_MODE[mode]}` })
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
