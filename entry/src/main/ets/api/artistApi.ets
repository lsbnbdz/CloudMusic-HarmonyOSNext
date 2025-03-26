import { ArtistInfo, ArtistInfoItem } from "../common/entities/ArtistResult"
import { getApiUrl } from "../common/functions/common/get"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"

const TAG = '[artistApi] '

/**
 * 获取歌手信息
 * @param id
 * @returns
 */
export async function getArtistInfo(id: number): Promise<ArtistInfo> {
  let empty = ArtistInfoItem
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/artists?id=${id}`
  const request = new HttpRequest(url)
  const data = await request.RequestInStream()
  const dataGot: ArtistInfo = data.result as ArtistInfo
  return dataGot ?? empty
}