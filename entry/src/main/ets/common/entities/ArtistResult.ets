import { PlayListSongItem } from "./PlayListSongs"

interface ArtistBody {
  briefDesc: string // 简介
  picUrl: string
  alias: string[] //别名
  name: string
  id: number
}

export interface ArtistInfo {
  artist: ArtistBody
  hotSongs: PlayListSongItem[]
  code: number
  more: boolean
}

export const ArtistInfoItem: ArtistInfo = {
  artist: {
    briefDesc: '',
    picUrl: '',
    alias: [],
    name: '',
    id: 0
  },
  hotSongs: [],
  code: 0,
  more: false
}