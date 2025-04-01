import { PlayListSong } from "../playlist/PlayListSongs"
import { Song } from "../song/SongsResult"

export interface PlayQueue {
  playmode: number // 0-本地文件Song   1-在线单曲Song   2-在线歌单歌曲PlayListSongItem
  song: Song | PlayListSong
  artists: string
  fileName: string
  picUrl: string | ResourceStr
}