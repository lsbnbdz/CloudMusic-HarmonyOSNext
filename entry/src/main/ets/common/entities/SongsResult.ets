export interface Artist {
  id:number
  name:string
}

export interface Song {
  id:number
  name:string
  artists:Artist[]
  duration:number
}

interface Result {
  songs:Song[]
}

export interface SongsData {
  result:Result
}




export const SongClass: Song = {
  id: 0,
  name: '',
  artists: [
    {
      id: 0,
      name: '',
    }
  ],
  duration: 0
};


export const SongsDataClass: SongsData = {
  result: {
    songs: [
      {
        id: 0,
        name: '',
        artists: [
          {
            id: 0,
            name: '',
          }
        ],
        duration: 0
      }
    ]
  }
};
