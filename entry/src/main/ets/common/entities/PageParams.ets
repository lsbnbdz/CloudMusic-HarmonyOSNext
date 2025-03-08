import { PlayList } from "./PlayList";

/**
 * 歌单详情页参数
 */
export interface PlayListPageParam {
  playList: PlayList
  isShowHeart: boolean
  useTimestamp: boolean
}

/**
 * 网页参数
 */
export interface WebPageParam {
  title: string
  url: string
}