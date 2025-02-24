/**
 * 存储常量
 */
export class StorageConstants {
  /**
   * 设备类型
   * @description AppStorage
   */
  static readonly DEVICE_TYPE: string = 'deviceType'
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
   * User LikeList
   * @description AppStorage
   */
  static readonly PLAYLIST_LIKE: string = 'like-list'
  /**
   * 播放器是否正在播放
   * @description AppStorage
   */
  static readonly IS_PLAYING: string = 'player-isplaying'
  /**
   * 播放器是否暂停
   * @description AppStorage
   */
  static readonly IS_PAUSED: string = 'player-ispaused'
  /**
   * 播放模式
   * @description AppStorage
   */
  static readonly PLAY_MODE: string = 'player-mode'
  /**
   * 歌曲文件名
   * @description AppStorage
   */
  static readonly PLAY_FILE_NAME: string = 'player-fileName'
  /**
   * 歌曲SongClass
   * @description AppStorage
   */
  static readonly PLAY_SONG: string = 'player-song'
  /**
   * 歌曲艺术家
   * @description AppStorage
   */
  static readonly PLAY_ARTISTS: string = 'player-artists'
  /**
   * 歌曲封面Url
   * @description AppStorage
   */
  static readonly PIC_URL: string = 'player-picurl'
  /**
   * 是否喜欢当前歌曲
   * @description AppStorage
   */
  static readonly ISLIKED: string = 'player-isLiked'
  /**
   * 用户喜欢的音乐列表 string[]
   * @description AppStorage
   */
  static readonly USER_LIKELIST: string = 'user-likelist'
  /**
   * 是否有正在进行的播放任务
   * (如 添加整个歌单至播放列表)
   * @description AppStorage
   */
  static readonly IS_PLAYER_LOADING: string = 'isPlayerLoading'



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