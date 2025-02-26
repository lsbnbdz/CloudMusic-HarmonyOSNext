import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/cards/SongCard'
import { playListClass } from '../common/entities/PlayList'
import { DialogUtil, LogUtil, ToastUtil } from '@pura/harmony-utils'
import { getPlayListSongs, PlayListOperation, subscribePlayList } from '../api/playListApi'
import { BottomBarComponent } from '../components/play/BottomBarComponent'
import { DialogAction } from '@pura/harmony-utils/src/main/ets/entity/constraint'
import { formatNumber } from '../common/functions/commonFunction'
import { playListToQueue } from '../common/functions/play/playListOp'
import { AddToPlayListButton } from '../components/buttons/play/AddToPlayListButton'
import Constants from '../common/constants/Constants'
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from '../components/buttons/LoadMoreButtons'
import { PlayListPageParam } from '../common/entities/PageParams'
import { PlayListCard_Skeleton } from '../components/cards/PlayListCard'
import { StorageConstants } from '../common/constants/StorageConstants'
import { resourceManager } from '@kit.LocalizationKit'

/**
 * 歌单二级页面
 */

const TAG = '[PlayListPage] '

@Component
export struct PlayListPage {
  @State param: PlayListPageParam = {
    playList: playListClass,
    isShowHeart: false
  }
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('isPlayerLoading') isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  private currentOffset: number = 0 // 歌曲偏移量

  @State isSubscribed: boolean = false
  @State list: Array<Song> = new Array()
  @State filteredList: Array<Song> = new Array()
  @State hasMore: boolean = true
  @State hasLoaded: boolean = false // 判定是否已加载 避免重复加载
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false
  @State pageOpacity: number = 1
  @State searchKeyword: string = ''
  @State menuItem: NavigationMenuItem[] = [
    {
      value: '12',
      icon: $r('app.media.ic_public_help'),
      action: () => {
        DialogUtil.showConfirmDialog({
          title: '歌单操作',
          message: '增删歌曲：左滑歌曲卡片\n\n' +
            '收藏歌单：点击信息栏右边爱心图标'
        })
      }
    }
  ]

