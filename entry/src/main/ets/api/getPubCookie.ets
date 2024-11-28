import { ToastUtil } from "@pura/harmony-utils";
import Constants from "../common/constants/Constants";
import { HttpRequest } from "../common/utils/HttpRequestUtil";

export async function getPubCookie() {
  const url = `${Constants.API_URL}/api/cloudmusic/getCookie.json`
  const request = new HttpRequest(url)
  try {
    await request.Request().then((data) => {
      let pubCookie: string = data.result["data"]["cookie"]
      AppStorage.setOrCreate('pubCookie', pubCookie)
      console.log('pubcookie: ' + pubCookie)
    })
  } catch (e) {
    console.log('pubcookiee error: ' + e.message())
    ToastUtil.showToast('获取公共cookie时出错')
  }
}