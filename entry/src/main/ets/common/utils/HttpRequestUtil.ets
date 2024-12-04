import { http } from "@kit.NetworkKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { DialogUtil, LogUtil } from "@pura/harmony-utils"
import Constants from "../constants/Constants"

/**
 * 网络请求工具类
 * HTTP Request
 */
const TAG = '[HTTPRequest]'

export class HttpRequest {
  private url: string = ''
  private usingCache:boolean = true

  constructor(url: string, usingCache?:boolean) {
    this.url = url
    if(usingCache) { this.usingCache = usingCache }
  }

  public async Request(): Promise<http.HttpResponse> {
    const cookie:string | undefined = await AppStorage.get('cookie')
    LogUtil.info('Result Cookie: ' + cookie)
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp()
      httpRequest.request(
        this.url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'cookie': cookie,
          },
          usingCache: this.usingCache,
          expectDataType: http.HttpDataType.OBJECT,
          connectTimeout: 8000,
          readTimeout: 8000,
        }, (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          // 解析HTTP响应内容
          console.info('Data Result:' + JSON.stringify(data.result))
          console.info('code:' + JSON.stringify(data.responseCode))
          console.info('header:' + JSON.stringify(data.header))
          // 调用destroy方法主动销毁
          httpRequest.destroy()
          resolve(data)  // 返回请求数据
        } else {
          LogUtil.error(TAG + 'HttpRequest Error: ' + JSON.stringify(err))
          httpRequest.off('headersReceive')
          httpRequest.destroy()
          reject(err)  // 出现错误时reject
          setTimeout(() => {
            DialogUtil.showConfirmDialog({ title: '出错', message: Constants.HTTP_ERROR_MSG})
          },1000)
        }
      })
    })
  }

  public async RequestWithVipType(): Promise<http.HttpResponse> {
    const vipType:number | undefined = await AppStorage.get('vipType')
    let cookie:string | undefined = ''
    if(vipType == 0) { cookie = await AppStorage.get('pubCookie') }
    else { cookie = await AppStorage.get('cookie') }
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp()
      httpRequest.request(
        this.url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'cookie': cookie
          },
          usingCache: this.usingCache,
          expectDataType: http.HttpDataType.OBJECT,
          connectTimeout: 8000,
          readTimeout: 8000,
        }, (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          // 解析HTTP响应内容
          console.info('Data Result:' + JSON.stringify(data.result))
          console.info('code:' + JSON.stringify(data.responseCode))
          console.info('header:' + JSON.stringify(data.header))
          // 调用destroy方法主动销毁
          httpRequest.destroy()
          resolve(data)  // 返回请求数据
        } else {
          LogUtil.error(TAG + 'HttpRequest Error: ' + JSON.stringify(err))
          httpRequest.off('headersReceive')
          httpRequest.destroy()
          reject(err)  // 出现错误时reject
          setTimeout(() => {
            DialogUtil.showConfirmDialog({ title: '出错', message: Constants.HTTP_ERROR_MSG})
          },1000)
        }
      })
    })
  }
}
