import { Song } from '../common/entities/SongsResult'
import { SongCard } from '../components/cards/SongCard'
import { ListHead } from '../components/head/ListHead'

import { LogUtil } from '@pura/harmony-utils'
import { DailySongRes, PlayDailySongs } from '../api/playListApi'
import { BottomBarComponent } from '../components/play/BottomBarComponent'
import { CommonCircleButton } from '../components/buttons/CircleButton'
import { playQueue } from '../common/functions/play/playControl'
import { AddToPlayListButton } from '../components/buttons/play/AddToPlayListButton'
import { getDailySongs } from '../api/songApi'
import { promptAction } from '@kit.ArkUI'
import { MsgConstants } from '../common/constants/MsgConstants'
import Constants from '../common/constants/Constants'

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
  @State hasLoaded: boolean = false
  @State isLoading: boolean = true
  @State loadingPlayList:boolean = false
  @State pageOpacity: number = 1
  @State totayDate: string = ''
  hasAnimation:boolean | undefined = false

  async onPageShow(): Promise<void> {
    if(!this.hasLoaded) {
      this.hasAnimation = AppStorage.get('set-hasAnimation')
      await this.loadSongs()
      this.hasLoaded = true
    }
    let date = new Date()
    this.totayDate = `${date.toDateString()}`
  }

  async loadSongs(): Promise<void> {
    this.isLoading = true
    try {
      let result:Array<DailySongRes> = await getDailySongs()
      if(result.length < 3) { result = await getDailySongs(false) }
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
            LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }.height('100%').width('100%').justifyContent(FlexAlign.Center)
        } else {
          // debug
          Stack({ alignContent: Alignment.Top}) {
            Column() {
            if(this.list.length < 3) {
              Text('当前环境无法获取每日推荐歌单。').fontSize(Constants.FONT_SIZE_COMMON).textAlign(TextAlign.Center)
            }
            }
            .padding({ top: px2vp(this.topRectHeight) + 150, left: 20, right: 20 })

            List() {
              ListItem().height(px2vp(this.topRectHeight) + 50)
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
                  this.loadingPlayList = true
                  await PlayDailySongs()
                  this.loadingPlayList = false
                  playQueue(0)
                })
              }
              .padding({ left: 20, bottom: 10 })

              ForEach(this.list, (item: DailySongRes, index) => {
                ListItem() {
                  SongCard({
                    song: item.song,
                    sid: index,
                    hasAnimation: this.hasAnimation,
                    isPlayList: false,
                    index: index,
                    reason: item.reason
                  })
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
          .height('100%')
          .layoutWeight(1)
          .width('100%')
        }
        ListHead({
          title: '每日推荐',
          slot: this.HeadSlot
        })
      }
      .height('100%')

      BottomBarComponent()
        .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight)})
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

  @Builder
  HeadSlot() {
    CommonCircleButton({ ButtonImageName: 'ic_public_more_filled', wid: Constants.SIZE_ICON_BUTTON_HEAD })
      .onClick(() => {
        promptAction.showToast({ message: MsgConstants.DEVELOPING, duration: 3000 })
      })
  }

  @Builder SwipeItem(song: Song) {
    AddToPlayListButton({ song: song })
  }

}