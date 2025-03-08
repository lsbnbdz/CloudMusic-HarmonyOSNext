import { EmitterUtil } from "@pura/harmony-utils"
import { getLyric } from "../../../api/LyricApi"
import { EmitterConstants } from "../../constants/EmitterConstants"
import { StorageConstants } from "../../constants/StorageConstants"
import { Lyric } from "../../entities/Lyric"
import { Song } from "../../entities/SongsResult"

class LyricUtils {
  lyricString: string = ''
  lyricArr: Array<string> = []
  lyricObjects: Array<Lyric> = []
  currentLyricIndex: number = 0
  updateLyricInterval: number = 0
  isUpdating: boolean = false

  async setLyric(song: Song) {
    AppStorage.setOrCreate('player-currentLyric', '')
    this.currentLyricIndex = 0
    let lyricArr: string[] = []
    if(song.artists[0].id == 0) {
      this.lyricString = '[00:00:00] 暂无歌词'
      lyricArr = ['[00:00:00] 暂无歌词']
    } else {
      lyricArr = await getLyric(song.id)
    }
    await this.setLyricArr(lyricArr)
    EmitterUtil.post(EmitterConstants.EMITTER_LYRIC_UPDATE,'Lyric Updated')
  }

  async setLyricArr(arr: Array<string>) {
    this.lyricArr = arr
    this.lyricObjects = await this.parseLyricArray(this.lyricArr)
  }

  getCurrentLyric(): string {
    return this.lyricObjects[this.currentLyricIndex].content
  }

  startInterval() {
    if(this.isUpdating) { return }
    else {
      this.isUpdating = true
      this.updateLyricInterval = setInterval(() => {
        let time: number | undefined = AppStorage.get(StorageConstants.PLAY_TIME)
        if (time) {
         let newIndex = this.updateCurrentLyricIndex(time, this.lyricObjects)
          if(newIndex != this.currentLyricIndex) {
            this.currentLyricIndex = newIndex
            AppStorage.setOrCreate('player-currentLyricIndex', this.currentLyricIndex)
            AppStorage.setOrCreate('player-currentLyric', this.lyricObjects[newIndex].content)
          }
        }
      }, 100)
    }
  }

  endInterval() {
    try {
      clearInterval(this.updateLyricInterval)
      this.isUpdating = false
    } catch (e) {

    }
  }

  /**
   * 解析歌词字符串数组
   * @param lyricArr 歌词字符串数组
   */
  async parseLyricArray(lyricArr: string[]): Promise<Array<Lyric>> {
    if (lyricArr.length > 1) {
      return lyricArr.map(item => {
        const match = item.match(/\[(\d+):(\d+)[.:](\d+)(?:-\d+)?\]\s*(.*)/)
        if (match) {
          const minutes = parseInt(match[1], 10) * 60 * 1000
          const seconds = parseInt(match[2], 10) * 1000
          const millisecondsPart = match[3]
          const milliseconds = parseInt(millisecondsPart, 10) * (millisecondsPart.length === 2 ? 10 : 1)
          const content = match[4]?.trim() || ""
          return { time: minutes + seconds + milliseconds, content } as Lyric
        }
        return { time: 0, content: "" }
      })
        .filter(lyric => lyric.content)
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
