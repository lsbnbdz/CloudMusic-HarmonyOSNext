import Constants from "../common/constants/Constants";
import { PlayListSongs } from "../common/entities/PlayListSongs";
import { Song } from "../common/entities/SongsResult";
import { HttpRequest } from "../common/utils/HttpRequestUtil";

export async function getPlayListSongs(listId:number): Promise<Array<Song>> {
  let list:Array<Song> = new Array()
  const url:string = `${Constants.ROOT_URL}/playlist/track/all?id=${listId}&limit=20&offset=0`
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