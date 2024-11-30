import { PlayListSongs } from "../common/entities/PlayListSongs";
import { Song } from "../common/entities/SongsResult";
import { getApiUrl } from "../common/functions/functions";
import { HttpRequest } from "../common/utils/HttpRequestUtil";

/**
 * 获取歌单内歌曲列表
 * @param listId 歌单ID
 * @param trackCount 歌曲总数
 * @param offset 从第几个开始
 * @returns list 歌曲列表
 */
export async function getPlayListSongs(listId:number, trackCount:number, offset:number): Promise<Array<Song>> {
  let list:Array<Song> = new Array()
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/playlist/track/all?id=${listId}&limit=30&offset=${offset}`
  const request = new HttpRequest(url)
  await request.Request().then((data) => {
    const dataGot:PlayListSongs = data.result as PlayListSongs
    for(let song of dataGot.songs) {
      list.push({
        id: song.id ,
        name: song.name,
        artists: song.ar,
        duration: song.dt,
      })
    }
  })
  console.log('getPlayListSongs: ' + JSON.stringify(list))
  return list;
}