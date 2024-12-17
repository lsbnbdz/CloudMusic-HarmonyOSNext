/**
 * 歌词类
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