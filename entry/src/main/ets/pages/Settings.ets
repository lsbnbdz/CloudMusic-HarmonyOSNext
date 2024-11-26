import { PasteboardUtil, ToastUtil } from '@pura/harmony-utils';
import { SettingsHead } from '../components/head/SettingsHead'

@Entry
@Component
struct Settings {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    Column({ space: 30 }) {
      SettingsHead()
      List({ space:10 }) {
        ListItem() { Version() }
      }.divider({ strokeWidth:2 }).width('100%').scrollBar(BarState.Auto)
      Bottom()
    }
    // .height(`calc(100% - 70px - ${this.topRectHeight}px - ${this.bottomRectHeight}px)`)
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
      Text('V.0.9.1 - 云音汇测试版').RightText()
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

@Component
struct Bottom {
  build() {
    Column() {
      Text('云音汇 @Chenlvin\n' +
        'GitHub: CloudMusic-HarmonyOSNext').BottomText()
    }.width('100%')
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