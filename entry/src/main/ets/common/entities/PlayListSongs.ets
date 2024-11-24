import { Artist } from "./SongsResult"

interface Album {
  id:number
  picUrl:string
}

interface Song {
  name:string
  id:number
  dt:number
  al:Album[]
  ar:Artist[]
}

export interface PlayListSongs {
  songs:Song[]
}