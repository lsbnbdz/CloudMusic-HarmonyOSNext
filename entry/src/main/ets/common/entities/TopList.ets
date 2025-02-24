export interface TopListItem {
  id: number
  name: string
  trackCount: number
  updateFrequency: string // “更新xx首”
  coverImgUrl: string
  description: string
  playCount: number
  subscribedCount: number
}

export interface TopList {
  code: number
  list: TopListItem[]
}