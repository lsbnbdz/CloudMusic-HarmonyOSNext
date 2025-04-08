import { AlbumResult, AlbumResultItem } from "../common/entities/song/Album";
import { getApiUrl } from "../common/functions/common/get";
import { HttpRequest } from "../common/utils/request/HttpRequestUtils";

const TAG = '[albumApi] '
/**
 * 获取专辑信息和歌曲
 * @param id
 * @returns
 */
export async function getAlbumInfo(id: number): Promise<AlbumResult> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/album?id=${id}`
  const request = new HttpRequest(url)
  const response = await request.RequestInStream()
  const dataGot = response.result as AlbumResult
  return dataGot ?? AlbumResultItem
}