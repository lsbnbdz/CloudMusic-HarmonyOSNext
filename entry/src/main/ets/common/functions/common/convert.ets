import { Artist, Song } from "../../entities/SongsResult"
import { util } from "@kit.ArkTS"
import { media } from "@kit.MediaKit"
import { fileIo } from "@kit.CoreFileKit"

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

export async function setMetadata(fileUrl: string, title: string, artists: string) {
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

  let song: Song = {
    id: -1,
    name: songName,
    artists: artists,
    duration: -1,
    alias: [],
    fee: 0
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
 * 提取MUSIC_U信息
 * @param cookieString
 * @returns
 */
export function extractCookie(cookieString: string): string {
  const parts: string[] = cookieString.split(';')
  for (let part of parts) {
    part = part.trim()
    if (part.startsWith('MUSIC_U=')) {
      const musicUPart: string = part.split(';')[0].trim()
      return musicUPart
    }
  }
  return ''
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

/**
 * 格式化数字为带中文单位的字符串
 * @param num 需要格式化的数字
 * @returns 格式化后的字符串
 */
export function formatNumber(num: number): string {
  if (num >= 100_000_000) {
    return (num / 100_000_000).toFixed(1).replace(/\.0$/, '') + '亿'
  }
  else if (num >= 10_000) {
    return (num / 10_000).toFixed(1).replace(/\.0$/, '') + '万'
  }
  return num.toString()
}
