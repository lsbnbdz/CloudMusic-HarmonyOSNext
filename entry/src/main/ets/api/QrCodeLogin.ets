import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { getApiUrl, removeHTTPOnly } from "../common/functions/functions"
import { HttpRequest } from "../common/utils/HttpRequestUtils"
import { getLoginStatus } from "./getLoginStatus"

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

export async function checkQrLogin(key:string) {
  const timestamp = new Date().getTime()
  const rootUrl = await getApiUrl()
  const url:string = `${rootUrl}/login/qr/check?key=${key}&timestamp=${timestamp}`
  const request = new HttpRequest(url)
  await request.Request().then(async (data) => {
    const code:number = data.result["code"]
    if(code == 800 || code == 801) {
      ToastUtil.showToast(data.result["message"])
    }
    else if(code == 803) { // success
      let cookie:string = data.result["cookie"]
      if(cookie) {
        cookie = removeHTTPOnly(cookie)
        cookie = cookie + '; OS=pc'
        AppStorage.setOrCreate('cookie', cookie)
        getLoginStatus(cookie)
      }
      else {
        ToastUtil.showToast('获取登录状态失败')
      }
    }
  })
}