import { PasteboardUtil, ToastUtil } from '@pura/harmony-utils'
import Constants from '../common/constants/Constants'
import { SettingsHead } from '../components/head/SettingsHead'
import { router } from '@kit.ArkUI'
import PreferencesUtils from '../common/utils/PreferencesUtils'

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

@Component struct hasAnimation {
  @StorageLink('set-hasAnimation') hasAnimation: boolean = true
  build() {
    Row() {
      Text('是否开启列表动画').LeftText()
      Toggle({ type: ToggleType.Switch, isOn:this.hasAnimation }).height(24).width(48)
        .onChange(async () => { this.hasAnimation = !this.hasAnimation; AppStorage.setOrCreate('set-hasAnimation',this.hasAnimation); await PreferencesUtils.putPreferenceValue('Settings','hasAnimation',this.hasAnimation)})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

@Component struct Version {
  build() {
    Row() {
      Text('当前版本').LeftText()
      Text(Constants.VERSION + Constants.VER_DESC).RightText()
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

@Component struct Feedback {
  build() {
    Row() {
      Text('建议与反馈').LeftText()
      Text('前往反馈').RightText().textAlign(TextAlign.End).decoration({type: TextDecorationType.Underline})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
    .onClick(() => {
      router.pushUrl({
        url:'pages/WebPage',
        params: {title:'建议与反馈', url:'https://www.wjx.cn/vm/PeLnYfc.aspx# '}
      })
    })
  }
}

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