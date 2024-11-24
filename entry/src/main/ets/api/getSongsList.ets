import Constants from "../common/constants/Constants";
import { SongsData, Song } from "../common/entities/SongsResult";
import { HttpRequest } from "../common/utils/HttpRequestUtil";

export async function getSongsList(searchKeyword:string): Promise<Array<Song>> {
  let list:Array<Song> = new Array()
  const url:string = `${Constants.ROOT_URL}/search?keywords=${encodeURIComponent(searchKeyword)}`
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
  console.log('getSongList: ' + JSON.stringify(list))
  return list;
}