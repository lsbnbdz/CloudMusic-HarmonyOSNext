import { PLAYMODE } from "../../model/Enum"
import { Song } from "../song/Song"

export interface PlayQueue {
  playmode: PLAYMODE
  song: Song
  fileName: string
  picUrl: string | ResourceStr
}