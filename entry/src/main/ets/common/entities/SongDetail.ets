/**
 * 歌曲详细信息
 */
interface Al {
  picUrl:string
}

interface Song {
  al:Al
}

export interface SongDetail {
  songs:Song[]
}

export const SongDetailClass: SongDetail = {
  songs: [
    {
      al: {
        picUrl: ''
      }
    }
  ]
};
