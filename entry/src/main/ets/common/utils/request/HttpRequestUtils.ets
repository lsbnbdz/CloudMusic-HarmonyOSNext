import { http } from "@kit.NetworkKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { LogUtil } from "@pura/harmony-utils"
import { uint8ArrayToString } from "../../functions/common/convert"
import { MsgConstants } from "../../constants/MsgConstants"
import { getCookie } from "../../functions/common/get"
import { promptAction } from "@kit.ArkUI"

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

  /**
   * Http请求
   * @param useCookie 是否使用cookie (boolean)
   * @returns
   */
  public async Request(useCookie: boolean = true, method: string = 'get'): Promise<http.HttpResponse> {
    const cookie = await getCookie()
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp()
      httpRequest.request(
        this.url,
        {
          method: method == 'post' ? http.RequestMethod.POST : http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'cookie': useCookie ? cookie : ''
          },
          usingCache: this.usingCache,
          expectDataType: http.HttpDataType.OBJECT,
          connectTimeout: 15000,
          readTimeout: 15000,
        }, (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          httpRequest.destroy()
          resolve(data)  // 返回请求数据
        } else {
          LogUtil.error(TAG + 'HttpRequest Error: '+ `Url: ${this.url}` + JSON.stringify(err))
          httpRequest.off('headersReceive')
          httpRequest.destroy()
          reject(err)  // 出现错误时reject
          promptAction.showToast({
            message: `${MsgConstants.HTTP_ERROR}:\n\n${this.url}`,
            duration: 5000
          })
        }
      })
    })
  }

  /**
   * Http请求 (流式)
   * @param useCookie 是否使用Cookie(boolean)
   * @returns
   */
  public async RequestInStream(useCookie:boolean = true): Promise<http.HttpResponse> {
    const cookie = await getCookie()
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp()

      // 创建一个存储所有接收数据的容器
      let resView = new Uint8Array(0)

      // 当收到数据时
      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        const newView = new Uint8Array(resView.length + data.byteLength)
        newView.set(resView, 0);
        newView.set(new Uint8Array(data), resView.length)
        resView = newView
      })

      // 当数据接收完毕时
      httpRequest.on('dataEnd', () => {
        let resultString = uint8ArrayToString(resView)
        try {
          const result:string = JSON.parse(resultString)
          const data: http.HttpResponse = {
            result: result,
            responseCode: 200,
            header: {},
            resultType: http.HttpDataType.OBJECT,
            cookies: "",
            performanceTiming: {
              dnsTiming: 0,
              tcpTiming: 0,
              tlsTiming: 0,
              firstSendTiming: 0,
              firstReceiveTiming: 0,
              totalFinishTiming: 0,
              redirectTiming: 0,
              responseHeaderTiming: 0,
              responseBodyTiming: 0,
              totalTiming: 0
            }
          }
          resolve(data)
        } catch (err) {
          LogUtil.error(TAG + 'Error: ' + this.url + '\nerr: ' + err)
          reject(err)
          promptAction.showToast({
            message: `${MsgConstants.HTTP_ERROR}:\n\n${this.url}`,
            duration: 5000
          })
        }
      })

      // 发起请求
      let streamInfo: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'cookie': useCookie ? cookie : '',
        },
        usingCache: this.usingCache,
        expectDataType: http.HttpDataType.OBJECT,
        connectTimeout: 15000,
        readTimeout: 15000,
      }
      httpRequest.requestInStream(this.url, streamInfo)
    })
  }
}
