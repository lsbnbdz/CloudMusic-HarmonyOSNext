import { Song } from "../song/SongsResult"

export interface PlayQueue {
  playmode: number
  song: Song
  artists: string
  fileName: string
  picUrl: string | ResourceStr
}