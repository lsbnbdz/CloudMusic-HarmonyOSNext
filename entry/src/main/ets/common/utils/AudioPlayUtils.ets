import { LogUtil, ToastUtil } from '@pura/harmony-utils'
import { EfAVPlayer } from '@yunkss/ef_audio'
import ContinuousTask from './ContinuousTask'
import AVSessionUtils from './AVSessionUtils'
import { completeDo } from '../functions/playerControl'
import { changeDuration } from '../functions/functions'
import LyricUtils from './LyricUtils'

/**
 * 音频播放工具
 * AudioPlayUtils
 */
const TAG = '[AudioPlayUtils] '

class AudioPlayUtils {
  mPlayer: EfAVPlayer = new EfAVPlayer()

  updateAvSession = 0

  async init() {
    try {
      await this.mPlayer.init({ immediately: false, loop: false })
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
    LyricUtils.startInterval()
    ContinuousTask.startTask()
    await this.mPlayer.play()
    AVSessionUtils.playState(this.mPlayer.currentTime)

    this.updateAvSession = setInterval(() => {
      if(this.mPlayer.state == 'playing') {
        AVSessionUtils.playState(this.mPlayer.currentTime)
      }
    }, 1000)

    this.mPlayer.onTimeUpdate((time) => {
      AppStorage.setOrCreate('player-time',time)
    })
  }

  async stop() {
    this.clearInterval()
    this.mPlayer.stop()
    ContinuousTask.stopTask()
    LogUtil.info(TAG + '停止播放')
  }

  async pause() {
    this.clearInterval()
    this.mPlayer.pause()
    LogUtil.info(TAG + '暂停播放')
  }

  async resume() {
    this.play()
    LogUtil.info(TAG + '继续播放')
  }

  async seek(time: number) {
    this.mPlayer.currentTime = time
    this.mPlayer.seek(time)
    AVSessionUtils.playState(time)
    LogUtil.info(TAG + `跳转至 ${time} ( ${changeDuration(time)} )`)
  }

  clearInterval() {
    clearInterval(this.updateAvSession)
    LyricUtils.endInterval()
  }

  onState() {
    this.mPlayer.onStateChange(async (state) => {
      if(state == 'prepared') { this.play(); }
      if(state == 'playing') { AppStorage.setOrCreate('player-isplaying', true); AppStorage.setOrCreate('player-ispaused', false); }
      if(state == 'paused') { this.clearInterval(); AppStorage.setOrCreate('player-ispaused', true); AVSessionUtils.pauseState(this.mPlayer.currentTime) }
      if(state == 'idle') { this.clearInterval(); AVSessionUtils.deactive() }
      if(state == 'stopped') { this.clearInterval(); AppStorage.setOrCreate('player-ispaused', true); ContinuousTask.stopTask() }
      if(state == 'completed') { this.clearInterval(); AppStorage.setOrCreate('player-ispaused', true); ContinuousTask.stopTask(); completeDo() }
    })
  }
}

const audioPlayUtils = new AudioPlayUtils()
export default audioPlayUtils as AudioPlayUtils
