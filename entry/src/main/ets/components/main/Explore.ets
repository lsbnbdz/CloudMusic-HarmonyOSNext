import { DialogUtil, LogUtil, ToastUtil} from "@pura/harmony-utils";
import { RecommendCards, RecommendCards_Skeleton } from "../cards/RecommendCards";
import { User, UserClass } from "../../common/entities/User";
import Constants from "../../common/constants/Constants";
import { TopListItem } from "../../common/entities/TopList";
import { getTopList } from "../../api/topListApi";
import { TopListItemCard } from "../cards/TopListItemCard";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { PlayList } from "../../common/entities/PlayList";
import { getPersonalizedList, getPlayLists } from "../../api/playListApi";
import { PersonalListItem } from "../../common/entities/Personalized";
import { PersonalizedCard } from "../cards/PersonalizedCard";
import { ObservableScroller } from "../../common/utils/ObservableScroller";
import { MultiFunctionalButton } from "../buttons/MultiFunctionalButton";
import { AppInfo, AppInfoClass } from "../../common/entities/AppInfo";

@Component
export struct Explore {

  @State observableScroller: ObservableScroller = new ObservableScroller()
  @Link titleOpacity: number[]
  @Link index: number

  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getPlayLists') isLogged: boolean = false
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = true
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.APP_INFO) appInfo: AppInfo = AppInfoClass
  @StorageLink(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @StorageLink(StorageConstants.TOPLISTS) topList: Array<TopListItem> = []
  @StorageLink(StorageConstants.PERSONALIZED_LIST) personalizedList: Array<PersonalListItem> = []
  @State isLoading: boolean = false
  @State isLoadingPersonalized: boolean = false
  @State columnsTemplate: string = '1fr'
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @Consume('pageInfos') pageInfos: NavPathStack
  private refreshCooldown: number = 5000

  async aboutToAppear(): Promise<void> {
    try {
      setTimeout(async () => {
        await Promise.all([
          this.getTopLists(),
          this.getPlayLists(),
          this.getPersonalizedList()
        ])
      }, 500)
    } catch (e) {
      LogUtil.error('Error: ' + e.message)
    }
  }

  private async getTopLists() {
    if(this.topList.length == 0 && this.validApiUrl) {
      this.isLoading = true
      await getTopList()
      this.isLoading = false
    }
    else return
  }

  async getPlayLists() {
    if(this.isLogged && this.playLists.length == 0 && this.validApiUrl) {
      this.isLoading = true
      await getPlayLists(0)
      this.isLoading = false
    }
    else return
  }

  async getPersonalizedList() {
    if(this.isLogged && this.personalizedList.length == 0 && this.validApiUrl) {
      this.isLoadingPersonalized = true
      await getPersonalizedList()
      this.isLoadingPersonalized = false
    }
    else return
  }

  private async refreshContent() {
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    } else {
      try {
        await getTopList()
        await getPersonalizedList()
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
        ToastUtil.showToast('内容刷新失败: ' + e.message)
      }
    }
    this.isRefreshing = false
  }

  build() {
    Stack({ alignContent: Alignment.Bottom}){
      Column() {
        Refresh({ refreshing: this.isRefreshing}) {
          Column({ space: 5 }) {
            if (this.appInfo.data.Announcement.isShow) {
              this.Announcement()
            }
// <<<<<<< HEAD
            Scroll(this.observableScroller.getScroller()){
              Grid() {
                GridItem().height('7%').backgroundColor('transparent')
                GridItem() {
                  Search({
                    placeholder: '搜索内容',
                    icon: '/resources/base/media/ic_public_search_filled.svg',
                  })
                    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
                    .focusable(false)
                    .onClick(() => {
                      this.pageInfos.clear()
                      this.pageInfos.pushPathByName('SearchPage', null, true)
                    })
                    .layoutWeight(1)
                }
                .padding({ left: 20, right: 20 })

                GridItem() {
                  if (this.isLoading) {
                    RecommendCards_Skeleton()
                  } else {
                    RecommendCards({ isLogged: this.isLogged })
                  }
                }

                if(this.validApiUrl) {
                  GridItem() {
                    Column({ space: 5 }) {
                      this.Intro('推荐歌单', () => {
                      })
                      // 推荐歌单
                      if (this.isLoadingPersonalized) {
                        GridItem() {
                          this.Loading(300)
                        }
                      } else {
                        List() {
                          ListItem().width(5)
                          ListItem().width(5)
                          ForEach(this.personalizedList, (item: PersonalListItem, index) => {
                            ListItem() {
                              PersonalizedCard({ item: item }).padding(5)
                            }
                          }, (item: PersonalListItem) => item.id.toString())
                          ListItem().width(5)
                          ListItem().width(5)
                        }
                        .lanes(2)
                        .listDirection(Axis.Horizontal)
                        .scrollBar(BarState.Off)
                        .width('100%')
                      }
                    }
                  }
                  .padding({ top: 20 })

                  GridItem() {
                    Column({ space: 15 }) {
                      this.Intro('排行榜', () => {
                        this.pageInfos.pushPathByName('TopListPage', null)
                      })
                      // 排行榜
                      if (this.isLoading) {
                        GridItem() {
                          this.Loading(300)
                        }
                      } else {
                        List() {
                          ListItem().width(15)
                          ForEach(this.topList.slice(0, 5), (item: TopListItem, index) => {
                            ListItem() {
                              TopListItemCard({ topListItem: item }).padding(5)
                            }
                          })
                          ListItem() {
                            Button() {
                              Column({ space: 5 }) {
                                Stack({ alignContent: Alignment.Center }) {
                                  Image($r('app.media.bg4'))
                                    .width(120)
                                    .aspectRatio(1)
                                    .borderRadius(Constants.RADIUS_CARD)
                                    .draggable(false)
                                  Text('更多排行')
                                    .fontSize(Constants.FONT_SIZE_COMMON + 3)
                                    .fontWeight(FontWeight.Bold)
                                    .fontColor(Color.White)
                                }
                                .width(120)
                                .aspectRatio(1)
                                .backgroundColor(Color.Transparent)
                              }
                            }
                            .backgroundColor(Color.Transparent)
                            .borderRadius(Constants.RADIUS_CARD)
                            .type(ButtonType.Normal)
                            .width(120)
                            .aspectRatio(1)
                            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
                            .onClick(() => {
                              this.pageInfos.pushPathByName('TopListPage', null)
                            })
                          }.padding(5)

                          ListItem().width(15)
                        }
                        .listDirection(Axis.Horizontal)
                        .scrollBar(BarState.Off)
                        .width('100%')
                      }
                    }
                  }
                }
                GridItem()
                  .height(px2vp(this.bottomRectHeight) + 115)
              }
              .height('auto')
              .width('100%')
              .edgeEffect(EdgeEffect.Spring)
              .scrollBar(BarState.Off)
              .rowsGap(15)
              .columnsTemplate(this.columnsTemplate)
              .layoutDirection(GridDirection.Column)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
              .backToTop(true)
            }
            .height('100%')
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
            // .onWillScroll(() => this.handleScroll())

          }
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRefreshing(async () => {
          await this.refreshContent()
        })
      }
      .width('100%')
      .height('100%')

      MultiFunctionalButton({ index: this.index, observableScroller: this.observableScroller })
    }

  }

  handleScroll(): void {
    const currentOffset: number = this.observableScroller.getScroller().currentOffset().yOffset
    this.titleOpacity[0] = Math.max(0, Math.min(1, 1 - currentOffset / 100))
  }

  @Builder
  Loading(ht: number | string = '100%') {
    Column() {
      LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
    }
    .height(ht)
    .padding({ bottom: px2vp(this.topRectHeight) + 60 })
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  Announcement() {
    Row() {
      Text(this.appInfo.data.Announcement.message)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.main'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .padding({ top: 5, bottom: 5 })
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .onClick(() => {
          DialogUtil.showConfirmDialog({
            title: this.appInfo.data.Announcement.title,
            message: this.appInfo.data.Announcement.message
          })
        })
    }
    .backgroundColor('#fff8b8b8')
  }

  @Builder Intro(title: string, action: () => void) {
    Row({ space: 5 }) {
      Text(title)
        .textStyle(18)
      Image($r('app.media.ic_public_arrow_right'))
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .fillColor($r('app.color.reverse'))
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(action)
  }
}

@Extend(Text) function textStyle(size: number) {
  .fontSize(size)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.reverse'))
  .padding({ left: 20 })
}