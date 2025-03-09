import { Artist } from "./SongsResult"

/**
 * 歌单内歌曲
 */
interface Album {
  id: number
  picUrl: string
}

export interface PlayListSongItem {
  name: string
  id: number
  dt: number
  al: Album
  ar: Artist[]
  fee: number
}

export interface PlayListSongs {
  songs: PlayListSongItem[]
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
  simpleSong: PlayListSongItem
}

export interface CloudSongs {
  data: CloudData[]
}