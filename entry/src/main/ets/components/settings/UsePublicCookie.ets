import { ExplainButton } from "../buttons/ExplainButton"
import Constants from "../../common/constants/Constants"
import PreferencesUtils from "../../common/utils/app/PreferencesUtils"
import { StorageConstants } from "../../common/constants/StorageConstants"

/**
 * 是否使用公共Cookie
 */
@Component
export struct UsePublicCookie {
  @StorageLink(StorageConstants.USE_PUBLIC_COOKIE) isUsePubCookie: boolean = true
  build() {
    Row() {
      Row({ space: 5 }) {
        Text('使用公共Cookie').LeftText()
        ExplainButton({
          title:'公共 Cookie',
          msg:'该功能不稳定，不保证可用\n仅对非VIP用户生效\n开启后，非VIP用户将使用公共Cookie\n' +
            '获取完整的歌曲内容'
        })
      }
      Toggle({ type: ToggleType.Switch, isOn:this.isUsePubCookie }).height(24).width(48)
        .onChange(() => {
          this.isUsePubCookie = !this.isUsePubCookie
          AppStorage.setOrCreate(StorageConstants.USE_PUBLIC_COOKIE,this.isUsePubCookie)
          PreferencesUtils.putPreferenceValue('Settings',StorageConstants.USE_PUBLIC_COOKIE,this.isUsePubCookie)
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}
