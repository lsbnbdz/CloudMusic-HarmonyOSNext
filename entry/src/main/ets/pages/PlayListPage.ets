import { SongCard } from '../components/cards/SongCard'
import { PlayList, playListClass } from '../common/entities/playlist/PlayList'
import { DialogUtil, LogUtil, PasteboardUtil, ToastUtil } from '@pura/harmony-utils'
import { deletePlayList, getPlayListSongs, PlayListOperation, subscribePlayList } from '../api/playListApi'
import { BottomBarComponent } from '../components/play/BottomBarComponent'
import { formatNumber } from '../common/functions/common/convert'
import { cleanLastPlayInfo, playListToQueue } from '../common/functions/play/playListOp'
import { AddToPlayListButton } from '../components/buttons/play/AddToPlayListButton'
import Constants from '../common/constants/Constants'
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from '../components/buttons/LoadMoreButtons'
import { PlayListPageParam } from '../common/entities/local/PageParams'
import { PlayListCard_Skeleton } from '../components/cards/PlayListCard'
import { StorageConstants } from '../common/constants/StorageConstants'
import { PlayListSongItem } from '../common/entities/playlist/PlayListSongs'
import { User, UserClass } from '../common/entities/user/User'
import { promptAction } from '@kit.ArkUI'
import { LazyData } from '@pie/lazy-data'

/**
 * 歌单二级页面
 */

const TAG = '[PlayListPage] '

