import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { CacheSet, CacheSetItem } from "../../common/entities/local/Settings"
import { changeSettings } from "../../common/functions/app/settings"
import FileUtils from "../../common/utils/file/FileUtils"

/**
 * 应用缓存
 */
@Component
export struct CacheManagePage {
  @State cacheDirSize: number = -1
  @State songCacheSize: number = -1
  @StorageProp(StorageConstants.CACHE_SETTINGS) cacheSet: CacheSet = CacheSetItem
  @State set: CacheSet = CacheSetItem

  async aboutToAppear(): Promise<void> {
    this.set = this.cacheSet
    this.cacheDirSize = FileUtils.getCacheSize()
    this.songCacheSize = await FileUtils.getSongCacheSize()
  }

  private updateCacheSet() {
    this.cacheSet = this.set
    changeSettings(StorageConstants.CACHE_SETTINGS, this.cacheSet)
  }

  build() {
    NavDestination() {
      List({ space: Constants.PADDING_EDGE_DEFAULT }) {
        ListItem() {
          this.SetMaxCacheSize()
        }
        .itemStyle()

        ListItem() {
          Row(){
            Text('图片与下载临时文件')
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontWeight(FontWeight.Bold)
            Text(`${(this.cacheDirSize / (1024 * 1024)).toFixed(2)} MB`)
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontWeight(FontWeight.Bold)
          }
          .height(Constants.HEIGHT_SETTINGS_ITEM)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
        }
        .itemStyle()

        ListItem() {
          Button('清理临时文件缓存')
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontColor($r('app.color.app_red'))
            .backgroundColor(Color.Transparent)
            .width('100%')
            .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
            .onClick(() => {
              this.showDialog()
            })
        }
        .itemStyle()
      }
      .padding(Constants.PADDING_EDGE_DEFAULT)
      .width('100%')
      .height('100%')
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

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }

  @Builder SetMaxCacheSize() {
    Column({ space: 5 }) {
      Row() {
        Text('歌曲最大缓存空间')
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
        Text(`${this.cacheSet.songCacheMaxSize / (1024 * 1024 * 1024)} G`)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
      }
      .padding({ top: 10, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Slider({
        value: this.set.songCacheMaxSize / (1024 * 1024 * 1024),
        min: 1,
        max: 20
      })
        .selectedColor($r('app.color.app_red'))
        .width('100%')
        .onChange((value, mode) => {
          if(mode == SliderChangeMode.Moving) {
            animateTo({ duration: 100, curve: Curve.Linear}, () => {
              this.set.songCacheMaxSize = value * 1024 * 1024 * 1024
            })
            return
          }
          this.cacheSet.songCacheMaxSize = value * 1024 * 1024 * 1024
          this.updateCacheSet()
        })
    }
    .width('100%')
  }
}

