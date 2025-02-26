import { DialogUtil, LogUtil, ToastUtil} from "@pura/harmony-utils";
import { RecommendCards, RecommendCards_NotLogged, RecommendCards_Skeleton } from "../cards/RecommendCards";
import { Announcement } from "../../common/entities/Announcement";
import { User, UserClass } from "../../common/entities/User";
import Constants from "../../common/constants/Constants";
import { TopListItem } from "../../common/entities/TopList";
import { getTopList } from "../../api/topListApi";
import { TopListItemCard } from "../cards/TopListItemCard";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { PlayList } from "../../common/entities/PlayList";
import { getPlayLists } from "../../api/playListApi";

@Component
export struct Explore {
  @StorageLink('UserPlayLists') playLists: Array<PlayList> = []
  @StorageLink('topList') topList: Array<TopListItem> = []
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getPlayLists') isLogged: boolean = false
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageProp('Announcement') announcement: Announcement = {
    code: -1,
    data: { title:'', content: '' },
    visible: false
  }
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State columnsTemplate: string = '1fr'
  @Consume('pageInfos') pageInfos: NavPathStack

  async aboutToAppear(): Promise<void> {
    if (this.topList.length == 0) {
      this.isLoading = true
      try {
        const toplist = await getTopList()
        this.topList = toplist
        this.isLoading = false
        await this.getPlayLists()
      } catch (e) {
        LogUtil.error('Error fetching playlists: ', e)
      } finally {
        this.isLoading = false
      }
    }
  }

  async getPlayLists() {
    if(this.isLogged && this.user && this.playLists.length == 0) {
      try {
        const playlist = await getPlayLists(0)
        this.playLists = playlist.playlist
      } catch (e) {
        ToastUtil.showToast('获取歌单列表失败')
        LogUtil.error('Error fetching playlists: ', e.message)
      }
    }
  }

  build() {
    Column() {
      Column({ space: 5 }) {
        if(this.announcement.visible) {
          this.Announcement()
        }
        Grid() {
          GridItem() {
            Search({
              placeholder: '搜索内容',
              icon: '/resources/base/media/ic_public_search_filled.svg',
            })
              .focusable(false)
              .onClick(() => {
                this.pageInfos.clear()
                this.pageInfos.pushPathByName('SearchPage', null, true)
              })
              .layoutWeight(1)
          }
          .columnStart(0)
          .columnEnd(1)
          .padding({ left: 20, right: 20 })

          GridItem() {
            Column({ space: 10 }) {
              if(this.isLoading) {
                RecommendCards_Skeleton()
              } else {
                if(this.isLogged && this.user) {
                  RecommendCards()
                }
                else { RecommendCards_NotLogged() }
              }
            }
            .width('100%')
          }
          .columnStart(0)
          .columnEnd(1)

          GridItem() {
            Text(`排行榜`).textStyle(18)
          }
          .columnStart(0)
          .columnEnd(1)
          .padding({ top: 20 })

          if(this.isLoading) {
            GridItem() {
              this.Loading(300)
            }
            .columnStart(0)
            .columnEnd(1)
          } else {
            GridItem() {
              GridRow({ columns: { xs: 2, sm: 3, md: 2, lg: 3, xl: 3 } }) {
                ForEach(this.topList, (item: TopListItem) => {
                  GridCol() {
                    TopListItemCard({ topListItem: item }).padding(Constants.PADDING_EDGE_DEFAULT)
                  }
                })
              }
            }
            .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
            .width('100%')
          }

          GridItem()
            .height( px2vp(this.bottomRectHeight) + 80 )
            .columnStart(0)
            .columnEnd(1)
        }
        .height('100%')
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.On)
        .rowsGap(15)
        .columnsTemplate(this.columnsTemplate)
        .layoutDirection(GridDirection.Column)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
    }
    .width('100%')
    .height('100%')
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
      Text(this.announcement.data.content)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.main'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .padding({ top: 5, bottom: 5 })
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .onClick(() => {
          DialogUtil.showConfirmDialog({
            title: this.announcement.data.title,
            message: this.announcement.data.content
          })
        })
    }
    .backgroundColor('#fff8b8b8')
  }
}

@Extend(Text) function textStyle(size: number) {
  .width('100%')
  .fontSize(size)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.reverse'))
  .padding({ left: 20, right: 20 })
}