import { router } from '@kit.ArkUI'
import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/main/SongCard'
import { PlayList } from '../common/entities/PlayList'
import { ListHead } from '../components/head/ListHead'
import { SpinKit, SpinType } from '@pura/spinkit'
import { DialogUtil, LogUtil, ToastUtil } from '@pura/harmony-utils'
import { getPlayListSongs, PlayListOperation, putPlayListInQueue } from '../api/playListApi'
import { BottomPlayController } from '../components/play/BottomPlayController'
import { CommonCircleButton } from '../components/buttons/CircleButton'
import Constants from '../common/constants/Constants'
import { playQueue } from '../common/functions/playerControl'
import { DialogAction } from '@pura/harmony-utils/src/main/ets/entity/constraint'
import { formatNumber } from '../common/functions/functions'

/**
 * 歌单二级页面
 */

const TAG = '[PlayListPage] '

@Entry
@Component
struct PlayListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

  private playList: PlayList = Object(router.getParams())['playList']
  private trackCount: number = Object(router.getParams())['trackCount']

  @State list: Array<Song> = new Array()
  @State hasMore: boolean = true
  @State hasLoaded: boolean = false // 判定是否已加载 避免重复加载
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false
  @State loadingPlayList:boolean = false
  @State pageOpacity: number = 1

  private currentOffset: number = 0 // 歌曲偏移量
  hasAnimation:boolean | undefined = false

  async onPageShow(): Promise<void> {
    this.hasAnimation = AppStorage.get('set-hasAnimation')
    if (!this.hasLoaded) {
      await this.loadSongs(30, 0)
    }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return // 没有更多歌曲直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    } else {
      this.isLoadingMore = true // 加载更多
    }

    try {
      const result = await getPlayListSongs(this.playList.id, offset)
      this.list = [...this.list, ...result] // 合并歌曲列表
      this.currentOffset += limit

      if (this.list.length >= this.trackCount) {
        this.hasMore = false
      }
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', e)
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasLoaded = true
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if (this.isLoading) {
            Column() {
              SpinKit({ spinType: SpinType.spinO, spinSize: 60, spinColor: Color.Gray }).width(60)
            }.height('100%').width('100%').justifyContent(FlexAlign.Center)
          } else {
            List() {
              ListItem().height( px2vp(this.topRectHeight) + 50 )
              ListItem() {
                this.PlayListInfo()
              }
              .padding({ bottom: 15 })
              ListItem() {
                Button() {
                  Row({ space: 5 }) {
                    Image($r('app.media.ic_play_fill')).width(15).fillColor(Color.Gray)
                    Text('播放全部').fontSize(15)
                  }
                }
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .borderRadius(15)
                .onClick(async () => {
                  this.loadingPlayList = true
                  await putPlayListInQueue(this.playList.id, this.trackCount)
                  this.loadingPlayList = false
                  playQueue(0)
                })
              }
              .padding({ left: 20, bottom: 10 })

              ForEach(this.list, (item: Song, index) => {
                ListItem() {
                  SongCard({ song: item, sid: index, hasAnimation: this.hasAnimation,
                    isPlayList: true, playList: this.playList, index: index })
                }
                .swipeAction({ end: this.SwipeItem(item, index) })
              });
              // 添加加载更多
              if (this.isLoadingMore) {
                ListItem() {
                  Column() {
                    SpinKit({ spinType: SpinType.spinO, spinSize: 30, spinColor: Color.Gray }).width(30)
                  }.justifyContent(FlexAlign.Center).width('100%').height(50)
                }
              } else if (this.hasMore) {
                ListItem() {
                  Text("点击加载更多")
                    .onClick(() => {
                      this.loadSongs(30, this.currentOffset)
                    })
                    .padding({ top: 10, bottom: px2vp(this.bottomRectHeight) })
                    .fontColor($r('app.color.reverse'))
                    .width('100%')
                    .textAlign(TextAlign.Center)
                }
              } else if (!this.hasMore) {
                ListItem() {
                  Text('没有更多了~').fontSize(16).textAlign(TextAlign.Center).width('100%').height(50);
                }
              }
              ListItem().height(px2vp(this.bottomRectHeight) + 80)
            }
            .height('100%')
            .layoutWeight(1)
            .width('100%')
            .scrollBar(BarState.Auto)
          }
          ListHead({
            title: this.playList.name,
            slot: this.HeadSlot
          })
        }
        .height('100%')

      BottomPlayController()
      .padding({ left: 10, right: 10, bottom: px2vp(this.bottomRectHeight)})
      .backgroundColor(Color.Transparent)

      if(this.loadingPlayList) {
        Column() {
          Column({ space: 10 }) {
            LoadingProgress().width(60)
            Text('正在获取完整歌曲列表')
          }
          .padding(30)
          .borderRadius(15)
          .backgroundColor($r('app.color.main'))
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: px2vp(this.topRectHeight) })
      }
    }
    .opacity(this.pageOpacity)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'));
  }

  @Builder
  HeadSlot() {
    CommonCircleButton({ ButtonImageName: 'ic_public_more_filled' })
      .onClick(() => {
        ToastUtil.showToast(Constants.DEVELOPING_MSG)
      })
  }

  @Builder PlayListInfo() {
    Column() {
      Row({ space: 15 }) {
        Column() {
          Stack() {
            Image($r('app.media.ic_public_music'))
              .width('100%')
              .borderRadius(10)
            Image(`${this.playList.coverImgUrl}?parm=256y256`)
              .width('100%')
              .borderRadius(10)
          }
          .height('100%')
          .width('100%')
        }
        .height(80)
        .width(80)

        Column({ space: 5 }) {
          Text(this.playList.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ bottom: 5 })
          Text(`由 ${this.playList.creator.nickname} 创建`)
            .fontSize(12)
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(`${formatNumber(this.playList.playCount)}次播放`)
            .fontSize(12)
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
      }
      .width('90%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder SwipeItem(song: Song, index: number) {
    Row({ space: 10 }) {
      Button() {
        Text('从歌单删除')
          .height('100%')
          .fontColor(Color.White)
          .padding({ left: 10, right: 10 })
          .textAlign(TextAlign.Center)
      }
      .type(ButtonType.Normal)
      .height('100%')
      .backgroundColor('#ffee4c51')
      .onClick(() => {
        DialogUtil.showPrimaryDialog({
          title: '从歌单删除歌曲',
          message: `${song.name}`,
          primaryButton: "取消",
          secondaryButton: "删除",
          onAction: async (action) => {
            if(action == DialogAction.TWO) {
              try {
                await PlayListOperation('del', this.playList.id, song.id)
                ToastUtil.showToast('删除成功')
                this.list.splice(index, 1)
              } catch (e) {
                ToastUtil.showToast('删除失败: ' + e)
              }
            }
          }
        })
      })
    }
  }
}