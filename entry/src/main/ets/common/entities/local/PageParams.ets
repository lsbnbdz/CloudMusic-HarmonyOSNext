import { DjRadio } from "../dj/DjResult";
import { PlayList } from "../playlist/PlayList";
import { Artist } from "../song/SongsResult";

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

/**
 * DjRadio信息参数
 */
export interface DjRadioParam {
  djRadio: DjRadio
}