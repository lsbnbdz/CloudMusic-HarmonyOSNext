import FileUtils from '../common/utils/file/FileUtils';
import { FileCard } from '../components/cards/FileCard';
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import { resourceManager } from '@kit.LocalizationKit';
import { StorageConstants } from '../common/constants/StorageConstants';

/**
 * 下载管理页
 * DownloadPage
 */
@Component
export struct DownloadPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @State fileList: string[] = []
  @State columnsTemplate: string = '1fr'
  @State columnEnd: number = 0

  async aboutToAppear(): Promise<void> {
    this.fileList = await FileUtils.getFileName()
    this.fileList.reverse()
  }

  async changeLayout(columnEnd: number ) {
    if(columnEnd == 0) { this.columnsTemplate = '1fr'; this.columnEnd = 0 }
    else if(columnEnd == 1) { this.columnsTemplate = '1fr 1fr'; this.columnEnd = 1 }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Column() {
            Grid() {
              GridItem() {
                if (this.fileList.length > 0) {
                  Row() {
                    Text(`共 ${this.fileList.length} 首歌曲 (点击排序)`)
                      .fontSize(Constants.FONT_SIZE_COMMON)
                      .onClick(() => {
                        this.fileList.sort()
                      })
                    Select([{ value: '1列' }, { value: '2列' }])
                      .height(Constants.HEIGHT_SELECT)
                      .selected(0)
                      .borderStyle(BorderStyle.Solid)
                      .value('1列')
                      .onSelect((index: number) => {
                        this.changeLayout(index)
                      })
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .width('100%')
                }
                else {
                  Text('下载文件为空').width('100%').textAlign(TextAlign.Center).padding({ left: 30, right: 30, top: 10 })
                }
              }
              .columnStart(0)
              .columnEnd(this.columnEnd)

              ForEach(this.fileList, (item: string, index: number) => {
                GridItem() {
                  FileCard({ fileName: item, list: this.fileList, columnEnd: this.columnEnd })
                    .layoutWeight(1)
                }
              })
              GridItem()
                .columnStart(0)
                .columnEnd(this.columnEnd)
                .height(px2vp(this.bottomRectHeight) + 80)
            }
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .rowsGap(10)
            .columnsGap(10)
            .columnsTemplate(this.columnsTemplate)
            .layoutDirection(GridDirection.Column)
            .backgroundColor($r('app.color.background'))
            .height('100%')
            .width('100%')
            .padding({ left: 10, right: 10 })
            .layoutWeight(1)
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
    .title('下载')
    .backgroundColor($r('app.color.background'))
  }
}