import Constants from "../constants/Constants"
import { Artist, Song } from "../entities/SongsResult"
import { util } from "@kit.ArkTS"
import { media } from "@kit.MediaKit"
import { fileIo } from "@kit.CoreFileKit"

/**
 * 通用函数
 */

/**
 * 获取网易云API Url
 * （根据用户设置）
 * @returns string - ApiUrl
 */
export async function getApiUrl(): Promise<string | undefined> {
  let rootUrl:string | undefined = Constants.ROOT_URL
  const isCustomApiUrl:boolean | undefined = await AppStorage.get('set-isCustomApiUrl')
  if(isCustomApiUrl) {
    rootUrl = await AppStorage.get('set-customApiUrl')
  }
  return rootUrl
}

/**
 * 获取metadata
 * @param fileUrl
 * @returns
 */
export async function fetchMetadata(fileUrl: string) {
  if(canIUse("SystemCapability.Multimedia.Media.AVMetadataExtractor")) {
    let avMetadataExtractor = await media.createAVMetadataExtractor()
    avMetadataExtractor.fdSrc = fileIo.openSync(fileUrl)
    let metadata = await avMetadataExtractor.fetchMetadata()
    avMetadataExtractor.release()
    return metadata
  } else {
    return undefined
  }
}

/**
 * 根据文件名拆分歌名与歌手
 * @param fileName
 * @returns song:Song
 */
export async function fetchSongInfo(fileName: string): Promise<Song> {
  const regex = /^(.+?) - (.+)\.\w+$/
  const match = fileName.match(regex)
  if (!match) { throw new Error('文件名格式错误') }
  const artistName = match[1].trim()
  const songName = match[2].trim()
  const artists: Artist[] = [
    {
      id: -1,
      name: artistName
    }
  ]

  let song:Song = {
    id: -1,
    name: songName,
    artists: artists,
    duration: -1
  }
  return song
}

/**
 * 转换 Artists[] 至 string
 * @param artists
 * @returns
 */
export async function getArtists(artists:Artist[]): Promise<string> {
  let artistStr:string = ''
  for(let artist of artists) {
    artistStr = artistStr + artist.name + ', '
  }
  return artistStr.slice(0,-2)
}

/**
 * 转换时间函数
 * @param dur 时间number（ms）
 * @returns string - 分:秒 形式
 */
export function changeDuration(dur: number): string {
  const seconds = Math.floor(dur / 1000)
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}:${remainingSeconds < 10 ? '0' + remainingSeconds : remainingSeconds}`
}

/**
 * 是否使用公共Cookie（根据用户设置）
 * @returns
 */
export async function isUsePubCookie(): Promise<boolean> {
  const isUsePubCookie:boolean | undefined = AppStorage.get('set-isUsePubCookie')
  if(isUsePubCookie) return true
  else return false
}

/**
 * 使用正则表达式匹配并删除所有 HTTPOnly 标记
 * @param cookieString
 * @returns string - cookie
 */
export function removeHTTPOnly(cookieString: string): string {
  return cookieString.replace(/HTTPOnly;/g, "")
}

/**
 * b -> mb
 */
export function changeb2Mb(b: number): number {
  return parseFloat((b / 1000000).toFixed(2));
}

/**
 * 替换fileName的非法字符
 * @param input
 * @returns
 */
export function sanitizeFileName(input: string): string {
  const invalidCharsPattern = /[<>:"/\\|?*]/g;
  const sanitized = input.replace(invalidCharsPattern, ' ');
  return sanitized;
}

/**
 * 使用TextDecoder编码Uint8Array
 * @param buffer
 * @returns
 */
export function uint8ArrayToString(buffer: Uint8Array): string {
  const decoder = new util.TextDecoder('utf-8');
  return decoder.decode(buffer);
}
