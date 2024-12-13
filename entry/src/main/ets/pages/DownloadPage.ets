import FileUtils from '../common/utils/FileUtils';
import { DeleteCircleButton, SaveCircleButton } from '../components/buttons/CircleButton';
import { ListHead } from '../components/head/ListHead';
import { FileCard } from '../components/main/FileCard';
import { BottomPlayController } from '../components/play/BottomPlayController';

@Entry
@Component
struct DownloadPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

  @State fileList:string[] = []

  async onPageShow(): Promise<void> {
    this.fileList = await FileUtils.getFileName()
  }
  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        ListHead({ title: '下载管理' })
        Column() {
          List({ space: 10 }) {
            ListItem() {
              if (this.fileList.length > 0) {
                Row() {
                  Text(`下载完成 (${this.fileList.length})`)
                  Text('单击/左滑进行文件操作')
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ left: 30, right: 30, top: 10 })
                .width('100%')
              }
              else {
                Text('下载文件为空').width('100%').textAlign(TextAlign.Center).padding({ left: 30, right: 30, top: 10 })
              }
            }
            ForEach(this.fileList, (item: string, index: number) => {
              ListItem() {
                Row({ space: 15 }) {
                  FileCard({ fileName: item })
                    .layoutWeight(1)
                }
                .padding({ left: 15, right: 15 })
              }
              .swipeAction({ end: this.SwipeItem(item) })
            })
            ListItem()
              .height(px2vp(this.bottomRectHeight) + 80)
          }
          .backgroundColor($r('app.color.background'))
          .height('100%')
          .width('100%')
          .layoutWeight(1)
          .height('100%')
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')

    BottomPlayController()
      .padding({ left: 10, right: 10, bottom: px2vp(this.bottomRectHeight)})
      .backgroundColor(Color.Transparent)
    }
    .backgroundColor($r('app.color.background'))
    .height('100%')
  }

  @Builder SwipeItem(fileName:string) {
    Row({ space: 10 }) {
      SaveCircleButton({ list: this.fileList, fileName: fileName })
      DeleteCircleButton({ list: this.fileList, fileName: fileName })
    }.padding({ right: 15 })
  }
}