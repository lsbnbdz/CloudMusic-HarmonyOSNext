import { QualityType } from "../entities/SongDownload"

/**
 * 常量类
 */
export default class Constants {
  static readonly VERSION: string = '0.9.10'
  static readonly VER_DESC: string = ''

  static readonly USER_PREF: string = 'UserPreference'
  static readonly SET_PERF: string = 'Settings'
  static readonly QUEUE_PREF: string = 'Play'

  static readonly ROOT_URL: string = 'http://111.229.38.178:3000'
  static readonly EAPI_URL: string = 'https://interface.music.163.com/eapi'
  static readonly MUSIC_URL: string = 'https://music.163.com'
  static readonly API_URL: string = 'https://api.chenlvin.cc'

  static readonly COOKIE_EXPIRY_DAYS = 7;

  static readonly QUALITY: QualityType[] = ['standard', 'higher', 'exhigh', 'lossless']
  static readonly QUALITY_NAME: string[] = ['标准', '高', '极高', '无损']
  /**
   * 0-顺序播放, 1-单曲循环, 2-顺序循环, 3-随机播放
   */
  static readonly CYCLE_MODE: string[] = ['顺序播放', '单曲循环', '顺序循环', '随机播放']

  // Messages
  static readonly HTTP_ERROR_MSG: string = '网络请求发生错误，请检查：\n网络连接和API服务器是否正常'
  static readonly DEVELOPING: string = '该功能正在开发中，敬请期待。'
}