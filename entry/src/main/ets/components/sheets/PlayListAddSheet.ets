import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { getPlayLists, PlayListOperation } from "../../api/playListApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayList } from "../../common/entities/PlayList"
import { Song } from "../../common/entities/SongsResult"
import { User, UserClass } from "../../common/entities/User"
import { PlayQueueButton } from "../buttons/play/PlayQueueButton"
import { PlayListCard } from "../cards/PlayListCard"

/**
 * 添加至歌单Sheet
 */
const TAG = '[PlayListAddSheet] '

@Component
export struct PlayListAddSheet {
  @StorageProp('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.USER) user: User = UserClass
  @StorageLink(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @State songId: number = -1
  @Link isShow: boolean
  private refreshCooldown: number = 5000

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    try {
      if(this.playLists.length == 0) {
        const result = await getPlayLists(0)
        this.playLists = result.playlist
      }
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching playlists: ', e)
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column({ space: 10 }) {
      Text('添加到歌单')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
      if(this.isLoading) {
        Column() {
          LoadingProgress().width(40)
        }
        .width('100%')
      }
      else {
        Refresh({ refreshing: this.isRefreshing }) {
          List() {
            ForEach(this.playLists, (item: PlayList, index) => {
              if (item.userId == this.user.data.profile.userId) {
                ListItem() {
                  Button() {
                    Row({ space: 15 }) {
                      Image(`${item.coverImgUrl}?param=256y256`).width(40).borderRadius(15)
                      Column({ space: 8 }) {
                        Text(item.name)
                          .fontSize(Constants.FONT_SIZE_COMMON)
                          .fontWeight(FontWeight.Medium)
                          .textAlign(TextAlign.Start)
                          .width('100%')
                        Text(`${item.trackCount} 首歌曲`)
                          .fontSize(12)
                          .textAlign(TextAlign.Start)
                          .width('100%')
                      }
                      .layoutWeight(1)
                    }
                    .width('100%')
                  }
                  .backgroundColor(Color.Transparent)
                  .borderRadius(5)
                  .type(ButtonType.Normal)
                  .width('100%')
                  .height(60)
                  .onClick(async () => {
                    try {
                      const result = await PlayListOperation('add', item.id, this.songId)
                      if (result) ToastUtil.showToast('成功添加到歌单')
                      this.isShow = false
                    } catch (e) {
                      LogUtil.error(TAG + 'Add to PlayList Error: ' + e)
                      ToastUtil.showToast(e.message)
                    }
                  })
                }
                .padding({ left: 15, right: 15 })
              }
            })
            ListItem().height(px2vp(this.bottomRectHeight))
          }
          .layoutWeight(1)
          .width('100%')
        }
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRefreshing(async () => {
          await this.handleRefresh()
        })
      }
    }
    .padding({ top:15 })
    .width('100%')
  }

  private async handleRefresh() {
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    } else {
      try {
        await getPlayLists(0)
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
      }
    }
    this.isRefreshing = false
  }
}