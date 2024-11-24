import Constants from "../common/constants/Constants";
import { SongDetail } from "../common/entities/SongDetail";
import { Song } from "../common/entities/SongsResult";
import { HttpRequest } from "../common/utils/HttpRequestUtil";

export async function getSongPicUrl(song: Song): Promise<string> {
  const url: string = `${Constants.ROOT_URL}/song/detail?ids=${song.id}`;
  const request = new HttpRequest(url);
  try {
    const data = await request.Request();
    const dataGot: SongDetail = data.result as SongDetail;
    const songPicUrl = dataGot.songs[0].al.picUrl;
    return songPicUrl;
  } catch (error) {
    console.error('Error fetching song picUrl:', error);
    return 'NULL';
  }
}
