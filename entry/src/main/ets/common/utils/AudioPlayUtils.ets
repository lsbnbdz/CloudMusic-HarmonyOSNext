import { LogUtil } from '@pura/harmony-utils'
import { EfAVPlayer } from '@yunkss/ef_audio'
import ContinuousTask from './ContinuousTask'
import AVSessionUtils from './AVSessionUtils'
import { completeDo } from '../functions/playerControl'
import { changeDuration } from '../functions/functions'

/**
 * 音频播放工具
 * AudioPlayUtils
 */
const TAG = '[AudioPlayUtils] '

class AudioPlayUtils {
  mPlayer: EfAVPlayer = new EfAVPlayer()

  async init() {
    try {
      await this.mPlayer.init({ immediately: true, loop: false })
      this.onState()
      LogUtil.info(TAG + '播放器初始化完成')
    } catch (e) {
      LogUtil.error(TAG + '播放器初始化失败')
      throw new Error(e)
    }
  }

  async reset() {
    await this.mPlayer.reset()
  }

  async setUrl(url: string) {
    await this.reset()
    await this.init()
    await this.mPlayer.setUrl(url)
  }

  async play() {
    await this.mPlayer.play()
    this.mPlayer.onTimeUpdate((time) => {
      AVSessionUtils.playState()
      AppStorage.setOrCreate('player-time',time)
    })
  }

  async stop() {
    await this.mPlayer.stop()
    ContinuousTask.stopTask()
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

  async seek(time: number) {
    await this.mPlayer.seek(time)
    LogUtil.info(TAG + `跳转至 ${time} ( ${changeDuration(time)} )`)
  }



  onState() {
    this.mPlayer.onStateChange(async (state) => {
      if(state == 'prepared') { AVSessionUtils.bufferingState() }
      if(state == 'playing') { AppStorage.setOrCreate('player-isplaying', true); AVSessionUtils.playState() }
      if(state == 'paused') { AppStorage.setOrCreate('playerw-ispaused', true); AVSessionUtils.pauseState() }
      if(state == 'idle') { AVSessionUtils.deactive() }
      if(state == 'stopped') { AppStorage.setOrCreate('player-ispaused', true); ContinuousTask.stopTask() }
      if(state == 'completed') { AppStorage.setOrCreate('player-ispaused', true); ContinuousTask.stopTask(); completeDo() }
    })
  }
}

const audioPlayUtils = new AudioPlayUtils()
export default audioPlayUtils as AudioPlayUtils
