import { Song } from "../song/SongsResult"
import { Dj, DjRadio } from "./DjResult"

export interface DjRadioProgram {
  mainSong: Song
  dj: Dj
  radio: DjRadio
  coverUrl: string
}

export interface DjProgramResult {
  count: number
  code: number
  more: boolean
  programs: DjRadioProgram[]
}