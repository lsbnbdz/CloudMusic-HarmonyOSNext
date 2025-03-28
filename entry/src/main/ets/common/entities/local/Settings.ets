export interface LyricStyle {
  size: number
  color: ResourceColor | string
  align: 'center' | 'start'
  mode: number // 0 - Normal, 1 - Translate, 2 - Roma
}

export const LyricStyleItem: LyricStyle = {
  size: 20,
  color: Color.White,
  align: 'center',
  mode: 0
}