import { LogUtil } from '@pura/harmony-utils'
import { EfAVPlayer } from '@yunkss/ef_audio'
import { Song } from '../entities/SongsResult'

const TAG = '[AudioPlayUtils] '

class AudioPlayUtils {
  mPlayer: EfAVPlayer = new EfAVPlayer()

  async init() {
    try {
      await this.mPlayer.init({ immediately: true, loop: false })
      LogUtil.info(TAG + '播放器初始化完成')
    } catch (e) {
      LogUtil.error(TAG + '播放器初始化失败')
      throw new Error(e)
    }
  }

  async setUrl(url: string) {
    await this.mPlayer.setUrl(url)
    LogUtil.info(TAG + '成功设置播放Url: ' + url)
  }

  async play(url?:string) {
    try {
      await this.init()
      if (url) {
        await this.setUrl(url)
      }
      LogUtil.info(TAG + '开始播放: ' + url)
      this.mPlayer.play()
    } catch (e) {
      AppStorage.setOrCreate('player-isplaying',false)
      LogUtil.error(TAG + '播放失败: ' + JSON.stringify(e))
    }
  }

  async stop() {
    await this.mPlayer.stop()
    LogUtil.info(TAG + '停止播放')
  }

  async pause() {
    await this.mPlayer.pause()
    LogUtil.info(TAG + '暂停播放')
  }

  async resume() {
    await this.mPlayer.play()
    LogUtil.info(TAG + '继续播放')
  }

}

const audioPlayUtils = new AudioPlayUtils()
export default audioPlayUtils as AudioPlayUtils
