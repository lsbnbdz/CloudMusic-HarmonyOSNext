import { DialogUtil, PasteboardUtil, ToastUtil } from '@pura/harmony-utils'
import Constants from '../common/constants/Constants'
import { SettingsHead } from '../components/head/SettingsHead'
import { router } from '@kit.ArkUI'
import PreferencesUtils from '../common/utils/PreferencesUtils'
import { ExplainButton } from '../components/buttons/ExplainButton'

/**
 * 设置页面
 */
@Entry
@Component
struct Settings {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

  build() {
    Stack() {
      Column({ space: 10 }) {
        SettingsHead().padding({ bottom: 20 })

        List({ space: 20 }) {
          ListItem() { hasAnimation() }
          ListItem() { isUsePubCookie() }
          ListItem() { customApiUrl() }
          ListItem() { Divider() }
          ListItem() { Version() }
          ListItem() { Privacy() }
          ListItem() { Feedback() }
        }
        .scrollBar(BarState.Auto)
        .width('100%').layoutWeight(1)

        Bottom()
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main'))
  }
}

/**
 * 动画开关
 */
@Component struct hasAnimation {
  @StorageLink('set-hasAnimation') hasAnimation: boolean = true
  build() {
    Row() {
      Text('歌曲列表动画').LeftText()
      Toggle({ type: ToggleType.Switch, isOn:this.hasAnimation }).height(24).width(48)
        .onChange(async () => { this.hasAnimation = !this.hasAnimation; AppStorage.setOrCreate('set-hasAnimation',this.hasAnimation); await PreferencesUtils.putPreferenceValue('Settings','hasAnimation',this.hasAnimation)})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

/**
 * 是否使用公共Cookie
 */
@Component struct isUsePubCookie {
  @StorageLink('set-isUsePubCookie') isUsePubCookie: boolean = true
  build() {
    Row() {
      Row({ space: 5 }) {
        Text('使用公共Cookie').LeftText()
        ExplainButton()
          .onClick(() => {
            DialogUtil.showPrimaryDialog({title:'公共 Cookie', message:'该功能仅对非VIP用户生效\n开启后，非VIP用户将使用公共Cookie\n' +
              '获取完整的下载链接/歌曲Url'})
          })
      }
      Toggle({ type: ToggleType.Switch, isOn:this.isUsePubCookie }).height(24).width(48)
        .onChange(async () => { this.isUsePubCookie = !this.isUsePubCookie; AppStorage.setOrCreate('set-isUsePubCookie',this.isUsePubCookie); await PreferencesUtils.putPreferenceValue('Settings','isUsePubCookie',this.isUsePubCookie)})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

/**
 * 自定义API地址
 */
@Component struct customApiUrl {
  @StorageLink('set-isCustomApiUrl') isCustomApiUrl: boolean = false
  @StorageProp('set-customApiUrl') customApiUrl: string = ''
  build() {
    Column({ space: 5 }) {
      Row() {
        Text('自定义API服务器地址').LeftText()
        Toggle({ type: ToggleType.Switch, isOn: this.isCustomApiUrl }).height(24).width(48)
          .onChange(async () => {
            this.isCustomApiUrl = !this.isCustomApiUrl;
            AppStorage.setOrCreate('set-isCustomApiUrl', this.isCustomApiUrl);
            await PreferencesUtils.putPreferenceValue('Settings', 'isCustomApiUrl', this.isCustomApiUrl)
          })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 30, right: 30 })
      if(this.isCustomApiUrl) {
        Row({ space: 10 }) {
          TextInput({ text: this.customApiUrl })
            .layoutWeight(4)
            .onChange((text) => this.customApiUrl = text)
          Button('设置')
            .layoutWeight(1)
            .onClick(async () => {
              AppStorage.setOrCreate('set-customApiUrl',this.customApiUrl)
              await PreferencesUtils.putPreferenceValue('Settings','customApiUrl',this.customApiUrl)
              ToastUtil.showToast('设置成功，API地址：\n' + this.customApiUrl)
          })
        }
        .justifyContent(FlexAlign.Center)
        .width('80%')
      }
    }
    .width('100%')
  }
}

/**
 * 显示版本号
 */
@Component struct Version {
  build() {
    Row() {
      Text('当前版本').LeftText()
      Text(Constants.VERSION + Constants.VER_DESC).RightText()
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

/**
 * 反馈
 */
@Component struct Feedback {
  build() {
    Row() {
      Text('建议与反馈').LeftText()
      Text('前往反馈').RightText().textAlign(TextAlign.End).decoration({type: TextDecorationType.Underline})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
    .onClick(() => {
      router.pushUrl({
        url:'pages/WebPage',
        params: {title:'建议与反馈', url:'https://www.wjx.cn/vm/PeLnYfc.aspx#'}
      })
    })
  }
}

/**
 * 隐私政策
 */
@Component struct Privacy {
  build() {
    Row() {
      Text('隐私政策').LeftText()
      Text('前往查看本软件的隐私政策').RightText().decoration({type: TextDecorationType.Underline})
        .onClick(() => {
          router.pushUrl({
            url:'pages/WebPage',
            params: {title:'隐私政策', url:'https://docs.chenlvin.cc/cloudmusic/#/privacy'}
          })
        })
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

@Component struct Bottom {
  build() {
    Column() {
      Text('云音汇 @Chenlvin\n' +
        'GitHub: CloudMusic-HarmonyOSNext').BottomText()
    }
    .width('100%')
    .height(50)
  }
}


@Extend(Text) function LeftText() {
  .fontSize(16)
  .fontWeight(FontWeight.Bold)
}

@Extend(Text) function RightText() {
  .fontSize(16)
}

@Extend(Text) function BottomText() {
  .fontSize(12)
  .textAlign(TextAlign.Center)
  .onClick(() => {
    PasteboardUtil.setDataText('https://github.com/Chenlvin/CloudMusic-HarmonyOSNext')
    ToastUtil.showToast('已复制链接到剪贴板')
  })
}