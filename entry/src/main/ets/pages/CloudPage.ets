import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/cards/SongCard'
import { ListHead } from '../components/head/ListHead'

import { LogUtil } from '@pura/harmony-utils'
import { getCloudList } from '../api/playListApi'
import { BottomBarComponent } from '../components/play/BottomBarComponent'
import { AddToPlayListButton } from '../components/buttons/play/AddToPlayListButton'
import { QuestionButton } from '../components/buttons/QuestionButton'
import Constants from '../common/constants/Constants'

/**
 * 云盘
 */

const TAG = '[CloudPage] '

@Entry
@Component
struct PlayListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

  @State list: Array<Song> = new Array()
  @State pageOpacity: number = 1

  @State hasMore: boolean = true
  @State hasLoaded: boolean = false
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false

  private currentOffset: number = 0
  hasAnimation:boolean | undefined = false

  async onPageShow(): Promise<void> {
    this.hasAnimation = AppStorage.get('set-hasAnimation')
    if (!this.hasLoaded) {
      await this.loadSongs(20, 0)
    }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return
    if (offset == 0) {
      this.isLoading = true
    } else {
      this.isLoadingMore = true
    }

    try {
      const result = await getCloudList(offset)
      this.list = [...this.list, ...result]
      this.currentOffset += limit
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', e)
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasLoaded = true
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Stack({ alignContent: Alignment.Top }) {
        if (this.isLoading) {
          Column() {
            LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }.height('100%').width('100%').justifyContent(FlexAlign.Center)
        } else {
          List() {
            ListItem().height( px2vp(this.topRectHeight) + 50 )
            ForEach(this.list, (item: Song, index) => {
              ListItem() {
                SongCard({ song: item, sid: index, hasAnimation: this.hasAnimation,
                  isPlayList: false, index: index })
              }
              .swipeAction({ end: this.SwipeItem(item) })
            })
            if (this.isLoadingMore) {
              ListItem() {
                Column() {
                  LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_CARD)
                }.justifyContent(FlexAlign.Center).width('100%').height(50)
              }
            } else if (this.hasMore) {
              ListItem() {
                Text("点击加载更多")
                  .onClick(() => {
                    this.loadSongs(30, this.currentOffset)
                  })
                  .padding({ top: 10, bottom: px2vp(this.bottomRectHeight) })
                  .fontColor($r('app.color.reverse'))
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
            } else if (!this.hasMore) {
              ListItem() {
                Text('没有更多了~').fontSize(Constants.FONT_SIZE_COMMON).textAlign(TextAlign.Center).width('100%').height(50);
              }
            }
            ListItem().height(px2vp(this.bottomRectHeight) + 80)
          }
          .height('100%')
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Auto)
        }
        ListHead({
          title: '音乐云盘',
          slot: this.HeadSlot
        })
      }
      .height('100%')

      BottomBarComponent()
        .padding({ left: 10, right: 10, bottom: px2vp(this.bottomRectHeight)})
        .backgroundColor(Color.Transparent)
    }
    .opacity(this.pageOpacity)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'));
  }

  @Builder
  HeadSlot() {
    QuestionButton({ title: '云盘', msg: '音乐云盘内歌曲仅支持单首播放、下载', comSize: Constants.SIZE_ICON_BUTTON_HEAD })
  }

  @Builder
  SwipeItem(song: Song) {
    AddToPlayListButton({ song: song })
  }
}