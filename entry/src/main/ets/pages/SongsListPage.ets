import { router } from '@kit.ArkUI';
import { Song } from '../common/entities/SongsResult';
import { SongCard } from '../components/main/SongCard';
import { LogUtil, ToastUtil } from '@pura/harmony-utils';
import { SpinKit, SpinType } from '@pura/spinkit';
import { getSongsList } from '../api/songApi';
import { BottomPlayController } from '../components/play/BottomPlayController';
import { BackButton } from '../components/buttons/BackButton';

/**
 * 歌曲列表页（搜索结果）
 */
const TAG = "[SongListPage] "
@Entry
@Component
struct SongsListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  @State list: Array<Song> = []
  @State resOffset: number = 0
  @State hasMore: boolean = true
  @State hasLoaded: boolean = false // 判定是否已加载 避免重复加载
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State pageOpacity: number = 1

  @State searchKeyword: string = ''
  hasAnimation: boolean | undefined = false

  pageTransition() {
    PageTransitionEnter({ duration: 600, curve: Curve.Linear })
      .onEnter((progress: number) => {
        this.pageOpacity = progress
      })
  }

  async onPageShow(): Promise<void> {
  }

  async loadSongs(offset:number): Promise<void> {
    if (!this.hasMore) return // 没有更多歌曲直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    } else {
      this.isLoadingMore = true // 加载更多
    }
    try {
      const result = await getSongsList(this.searchKeyword, offset)
      this.list = [...this.list, ...result.list] // 合并歌曲列表
      this.resOffset += 30
      this.hasMore = result.hasMore
      this.isLoading = false;
      this.hasLoaded = true;
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', JSON.stringify(e));
    } finally {
        this.isLoading = false
        this.isLoadingMore = false
        this.hasLoaded = true
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
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
              ListItem().height(px2vp(this.topRectHeight) + 60)
              ForEach(this.list, (item: Song, index) => {
                ListItem() {
                  SongCard({ song: item, sid: index, hasAnimation: this.hasAnimation })
                }
              })
              // 添加加载更多
              if (this.isLoadingMore) {
                ListItem() {
                  Column() {
                    SpinKit({ spinType: SpinType.spinO, spinSize: 30, spinColor: Color.Gray }).width(30)
                  }.justifyContent(FlexAlign.Center).width('100%').height(50)
                }
              } else if (this.hasMore && this.searchKeyword) {
                ListItem() {
                  Text("点击加载更多")
                    .onClick(() => {
                      this.loadSongs(this.resOffset)
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
            .layoutWeight(1)
            .width('100%')
            .scrollBar(BarState.Auto)
            .height('100%')
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
  Head() {
    Row({ space: 20 }) {
      BackButton()
      Search({
        placeholder: '搜索内容',
        icon: '/resources/base/media/ic_public_search_filled.svg',
      })
        .sharedTransition('search_component', {
            duration: 300,
            curve: Curve.Friction
          })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onSubmit(async (value) => {
          this.searchKeyword = value
          if(value) {
            this.list = []
            this.resOffset = 0
            this.hasAnimation = AppStorage.get('set-hasAnimation')
            await this.loadSongs(0);
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

}