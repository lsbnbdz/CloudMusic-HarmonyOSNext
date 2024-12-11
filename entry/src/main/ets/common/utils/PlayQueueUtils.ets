import { LogUtil } from '@pura/harmony-utils'
import Constants from '../constants/Constants'
import { PlayQueue } from '../entities/PlayQueue'
import { Song, SongClass } from '../entities/SongsResult'
import PreferencesUtils from './PreferencesUtils'

/**
 * 播放列表工具
 */
const TAG = '[PlayQueueUtils] '
const pref = Constants.QUEUE_PREF

class PlayQueueUtils {
  queue:Array<PlayQueue> = []
  currentQueueIndex: number = -1

  getQueueLength(): number {
    return this.queue.length
  }

  /**
   * 初始化播放列表
   */
  async init() {
    try {
      this.currentQueueIndex = -1
      let gotQueue = await PreferencesUtils.getPreferenceValue<Array<PlayQueue>>(pref, 'queue', this.queue)
      let circleMode = await PreferencesUtils.getPreferenceValue<number>(pref, 'cycleMode', 0)
      this.queue = gotQueue
      AppStorage.setOrCreate('currentQueueIndex',this.currentQueueIndex)
      AppStorage.setOrCreate('PlayQueue',this.queue)
      AppStorage.setOrCreate('cycleMode', circleMode)
      LogUtil.info(TAG + '初始化播放列表成功')
    } catch (e) {
      LogUtil.error(TAG + '初始化播放列表 init playqueue error: ' + e.message())
    }
  }

  /**
   * 添加歌曲至播放列表
   */
  async queueAdd(playmode:number, song:Song = SongClass, artists:string = '', fileName:string = '') {
    try {
      this.queue.splice(this.currentQueueIndex + 1 , 0 ,{
        playmode: playmode,
        song: song,
        artists: artists,
        fileName: fileName
      })
      AppStorage.setOrCreate('PlayQueue',this.queue)
      await PreferencesUtils.putPreferenceValue(pref, 'queue', this.queue)
      LogUtil.info(TAG + '添加成功 add queue element success')
      LogUtil.info(TAG + 'now queue: ' + JSON.stringify(this.queue))
    } catch (e) {
      LogUtil.error(TAG + '添加失败 add queue element error: ' + e.message())
    }
  }

  async queueAdd_array(queue:Array<PlayQueue>) {
    this.queue = this.queue.concat(queue)
    AppStorage.setOrCreate('PlayQueue',this.queue)
    await PreferencesUtils.putPreferenceValue(pref, 'queue', this.queue)
    LogUtil.info(TAG + '添加成功 add queue element success')
    LogUtil.info(TAG + 'now queue: ' + JSON.stringify(this.queue))
  }
  /**
   * 从播放列表中删除指定位置歌曲
   */
  async queueDelete(index:number) {
    try {
      this.queue.splice(index,1)
      AppStorage.setOrCreate('PlayQueue',this.queue)
      await PreferencesUtils.putPreferenceValue(pref, 'queue', this.queue)
      if(index < this.currentQueueIndex) {
        this.setIndex(this.currentQueueIndex - 1)
      }
      LogUtil.info(TAG + '删除成功 delete queue element success')
    } catch (e) {
      LogUtil.error(TAG + '删除失败 delete queue element error: ' + e.message())
    }
  }

  pre(): boolean {
    if(this.currentQueueIndex > 0) {
      this.setIndex(this.currentQueueIndex - 1)
      return true // true 表示有上一首歌曲，并且移动currentQueueIndex
    }
    else return false
  }

  next(): boolean {
		if(this.currentQueueIndex < (this.queue.length - 1)) {
      this.setIndex(this.currentQueueIndex + 1)
      return true
    }
    else return false
	}

  getQueueElement(index:number): PlayQueue {
    return this.queue[index]
  }

  getQueue(): Array<PlayQueue> {
    return this.queue
  }

  async cleanQueue() {
    this.queue = []
    this.currentQueueIndex = -1
    AppStorage.setOrCreate('PlayQueue',this.queue)
    AppStorage.setOrCreate('currentQueueIndex',this.currentQueueIndex)
    await PreferencesUtils.putPreferenceValue(pref, 'queue', this.queue)
  }

  async setIndex(index: number) {
    this.currentQueueIndex = index
    AppStorage.setOrCreate('currentQueueIndex',this.currentQueueIndex)
  }
}

const playQueueUtils:PlayQueueUtils = new PlayQueueUtils()
export default playQueueUtils as PlayQueueUtils