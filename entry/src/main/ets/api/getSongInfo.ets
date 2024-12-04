import { Song, SongClass, SongsData } from "../common/entities/SongsResult"
import { getApiUrl } from "../common/functions/functions"
import { HttpRequest } from "../common/utils/HttpRequestUtil"

/**
 * 根据文件名，搜索歌曲信息，返回结果数组的第一个信息
 * @param searchName
 */
export async function getSongInfo(searchName: string): Promise<Song> {
  let song:Song = SongClass
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/search?keywords=${encodeURIComponent(searchName)}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:SongsData = data.result as SongsData
    song = dataGot.result.songs[0]
  })
  return song
}