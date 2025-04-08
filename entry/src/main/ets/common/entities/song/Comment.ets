interface UserContent {
  avatarUrl: string
  nickname: string
  userId: number
  vipType: number
}

export interface Comment {
  user: UserContent
  commentId: number
  content: string
  time: number
  timeStr: string
  likedCount: number
}

export interface CommentResult {
  userId: number
  moreHot: boolean
  hotComments: Comment[]
}

export const CommentResultItem: CommentResult = {
  userId: 0,
  moreHot: false,
  hotComments: []
}

export const CommentItem: Comment = {
  user: {
    avatarUrl: '',
    nickname: '',
    userId: 0,
    vipType: 0
  },
  commentId: 0,
  content: '',
  time: 0,
  timeStr: '',
  likedCount: -1
}