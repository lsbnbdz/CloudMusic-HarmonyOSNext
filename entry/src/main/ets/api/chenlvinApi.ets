import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import Constants from "../common/constants/Constants";
import { Announcement } from "../common/entities/Announcement";
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
 * 获取公告
 */
export async function getAnnouncement() {
  const url = `${Constants.API_URL}/api/cloudmusic/announcement`
  const request = new HttpRequest(url)
  try {
    await request.Request().then((data) => {
      let dataGot: Announcement = data.result as Announcement
      AppStorage.setOrCreate('Announcement', dataGot)
    })
  } catch (e) {
    const announcement: Announcement = {
      code: 0,
      data: {
        title: '',
        content: 'null'
      },
      visible: false
    }
    AppStorage.setOrCreate('Announcement', announcement)
    LogUtil.error('获取公告内容 get Announcement Error: ' + e.message())
    ToastUtil.showToast(TAG + '获取公告内容出错')
  }
}