import { QualityType } from "../entities/SongDownload"

/**
 * 常量类
 */
export default class Constants {
  static readonly VERSION: string = '0.9.4'
  static readonly VER_DESC: string = ' - 241201'

  static readonly USER_PREF: string = 'UserPreference'
  static readonly SET_PERF: string = 'Settings'
  static readonly ROOT_URL: string = 'http://111.229.38.178:3000'
  static readonly EAPI_URL: string = 'https://interface.music.163.com/eapi'
  static readonly MUSIC_URL: string = 'https://music.163.com'
  static readonly API_URL: string = 'https://api.chenlvin.cc'

  static readonly COOKIE_EXPIRY_DAYS = 7;

  static readonly QUALITY: QualityType[] = ['standard','higher','exhigh','lossless']
  static readonly QUALITY_NAME: string[] = ['标准','高','极高','无损']
}