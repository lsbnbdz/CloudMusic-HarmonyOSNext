import { FileUtil, LogUtil, ToastUtil } from "@pura/harmony-utils";
import { getSongUrl } from "../../api/getSongUrl";
import { Song, SongClass } from "../entities/SongsResult";
import AudioPlayUtils from "../utils/AudioPlayUtils";
import ContinuousTask from "../utils/ContinuousTask";
import Constants from "../constants/Constants";
import FileUtils from "../utils/FileUtils";
import { getSongInfo } from "../../api/getSongInfo";
import { getArtists } from "./functions";
import { getSongPicUrl } from "../../api/getSongDetails";

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
      ContinuousTask.startPlay(1, songPlay.data[0].url)
      ToastUtil.showToast('开始播放歌曲: ' + song.name)
    } else {
      ToastUtil.showToast('获取播放资源失败')
    }
  } catch (e) {
    LogUtil.error(TAG + '播放歌曲失败: ' + JSON.stringify(e))
    ToastUtil.showToast('播放失败')
  }
}

export async function playMusicWithFile(fileName:string) {
  try {
    const fileUrl = await FileUtils.getFilesDir()
    const url = fileUrl + `/${fileName}`
    // const song = await getSongInfo(fileName)
    LogUtil.info(TAG + url)
    if(FileUtil.accessSync(url)) {
      AppStorage.setOrCreate('player-mode', 0)
      AppStorage.setOrCreate('player-fileName',fileName)
      AppStorage.setOrCreate('player-ispaused', false)
      AppStorage.setOrCreate('player-isplaying', false)
      AppStorage.setOrCreate('player-song', SongClass)
      AppStorage.setOrCreate('player-artists', fileName)
      await AudioPlayUtils.mPlayer.reset()
      await ContinuousTask.stopTask()
      ContinuousTask.startPlay(0, fileName)
      ToastUtil.showToast(`开始播放: ${fileName}`)
    } else {
      ToastUtil.showToast('未找到文件')
    }
  } catch (e) {
    LogUtil.error(TAG + '播放歌曲失败: ' + JSON.stringify(e))
    ToastUtil.showToast('播放失败')
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
