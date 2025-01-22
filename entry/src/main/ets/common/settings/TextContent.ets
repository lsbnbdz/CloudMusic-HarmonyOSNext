import { router } from "@kit.ArkUI"
import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { AppConstants } from "../constants/AppConstants"

/**
 * 显示版本号
 */
@Component
export struct Settings_Version {
  build() {
    Row() {
      Text('当前版本').LeftText()
      Text(AppConstants.VERSION + AppConstants.VER_DESC).RightText()
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

/**
 * 反馈
 */
@Component
export struct Settings_Feedback {
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
 * 底部信息
 */
@Component
export struct Settings_Bottom {
  build() {
    Column() {
      Row() {
        Text('疑难解答').BottomText().fontColor($r('app.color.blue'))
          .onClick(() => {
            router.pushUrl({
              url:'pages/WebPage',
              params: {title:'帮助', url:`https://docs.chenlvin.cc/cloudmusic/#/help?timestamp=${new Date().getTime()}`}
            })
          })
        Text('    |    ').BottomText().fontColor($r('app.color.blue'))
        Text('隐私政策').BottomText().fontColor($r('app.color.blue'))
          .onClick(() => {
            router.pushUrl({
              url:'pages/WebPage',
              params: {title:'隐私政策', url:'https://docs.chenlvin.cc/cloudmusic/#/privacy'}
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 15 })

      Text('云音汇 - HMOS\n' +
        'GitHub: CloudMusic-HarmonyOSNext').BottomText()
    }
    .width('100%')
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
    ToastUtil.showToast('已复制GitHub链接到剪贴板')
  })
}