import { AppUtil, PasteboardUtil, ToastUtil } from '@pura/harmony-utils';
import Constants from '../common/constants/Constants';
import { SettingsHead } from '../components/head/SettingsHead'
import { Want } from '@kit.AbilityKit';

let wantInfo: Want = {
  action: 'ohos.want.action.viewData',
  entities: ['entity.system.browsable'],
  uri: 'https://docs.chenlvin.cc/cloudmusic/#/privacy'
}

@Entry
@Component
struct Settings {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    Stack() {
      Column({ space: 10 }) {
        SettingsHead().padding({ bottom: 20 })

        List({ space: 20 }) {
          ListItem() { Version() }
          ListItem() { Privacy() }
          ListItem() { Feedback() }
        }.divider({ strokeWidth: 2 }).scrollBar(BarState.Auto)
        .height('100%').width('100%').layoutWeight(1)

        Bottom()
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main'))
  }
}

@Component
struct Version {
  build() {
    Row() {
      Text('当前版本').LeftText()
      Text(Constants.VERSION + Constants.VER_DESC).RightText()
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

@Component
struct Feedback {
  build() {
    Row() {
      Text('问题反馈').LeftText()
      Text('chenlvin@126.com\n' +
        '或 GitHub issue').RightText().textAlign(TextAlign.End)
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
    .onClick(() => {
      PasteboardUtil.setDataText('chenlvin@126.com')
      ToastUtil.showToast('已复制邮箱地址到剪贴板')
    })
  }
}

@Component
struct Privacy {
  build() {
    Row() {
      Text('隐私政策').LeftText()
      Text('前往查看本软件的隐私政策').RightText()
        .onClick(() => {
          AppUtil.getContext().startAbility(wantInfo)
        })
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

@Component
struct Bottom {
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