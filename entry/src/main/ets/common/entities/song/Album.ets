import { PlayListSong } from "../playlist/PlayListSongs"

interface AlbumDetail {
  company: string
  picUrl: string
  description: string
  name: string
  id: number
}

export interface AlbumResult {
  code: number
  resourceState: boolean
  songs: PlayListSong[]
  album: AlbumDetail
}

export const AlbumResultItem: AlbumResult = {
  code: 200,
  resourceState: false,
  songs: [],
  album: {
    company: '',
    picUrl: '',
    description: '',
    name: '',
    id: 0
  }
}