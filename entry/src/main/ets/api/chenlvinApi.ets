import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import Constants from "../common/constants/Constants";
import { StorageConstants } from "../common/constants/StorageConstants";
import { AppInfo, AppInfoClass } from "../common/entities/AppInfo";
import { HttpRequest } from "../common/utils/request/HttpRequestUtils";

/**
 * Chenlvin's API
 */
const TAG = '[getPubCookie] '

/**
 * 从API服务器获取公共Cookie
 */
export async function getPubCookie() {
  const url = `${Constants.API_URL}/api/cloudmusic/getCookie`
  const request = new HttpRequest(url)
  try {
    await request.Request().then((data) => {
      let pubCookie: string = data.result["data"]["cookie"]
      AppStorage.setOrCreate('pubCookie', pubCookie)
    })
  } catch (e) {
    LogUtil.error('获取公共Cookie getPubCookie Error: ' + e.message())
    ToastUtil.showToast(TAG + '获取公共Cookie时出错')
  }
}

/**
 * 获取App信息
 */
export async function getAppInfo() {
  const url = `${Constants.API_URL}/api/cloudmusic/app`
  const request = new HttpRequest(url)
  try {
    await request.Request().then((data) => {
      const dataGot: AppInfo = data.result as AppInfo
      AppStorage.setOrCreate(StorageConstants.APP_INFO, dataGot)
    })
  } catch (e) {
    const appInfo: AppInfo = AppInfoClass
    AppStorage.setOrCreate(StorageConstants.APP_INFO, appInfo)
    LogUtil.error('获取公告内容 get Announcement Error: ' + e.message())
    ToastUtil.showToast(TAG + '获取公告内容出错')
  }
}