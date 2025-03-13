import { StorageConstants } from "../common/constants/StorageConstants";
import { User, UserClass } from "../common/entities/User";
import { JSON } from "@kit.ArkTS";
import Constants from "../common/constants/Constants";
import { resourceManager } from "@kit.LocalizationKit";
import { AppConstants } from "../common/constants/AppConstants";
import { promptAction } from "@kit.ArkUI";
import { HttpRequest } from "../common/utils/request/HttpRequestUtils";
import { getApiUrl } from "../common/functions/common/get";

@Component
export struct DebugPage {
  @StorageProp(StorageConstants.COOKIE) cookie: string = ''
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @State apiUrl: string = ''
  @State result: string = ''

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 20 }) {
          Text(`APP Version: ${AppConstants.VERSION} ${AppConstants.VER_DESC}`)
            .textStyle()
          Text(`deviceType: ${this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_PHONE ? 'Phone' :
              this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_TABLET ? 'Tablet' :
              this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_2IN1 ? '2in1' : 'Unknown'} `)
            .textStyle()
          Text(`Breakpoint: ${this.breakpoint}`)
            .textStyle()
          Row({ space: 10 }) {
            TextInput()
              .onChange((text) => { this.apiUrl = text })
              .layoutWeight(1)
            Button('request')
              .onClick(async () => {
                await this.request()
              })
          }
          Text('Result: ' + this.result)
            .textStyle()
          Text(`current user: ${JSON.stringify(this.user, null, 2).replace(/\n/g, '\n')}`)
            .textStyle()
          Text(`cookie: \n${this.cookie}`)
            .textStyle()
        }
        .padding(Constants.PADDING_EDGE_DEFAULT)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .title('Debug')
  }

  async request() {
    const rootUrl = await getApiUrl()
    const url = rootUrl + this.apiUrl
    try {
      const request = new HttpRequest(url)
      const data = await request.RequestInStream()
      if(data.responseCode == 200) {
        promptAction.showToast({ message: '200 OK' })
        this.result = JSON.stringify(data.result, null, 2).replace(/\n/g, '\n')
      }
    } catch (e) {
      promptAction.showToast({ message: 'Error:' + e.message })
    }
  }
}

@Extend(Text) function textStyle() {
  .copyOption(CopyOptions.InApp)
  .textSelectable(TextSelectableMode.SELECTABLE_UNFOCUSABLE)
  .width('100%')
}