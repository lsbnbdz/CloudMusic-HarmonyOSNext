import { DialogUtil, PasteboardUtil, ToastUtil } from '@pura/harmony-utils'
import Constants from '../common/constants/Constants'
import { SettingsHead } from '../components/head/SettingsHead'
import { router } from '@kit.ArkUI'
import PreferencesUtils from '../common/utils/PreferencesUtils'
import { ExplainButton } from '../components/buttons/ExplainButton'
import { QualityType } from '../common/entities/SongDownload'
import { DialogAction } from '@pura/harmony-utils/src/main/ets/entity/constraint'
import FileUtils from '../common/utils/FileUtils'

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
          ListItem() { setPlayQuality() }
          ListItem() { customApiUrl() }
          ListItem() { removeCache() }
          ListItem() { Divider() }
          ListItem() { Version() }
          ListItem() { Help() }
          ListItem() { Privacy() }
          ListItem() { Feedback() }
        }
        .scrollBar(BarState.Auto)
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        Bottom()
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
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
            DialogUtil.showConfirmDialog({title:'公共 Cookie', message:'该功能仅对非VIP用户生效\n开启后，非VIP用户将使用公共Cookie\n' +
              '获取完整的下载链接/歌曲Url'})
          })
      }
      Toggle({ type: ToggleType.Switch, isOn:this.isUsePubCookie }).height(24).width(48)
        .onChange(async () => { this.isUsePubCookie = !this.isUsePubCookie; AppStorage.setOrCreate('set-isUsePubCookie',this.isUsePubCookie); await PreferencesUtils.putPreferenceValue('Settings','isUsePubCookie',this.isUsePubCookie)})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

/**
 * 设置播放音质
 */
@Component struct setPlayQuality {
  @StorageLink('set-playQuality') playQuality:QualityType = "standard"
  @State selected:number | undefined = 0

  async aboutToAppear(): Promise<void> {
    this.selected = await AppStorage.get('set-playQuality')
  }
  build() {
    Row() {
      Text('在线播放音质').LeftText()
      Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
        .selected(this.selected)
        .value(this.selected ? Constants.QUALITY_NAME[this.selected] : '标准')
        .width(100)
        .onSelect((index: number) => {
          AppStorage.setOrCreate('set-playQuality',index)
          PreferencesUtils.putPreferenceValue('Settings', 'playQuality', index)
        })
    }
    .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
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
        Row({ space: 5 }) {
          Text('自定义API服务器地址').LeftText()
          ExplainButton()
            .onClick(() => {
              DialogUtil.showConfirmDialog({
                title: '自定义API服务器地址', message: '使用自定义网易云音乐API地址\n' +
                  '需要搭建NeteaseCloudMusicApi服务\n\n' +
                  '地址格式: http://example.com:3000\n' +
                  '(注意末尾不带\"/\")'
              })
            })
        }
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
 * 清理缓存
 */
@Component struct removeCache {
  build() {
    Row() {
      Text('清除缓存').LeftText()
      Button('清理')
        .backgroundColor(Color.Transparent)
        .borderWidth(2)
        .borderColor(Color.Gray)
        .fontColor($r('app.color.reverse'))
        .onClick(() => {
          DialogUtil.showPrimaryDialog({
            title: '确认',
            message: '清理缓存\n请勿在下载过程中清理，否则可能导致下载内容异常',
            primaryButton: "取消",
            secondaryButton: "清理",
            onAction: async (action) => {
              if(action == DialogAction.TWO) {
                FileUtils.removeCache()
              }
            }
          })
        })
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
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
 * 帮助
 */
@Component struct Help {
  build() {
    Row() {
      Text('帮助与疑难解答').LeftText()
      Text('前往查看').RightText().textAlign(TextAlign.End).decoration({type: TextDecorationType.Underline})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
    .onClick(() => {
      router.pushUrl({
        url:'pages/WebPage',
        params: {title:'建议与反馈', url:'https://docs.chenlvin.cc/cloudmusic/#/help'}
      })
    })
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

/**
 * 底部信息
 */
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