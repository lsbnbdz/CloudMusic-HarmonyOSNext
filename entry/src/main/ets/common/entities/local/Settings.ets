/**
 * 歌词样式
 */
export interface LyricStyle {
  size: number
  color: ResourceColor | string
  align: 'center' | 'start'
  mode: number // 0 - Normal, 1 - Translate, 2 - Roma
}

/**
 * 缓存设置
 */
export interface CacheSet {
  songCacheMaxSize: number
  staticCacheMaxSize: number
}

export const CacheSetItem: CacheSet = {
  songCacheMaxSize: 1024 * 1024 * 1024,
  staticCacheMaxSize: 1024 * 1024 * 1024
}

export const LyricStyleItem: LyricStyle = {
  size: 20,
  color: Color.White,
  align: 'center',
  mode: 0
}