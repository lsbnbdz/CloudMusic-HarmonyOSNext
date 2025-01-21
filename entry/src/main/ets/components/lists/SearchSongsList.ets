import { EmitterUtil, LogUtil } from "@pura/harmony-utils"
import { SpinKit, SpinType } from "@pura/spinkit"
import { searchSongs } from "../../api/songApi"
import Constants from "../../common/constants/Constants"
import { Song } from "../../common/entities/SongsResult"
import { AddToPlayListButton } from "../buttons/AddToPlayListButton"
import { SongCard } from "../cards/SongCard"

/**
 * 搜索结果——单曲列表
 */
const TAG = "[SearchSongsList] "

@Component
export struct SearchSongsList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('set-hasAnimation') hasAnimation: boolean = true
  @Prop searchKeyword: string = ''
  @State songList: Array<Song> = []
  @State songOffset: number = 0
  @State hasMoreSongs: boolean = true
  @State hasSongLoaded: boolean = false
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false

  async aboutToAppear(): Promise<void> {
    if(this.searchKeyword) {
      await this.loadSongs(0)
    }
    EmitterUtil.onSubscribe(Constants.EMITTER_SEARCH, async (keyword: string) => {
      this.searchKeyword = keyword
      this.songList = []
      this.songOffset = 0
      await this.loadSongs(0)
    })
  }

  aboutToDisappear(): void {
    EmitterUtil.unSubscribe(Constants.EMITTER_SEARCH)
  }

  build() {
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
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height(50)
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

  @Builder SwipeItem(song: Song) {
    Row({ space: 10 }) {
      AddToPlayListButton({ song: song })
    }
    .height('100%')
    .backgroundColor(Color.Transparent)
  }

  async loadSongs(offset: number): Promise<void> {
    if (!this.hasMoreSongs) return // 没有更多歌曲直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    } else {
      this.isLoadingMore = true // 加载更多
    }
    try {
      const result = await searchSongs(this.searchKeyword, offset)
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
}