  async aboutToAppear(): Promise<void> {
    this.isSubscribed = this.param.playList.subscribed
    if (!this.hasLoaded) {
      await this.loadSongs(100, 0)
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
      LogUtil.info(TAG + 'loadSongs: ' + `limit: ${limit}, offset: ${offset}`)
      const result = await getPlayListSongs(this.param.playList.id, this.param.playList.trackCount, offset)
      this.list = [...this.list, ...result] // 合并歌曲列表
      this.currentOffset += limit

      if (this.list.length >= this.param.playList.trackCount) {
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
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          List() {
            ListItem() {
             this.PlayListInfo()
            }
            .padding({ bottom: 15 })
            ListItem() {
              Row() {
                Button() {
                  Row({ space: 5 }) {
                    if (this.isPlayerLoading) {
                      LoadingProgress().height(35).padding({ left: 30 })
                    } else {
                      Image($r('app.media.ic_play_fill')).width(Constants.FONT_SIZE_COMMON).fillColor(Color.Gray)
                      Text(`播放全部 (${this.param.playList.trackCount})`).fontSize(Constants.FONT_SIZE_COMMON)
                    }
                  }
                  .height(Constants.HEIGHT_TEXT_BUTTON)
                }
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .borderRadius(15)
                .onClick(async () => {
                  if (this.isPlayerLoading) {
                    ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
                  } else {
                    playListToQueue(this.param.playList.id, this.param.playList.trackCount, 0)
                  }
                })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
            }
            .padding({ left: 20, bottom: 10, right: 20 })

            ListItem() {
              Column() {
                Search({
                  placeholder: '搜索歌单',
                  icon: '/resources/base/media/ic_public_search_filled.svg'
                })
                  .height(Constants.HEIGHT_SELECT)
                  .width('100%')
                  .searchButton('搜索')
                  .margin({ left: Constants.PADDING_EDGE_DEFAULT })
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
              .padding({ left: 20, right: 20, bottom: 10 })
              .justifyContent(FlexAlign.Center)
            }

            if (this.isLoading) {
              ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
                ListItem() {
                  PlayListCard_Skeleton()
                }
              })
            } else {
              ForEach(this.searchKeyword ? this.filteredList : this.list, (item: Song, index) => {
                ListItem() {
                  SongCard({ song: item, sid: index,
                    isPlayList: true, playList: this.param.playList, index: index })
                }
                .swipeAction({ end: this.SwipeItem(item, index), edgeEffect: SwipeEdgeEffect.None })
                .translate({ y: -40 })
                .animation({
                  duration: 600,
                  curve: Curve.LinearOutSlowIn
                })
                .translate({ y: 0 })
              })

              // 添加加载更多
              if (this.isLoadingMore) {
                ListItem() {
                  LoadingMoreButton()
                }
              } else if (this.hasMore) {
                ListItem() {
                  ClickToLoadButton()
                    .onClick(async () => {
                      await this.loadSongs(100, this.currentOffset)
                      if(this.searchKeyword) {
                        this.handelSearch()
                      }
                    })
                }
              } else if (!this.hasMore) {
                ListItem() {
                  NoMoreButton()
                }
              }
            }

            ListItem().height(px2vp(this.bottomRectHeight) + 80)
          }
          .cachedCount(5)
          .height('100%')
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        }
        .height('100%')

        if(this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_PHONE) {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
      .opacity(this.pageOpacity)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .title(this.param.playList.name)
    .menus(this.menuItem)
    .backgroundColor($r('app.color.background'))
  }

  @Builder PlayListInfo() {
    Column() {
      Row({ space: 15 }) {
        Column() {
          Stack() {
            Image('')
              .width('100%')
              .borderRadius(10)
            LoadingProgress().width(40)
            Image(`${this.param.playList.coverImgUrl}?param=256y256`)
              .width('100%')
              .borderRadius(10)
          }
          .height('100%')
          .width('100%')
        }
        .height(80)
        .width(80)

        Column() {
          Text(this.param.playList.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ bottom: 5 })
          Text(`由 ${this.param.playList.creator.nickname} 创建`)
            .fontSize(12)
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(`${this.param.playList.trackCount}首歌曲     ${formatNumber(this.param.playList.playCount)}次播放`)
            .fontSize(12)
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .height(80)
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceEvenly)

        if(this.param.isShowHeart) {
          if (this.isSubscribed) {
            Image($r('app.media.ic_heart_filled')).fillColor(Color.Pink).width(25)
              .onClick(async () => {
                this.UnSubScribe()
              })
          } else {
            Image($r('app.media.ic_heart_filled')).fillColor($r('app.color.main')).width(25)
              .onClick(async () => {
                let res:boolean = await subscribePlayList(this.param.playList.id, 1)
                if(res) {
                  ToastUtil.showToast('成功收藏歌单')
                  this.isSubscribed = true
                }
              })
          }
        }
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder SwipeItem(song: Song, index: number) {
    Row() {
      AddToPlayListButton({ song: song })
      // Delete button
      if (!this.param.isShowHeart) {
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
            secondaryButton: {
              value: '删除',
              fontColor: Color.Red,
              action: async () => {
                try {
                  await PlayListOperation('del', this.param.playList.id, song.id)
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

  private UnSubScribe() {
    DialogUtil.showPrimaryDialog({
      title: '取消收藏歌单',
      message: `《${this.param.playList.name}》`,
      primaryButton: "取消",
      secondaryButton: {
        value: '确认',
        fontColor: Color.Red,
        action: async () => {
          let res: boolean = await subscribePlayList(this.param.playList.id, 2)
          LogUtil.info(TAG + 'res: ' + res)
          if(res) {
            ToastUtil.showToast('取消收藏歌单')
            this.isSubscribed = false
          }
        }
      }
    })
  }

  private handelSearch() {
    try {
      if (this.searchKeyword.trim() === '') {
        this.filteredList = [...this.list]
        return
      }
      const keyword = this.searchKeyword.trim().toLowerCase()
      this.filteredList = this.list.filter(song =>
      song.name.toLowerCase().includes(keyword) ||
      song.artists?.some(artist =>
      artist.name.toLowerCase().includes(keyword)
      ))
    } catch (e) {
      ToastUtil.showToast('搜索时出错')
      LogUtil.error(TAG + 'Error while handelSearch: ' + e.message)
    }
  }
}