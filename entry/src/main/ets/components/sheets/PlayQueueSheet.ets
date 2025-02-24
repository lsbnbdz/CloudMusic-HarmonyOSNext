import { DialogUtil, EmitterUtil, ToastUtil } from "@pura/harmony-utils"
import { DialogAction } from "@pura/harmony-utils/src/main/ets/entity/constraint"
import { PlayQueue } from "../../common/entities/PlayQueue"
import { playQueue } from "../../common/functions/play/playControl"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { LoopModeButton } from "../buttons/play/LoopModeButton"
import { LazyData } from '@pie/lazy-data';
import { setHeartMode } from "../../api/songApi"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayList, playListClass } from "../../common/entities/PlayList"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"

/**
 * 播放列表 Sheet
 */
@Component
export struct PlayQueueSheet {
  @StorageProp('PlayQueue') queue: Array<PlayQueue> = []
  @StorageLink('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('player-mode') playmode: number = 1
  @State isLoading: boolean = false
  @Link isShow: boolean
  @State dataSource: LazyData<PlayQueue> = new LazyData()
  @StorageProp(StorageConstants.PLAYLIST_LIKE) likePlayList: PlayList = playListClass
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.dataSource.setData(this.queue)

    setTimeout(() => {
      this.scrollToCurrent(false)
    }, 100)

    EmitterUtil.onSubscribe(EmitterConstants.EMITTER_REFRESH_PLAYQUEUE, () => {
      this.dataSource.setData(this.queue)
      this.dataSource.notifyDataReload()
    })
  }

  aboutToDisappear(): void {
    EmitterUtil.off(EmitterConstants.EMITTER_REFRESH_PLAYQUEUE, () => {})
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: 10 }) {
        Row() {
          Row({ space: 15 }) {
            Text() {
              Span('播放列表').fontSize(Constants.FONT_SIZE_TITLE).fontColor(Color.Gray).fontWeight(FontWeight.Bold)
              Span(`  (${this.queue.length})`).fontSize(Constants.FONT_SIZE_COMMON).fontColor(Color.Gray)
            }

            LoopModeButton({ imgWidth: Constants.SIZE_ICON_BUTTON_BAR, btnWidth: Constants.SIZE_ICON_BUTTON_BAR })

            // HeartMode Button
            if(this.queue.length > 0 && this.playmode == 1) {
              Button() {
                Image($r('app.media.ic_heart_filled')).width(Constants.SIZE_ICON_BUTTON_BAR - 5).fillColor($r('app.color.reverse'))
              }
              .backgroundColor(Color.Transparent)
              .onClick(async () => {
                await this.startHeartMode()
              })
            }

            if(this.isLoading) {
              LoadingProgress().width(Constants.SIZE_ICON_BUTTON_BAR)
            }
          }

          Row({ space: 10 }) {
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_position')).width(Constants.SIZE_ICON_BUTTON_BAR).fillColor(Color.Gray)
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.scrollToCurrent()
            })

            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_public_delete_filled')).width(Constants.SIZE_ICON_BUTTON_BAR - 5).fillColor(Color.Gray)
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.cleanPlayQueue()
            })
          }
        }
        .padding({ left: 5, right: 5 })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        List({ scroller: this.scroller, space: 20 }) {
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
                      .fontColor($r('app.color.app_red'))
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

  private cleanPlayQueue() {
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
  }

  private async startHeartMode() {
    DialogUtil.showPrimaryDialog({
      title: '心动歌单',
      message: '是否将播放列表替换为【心动歌单】?\n\n开启心动歌单后，\n将会替换当前播放列表并开始新的播放',
      primaryButton: "取消",
      secondaryButton: {
        value: '确认',
        fontColor: Color.Red,
        action: async () => {
          this.isLoading = true
          try {
            await setHeartMode(this.queue[this.currentQueueIndex].song.id, this.likePlayList.id)
            playQueue(0)
            this.scroller.scrollToIndex(0)
          } catch (e) {
            ToastUtil.showToast('获取心动模式歌单失败')
          } finally {
            this.dataSource.setData(this.queue)
            this.dataSource.notifyDataReload()
            this.isLoading = false
          }
        }
      }
    })
  }
}

@Extend(Text) function textStyle(size:number) {
  .width('100%')
  .fontSize(size)
  .maxLines(1)
  .fontColor($r('app.color.reverse'))
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}