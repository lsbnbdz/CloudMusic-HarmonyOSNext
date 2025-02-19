import { getPlayLists } from "../../api/playListApi"
import { PlayList, playListClass } from "../../common/entities/PlayList"
import { PlayListCard } from "../cards/PlayListCard"
import { DialogUtil, LogUtil, ToastUtil } from "@pura/harmony-utils";
import { RecommendCards, RecommendCards_Skeleton } from "../cards/RecommendCards";
import { Announcement } from "../../common/entities/Announcement";
import { router } from "@kit.ArkUI";
import { User, UserClass } from "../../common/entities/User";
import { StorageConstants } from "../../common/constants/StorageConstants";
import Constants from "../../common/constants/Constants";

@Component
export struct UserPlayLists {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('set-hasAnimation') hasAnimation: boolean = true
  @StorageProp('User') user: User = UserClass
  @StorageProp('Announcement') announcement: Announcement = {
    code: -1,
    data: { title:'', content: '' },
    visible: false
  }
  @Link isShowSearchButton: boolean
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  refreshCooldown: number = 5000
  @State playLists: Array<PlayList> = new Array()
  @StorageLink(StorageConstants.PLAYLIST_LIKE) likePlayList: PlayList = playListClass

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    try {
      const result = await getPlayLists(0)
      this.playLists = result.playlist
      this.likePlayList = this.playLists[0]
      this.playLists = this.playLists.slice(1)
      LogUtil.info('Get play lists: ' + JSON.stringify(this.playLists))
      setTimeout(() => {
        this.isLoading = false
      }, 100)
    } catch (e) {
      LogUtil.error('Error fetching playlists: ', e)
    }
  }

  build() {
    Column() {
      Refresh({ refreshing: this.isRefreshing}) {
        List({ space: 10 }) {
          if(this.announcement.visible) {
            ListItem() {
              this.Announcement()
            }
          }
          ListItem() {
            Search({
              placeholder: '搜索内容',
              icon: '/resources/base/media/ic_public_search_filled.svg',
            })
              .sharedTransition('search_component', {
                duration: 300,
                curve: Curve.Friction
              })
              .focusable(false)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/SearchPage'
                })
              })
              .layoutWeight(1)
          }
          .padding({ left: 20, right: 20 })

          ListItem() {
            Column({ space: 10 }) {
              Text(`发现`).textStyle(18)
              if(this.isLoading) {
                RecommendCards_Skeleton()
              } else {
                RecommendCards({ LikeList: this.likePlayList })
              }
            }
            .width('100%')
          }
          ListItem() {
            Column({ space: 10 }) {
              Text(`${this.user.data.profile.nickname} 的歌单`).textStyle(18)
              if(this.isLoading) {
                this.Loading(300)
              } else {
                ForEach(this.playLists, (item: PlayList) => {
                  ListItem() {
                    PlayListCard({
                      playList: item,
                      isShowHeart: item.creator.userId == this.user.data.account.id ? false : true
                    })
                  }
                })
              }
            }
            .width('100%')
          }.padding({ top: 20 })
          ListItem().height( px2vp(this.bottomRectHeight) + 120 )
        }
        .onScrollIndex((end) => {
          if(end < 1) { this.isShowSearchButton = false }
          else { this.isShowSearchButton = true }
        })
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Off)
      }
      .onRefreshing(async () => {
        await this.refreshContent()
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  itemLayout(playList: PlayList, index: number): void {
    PlayListCard({ playList: playList, hasAnimation: this.hasAnimation })
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

  private async refreshContent() {
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    if(currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    }
    else {
      try {
        const result = await getPlayLists(0)
        this.playLists = result.playlist
        this.likePlayList = this.playLists[0]
        this.playLists = this.playLists.slice(1)
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
      }
    }
    this.isRefreshing = false
  }
}

@Extend(Text) function textStyle(size: number) {
  .width('100%')
  .fontSize(size)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.reverse'))
  .padding({ left: 20, right: 20 })
}