import { Dj } from "./DjResult"

export interface RecommendDjRadio {
  id: number
  name: string
  picUrl: string
  categoryId: number
  category: string
  rcmdtext: string
  playCount: number
  dj: Dj
  copywriter: string
  buyed: boolean
}

export interface DjRecommendResult {
  djRadios: RecommendDjRadio[]
}

export const RecommendDjRadioItem: RecommendDjRadio = {
  id: 0,
  name: "",
  picUrl: "",
  categoryId: 0,
  category: "",
  rcmdtext: "",
  playCount: 0,
  dj: {
    avatarUrl: '',
    userId: 0,
    nickname: '',
    backgroundUrl: ''
  },
  copywriter: "",
  buyed: false
}