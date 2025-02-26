import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import FileUtils from "../../common/utils/file/FileUtils"

/**
 * 清理缓存
 */
@Component
export struct RemoveCache {
  @State cacheSize: number = -1
  aboutToAppear(): void {
    this.cacheSize = FileUtils.getCacheSize()
  }
  build() {
    Row() {
      Text('清除缓存目录').LeftText()
      Button(`${(this.cacheSize / (1024 * 1024)).toFixed(2)} MB`)
        .height(Constants.HEIGHT_TEXT_BUTTON)
        .backgroundColor(Color.Transparent)
        .borderWidth(2)
        .borderColor(Color.Gray)
        .fontColor($r('app.color.reverse'))
        .onClick(() => {
          this.showDialog()
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  private showDialog() {
    DialogUtil.showPrimaryDialog({
      title: '清理缓存',
      message: '清理应用缓存，不会影响缓存到沙箱的歌曲\n\n请勿在缓存歌曲过程中清理，否则可能导致正在缓存的歌曲异常',
      primaryButton: "取消",
      secondaryButton: {
        fontColor: Color.Red,
        value: '清理',
        action: async () => {
          try {
            const is = await FileUtils.removeCache()
            if (is) {
              ToastUtil.showToast('成功清理缓存目录')
            } else {
              ToastUtil.showToast('清理缓存目录失败')
            }
          } catch (e) {
            ToastUtil.showToast('清理缓存目录出错: ' + e)
          } finally {
            this.cacheSize = FileUtils.getCacheSize()
          }
        }
      }
    })
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}
