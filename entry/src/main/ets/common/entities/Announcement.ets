/**
 * 公告类
 */
interface Data {
  title: string
  content: string
}

export interface Announcement {
  code: number
  data: Data
  visible: boolean
}