/**
 * 歌词类
 */

/**
 * 歌词格式 time + content
 */
export interface Lyric {
  time: number
  content: string
}

/**
 * HTTP Result
 */
interface Lrc {
  lyric: string
}

export interface LyricResult {
  lrc: Lrc
  code: number
}

export const LyricResultClass: LyricResult = {
  lrc: {
    lyric: ''
  },
  code: 0
}