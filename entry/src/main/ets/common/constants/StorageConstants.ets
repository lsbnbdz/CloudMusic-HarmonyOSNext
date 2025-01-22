/**
 * 存储常量
 */
export class StorageConstants {
  /**
   * 是否为本地文件 - boolean
   * @description AppStorage
   */
  static readonly PLAY_IS_LOCALFILE: string = 'play-is-localfile'
  /**
   * 倒计时时间 - number
   * @description AppStorage
   */
  static readonly PLAY_COUNTDOWN: string = 'play-countdown'
  /**
   * 倒计时是否工作 - boolean
   * @description AppStorage
   */
  static readonly PLAY_COUNTDOWN_WORKING: string = 'play-countdown-working'
  /**
   * timer(IntervalID) - number
   * @description AppStorage
   */
  static readonly PLAY_COUNTDOWN_TIMER: string = 'play-countdown-timer'



  /**
   * 用户信息
   * @description Preference
   */
  static readonly USER_PREF: string = 'UserPreference'
  /**
   * 设置信息
   * @description Preference
   */
  static readonly SET_PERF: string = 'Settings'
  /**
   * 播放信息
   * @description Preference
   */
  static readonly QUEUE_PREF: string = 'Play'
}