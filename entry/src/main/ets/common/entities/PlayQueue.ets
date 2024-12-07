import { Song } from "./SongsResult"

export interface PlayQueue {
  playmode:number
  song:Song
  artists:string
  fileName:string
}

export const PlayQueueClass:PlayQueue = {
  playmode: 1,
  song: {
    id: 0,
    name: '',
    artists: [
      {
        id: 0,
        name: '',
      }
    ],
    duration: 0
  },
  artists: '',
  fileName: ''
}