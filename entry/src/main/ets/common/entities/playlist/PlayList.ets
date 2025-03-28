/**
 * 歌单类
 */
interface Creator {
  userId: number
  nickname: string
}

export interface PlayList {
  coverImgUrl: string
  name: string
  id: number
  playCount: number
  subscribedCount: number
  userId: number
  trackCount: number
  subscribed: boolean
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
  subscribed: false,
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
      subscribed: false,
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

/**
 * 歌单列表返回类
 */
export interface PlayListsResult {
  more:boolean
  playlist:PlayList[]
}

/**
 * 搜索歌单返回类
 */
interface SearchBody {
  hasMore: boolean
  playlists: Array<PlayList>
}

export interface PlayListSearchResult {
  code: number
  result: SearchBody
}

/**
 * 正在播放的歌单信息
 */
export interface PlayingPlayList {
  id: number,
  count: number
}
