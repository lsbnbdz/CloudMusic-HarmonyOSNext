import { http } from "@kit.NetworkKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../constants/Constants"
import { PlayListsResult } from "../../api/playListApi"
import { uint8ArrayToString } from "../functions/functions"

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
  public async Request(useCookie:boolean = true): Promise<http.HttpResponse> {
    const cookie:string | undefined = await AppStorage.get('cookie')
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp()
      httpRequest.request(
        this.url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'cookie': useCookie ? cookie : '',
          },
          usingCache: this.usingCache,
          expectDataType: http.HttpDataType.OBJECT,
          connectTimeout: 15000,
          readTimeout: 15000,
        }, (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          // 解析HTTP响应内容
          console.info('Data Result:' + JSON.stringify(data.result))
          console.info('code:' + JSON.stringify(data.responseCode))
          // 调用destroy方法主动销毁
          httpRequest.destroy()
          resolve(data)  // 返回请求数据
        } else {
          LogUtil.error(TAG + 'HttpRequest Error: ' + JSON.stringify(err))
          httpRequest.off('headersReceive')
          httpRequest.destroy()
          reject(err)  // 出现错误时reject
          setTimeout(() => {
            ToastUtil.showToast(`${Constants.HTTP_ERROR_MSG}`, { duration: 4000 })
          },1000)
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
    const cookie:string | undefined = await AppStorage.get('cookie')
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp()

      // 创建一个存储所有接收数据的容器
      let resView = new Uint8Array(0);

      // 当收到数据时
      httpRequest.on('dataReceive', (data: ArrayBuffer) => {
        const newView = new Uint8Array(resView.length + data.byteLength);
        newView.set(resView, 0);
        newView.set(new Uint8Array(data), resView.length);
        resView = newView
      });

      // 当数据接收完毕时
      httpRequest.on('dataEnd', () => {
        let resultString = uint8ArrayToString(resView)
        try {
          const result:PlayListsResult = JSON.parse(resultString);
          const data: http.HttpResponse = {
            result: result,
            responseCode: 200,
            header: {},
            resultType: http.HttpDataType.OBJECT,
            cookies: "",
            performanceTiming: {dnsTiming: 0, tcpTiming: 0, tlsTiming: 0, firstSendTiming: 0, firstReceiveTiming: 0, totalFinishTiming: 0, redirectTiming: 0, responseHeaderTiming: 0, responseBodyTiming: 0, totalTiming: 0}
          }
          resolve(data)
        } catch (err) {
          setTimeout(() => {
            ToastUtil.showToast(`${Constants.HTTP_ERROR_MSG}`, { duration: 4000 })
          },1000)
          reject(err)
        }
      });

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
      httpRequest.requestInStream(this.url, streamInfo);
    });
  }

  /**
   * Http请求 (根据VipType)_
   * @returns
   */
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
          connectTimeout: 15000,
          readTimeout: 15000,
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
            ToastUtil.showToast(`${Constants.HTTP_ERROR_MSG}`, { duration: 4000 })
          },1000)
        }
      })
    })
  }
}
