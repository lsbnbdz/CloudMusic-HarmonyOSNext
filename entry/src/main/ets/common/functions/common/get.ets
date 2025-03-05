import { LogUtil } from "@pura/harmony-utils";
import { StorageConstants } from "../../constants/StorageConstants";
import { HttpRequest } from "../../utils/request/HttpRequestUtils";

/**
 * 获取网易云API Url
 * （根据用户设置）
 * @returns string - ApiUrl
 */
export async function getApiUrl(): Promise<string | undefined> {
  return AppStorage.get(StorageConstants.API_URL)
}

/**
 * 获取用户Cookie
 * @returns
 */
export async function getCookie(): Promise<string> {
  let cookie = ''
  let isCustomCookie = await AppStorage.get(StorageConstants.IS_CUSTOM_COOKIE) as boolean
  if(isCustomCookie) {
    cookie = await AppStorage.get(StorageConstants.CUSTOM_COOKIE) as string
  } else {
    cookie = await AppStorage.get(StorageConstants.COOKIE) as string
  }
  return cookie
}

/**
 * 检查API URL连通性
 * @returns
 */
export async function checkValidUrl(): Promise<boolean> {
  try {
    const rootUrl = await getApiUrl()
    const url: string = `${rootUrl}`
    const request = new HttpRequest(url)
    const data = await request.Request()
    if (data.responseCode == 200) {
      AppStorage.setOrCreate(StorageConstants.VALID_API_URL, true)
      return true
    } else {
      AppStorage.setOrCreate(StorageConstants.VALID_API_URL, false)
      return false
    }
  } catch (e) {
    AppStorage.setOrCreate(StorageConstants.VALID_API_URL, false)
    return false
  }
}