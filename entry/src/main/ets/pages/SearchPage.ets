import { Song } from '../common/entities/SongsResult';
import { SongCard } from '../components/main/SongCard';
import { LogUtil, ToastUtil } from '@pura/harmony-utils';
import { SpinKit, SpinType } from '@pura/spinkit';
import { getSongsList } from '../api/songApi';
import { BottomPlayController } from '../components/play/BottomPlayController';
import { AddToPlayListButton } from '../components/buttons/AddToPlayListButton';
import { CommonCircleButton } from '../components/buttons/CircleButton';
import { router } from '@kit.ArkUI';
import { searchPlayLists } from '../api/playListApi';
import { PlayList } from '../common/entities/PlayList';
import { PlayListCard } from '../components/main/PlayListCard';

/**
 * 歌曲列表页（搜索结果）
 */
const TAG = "[SearchPage] "
@Entry
@Component
struct SearchPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  @State songList: Array<Song> = []
  @State playLists: Array<PlayList> = []
  @State songOffset: number = 0
  @State playListOffset: number = 0
  @State pageOpacity: number = 1
  
  @State hasMoreSongs: boolean = true
  @State hasSongLoaded: boolean = false
  @State hasMorePlayLists: boolean = true
  @State hasPlayListLoaded: boolean = false
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false

  @State searchKeyword: string = ''
  hasAnimation: boolean | undefined = false

  pageTransition() {
    PageTransitionEnter({ duration: 0, curve: Curve.Ease })
      .onEnter((progress: number) => {
        this.pageOpacity = progress
      })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if(this.searchKeyword != '') {
            Tabs() {
              TabContent() {
                this.Songs()
              }
              .tabBar('单曲')

              TabContent() {
                this.PlayLists()
              }
              .tabBar('歌单')
            }
            .scrollable(false)
            .barMode(BarMode.Fixed)
            .barWidth('80%')
            .barHeight(40)
            .padding({ top: px2vp(this.topRectHeight) + 60 })
          }

          this.Head()
        }
        .height('100%')

      BottomPlayController()
        .padding({ left: 10, right: 10, bottom: px2vp(this.bottomRectHeight)})
        .backgroundColor(Color.Transparent)
    }
    .opacity(this.pageOpacity)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  Songs() {
    if(this.isLoading == true) {
      Column() {
        SpinKit({ spinType: SpinType.spinO, spinSize:60, spinColor:Color.Gray }).width(60)
      }
      .padding({ bottom: px2vp(this.topRectHeight) })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.songList, (item: Song, index) => {
          ListItem() {
            SongCard({ song: item, sid: index, hasAnimation: this.hasAnimation })
          }
          .swipeAction({ end: this.SwipeItem(item)})
        })
        // 添加加载更多
        if (this.isLoadingMore) {
          ListItem() {
            Column() {
              SpinKit({ spinType: SpinType.spinO, spinSize: 30, spinColor: Color.Gray }).width(30)
            }.justifyContent(FlexAlign.Center).width('100%').height(50)
          }
        } else if (this.hasMoreSongs && this.searchKeyword) {
          ListItem() {
            Text("点击加载更多")
              .onClick(() => {
                this.loadSongs(this.songOffset)
              })
              .padding({ top: 10, bottom: px2vp(this.bottomRectHeight) })
              .fontColor($r('app.color.reverse'))
              .width('100%')
              .textAlign(TextAlign.Center)
          }
        } else if (!this.hasMoreSongs) {
          ListItem() {
            Text('没有更多了~').fontSize(16).textAlign(TextAlign.Center).width('100%').height(50);
          }
        }
        ListItem().height(px2vp(this.bottomRectHeight) + 80)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto)
      .height('100%')
    }
  }

  async loadSongs(offset: number): Promise<void> {
    if (!this.hasMoreSongs) return // 没有更多歌曲直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    } else {
      this.isLoadingMore = true // 加载更多
    }
    try {
      const result = await getSongsList(this.searchKeyword, offset)
      this.songList = [...this.songList, ...result.list] // 合并歌曲列表
      this.songOffset += 30
      this.hasMoreSongs = result.hasMore
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', JSON.stringify(e))
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasSongLoaded = true
    }
  }

  async loadPlayLists(offset: number): Promise<void> {
    if(!this.hasMorePlayLists) return
    if(offset == 0) { this.isLoading = true }
    else { this.isLoadingMore = true }
    try {
      const result = await searchPlayLists(this.searchKeyword, offset)
      this.playLists = [...this.playLists, ...result.playlist]
      this.playListOffset += 10
      this.hasMorePlayLists = result.more
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching playLists: ', JSON.stringify(e));
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasPlayListLoaded = true
    }
  }

  @Builder
  PlayLists() {
    if(this.isLoading == true) {
      Column() {
        SpinKit({ spinType: SpinType.spinO, spinSize:60, spinColor:Color.Gray }).width(60)
      }
      .padding({ bottom: px2vp(this.topRectHeight) })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.playLists, (item: PlayList, index) => {
          ListItem() {
            PlayListCard({ playList: item })
          }
        })
        if (this.isLoadingMore) {
          ListItem() {
            Column() {
              SpinKit({ spinType: SpinType.spinO, spinSize: 30, spinColor: Color.Gray }).width(30)
            }.justifyContent(FlexAlign.Center).width('100%').height(50)
          }
        } else if (this.hasMorePlayLists && this.searchKeyword) {
          ListItem() {
            Text("点击加载更多")
              .onClick(() => {
                this.loadPlayLists(this.playListOffset)
              })
              .padding({ top: 10, bottom: px2vp(this.bottomRectHeight) })
              .fontColor($r('app.color.reverse'))
              .width('100%')
              .textAlign(TextAlign.Center)
          }
        } else if (!this.hasMorePlayLists) {
          ListItem() {
            Text('没有更多了~').fontSize(16).textAlign(TextAlign.Center).width('100%').height(50);
          }
        }
        ListItem().height(px2vp(this.bottomRectHeight) + 80)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto)
      .height('100%')
    }
  }

  @Builder
  Head() {
    Row({ space: 20 }) {
      CommonCircleButton({ ButtonImageName:'ic_public_back' })
        .onClick(() => {
          router.back()
        })
      Search({
        placeholder: '搜索内容',
        icon: '/resources/base/media/ic_public_search_filled.svg',
      })
        .sharedTransition('search_component', {
            duration: 300,
            curve: Curve.EaseOut
          })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onSubmit(async (value) => {
          this.searchKeyword = value
          if(value) {
            this.songList = []
            this.songOffset = 0
            this.hasAnimation = AppStorage.get('set-hasAnimation')
            await this.loadSongs(0)
            await this.loadPlayLists(0)
            if(this.hasPlayListLoaded) {
              this.playLists = []
              this.playListOffset = 0
              await this.loadPlayLists(0)
            }
          } else {
            ToastUtil.showToast('请输入搜索内容')
          }
        })
    }
    .opacity(0.95)
    .backdropBlur(50)
    .padding({ left: 10, right: 20, top: px2vp(this.topRectHeight) })
    .width('100%')
    .backgroundColor(Color.Transparent)
  }

  @Builder SwipeItem(song: Song) {
    Row({ space: 10 }) {
      AddToPlayListButton({ song: song })
    }
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}