@Component
export struct PlayListPage {
  @State param: PlayListPageParam = {
    playList: playListClass,
    isShowHeart: false,
    useTimestamp: true
  }
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.USER_PLAYLISTS) userPlayLists: PlayList[] = []
  @StorageProp(StorageConstants.IS_LOGGED) isLogged: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack
  @State isSubscribed: boolean = false
  @State list: PlayListSongItem[] = new Array()
  @State filteredList: PlayListSongItem[] = new Array()
  @State listDataSource: LazyData<PlayListSongItem> = new LazyData()
  @State filteredDataSource: LazyData<PlayListSongItem> = new LazyData()
  @State hasMore: boolean = true
  @State hasLoaded: boolean = false // 判定是否已加载 避免重复加载
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false
  @State isSelecting: boolean = false
  @State translateY: number = 40
  @State selectedSongs: PlayListSongItem[] = []
  @State searchKeyword: string = ''
  @State trackCount: number = -1
  @State showTitleBar: boolean = false
  @State menuItem: NavigationMenuItem[] = [
    {
      value: 'help',
      icon: $r('app.media.ic_public_help'),
      action: this.helpButtonAction
    },
    // {
    //   value: 'select',
    //   icon: $r('app.media.ic_public_select_all'),
    //   action: () => {
    //     this.selectButtonAction()
    //   }
    // }
  ]
  private currentOffset: number = 0 // 歌曲偏移量
  private useTimestamp: boolean = true

  async aboutToAppear(): Promise<void> {
    this.isSubscribed = this.param.playList.subscribed
    this.trackCount = this.param.playList.trackCount
    if (!this.hasLoaded) {
      await this.loadSongs(100, 0)
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
            .padding({ bottom: Constants.PADDING_EDGE_DEFAULT })
            ListItem() {
              Row() {
                Button() {
                  Row({ space: 5 }) {
                    if (this.isPlayerLoading) {
                      LoadingProgress().height(35).padding({ left: 30 })
                    } else {
                      Image($r('app.media.ic_play_fill')).width(Constants.FONT_SIZE_COMMON).fillColor(Color.Gray)
                      Text(`播放全部 (${this.trackCount})`).fontSize(Constants.FONT_SIZE_COMMON)
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
            .padding({ left: 20, right: 20 })
            if (this.isLoading) {
              ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
                ListItem() {
                  PlayListCard_Skeleton()
                }
              })
            } else {
              ListItemGroup({ header: this.ToolBar() }) {
                if(this.searchKeyword) {
                  this.ContentList(this.filteredDataSource)
                } else {
                  this.ContentList(this.listDataSource)
                }
              }
              .translate({ y: this.translateY })
              .animation({
                duration: 600,
                curve: Curve.LinearOutSlowIn
              })
              .onAppear(() => { this.translateY = 0 })

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

            ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
          }
          .edgeEffect(EdgeEffect.None)
          .cachedCount(3)
          .height('100%')
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .sticky(StickyStyle.Header | StickyStyle.Footer)
          .backToTop(true)
        }
        .height('100%')

        if(this.breakpoint !== 'lg') {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .title(this.param.playList.name)
    .menus(this.menuItem)
    .backgroundColor($r('app.color.background'))
  }

  @Builder ContentList(dataSource: LazyData<PlayListSongItem>) {
    LazyForEach(dataSource, (item: PlayListSongItem, index) => {
        ListItem() {
          Row() {
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
              isPlayList: true,
              playList: this.param.playList,
              picUrl: item.al?.picUrl ?? $r('app.media.ic_public_music'),
              index: this.list.indexOf(item)
            })
              .layoutWeight(1)
            if(this.isSelecting) {
              this.CardCheckBox(item)
            }
          }
        }
        .key(this.searchKeyword)
        .swipeAction({ end: this.SwipeItem(item, index), edgeEffect: SwipeEdgeEffect.None })
      }
      ,(item: PlayListSongItem, index) => item.name + index)
  }

  @Builder ToolBar() {
    Row({ space: 5 }) {
      Search({
        placeholder: '搜索歌名或歌手',
        icon: '/resources/base/media/ic_public_search_filled.svg'
      })
        .backgroundBlurStyle(BlurStyle.Thin)
        .height(Constants.HEIGHT_SEARCH)
        .layoutWeight(1)
        .searchButton('搜索')
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

      if(this.isSelecting) {
        Row({ space: 5 }) {
          Image($r('app.media.ic_public_folder'))
            .width(Constants.SIZE_ICON_BUTTON_BAR)
            .aspectRatio(1)
            .fillColor(Color.Gray)
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })

          CheckboxGroup({ group: 'playListSongs' })
            .width(Constants.SIZE_ICON_BUTTON_BAR_SMALL)
            .aspectRatio(1)
        }
        .backgroundColor(Color.Transparent)
        .backgroundBlurStyle(BlurStyle.Thin)
        .height(Constants.HEIGHT_SEARCH)
        .borderRadius(Constants.RADIUS_CARD)
        .padding(5)
      }
    }
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder PlayListInfo() {
    Column({ space: 20 }) {
      Row() {
        // CoverImage
        Stack() {
          Image('')
            .width('100%')
            .borderRadius(10)
          LoadingProgress().width(40)
          Image(`${this.param.playList.coverImgUrl}?param=256y256`)
            .width('100%')
            .borderRadius(10)
        }
        .height(100)
        .aspectRatio(1)

        // TextInfo
        Column({ space: 5 }) {
          Text(this.param.playList.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Row({ space: 5 }) {
            Image(this.param.playList.creator?.avatarUrl ? this.param.playList.creator.avatarUrl + '?param=100y100' : $r('app.media.ic_user_portrait'))
              .width(14)
              .aspectRatio(1)
              .borderRadius(50)
            Text(`${this.param.playList.creator.nickname}   |   ${formatNumber(this.param.playList.playCount)} 次播放`)
              .fontSize(12)
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .width('100%')

          Text(this.param.playList?.description ? this.param.playList.description : '暂无介绍')
            .fontSize(12)
            .width('100%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
            .onClick(() => {
              DialogUtil.showConfirmDialog({
                title: '歌单介绍',
                message: this.param.playList?.description ? this.param.playList.description : '暂无介绍'
              })
            })
        }
        .height(100)
        .layoutWeight(1)
        .padding({ left: Constants.PADDING_EDGE_DEFAULT })
        .justifyContent(FlexAlign.SpaceAround)
      }
      .width('100%')
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      .justifyContent(FlexAlign.SpaceAround)

      Row({ space: 15 }) {
        // 分享歌单
        this.ToolButton($r('app.media.ic_public_share_filled'), '分享歌单', () => {
          PasteboardUtil.setDataText(`[${this.param.playList.name}] https://music.163.com/playlist?id=${this.param.playList.id}`)
          ToastUtil.showToast('已复制链接至剪贴板')
        })
        // 喜欢歌单
        if(this.param.isShowHeart) {
          if(this.isSubscribed) {
            this.ToolButton($r('app.media.ic_public_favor_filled'), '取消喜欢',
              () => {
                this.UnSubScribe()
              })
          } else {
            this.ToolButton($r('app.media.ic_public_favor'), '喜欢歌单',
              async () => {
                let res:boolean = await subscribePlayList(this.param.playList.id, 1)
                if(res) {
                  ToastUtil.showToast('成功收藏歌单')
                  this.isSubscribed = true
                }
              })
          }
        }
        // 删除歌单
        if(this.isLogged && this.user.data.account?.id == this.param.playList.userId &&
          this.param.playList.id != this.userPlayLists[0]?.id) {
          this.ToolButton($r('app.media.ic_public_delete_filled'), '删除歌单', () => {
            this.deleteButtonAction()
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .backgroundImage(`${this.param.playList.coverImgUrl}?param=256y256`)
    .backgroundBlurStyle(BlurStyle.Regular)
    .backgroundImageSize({ width: '100%', height: '100%' })
    .padding({ top: Constants.PADDING_EDGE_TEXT, bottom: 20 })
    .width('100%')
  }

  @Builder SwipeItem(listSong: PlayListSongItem, index: number) {
    Row() {
      AddToPlayListButton({ songId: listSong.id })
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
            message: `${listSong.name}`,
            primaryButton: "取消",
            secondaryButton: {
              value: '删除',
              fontColor: Color.Red,
              action: async () => {
                try {
                  await PlayListOperation('del', this.param.playList.id, listSong.id)
                  this.list.splice(index, 1)
                  this.trackCount -= 1
                  this.listDataSource.notifyDataReload()
                  cleanLastPlayInfo()
                  ToastUtil.showToast('删除成功')
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

  @Builder CardCheckBox(item: PlayListSongItem) {
    Checkbox({ group: 'playListSongs' })
      .padding({ right: 5 })
      .shape(CheckBoxShape.ROUNDED_SQUARE)
      .width(Constants.SIZE_ICON_BUTTON_BAR)
      .aspectRatio(1)
      .onChange((value) => {
        if(value) {
          this.selectedSongs.push(item)
        } else {
          this.selectedSongs = this.selectedSongs.filter(item => item.id != item.id)
        }
      })
  }

  @Builder ToolButton(icon: ResourceStr, text: string, action: () => void) {
    Button() {
      Row({ space: 5 }) {
        Image(icon)
          .fillColor(Color.White)
          .width(Constants.FONT_SIZE_COMMON)
          .aspectRatio(1)
        Text(text)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontColor(Color.White)
      }
      .padding(Constants.PADDING_EDGE_DEFAULT)
    }
    .backgroundColor(Color.Transparent)
    .backgroundBrightness({ rate: 0.1, lightUpDegree: -0.1 })
    .backdropBlur(BlurStyle.Regular)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(action)
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return // 没有更多歌曲直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    } else {
      this.isLoadingMore = true // 加载更多
    }
    try {
      const result = await getPlayListSongs(this.param.playList.id, this.param.playList.trackCount, offset, this.useTimestamp)
      this.list = [...this.list, ...result] // 合并歌曲列表
      this.listDataSource.setData(this.list)
      this.listDataSource.notifyDataReload()
      this.currentOffset += limit
      if (this.list.length >= this.param.playList.trackCount) {
        this.hasMore = false
      }
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', e.message)
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasLoaded = true
    }
  }

  private helpButtonAction() {
    DialogUtil.showConfirmDialog({
      title: '歌单操作',
      message: '增删歌曲：左滑歌曲卡片\n\n' +
        '收藏歌单：点击信息栏右边爱心图标\n\n' +
        '歌单内搜索：本地搜索，仅支持搜索已加载的部分歌曲'
    })
  }

  private selectButtonAction() {
    animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
      this.isSelecting = !this.isSelecting
    })
    this.selectedSongs = []
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
      if (!this.searchKeyword) {
        this.filteredList = []
        this.filteredDataSource.setData([])
      }
      const keyword = this.searchKeyword.toLowerCase()
      this.filteredDataSource.setData(this.list.filter((item: PlayListSongItem) => {
        const idMatch = item.name.toString().toLowerCase().includes(keyword)
        const artistMatch = item.ar.some(artist =>
        artist.name.toLowerCase().includes(keyword))
        return idMatch || artistMatch
      }))
    } catch (e) {
      ToastUtil.showToast('搜索时出错: ' + (e as Error).message)
      LogUtil.error(TAG + 'Error while handelSearch: ' + (e as Error).message)
    }
  }

  private deleteButtonAction() {
    DialogUtil.showPrimaryDialog({
      title: '确认删除歌单',
      message:`《${this.param.playList.name}》`,
      primaryButton: "取消",
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          await this.handleDelete()
        }
      }
    })
  }

  private async handleDelete() {
    const result = await deletePlayList(this.param.playList.id)
    if(result) {
      promptAction.showToast({ message: '成功删除歌单', duration: 4000 })
      this.pageInfos.pop()
    } else {
      promptAction.showToast({ message: '删除歌单失败', duration: 4000 })
    }
  }
}