import { Lyric } from "../../components/sheets/PlayingCover"

class LyricUtils {
  // currentLyricIndex: number = 0
  // lyricObjects: Array<Lyric> = []
  // updateLyricInterval: number = 0

  /**
   * 解析歌词字符串数组
   * @param lyricArr 歌词字符串数组
   */
  parseLyricArray(lyricArr: string[]): Lyric[] {
    if (lyricArr.length > 1) {
      return lyricArr.map(item => {
        const match = item.match(/\[(\d+):(\d+)[.:](\d+)\](.*)/)
        if (match) {
          const minutes = parseInt(match[1], 10) * 60 * 1000
          const seconds = parseInt(match[2], 10) * 1000
          const milliseconds = parseInt(match[3], 10)
          const content = match[4]?.trim() || ""
          return { time: minutes + seconds + milliseconds, content } as Lyric
        }
        return { time: 0, content: "" }
      }).filter(lyric => lyric.content)
    }
    return [{ time: 0, content: '暂无歌词' }]
  }

  /**
   * 更新当前歌词索引
   * @param time 当前时间
   * @param lyricObjects 歌词对象数组
   * @returns 当前歌词索引
   */
  updateCurrentLyricIndex(time: number, lyricObjects: Lyric[]): number {
    for (let i = 0; i < lyricObjects.length; i++) {
      if (time >= lyricObjects[i].time &&
        (i === lyricObjects.length - 1 || time < lyricObjects[i + 1].time)) {
        return i
      }
    }
    return 0
  }
}

const lyricUtils = new LyricUtils()
export default lyricUtils as LyricUtils
