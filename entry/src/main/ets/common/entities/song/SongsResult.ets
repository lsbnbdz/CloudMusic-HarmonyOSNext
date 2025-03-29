/**
 * 歌曲搜索结果
 */

export interface Artist {
  id: number
  name: string
}

export interface Song {
  id: number
  name: string
  artists: Artist[]
  duration: number
  alias: string[]
  fee: number
}

interface Result {
  songs: Song[]
  hasMore: boolean
  songCount: number // 歌曲总数
}

export interface SongsData {
  result: Result
}

export const SongClass: Song = {
  id: 0,
  name: '',
  artists: [
    {
      id: 0,
      name: '',
    }
  ],
  duration: 0,
  alias: [],
  fee: 0
}
