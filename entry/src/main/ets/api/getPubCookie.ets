import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import Constants from "../common/constants/Constants";
import { getApiUrl } from "../common/functions/functions";
import { HttpRequest } from "../common/utils/HttpRequestUtils";

/**
 * 从API服务器获取公共Cookie
 * （非网易云API）
 */
const TAG = '[getPubCookie] '
export async function getPubCookie() {
  const url = `${Constants.API_URL}/api/cloudmusic/getCookie.json`
  const request = new HttpRequest(url)
  try {
    await request.Request().then((data) => {
      let pubCookie: string = data.result["data"]["cookie"]
      AppStorage.setOrCreate('pubCookie', pubCookie)
      LogUtil.info('Get Public Cookie: ' + pubCookie)
    })
  } catch (e) {
    LogUtil.error('获取公共Cookie getPubCookie Error: ' + e.message())
    ToastUtil.showToast(TAG + '获取公共Cookie时出错')
  }
}