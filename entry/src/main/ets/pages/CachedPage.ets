import FileUtils from '../common/utils/file/FileUtils';
import { FileCard } from '../components/cards/FileCard';
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import { resourceManager } from '@kit.LocalizationKit';
import { StorageConstants } from '../common/constants/StorageConstants';
import { LogUtil, ToastUtil } from '@pura/harmony-utils';

/**
 * 缓存管理页
 * DownloadPage
 */
const TAG = '[CachedPage] '

@Component
export struct CachedPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @State searchKeyword: string = ''
  @State fileList: string[] = []
  @State filteredList: Array<string> = new Array()

  menus: NavigationMenuItem[] = [{
    value: '搜索',
    icon: $r('app.media.ic_public_search_filled'),
    action: () => {
      this.getUIContext().getFocusController().requestFocus('search')
    }
  }]

  async aboutToAppear(): Promise<void> {
    this.fileList = await FileUtils.getFileName()
    this.fileList.reverse()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Column() {
            Grid() {
              GridItem() {
                Search({
                  placeholder: '搜索文件',
                  icon: '/resources/base/media/ic_public_search_filled.svg'
                })
                  .id('search')
                  .height(Constants.HEIGHT_SELECT)
                  .width('100%')
                  .searchButton('搜索')
                  .onChange((value) => {
                    if(value == '') {
                      this.filteredList = []
                      this.searchKeyword = ''
                    }
                  })
                  .onSubmit((value) => {
                    this.searchKeyword = value
                    this.handelSearch()
                  })
              }
              GridItem() {
                if (this.fileList.length > 0) {
                  Row() {
                    Text(`共 ${this.fileList.length} 首歌曲 (点击排序)`)
                      .fontSize(Constants.FONT_SIZE_COMMON)
                      .onClick(() => {
                        this.fileList.sort()
                      })
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .width('100%')
                }
                else {
                  Text('文件沙箱目录为空').width('100%').textAlign(TextAlign.Center).padding({ left: 30, right: 30, top: 10 })
                }
              }

              GridItem() {
                GridRow({ columns: { xs: 1, sm: 1, md: 1, lg: 2, xl: 2 } }) {
                  ForEach(this.searchKeyword ? this.filteredList : this.fileList, (item: string, index: number) => {
                    GridCol() {
                      FileCard({ fileName: item, list: this.fileList })
                        .padding({ bottom: Constants.PADDING_EDGE_DEFAULT })
                    }
                  })
                }
              }
              .width('100%')

              GridItem()
                .height(px2vp(this.bottomRectHeight) + 80)
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .rowsGap(10)
            .columnsGap(10)
            .columnsTemplate('1fr')
            .layoutDirection(GridDirection.Column)
            .backgroundColor($r('app.color.background'))
            .height('100%')
            .width('100%')
            .padding({ left: 10, right: 10 })
            .layoutWeight(1)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .height('100%')

        if(this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_PHONE) {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
      .backgroundColor($r('app.color.background'))
      .height('100%')
    }
    .title('缓存')
    .menus(this.menus)
    .backgroundColor($r('app.color.background'))
  }
  private handelSearch() {
    try {
      if (this.searchKeyword.trim() === '') {
        this.filteredList = [...this.fileList]
        return
      }
      const keyword = this.searchKeyword.trim().toLowerCase()
      this.filteredList = this.fileList.filter(string =>
      string.toLowerCase().includes(keyword)
      )
    } catch (e) {
      ToastUtil.showToast('搜索时出错')
      LogUtil.error(TAG + 'Error while handelSearch: ' + e.message)
    }
  }
}