import { SongCard } from '../../components/cards/SongCard'
import { EmitterUtil, LogUtil } from '@pura/harmony-utils'
import { DailySongRes, PlayDailySongs } from '../../api/playListApi'
import { BottomBarComponent } from '../../components/play/BottomBarComponent'
import { getDailySongs } from '../../api/songApi'
import Constants from '../../common/constants/Constants'
import { StorageConstants } from '../../common/constants/StorageConstants'
import { PlayQueue } from '../../common/entities/local/PlayQueue'
import PlayQueueUtils from '../../common/utils/play/PlayQueueUtils'
import { playQueue } from '../../common/functions/play/playControl'
import { EmitterConstants } from '../../common/constants/EmitterConstants'
import { PlayList, playListItem } from '../../common/entities/playlist/PlayList'

/**
 * 每日推荐歌单页面
 */

const TAG = '[DailyListPage] '

@Component
export struct DailyListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @State list: DailySongRes[] = new Array()
  @State hasLoaded: boolean = false
  @State isLoading: boolean = true
  @State pageOpacity: number = 1
  @State totayDate: string = ''
  playListItem: PlayList = playListItem

  async aboutToAppear() {
    if(!this.hasLoaded) {
      await this.loadSongs()
      this.hasLoaded = true
    }

    EmitterUtil.unSubscribe(EmitterConstants.PLAY_PLAYLIST_SONGS)
    EmitterUtil.onSubscribe(EmitterConstants.PLAY_PLAYLIST_SONGS, ((index: number) => {
      this.playSong(index)
    }))
    let date = new Date()
    this.totayDate = `${date.toDateString()}`
    this.playListItem.id = 1
  }

  async loadSongs(): Promise<void> {
    this.isLoading = true
    try {
      let result: DailySongRes[] = await getDailySongs()
      if(result.length < 3) { result = await getDailySongs(false) }
      this.list = result
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', e)
    } finally {
      this.isLoading = false
    }
  }

  async playSong(songIndex: number) {
    try {
      let queue: PlayQueue[] = this.list.map((item): PlayQueue => ({
        playmode: 2,
        song: item.song,
        fileName: '',
        picUrl: item.picUrl
      }))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAdd_array(queue)
      playQueue(songIndex)
    } catch (e) {
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if (this.isLoading) {
            Column() {
              LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
            }.height('100%').width('100%').justifyContent(FlexAlign.Center)
          } else {
            // debug
            Stack({ alignContent: Alignment.Top}) {
              Column() {
                if(this.list.length < 3) {
                  Text('获取每日歌单失败').fontSize(Constants.FONT_SIZE_COMMON).textAlign(TextAlign.Center)
                }
              }
              .padding({ top: px2vp(this.topRectHeight) + 150, left: 20, right: 20 })

              List() {
                ListItem() {
                  this.Info()
                }
                ListItem() {
                  Button() {
                    Row({ space: 5 }) {
                      Image($r('app.media.ic_play_fill')).width(Constants.FONT_SIZE_COMMON).fillColor(Color.Gray)
                      Text('播放全部').fontSize(Constants.FONT_SIZE_COMMON)
                    }
                    .height(Constants.HEIGHT_TEXT_BUTTON)
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor(Color.Transparent)
                  .borderRadius(Constants.RADIUS_BUTTON)
                  .onClick(async () => {
                    this.playSong(0)
                  })
                }
                .padding({ left: 20, bottom: 10 })

                ForEach(this.list, (item: DailySongRes, index) => {
                  ListItem() {
                    SongCard({
                      playmode: 2,
                      song: item.song,
                      sid: index,
                      index: index,
                      reason: item.reason,
                      playlist: this.playListItem,
                      picUrl: item.picUrl ?? $r('app.media.ic_public_music')
                    })
                  }
                  .translate({ y: -40 })
                  .animation({
                    duration: 600,
                    curve: Curve.LinearOutSlowIn
                  })
                  .translate({ y: 0 })
                })

                ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
              }
              .height('100%')
              .layoutWeight(1)
              .width('100%')
              .scrollBar(BarState.Auto)
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .backToTop(true)
            }
            .height('100%')
            .layoutWeight(1)
            .width('100%')
          }
        }
        .height('100%')

        if(this.breakpoint !== 'lg') {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
      .opacity(this.pageOpacity)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .title('每日推荐')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  Info() {
    Column() {
      Text(this.totayDate)
        .fontWeight(FontWeight.Bold)
        .fontSize(18)
        .width('100%')
      Text('根据你的音乐口味生成，每天6:00更新')
        .fontSize(12)
        .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 20 })
  }
}