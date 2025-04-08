import { Song, SongItem } from "../song/Song"
import { Dj, DjRadio, djRadioItem } from "./DjResult"

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