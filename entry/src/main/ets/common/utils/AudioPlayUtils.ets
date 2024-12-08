import { LogUtil } from '@pura/harmony-utils'
import { EfAVPlayer } from '@yunkss/ef_audio'
import ContinuousTask from './ContinuousTask'
import FileUtils from './FileUtils'
import { fileIo } from '@kit.CoreFileKit'
import AVSessionUtils from './AVSessionUtils'
import { completeDo, playNext } from '../functions/playerControl'

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
      LogUtil.info(TAG + '播放器初始化完成')
    } catch (e) {
      LogUtil.error(TAG + '播放器初始化失败')
      throw new Error(e)
    }
  }

  async playWithUrl(url:string) {
    try {
      await this.mPlayer.reset()
      await this.init()
      await this.mPlayer.setUrl(url)
      this.onState()
      LogUtil.info(TAG + '开始播放: ' + url)
      this.mPlayer.play()
      AppStorage.setOrCreate('player-isplaying',true)
      this.mPlayer.onTimeUpdate((time) => {
        AppStorage.setOrCreate('player-time',time)
      })
    } catch (e) {
      AppStorage.setOrCreate('player-isplaying',false)
      LogUtil.error(TAG + '播放失败: ' + JSON.stringify(e))
    }
  }

  async playWithFile(fileName:string) {
    try {
      let path = await FileUtils.getFilesDir() + `/${fileName}`
      LogUtil.info(TAG + 'path: ' + path)
      let file = await fileIo.open(path)
      let fdPath = 'fd://' + file.fd
      LogUtil.info(TAG + 'fdPath: ' + fdPath)
      await this.mPlayer.reset()
      await this.init()
      await this.mPlayer.setUrl(fdPath)
      this.onState()

      this.mPlayer.play()
      LogUtil.info(TAG + '开始播放: ' + fileName)
      AppStorage.setOrCreate('player-isplaying',true)
      this.mPlayer.onTimeUpdate((time) => {
        AppStorage.setOrCreate('player-time',time)
      })
    } catch (e) {
      AppStorage.setOrCreate('player-isplaying',false)
      LogUtil.error(TAG + '播放失败 play error: ' + JSON.stringify(e))
    }
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

  onState() {
    this.mPlayer.onStateChange(async (state) => {
      if(state == 'playing') { AppStorage.setOrCreate('player-isplaying', true); AVSessionUtils.playState() }
      if(state == 'paused') { AppStorage.setOrCreate('player-ispaused', true); AVSessionUtils.pauseState() }
      if(state == 'idle') { AVSessionUtils.deactive() }
      if(state == 'stopped') { AppStorage.setOrCreate('player-ispaused', true); ContinuousTask.stopTask() }
      if(state == 'completed') { AppStorage.setOrCreate('player-ispaused', true); ContinuousTask.stopTask(); completeDo() }
    })
  }
}

const audioPlayUtils = new AudioPlayUtils()
export default audioPlayUtils as AudioPlayUtils
