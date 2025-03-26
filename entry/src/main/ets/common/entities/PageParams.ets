import { PlayList } from "./PlayList";
import { Artist } from "./SongsResult";

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

/**
 * 歌手信息参数
 */
export interface ArtistParam {
  artist: Artist
}