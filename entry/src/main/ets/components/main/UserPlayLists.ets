import { getPlayLists } from "../../api/playListApi"
import { PlayList } from "../../common/entities/PlayList"
import { PlayListCard, PlayListCard_Skeleton } from "../cards/PlayListCard"
import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import { User, UserClass } from "../../common/entities/User";
import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { ObservableScroller } from "../../common/utils/ObservableScroller";
import { MultiFunctionalButton, MultiFunctionalButton2 } from "../buttons/MultiFunctionalButton";
import { ObservableTabsController } from "../../common/utils/ObservableTabsController";
import { promptAction } from "@kit.ArkUI";

/**
 * 用户歌单
 */
@Component
export struct UserPlayLists {

  @State observableScrollers: ObservableScroller[] = [new ObservableScroller(), new ObservableScroller(), new ObservableScroller()]
  @Link subTitleOpacity: number[]
  @Link index: number
  @Link subIndex: number

  @Link observableTabsController: ObservableTabsController
  private _subArrStr: string[] = ['所有', '自建', '收藏'];

  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getPlayLists') isLogged: boolean = false
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  private refreshCooldown: number = 5000
  private tabItems: string[] = ['所有', '创建', '收藏']

  async aboutToAppear(): Promise<void> {
    try {
      setTimeout(async () => {
        await this.getPlayLists()
      }, 100)
    } catch (e) {
      ToastUtil.showToast('获取歌单列表失败')
      LogUtil.error('Error fetching playlists: ', e.message)
    } finally {
      this.isLoading = false
    }
  }

  async getPlayLists() {
    if(this.isLogged && this.user && this.playLists.length == 0) {
      this.isLoading = true
      const playlist = await getPlayLists(0)
      this.playLists = playlist.playlist
      this.isLoading = false
    }
    else return
  }

  build() {

    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.isLogged) {
          Stack({ alignContent: Alignment.Bottom }){
            Refresh({ refreshing: this.isRefreshing}) {
              Tabs({ controller: this.observableTabsController.getTabsController() }) {
                TabContent() {
                  List({ scroller: this.observableScrollers[0].getScroller() }) {
                    ListItem(){}.height('7%').backgroundColor('transparent')
                    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
                    ForEach(this.playLists, (item: PlayList, index) => {
                      ListItem() {
                        PlayListCard({
                          playList: item,
                          isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
                        })
                          .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
                      }
                    })
                    ListItem().height(px2vp(this.bottomRectHeight) + 160)
                  }
                  .height('100%')
                  // .onWillScroll(() => this.handleScroll())
                  .edgeEffect(EdgeEffect.Spring)
                  .scrollBar(BarState.Off)
                  .contentListStyle(this.breakpoint)
                }
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
                TabContent() {
                  List({ scroller: this.observableScrollers[1].getScroller() }) {
                    ListItem(){}.height('7%').backgroundColor('transparent')
                    ForEach(this.playLists.filter((item) => item.userId === this.user.data.account.id),
                      (item: PlayList, index) => {
                        ListItem() {
                          PlayListCard({
                            playList: item,
                            isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
                          })
                            .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
                        }
                      })
                    ListItem().height(px2vp(this.bottomRectHeight) + 160)
                  }
                  .height('100%')
                  // .onWillScroll(() => this.handleScroll())
                  .edgeEffect(EdgeEffect.Spring)
                  .scrollBar(BarState.Off)
                  .contentListStyle(this.breakpoint)
                }
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
                TabContent() {
                  List({ scroller: this.observableScrollers[2].getScroller() }) {
                    ListItem(){}.height('7%').backgroundColor('transparent')
                    ForEach(this.playLists.filter((item) => item.userId !== this.user.data.account.id),
                      (item: PlayList, index) => {
                        ListItem() {
                          PlayListCard({
                            playList: item,
                            isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
                          })
                            .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
                        }
                      })
                    ListItem().height(px2vp(this.bottomRectHeight) + 160)
                  }
                  .height('100%')
                  // .onWillScroll(() => this.handleScroll())
                  .edgeEffect(EdgeEffect.Spring)
                  .scrollBar(BarState.Off)
                  .contentListStyle(this.breakpoint)
                }
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
              }
              .height('100%')
              .barHeight(0)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
              .onAnimationStart((from, target) => {
                this.subIndex = target
                this.showToast(`歌单-${this._subArrStr[this.subIndex]}`)
              })
            }
            .height('100%')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
            .onRefreshing(async () => {
              await this.refreshContent()
            })
          }
        }
      }

      MultiFunctionalButton2({ index: this.index, observableScrollers: this.observableScrollers, subIndex: this.subIndex })
    }
    .height('100%')
  }

  getLeftMargin(): Length | undefined {
    let result: number = 0
    const percent: number = 100/3
    if(this.subIndex == 1){
      result = 0
    }
    if(this.subIndex == 0){
      result = -percent * 2.34
    }
    if(this.subIndex == 2){
      result = percent * 2.34
    }
    return result
  }

  handleScroll(): void {
    const currentOffset: number = this.observableScrollers[this.subIndex].getScroller().currentOffset().yOffset
    this.subTitleOpacity[this.subIndex] = Math.max(0, Math.min(1, 1 - currentOffset / 100))
  }

  @Builder TabBar() {
    Row() {
      this.TabBarButtonItem('所有歌单', 0)
      this.TabBarButtonItem('我创建的', 1)
      this.TabBarButtonItem('我收藏的', 2)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
    .padding({ bottom: 5 })
  }

  @Builder TabBarButtonItem(title: string, index: number) {
    Button() {
      Text(title)
        .fontColor(this.subIndex === index ? $r('app.color.app_red') : Color.Gray)
        .fontWeight(FontWeight.Medium)
    }
    .layoutWeight(1)
    .backgroundColor(Color.Transparent)
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
    .onClick(() => {
      this.observableTabsController.changeIndex(index)
    })
  }

  showToast(msg: string) {
    promptAction.showToast({ message: msg, backgroundColor: Color.Transparent, backgroundBlurStyle: BlurStyle.BACKGROUND_THIN })
  }

  @Builder PlayListsContent(list: PlayList[]) {
    List() {
      ForEach(list, (item: PlayList, index) => {
        ListItem() {
          PlayListCard({
            playList: item,
            isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
          })
            .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
        }
      })
      ListItem().height(px2vp(this.bottomRectHeight) + 160)
    }
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Off)
    .lanes(this.breakpoint == 'md' ? 2 : 1)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  Loading() {
    ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
      PlayListCard_Skeleton()
    })
  }

  private async refreshContent() {
    if (this.isLogged) {
      this.isRefreshing = true
      const currentTime = new Date().getTime()
      if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
        ToastUtil.showToast('操作过于频繁，请5秒后再试')
      } else {
        try {
          const result = await getPlayLists(0)
          this.playLists = result.playlist
          this.lastRefreshTime = currentTime
          ToastUtil.showToast('刷新成功')
        } catch (e) {
        }
      }
      this.isRefreshing = false
    }
    else return
  }
}

@Extend(List) function contentListStyle(breakpoint: string) {
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Off)
    .lanes(breakpoint == 'md' ? 2 : 1)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
}
