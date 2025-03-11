import { ToastUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../common/constants/StorageConstants"
import { extractCookie } from "../common/functions/common/convert"
import { getApiUrl } from "../common/functions/common/get"
import { HttpRequest } from "../common/utils/request/HttpRequestUtils"
import { getLoginStatus } from "./loginApi"

/**
 * 获取登录二维码
 * @returns string - qrImg
 */
export async function getQrCode(): Promise<string[]> {
  const timestamp = new Date().getTime()
  let qrimg:string = ''
  let unikey:string = ''
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/login/qr/key?timestamp=${timestamp}`
  const request = new HttpRequest(url)
  await request.Request().then(async (data) => {
    unikey = data.result["data"]["unikey"]
    const timestamp2 = new Date().getTime()
    const request_qr = new HttpRequest(`${rootUrl}/login/qr/create?key=${unikey}&qrimg=true&timestamp=${timestamp2}`)
    await request_qr.Request().then((qrImg) => {
      qrimg = qrImg.result["data"]["qrimg"]
    })
  })
  return [unikey,qrimg]
}

export async function checkQrLogin(key: string): Promise<boolean> {
  const rootUrl = await getApiUrl()
  const url: string = `${rootUrl}/login/qr/check?timestamp=${new Date().getTime()}&key=${key}`
  const request = new HttpRequest(url)
  try {
    const data = await request.Request(false)
    const code: number = data.result["code"]
    if (code == 800 || code == 801) {
      ToastUtil.showToast(data.result["message"])
      return false
    } else if (code == 803) { // success
      let cookie: string = data.result["cookie"]
      if (cookie) {
        cookie = extractCookie(cookie)
        cookie = cookie + '; OS=pc'
        AppStorage.setOrCreate(StorageConstants.COOKIE, cookie)
        const result = await getLoginStatus(cookie)
        return result
      } else {
        ToastUtil.showToast('获取登录状态失败')
        return false
      }
    } else {
      return false
    }
  } catch (error) {
    ToastUtil.showToast(`请求失败: ${error}`)
    return false
  }
}