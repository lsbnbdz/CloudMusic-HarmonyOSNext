import { QualityType } from "../entities/SongDownload"

export class PlayConstants {
  /**
   * Quality Type
   */
  static readonly QUALITY: QualityType[] = ['standard', 'higher', 'exhigh', 'lossless']
  /**
   * Quality Name
   * 对应 QualityType
   */
  static readonly QUALITY_NAME: string[] = ['标准', '高', '极高', '无损']
  /**
   * 循环模式
   * 0-顺序播放, 1-单曲循环, 2-顺序循环, 3-随机播放
   */
  static readonly CYCLE_MODE: string[] = ['顺序播放', '单曲循环', '顺序循环', '随机播放']
}