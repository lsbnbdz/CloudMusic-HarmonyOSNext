/**
 * 歌单类
 */
export interface playList {
  coverImgUrl:string
  name:string
  id:number
  playCount:number
  subscribedCount:number
  userId:number
  trackCount:number // 歌曲数量
}

export interface PlayListResult {
  more:boolean
  playlist:playList[]
}

export const playListClass: playList = {
  coverImgUrl: '',
  name: '',
  id: 0,
  playCount: 0,
  subscribedCount: 0,
  userId: 0,
  trackCount: 0
};

export const PlayListClass: PlayListResult = {
  more: false,
  playlist: [
    {
      coverImgUrl: '',
      name: '',
      id: 0,
      playCount: 0,
      subscribedCount: 0,
      userId: 0,
      trackCount: 0
    }
  ]
};

/**
 * 歌单操作类(add,del)
 */
interface OperationBody {
  code: number
  message: string
}

export interface PlayListOperationRes {
  status: number
  body: OperationBody
}

export const PlayListOperationClass: PlayListOperationRes = {
  status: 200,
  body:
  {
    code: -1,
    message: ''
  }
}

