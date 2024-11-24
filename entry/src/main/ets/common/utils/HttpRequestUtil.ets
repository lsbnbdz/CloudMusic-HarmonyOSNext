import { http } from "@kit.NetworkKit"
import { BusinessError } from "@kit.BasicServicesKit"

export class HttpRequest {
  private url: string = ''

  constructor(url: string) {
    this.url = url
  }

  public async Request(): Promise<http.HttpResponse> {
    const cookie:string | undefined = await AppStorage.get('cookie')
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
          expectDataType: http.HttpDataType.OBJECT,
          connectTimeout: 60000,
          readTimeout: 60000,
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
          console.error('HttpRequest Error: ' + JSON.stringify(err))
          httpRequest.off('headersReceive')
          httpRequest.destroy()
          reject(err)  // 出现错误时reject
        }
      })
    })
  }
}
