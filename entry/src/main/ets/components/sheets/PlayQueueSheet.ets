import { DialogUtil } from "@pura/harmony-utils"
import { DialogAction } from "@pura/harmony-utils/src/main/ets/entity/constraint"
import { PlayQueue } from "../../common/entities/PlayQueue"
import { playQueue } from "../../common/functions/playControl"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { LoopModeButton } from "../buttons/play/LoopModeButton"
import { LazyData } from '@pie/lazy-data';

/**
 * 播放列表 Sheet
 */
@Component
export struct PlayQueueSheet {
  @StorageProp('PlayQueue') queue: Array<PlayQueue> = []
  @StorageProp('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State queueLength: number = PlayQueueUtils.getQueueLength()
  @State isLoading: boolean = false
  @Link isShow: boolean
  @State dataSource: LazyData<PlayQueue> = new LazyData()
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.dataSource.setData(this.queue)

    setTimeout(() => {
      this.scrollToCurrent(false)
    }, 100)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: 10 }) {
        Row() {
          Row({ space: 15 }) {
            Text() {
              Span('播放列表').fontSize(20).fontColor(Color.Gray).fontWeight(FontWeight.Bold)
              Span(`  (${this.queueLength})`).fontSize(16).fontColor(Color.Gray)
            }

            LoopModeButton({ imgWidth: 25, btnWidth: 25 })

            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_position')).width(20).fillColor($r('app.color.reverse'))
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.scrollToCurrent()
            })
          }

          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_public_delete_filled')).width(25).fillColor(Color.Gray)
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            DialogUtil.showPrimaryDialog({
              title: '确认',
              message: '清空播放列表',
              primaryButton: "取消",
              secondaryButton: "确认",
              onAction: async (action) => {
                if (action == DialogAction.TWO) {
                  PlayQueueUtils.cleanQueue()
                  this.dataSource.setData([])
                  this.dataSource.notifyDataReload()
                }
              }
            })
          })
        }
        .padding({ left: 5, right: 5 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        List({ scroller: this.scroller, space: 15 }) {
          LazyForEach(this.dataSource, (item: PlayQueue, index) => {
            ListItem() {
              Row({ space: 10 }) {
                Text(`${index + 1}`)
                  .fontSize(12)
                  .fontColor(Color.Gray)
                  .padding({ right: 10 })
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.End)
                // 本地文件
                if (item.playmode == 0) {
                  Image($r('app.media.ic_public_todo')).width(20).fillColor(Color.Green)
                  if (this.currentQueueIndex == index) {
                    Text(`${item.song.name} - ${item.artists}`)
                      .textStyle(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('app.color.app_red'))
                      .layoutWeight(1)
                  } else {
                    Text() {
                      Span(`${item.song.name}`)
                      Span(` - ${item.artists}`).fontColor(Color.Gray)
                    }
                    .layoutWeight(1)
                    .textStyle(16)
                    .onClick(async () => {
                      this.isLoading = true
                      await playQueue(index)
                      this.isLoading = false
                    })
                  }
                }

                // 在线音乐
                else {
                  if (this.currentQueueIndex == index) {
                    Text(`${item.song.name} - ${item.artists}`)
                      .layoutWeight(1)
                      .textStyle(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#ffd25959')
                  } else {
                    Text(``) {
                      Span(`${item.song.name}`)
                      Span(` - ${item.artists}`).fontColor(Color.Gray)
                    }
                    .layoutWeight(1)
                    .textStyle(16)
                    .onClick(async () => {
                      this.isLoading = true
                      await playQueue(index)
                      setTimeout(() => {
                        this.isLoading = false
                      }, 500)
                    })
                  }
                }

                // 从播放列表中删除
                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.ic_public_cancel')).width(20).fillColor(Color.Gray)
                }
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  PlayQueueUtils.queueDelete(index)
                  this.dataSource.deleteData(index)
                  this.queueLength = PlayQueueUtils.getQueueLength()
                  this.dataSource.notifyDataReload()
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceAround)
            }
          }, (item: PlayQueue, index) => item.song.id.toString() + index)

          ListItem().height(px2vp(this.bottomRectHeight))
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      if(this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
        }
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .width('100%')
      }
    }
    .padding({ left:20, right:20, top:15 })
    .width('100%')
  }

  scrollToCurrent(animation: boolean = true) {
    if(this.currentQueueIndex <= 3) { this.scroller.scrollToIndex(this.currentQueueIndex, animation) }
    else { this.scroller.scrollToIndex(this.currentQueueIndex, animation, ScrollAlign.CENTER) }
  }
}

@Extend(Text) function textStyle(size:number) {
  .width('100%')
  .fontSize(size)
  .maxLines(1)
  .fontColor($r('app.color.reverse'))
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}