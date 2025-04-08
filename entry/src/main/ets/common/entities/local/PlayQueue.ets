import { PLAYMODE } from "../../model/enum"
import { Song } from "../song/Song"

export interface PlayQueue {
  playmode: PLAYMODE
  song: Song
  fileName: string
  picUrl: string | ResourceStr
}