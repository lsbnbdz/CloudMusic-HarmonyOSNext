import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/main/SongCard'
import { ListHead } from '../components/head/ListHead'
import { SpinKit, SpinType } from '@pura/spinkit'
import { LogUtil, ToastUtil } from '@pura/harmony-utils'
import { getCloudList } from '../api/playListApi'
import { BottomPlayController } from '../components/play/BottomPlayController'
import { CommonCircleButton } from '../components/buttons/CircleButton'
import Constants from '../common/constants/Constants'

/**
 * 云盘
 */

const TAG = '[CloudPage] '

@Entry
@Component
struct PlayListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

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
      await this.loadSongs(20, 0)
    }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return
    if (offset == 0) {
      this.isLoading = true
    } else {
      this.isLoadingMore = true
    }

    try {
      const result = await getCloudList(offset)
      this.list = [...this.list, ...result]
      this.currentOffset += limit
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
              Text('云盘内歌曲仅支持单首播放和下载').textAlign(TextAlign.Center).width('100%').fontSize(14).padding(15)
            }
            ForEach(this.list, (item: Song, index) => {
              ListItem() {
                SongCard({ song: item, sid: index, hasAnimation: this.hasAnimation,
                  isPlayList: false, index: index, showPlayButton: true, showAddQueueButton: false })
              }
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
          title: '音乐云盘',
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
}