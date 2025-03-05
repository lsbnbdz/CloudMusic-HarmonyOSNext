export interface PersonalListItem {
  id: number
  type: number
  name: string
  copywriter: string
  picUrl: string
  playCount: number
  trackCount: number
}

export interface Personalized {
  hasTaste: boolean
  code: number
  result: PersonalListItem[]
}