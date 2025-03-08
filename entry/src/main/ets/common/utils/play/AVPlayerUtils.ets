import { LogUtil, ToastUtil } from '@pura/harmony-utils'
import ContinuousTask from './ContinuousTask'
import AVSessionUtils from './AVSessionUtils'
import { completeDo } from '../../functions/play/playControl'
import LyricUtils from './LyricUtils'
import { audio } from '@kit.AudioKit'
import { StorageConstants } from '../../constants/StorageConstants'
import { media } from '@kit.MediaKit'
import { BusinessError } from '@kit.BasicServicesKit'

const TAG = '[AVPlayerUtils] '

class AVPlayerUtils {
  private avPlayer: media.AVPlayer | null = null
  private updateAvSession: number = 0
  private audioManager = audio.getAudioManager()
  private audioSessionManager: audio.AudioSessionManager = this.audioManager.getSessionManager()

  async init() {
    if (!this.avPlayer) {
      this.avPlayer = await media.createAVPlayer()
      this.setCallback(this.avPlayer)
    }
    return this.avPlayer
  }

  async reset() {
    await this.avPlayer?.reset()
  }

  async release() {
    await this.avPlayer?.release()
    this.avPlayer?.off('stateChange')
    this.avPlayer?.off('error')
    this.avPlayer?.off('timeUpdate')
  }

  async setUrl(url: string) {
    await this.reset()
    const avPlayer = await this.init()
    avPlayer.url = url
  }

  async setFdSrc(url: media.AVFileDescriptor) {
    const avPlayer = await this.init()
    avPlayer.fdSrc = url
  }

  async play() {
    const avPlayer = await this.init()
    try {
      await this.setAudioSession()
      LyricUtils.startInterval()
      ContinuousTask.startTask()
      avPlayer.play()
      AVSessionUtils.playState(avPlayer.currentTime)
      this.updateAvSession = setInterval(() => {
        if (avPlayer.state === 'playing') {
          AVSessionUtils.playState(avPlayer.currentTime)
        }
      }, 1000)
      avPlayer.on('timeUpdate', (time: number) => {
        AppStorage.setOrCreate(StorageConstants.PLAY_TIME, time)
      })
    } catch (e) {
      LogUtil.error(TAG + '播放错误: ' + e.message)
    }
  }

  async stop() {
    const avPlayer = await this.init()
    this.clearInterval()
    await avPlayer.stop()
    ContinuousTask.stopTask()
  }

  async pause() {
    const avPlayer = await this.init()
    this.clearInterval()
    await avPlayer.pause()
  }

  async seek(time: number) {
    const avPlayer = await this.init()
    avPlayer.seek(time)
    AVSessionUtils.playState(time)
  }

  private clearInterval() {
    clearInterval(this.updateAvSession)
    LyricUtils.endInterval()
  }

  private setCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('error', (err: BusinessError) => {
      LogUtil.error(TAG + `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`)
      avPlayer.reset()
    })
    avPlayer.on('audioOutputDeviceChangeWithInfo', async(changeInfo: audio.AudioStreamDeviceChangeInfo) => {
      if (changeInfo.changeReason == audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        this.pause()
      }
    })
    avPlayer.on('audioInterrupt', async(interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            this.pause()
            break
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            this.pause()
            break
          default:
            break
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            this.play()
            break
          default:
            break
        }
      }
    })
    avPlayer.on('stateChange', async (state: string) => {
      switch (state) {
        case 'idle':
          this.clearInterval()
          AVSessionUtils.deactive()
          break
        case 'initialized':
          avPlayer.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags: 0
          }
          avPlayer.prepare()
          break
        case 'prepared':
          await this.play()
          break
        case 'playing':
          AppStorage.setOrCreate('player-isplaying', true)
          AppStorage.setOrCreate('player-ispaused', false)
          break
        case 'paused':
          this.clearInterval()
          ContinuousTask.stopTask()
          AppStorage.setOrCreate('player-ispaused', true)
          AVSessionUtils.pauseState(this.avPlayer!.currentTime)
          break
        case 'completed':
          this.clearInterval()
          AppStorage.setOrCreate('player-ispaused', true)
          ContinuousTask.stopTask()
          completeDo()
          break
      }
    })
  }

  async setAudioSession() {
    const isMixWithOthers = await AppStorage.get(StorageConstants.MIX_WITH_OTHERS) as boolean
    const strategy: audio.AudioSessionStrategy = {
      concurrencyMode: isMixWithOthers ?
      audio.AudioConcurrencyMode.CONCURRENCY_MIX_WITH_OTHERS :
      audio.AudioConcurrencyMode.CONCURRENCY_DEFAULT
    }
    await this.audioSessionManager.activateAudioSession(strategy)
  }
}

const avPlayerUtils = new AVPlayerUtils()
export default avPlayerUtils as AVPlayerUtils
