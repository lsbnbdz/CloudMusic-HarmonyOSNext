/**
 * 歌单类
 */
interface Creator {
  userId: number
  nickname: string
}

export interface PlayList {
  coverImgUrl:string
  name:string
  id:number
  playCount:number
  subscribedCount:number
  userId:number
  trackCount:number // 歌曲数量
  creator: Creator
}

export interface PlayListResult {
  more:boolean
  playlist:PlayList[]
}

export const playListClass: PlayList = {
  coverImgUrl: '',
  name: '',
  id: 0,
  playCount: 0,
  subscribedCount: 0,
  userId: 0,
  trackCount: 0,
  creator: {
    userId: -1,
    nickname: ''
  }
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
      trackCount: 0,
      creator: {
        userId: -1,
        nickname: ''
      }
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

