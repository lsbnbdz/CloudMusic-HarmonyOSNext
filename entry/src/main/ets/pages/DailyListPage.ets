import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/main/SongCard'
import { ListHead } from '../components/head/ListHead'
import { SpinKit, SpinType } from '@pura/spinkit'
import { LogUtil, ToastUtil } from '@pura/harmony-utils'
import { DailySongRes, getDailySongs, PlayDailySongs } from '../api/playListApi'
import { BottomPlayController } from '../components/play/BottomPlayController'
import { CommonCircleButton } from '../components/buttons/CircleButton'
import Constants from '../common/constants/Constants'
import { playQueue } from '../common/functions/playerControl'
import { AddToPlayListButton } from '../components/buttons/AddToPlayListButton'

/**
 * 每日推荐歌单页面
 */

const TAG = '[DailyListPage] '

@Entry
@Component
struct DailyListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0

  @State list: Array<DailySongRes> = new Array()
  @State isLoading: boolean = true
  @State loadingPlayList:boolean = false
  @State pageOpacity: number = 1
  hasAnimation:boolean | undefined = false

  async onPageShow(): Promise<void> {
    this.hasAnimation = AppStorage.get('set-hasAnimation')
    await this.loadSongs()
  }

  async loadSongs(): Promise<void> {
    this.isLoading = true
    try {
      const result:Array<DailySongRes> = await getDailySongs()
      this.list = result
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching songs: ', e)
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Stack({ alignContent: Alignment.Top }) {
        if (this.isLoading) {
          Column() {
            SpinKit({ spinType: SpinType.spinO, spinSize: 60, spinColor: Color.Gray }).width(60)
          }.height('100%').width('100%').justifyContent(FlexAlign.Center)
        } else {
          List() {
            ListItem().height( px2vp(this.topRectHeight) + 50 )
            ListItem() {
              Button() {
                Row({ space: 5 }) {
                  Image($r('app.media.ic_play_fill')).width(15).fillColor(Color.Gray)
                  Text('播放全部').fontSize(15)
                }
              }
              .type(ButtonType.Normal)
              .backgroundColor(Color.Transparent)
              .borderRadius(15)
              .onClick(async () => {
                this.loadingPlayList = true
                await PlayDailySongs()
                this.loadingPlayList = false
                playQueue(0)
              })
            }
            .padding({ left: 20, bottom: 10 })

            ForEach(this.list, (item: DailySongRes, index) => {
              ListItem() {
                SongCard({ song: item.song, sid: index, hasAnimation: this.hasAnimation,
                  isPlayList: true, index: index, reason: item.reason })
              }
              .swipeAction({ end: this.SwipeItem(item.song) })
            });
            ListItem().height(px2vp(this.bottomRectHeight) + 80)
          }
          .height('100%')
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Auto)
        }
        ListHead({
          title: '每日推荐',
          slot: this.HeadSlot
        })
      }
      .height('100%')

      BottomPlayController()
        .padding({ left: 10, right: 10, bottom: px2vp(this.bottomRectHeight)})
        .backgroundColor(Color.Transparent)

      if(this.loadingPlayList) {
        Column() {
          Column({ space: 10 }) {
            LoadingProgress().width(60)
            Text('正在获取完整歌曲列表')
          }
          .padding(30)
          .borderRadius(15)
          .backgroundColor($r('app.color.main'))
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: px2vp(this.topRectHeight) })
      }
    }
    .opacity(this.pageOpacity)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'));
  }

  @Builder
  HeadSlot() {
    CommonCircleButton({ ButtonImageName: 'ic_public_more_filled' })
      .onClick(() => {
        ToastUtil.showToast(Constants.DEVELOPING_MSG)
      })
  }

  @Builder SwipeItem(song: Song) {
    Row({ space: 10 }) {
      AddToPlayListButton({ song: song })
    }
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}