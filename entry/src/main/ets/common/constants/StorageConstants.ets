/**
 * 存储常量
 */
export class StorageConstants {
  /**
   * Vip类型
   * @description AppStorage
   */
  static readonly VIP_TYPE: string = 'vipType'
  /**
   * Cookie 有效性
   * @description AppStorage
   */
  static readonly VALID_COOKIE: string = 'isValidCookie'
  /**
   * 用户信息
   * @description AppStorage
   */
  static readonly USER: string = 'User'
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
   * 播放
   * @description AppStorage
   */
  static readonly IS_PLAYING: string = 'player-isplaying'
  static readonly IS_PAUSED: string = 'player-ispaused'
  static readonly PLAY_MODE: string = 'player-mode'
  static readonly PLAY_FILE_NAME: string = 'player-fileName'
  static readonly PLAY_SONG: string = 'player-song'
  static readonly PLAY_ARTISTS: string = 'player-artists'
  static readonly PIC_URL: string = 'player-picurl'
  static readonly ISLIKED: string = 'player-isLiked'
  /**
   * User LikeList
   * @description AppStorage
   */
  static readonly USER_LIKELIST: string = 'user-likelist'
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



  /**
   * 循环模式
   * @description AppStorage & Preference
   */
  static readonly CYCLE_MODE: string = 'cycleMode'
}