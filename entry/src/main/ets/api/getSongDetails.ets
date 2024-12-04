import { SongDetail } from "../common/entities/SongDetail";
import { Song } from "../common/entities/SongsResult";
import { getApiUrl } from "../common/functions/functions";
import { HttpRequest } from "../common/utils/HttpRequestUtil";

/**
 * 获取歌曲图片Url
 * @param song 歌曲类
 * @returns string 歌曲Url
 */
export async function getSongPicUrl(song: Song): Promise<string> {
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/song/detail?ids=${song.id}`;
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
