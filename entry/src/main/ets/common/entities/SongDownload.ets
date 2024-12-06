export type QualityType = 'standard' | 'higher' | 'exhigh' | 'lossless' | 'hires' | 'jyeffect' | 'sky' | 'dolby' | 'jymaster'

interface Data {
  id: number
  url: string
  size: number
  type: string
  level: QualityType
}

export interface SongDownload {
  data: Data
}

export const SongDownloadClass: SongDownload = {
  data: {
    id: 0,
    url: '',
    size: 0,
    type: '',
    level: 'lossless',
  },
};
