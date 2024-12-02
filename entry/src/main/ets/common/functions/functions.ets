import Constants from "../constants/Constants"

/**
 * 通用函数
 */

/**
 * 获取网易云API Url
 * （根据用户设置）
 * @returns string - ApiUrl
 */
export async function getApiUrl(): Promise<string | undefined> {
  let rootUrl:string | undefined = Constants.ROOT_URL
  const isCustomApiUrl:boolean | undefined = await AppStorage.get('set-isCustomApiUrl')
  if(isCustomApiUrl) {
    rootUrl = await AppStorage.get('set-customApiUrl')
  }
  return rootUrl
}

/**
 * 转换时间函数
 * @param dur 时间number（ms）
 * @returns string - 分:秒 形式
 */
export function changeDuration(dur: number): string {
  const seconds = Math.floor(dur / 1000)
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}:${remainingSeconds < 10 ? '0' + remainingSeconds : remainingSeconds}`
}

/**
 * 是否使用公共Cookie（根据用户设置）
 * @returns
 */
export async function isUsePubCookie(): Promise<boolean> {
  const isUsePubCookie:boolean | undefined = AppStorage.get('set-isUsePubCookie')
  if(isUsePubCookie) return true
  else return false
}

/**
 * 使用正则表达式匹配并删除所有 HTTPOnly 标记
 * @param cookieString
 * @returns string - cookie
 */
export function removeHTTPOnly(cookieString: string): string {
  return cookieString.replace(/HTTPOnly;/g, "")
}

/**
 * b -> mb
 */
export function changeb2Mb(b: number): number {
  return parseFloat((b / 1000000).toFixed(2));
}
