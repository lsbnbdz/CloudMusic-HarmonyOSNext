import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import { getSongUrl } from "../../api/getSongUrl";
import { Song } from "../entities/SongsResult";
import AudioPlayUtils from "../utils/AudioPlayUtils";

const TAG = '[playerControl] '

export async function playMusic(song:Song,artists:string,picUrl:string) {
  try {
    const songPlay = await getSongUrl(song.id)
    if(songPlay.data[0].url) {
      AppStorage.setOrCreate('player-isplaying',false)
      AppStorage.setOrCreate('player-songname',song.name)
      AppStorage.setOrCreate('player-artists',artists)
      AppStorage.setOrCreate('player-picurl',picUrl)

      await AudioPlayUtils.mPlayer.reset().then(async () => {
        LogUtil.info(TAG + songPlay.data[0].url)
        await AudioPlayUtils.play(songPlay.data[0].url).then(() => {
          AppStorage.setOrCreate('player-isplaying',true)
        })
        ToastUtil.showToast('开始播放歌曲: ' + song.name)
      })
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
