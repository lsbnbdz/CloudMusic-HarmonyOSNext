import { router } from '@kit.ArkUI'
import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/main/SongCard'
import { playList } from '../common/entities/PlayList'
import { PlayListHead } from '../components/head/PlayListHead'
import { getPlayListSongs } from '../api/getPlayListSongs'
import { SpinKit, SpinType } from '@pura/spinkit'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 歌单二级页面
 */

@Entry
@Component
struct PlayListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

  private playList: playList = Object(router.getParams())['playList']
  private trackCount: number = Object(router.getParams())['trackCount']

  @State hasLoaded: boolean = false // 判定是否已加载 避免重复加载
  @State isLoading: boolean = true
  @State list: Array<Song> = new Array()
  @State isLoadingMore: boolean = false
  @State hasMore: boolean = true

  private currentOffset: number = 0 // 歌曲偏移量

  async onPageShow(): Promise<void> {
    LogUtil.setTag('PlayListPage')
    if (!this.hasLoaded) {
      await this.loadSongs(30, 0)
    }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return // 没有更多歌曲直接返回

    if (offset === 0) {
      this.isLoading = true // 初次加载
    } else {
      this.isLoadingMore = true // 加载更多
    }

    try {
      const result = await getPlayListSongs(this.playList.id, limit, offset)
      this.list = [...this.list, ...result] // 合并歌曲列表
      this.currentOffset += limit

      if (this.list.length >= this.trackCount) {
        this.hasMore = false
      }
    } catch (e) {
      LogUtil.error('Error fetching songs: ', e)
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasLoaded = true
    }
  }

  build() {
    Stack() {
      if (this.isLoading == true) {
        Column() {
          SpinKit({ spinType: SpinType.spinO, spinSize: 60, spinColor: Color.Gray }).width(60)
        }.height('100%').width('100%').justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 10 }) {
          PlayListHead({ playListName: this.playList.name })
          List() {
            ForEach(this.list, (item: Song, index) => {
              ListItem() {
                SongCard({ song: item, sid: index })
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
                  .padding({ top:10, bottom:px2vp(this.bottomRectHeight) })
                  .fontColor($r('app.color.reverse'))
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
            } else if (!this.hasMore) {
              ListItem() {
                Text('没有更多了~').fontSize(16).textAlign(TextAlign.Center).width('100%').height(50);
              }
            }
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Auto)
        }
        .height('100%')
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.main'));
  }
}