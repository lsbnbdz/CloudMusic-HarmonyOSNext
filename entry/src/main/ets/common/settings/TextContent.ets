import { router } from "@kit.ArkUI"
import { PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../constants/Constants"

/**
 * 显示版本号
 */
@Component
export struct Settings_Version {
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
@Component
export struct Settings_Help {
  build() {
    Row() {
      Text('帮助与疑难解答').LeftText()
      Text('前往查看').RightText().textAlign(TextAlign.End).decoration({type: TextDecorationType.Underline})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
    .onClick(() => {
      router.pushUrl({
        url:'pages/WebPage',
        params: {title:'帮助', url:`https://docs.chenlvin.cc/cloudmusic/#/help?timestamp=${new Date().getTime()}`}
      })
    })
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
 * 隐私政策
 */
@Component
export struct Settings_Privacy {
  build() {
    Row() {
      Text('隐私政策').LeftText()
      Text('前往查看').RightText().decoration({type: TextDecorationType.Underline})
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
@Component
export struct Settings_Bottom {
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
    ToastUtil.showToast('已复制GitHub链接到剪贴板')
  })
}