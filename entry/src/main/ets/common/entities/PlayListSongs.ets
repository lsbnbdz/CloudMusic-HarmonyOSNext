import { Artist } from "./SongsResult"

/**
 * 歌单内歌曲
 */
interface Album {
  id:number
  picUrl:string
}

interface Song {
  name:string
  id:number
  dt:number
  al:Album[]
  ar:Artist[]
}

export interface PlayListSongs {
  songs:Song[]
}

/**
 * 每日推荐歌单内歌曲
 */
interface DailySong {
  name:string
  id:number
  dt:number
  al:Album[]
  ar:Artist[]
  reason:string
}

interface Data {
  dailySongs: DailySong[]
}

export interface DailyListSongs {
  data: Data
}