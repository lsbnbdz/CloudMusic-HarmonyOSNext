import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import { DialogAction } from "@pura/harmony-utils/src/main/ets/entity/constraint"
import FileUtils from "../utils/FileUtils"

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
                try {
                  const res = await FileUtils.removeCache()
                  if (res) {
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
        })
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

@Extend(Text) function LeftText() {
  .fontSize(16)
  .fontWeight(FontWeight.Bold)
}
