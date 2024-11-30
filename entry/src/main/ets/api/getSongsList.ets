import { SongsData, Song } from "../common/entities/SongsResult";
import { getApiUrl } from "../common/functions/functions";
import { HttpRequest } from "../common/utils/HttpRequestUtil";

/**
 * 搜素歌曲列表
 * @param searchKeyword 搜索词
 * @returns list 歌曲列表
 */
export async function getSongsList(searchKeyword:string): Promise<Array<Song>> {
  let list:Array<Song> = new Array()
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/search?keywords=${encodeURIComponent(searchKeyword)}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:SongsData = data.result as SongsData
    for(let song of dataGot.result.songs) {
      list.push({
        id: song.id,
        name: song.name,
        artists: song.artists,
        duration: song.duration,
      })
    }
  })
  return list;
}