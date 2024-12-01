import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import { getSongUrl } from "../../api/getSongUrl";
import { QualityType } from "../entities/SongDownload";
import { Song } from "../entities/SongsResult";
import AudioPlayUtils from "../utils/AudioPlayUtils";
import ContinuousTask from "../utils/ContinuousTask";
import { constant } from "@kit.NearLinkKit";
import Constants from "../constants/Constants";

/**
 * 音频播放控制
 */
const TAG = '[playerControl] '

export async function playMusic(song:Song,artists:string,picUrl:string,isLogged:boolean) {
  try {
    const quality:number | undefined = await AppStorage.get('set-playQuality')
    const songPlay = await getSongUrl(song.id, quality ? Constants.QUALITY[quality] : "standard", isLogged)

    if(songPlay.data[0].url) {
      AppStorage.setOrCreate('player-ispaused',false)
      AppStorage.setOrCreate('player-isplaying',false)
      AppStorage.setOrCreate('player-song',song)
      AppStorage.setOrCreate('player-artists',artists)
      AppStorage.setOrCreate('player-picurl',picUrl)
      await AudioPlayUtils.mPlayer.reset()
      await ContinuousTask.stopTask()
      ContinuousTask.startTask(song, artists, picUrl, songPlay.data[0].url)
      ToastUtil.showToast('开始播放歌曲: ' + song.name)
    } else {
      ToastUtil.showToast('获取播放资源失败')
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
