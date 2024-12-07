import { FileUtil, LogUtil, ToastUtil } from "@pura/harmony-utils";
import { Song } from "../entities/SongsResult";
import AudioPlayUtils from "../utils/AudioPlayUtils";
import ContinuousTask from "../utils/ContinuousTask";
import Constants from "../constants/Constants";
import FileUtils from "../utils/FileUtils";
import { getSongPicUrl, getSongUrl } from "../../api/songApi";
import { fetchMetadata, fetchSongInfo } from "./functions";
import PlayQueueUtils from "../utils/PlayQueueUtils";
import AVSessionUtils from "../utils/AVSessionUtils";

/**
 * 音频播放控制方法
 */
const TAG = '[playerControl] '

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
      await AudioPlayUtils.mPlayer.reset()
      await ContinuousTask.stopTask()
      ContinuousTask.startTask()
      AVSessionUtils.setMetadata(song,artists,picUrl)

      AudioPlayUtils.playWithUrl(songPlay.data[0].url)
      AVSessionUtils.activate()

      ToastUtil.showToast('开始播放歌曲: ' + song.name)
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
      AppStorage.setOrCreate('player-picurl',`${$r('app.media.ic_public_music')}`)
      await AudioPlayUtils.mPlayer.reset()
      await ContinuousTask.stopTask()
      ContinuousTask.startTask()
      AVSessionUtils.setMetadata(song,song.artists[0].name,'')

      AudioPlayUtils.playWithFile(fileName)
      AVSessionUtils.activate()
      ToastUtil.showToast(`开始播放: ${fileName}`)
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

export async function playQueue(index:number) {
  const queue = PlayQueueUtils.getQueue()
  const playqueue = queue[index]
  const picUrl = await getSongPicUrl(playqueue.song)
  const isLogged:boolean | undefined = AppStorage.get('isValidCookie')
  if(playqueue.playmode == 0) { // Play with file

  } else { // Play with url
    playMusicByUrl(playqueue.song, playqueue.artists, picUrl, isLogged ? true : false).then(() => {
      PlayQueueUtils.setIndex(index)
    })
  }
}

export async function playPre() {
  let isValidCookie:boolean | undefined = await AppStorage.get('isValidCookie')
  if(PlayQueueUtils.pre()) {
    const res = PlayQueueUtils.getQueueElement(PlayQueueUtils.currentQueueIndex)
    if(res.playmode == 0) {
      playMusicWithFile(res.fileName)
    } else {
      let picUrl = await getSongPicUrl(res.song)
      playMusicByUrl(res.song, res.artists, picUrl, isValidCookie?isValidCookie:false)
    }
  } else { ToastUtil.showToast('没有上一首了~') }
}

export async function playNext() {
  let isValidCookie:boolean | undefined = await AppStorage.get('isValidCookie')
  if(PlayQueueUtils.next()) {
    const res = PlayQueueUtils.getQueueElement(PlayQueueUtils.currentQueueIndex)
    if(res.playmode == 0) {
      playMusicWithFile(res.fileName)
    } else {
      let picUrl = await getSongPicUrl(res.song)
      playMusicByUrl(res.song, res.artists, picUrl, isValidCookie?isValidCookie:false)
    }
  } else { ToastUtil.showToast('没有下一首了~') }
}
