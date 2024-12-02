import FileUtils from '../common/utils/FileUtils';
import { DeleteCircleButton, SaveCircleButton } from '../components/buttons/CircleButton';
import { CommonHead } from '../components/head/CommonHead'
import { ListHead } from '../components/head/ListHead';
import { FileCard } from '../components/main/FileCard';

@Entry
@Component
struct DownloadPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State list:string[] = []

  async onPageShow(): Promise<void> {
    this.list = await FileUtils.getFileName()
  }
  build() {
    Stack() {
      Column() {
        ListHead({ title: '下载管理' })
        Column() {
          List({ space: 10 }) {
            ListItem() {
              Text('左滑进行文件操作').padding({ left: 30, right: 30, top: 10 }).width('100%')
            }

            ForEach(this.list, (item: string, index: number) => {
              ListItem() {
                Row({ space: 15 }) {
                  Text(`${index + 1}`).fontSize(15).padding({ left: 10 })
                  FileCard({ fileName: item })
                    .layoutWeight(1)
                }
                .padding({ left: 15, right: 15 })
              }
              .swipeAction({ end: this.SwipeItem(item) })
            })
            ListItem()
              .height(px2vp(this.bottomRectHeight))
          }
          .height('100%')
          .width('100%')
          .layoutWeight(1)
          .height('100%')
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .width('100%')
      }
      .padding({ top: px2vp(this.topRectHeight) })
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.main'))
    }.height('100%')
  }

  @Builder SwipeItem(fileName:string) {
    Row({ space: 10 }) {
      SaveCircleButton({ list: this.list, fileName: fileName }).padding({ left: 10 })
      DeleteCircleButton({ list: this.list, fileName: fileName })
    }.padding({ right: 15 })
  }
}