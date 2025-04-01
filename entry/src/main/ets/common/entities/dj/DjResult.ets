export interface Dj {
  avatarUrl: string
  userId: number
  nickname: string
  backgroundUrl: string
}

export interface DjRadio {
  dj: Dj
  category: string
  secondCategory: string
  buyed: boolean
  lastProgramName: string // 最新歌曲的标题
  intervenePicUrl: string
  subCount: number
  programCount: number
  picUrl: string
  lastProgramId: number
  desc: string // 简介
  name: string
  id: number
}

/**
 * Sublist 电台返回类
 */
export interface DjResult {
  code: number
  djRadios: DjRadio[]
  count: number
  hasMore: boolean
}

export const djRadioItem: DjRadio = {
  dj: {
    avatarUrl: '',
    userId: 0,
    nickname: '',
    backgroundUrl: ''
  },
  category: "",
  secondCategory: "",
  buyed: false,
  lastProgramName: "",
  intervenePicUrl: "",
  subCount: 0,
  programCount: 0,
  picUrl: "",
  lastProgramId: 0,
  desc: "",
  name: "",
  id: 0
}