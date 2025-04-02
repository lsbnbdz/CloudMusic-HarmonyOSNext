import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import FileUtils from "../../common/utils/file/FileUtils"

/**
 * 应用缓存
 */
@Component
export struct CacheManagePage {
  @State cacheDirSize: number = -1
  @State songCacheSize: number = -1

  async aboutToAppear(): Promise<void> {
    this.cacheDirSize = FileUtils.getCacheSize()
    this.songCacheSize = await FileUtils.getSongCacheSize()
  }

  build() {
    NavDestination() {
      Column({ space: 10 }) {
        Column({ space: 10 }) {
          Text('图片与下载临时文件')
            .fontSize(Constants.FONT_SIZE_TITLE)
            .fontWeight(FontWeight.Medium)
          Text(`${(this.cacheDirSize / (1024 * 1024)).toFixed(2)} MB`)
            .fontSize(Constants.FONT_SIZE_TITLE)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .borderRadius(Constants.RADIUS_CARD)
        .backgroundColor($r('app.color.main'))
        .padding(Constants.PADDING_EDGE_DEFAULT)

        Column({ space: 10 }) {
          Text('已缓存的歌曲')
            .fontSize(Constants.FONT_SIZE_TITLE)
            .fontWeight(FontWeight.Medium)
          Text(`${(this.songCacheSize / (1024 * 1024 * 1024)).toFixed(2)} MB`)
            .fontSize(Constants.FONT_SIZE_TITLE)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .borderRadius(Constants.RADIUS_CARD)
        .backgroundColor($r('app.color.main'))
        .padding(Constants.PADDING_EDGE_DEFAULT)


        Button('清理临时文件缓存')
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
      message: '清理应用缓存，不会影响缓存到沙箱的歌曲\n\n请勿在下载过程中清理，否则可能导致下载中的歌曲异常',
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
            this.cacheDirSize = FileUtils.getCacheSize()
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
