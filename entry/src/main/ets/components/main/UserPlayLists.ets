import { getPlayLists } from "../../api/playListApi"
import { PlayList } from "../../common/entities/PlayList"
import { PlayListCard, PlayListCard_Skeleton } from "../cards/PlayListCard"
import { DialogUtil, LogUtil, ToastUtil } from "@pura/harmony-utils";
import { Announcement } from "../../common/entities/Announcement";
import { User, UserClass } from "../../common/entities/User";
import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";

/**
 * 用户歌单
 */
@Component
export struct UserPlayLists {
  tabsController: TabsController = new TabsController()
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getPlayLists') isLogged: boolean = false
  @StorageProp('Announcement') announcement: Announcement = {
    code: -1,
    data: { title:'', content: '' },
    visible: false
  }
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @State tabsIndex: number = 0
  private refreshCooldown: number = 5000

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
    Column() {
      if(this.isLogged) {
        this.TabBar()
        Refresh({ refreshing: this.isRefreshing}) {
          Tabs({ controller: this.tabsController }) {
            TabContent() {
              List() {
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
              .contentListStyle(this.breakpoint)
            }
            TabContent() {
              List() {
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
              .contentListStyle(this.breakpoint)
            }
            TabContent() {
              List() {
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
              .contentListStyle(this.breakpoint)
            }
          }
          .barHeight(0)
          .onAnimationStart((from, target) => {
            this.tabsIndex = target
          })
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRefreshing(async () => {
          await this.refreshContent()
        })
      }
    }
    .width('100%')
    .height('100%')
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
        .fontColor(this.tabsIndex === index ? $r('app.color.app_red') : Color.Gray)
        .fontWeight(FontWeight.Medium)
    }
    .layoutWeight(1)
    .backgroundColor(Color.Transparent)
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
    .onClick(() => { this.tabsController.changeIndex(index) })
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