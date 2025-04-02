import { Song } from '../../common/entities/song/SongsResult'
import { SongCard } from '../../components/cards/SongCard'
import { DialogUtil, LogUtil } from '@pura/harmony-utils'
import { getCloudList } from '../../api/playListApi'
import { BottomBarComponent } from '../../components/play/BottomBarComponent'
import { AddToPlayListButton } from '../../components/buttons/play/AddToPlayListButton'
import Constants from '../../common/constants/Constants'
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from '../../components/buttons/LoadMoreButtons'
import { StorageConstants } from '../../common/constants/StorageConstants'
import { PlayListSong } from '../../common/entities/playlist/PlayListSongs'
import { LazyData } from '@pie/lazy-data'

/**
 * 云盘
 */

const TAG = '[CloudPage] '

@Component
export struct CloudPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  private currentOffset: number = 0
  @State list: Array<PlayListSong> = new Array()
  @State dataSource: LazyData<PlayListSong> = new LazyData()
  @State hasMore: boolean = true
  @State hasLoaded: boolean = false
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false
  @State menuItem: NavigationMenuItem[] = [
    {
      value: '',
      icon: $r('app.media.ic_public_help'),
      action: () => {
        DialogUtil.showConfirmDialog({
          title: '云盘',
          message: '音乐云盘内歌曲仅支持单首播放、缓存'
        })
      }
    }
  ]

  async aboutToAppear() {
    if (!this.hasLoaded) {
      await this.loadSongs(50, 0)
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
      this.dataSource.setData(this.list)
      this.dataSource.notifyDataReload()
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
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if (this.isLoading) {
            Column() {
              LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
            }.height('100%').width('100%').justifyContent(FlexAlign.Center)
          } else {
            List() {
              LazyForEach(this.dataSource, (item: PlayListSong, index) => {
                ListItem() {
                  SongCard({
                    song: {
                      id: item.id,
                      artists: item.ar,
                      name: item.name,
                      duration: item.dt,
                      alias: [],
                      fee: item.fee
                    },
                    sid: this.list.indexOf(item),
                    picUrl: item.al?.picUrl ?? $r('app.media.ic_public_music')
                  })
                }

              })
              if (this.isLoadingMore) {
                ListItem() {
                  LoadingMoreButton()
                }
              } else if (this.hasMore) {
                ListItem() {
                  ClickToLoadButton()
                    .onClick(() => {
                      this.loadSongs(30, this.currentOffset)
                    })
                }
              } else if (!this.hasMore) {
                ListItem() {
                  NoMoreButton()
                }
              }
              ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
            }
            .height('100%')
            .layoutWeight(1)
            .width('100%')
            .scrollBar(BarState.Auto)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .backToTop(true)
          }
        }
        .height('100%')

        if(this.breakpoint !== 'lg') {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
      .translate({ y: -40 })
      .animation({
        duration: 600,
        curve: Curve.LinearOutSlowIn
      })
      .translate({ y: 0 })
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .title('音乐云盘')
    .menus(this.menuItem)
    .backgroundColor($r('app.color.background'))
  }
}