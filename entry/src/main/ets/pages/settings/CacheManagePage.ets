import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import FileUtils from "../../common/utils/file/FileUtils"

/**
 * 应用缓存
 */
@Component
export struct CacheManagePage {
  @State cacheSize: number = -1
  aboutToAppear(): void {
    this.cacheSize = FileUtils.getCacheSize()
  }
  build() {
    NavDestination() {
      Column({ space: 10 }) {
        Column({ space: 10 }) {
          Text('缓存目录占用')
            .fontSize(Constants.FONT_SIZE_TITLE)
            .fontWeight(FontWeight.Medium)
          Text(`${(this.cacheSize / (1024 * 1024)).toFixed(2)} MB`)
            .fontSize(Constants.FONT_SIZE_TITLE)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .borderRadius(Constants.RADIUS_CARD)
        .backgroundColor($r('app.color.main'))
        .padding(Constants.PADDING_EDGE_DEFAULT)
        Button('清理缓存')
          .fontSize(Constants.FONT_SIZE_COMMON)
          .backgroundColor($r('app.color.app_red'))
          .fontColor(Color.White)
          .type(ButtonType.Normal)
          .borderRadius(Constants.RADIUS_CARD)
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.showDialog()
          })
      }
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
    }
    .title('应用缓存')
    .backgroundColor($r('app.color.background'))
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
