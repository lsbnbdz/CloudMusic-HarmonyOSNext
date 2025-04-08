import { CommentResult, CommentResultItem } from "../common/entities/song/Comment";
import { getApiUrl } from "../common/functions/common/get";
import { HttpRequest } from "../common/utils/request/HttpRequestUtils";

const TAG = '[commentApi] '
/**
 * 获取评论信息
 * @param id
 * @returns CommentResult
 */
export async function getComment(id: number): Promise<CommentResult> {
  const rootUrl = await getApiUrl()
  const url = `${rootUrl}/comment/music?id=${id}&limit=30`
  const request = new HttpRequest(url)
  const response = await request.RequestInStream(false)
  const dataGot = response.result as CommentResult
  return dataGot ?? CommentResultItem
}