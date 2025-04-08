import { Album, Artist } from "../song/Song"
import { PlayList } from "./PlayList"

/**
 * 歌单内歌曲
 */
export interface PlayListSong {
  name: string
  id: number
  dt: number
  al: Album
  ar: Artist[]
  fee: number
}

export interface PlayListSongs {
  songs: PlayListSong[]
}

/**
 * 每日推荐歌单内歌曲
 */
interface DailySong {
  name: string
  id: number
  dt: number
  al: Album
  ar: Artist[]
  reason: string
  fee: number
}

interface Data {
  dailySongs: DailySong[]
}

export interface DailyListSongs {
  data: Data
}

/**
 * 云盘歌单内歌曲
 */
interface CloudData {
  simpleSong: PlayListSong
}

export interface CloudSongs {
  data: CloudData[]
}

export const PlayListSongItem: PlayListSong = {
  name: "",
  id: 0,
  dt: 0,
  al: {
    id: 0,
    name: '',
    picUrl: ''
  },
  ar: [],
  fee: 0
}