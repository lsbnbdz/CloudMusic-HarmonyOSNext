import { LazyData } from "@pie/lazy-data"
import { ToastUtil } from "@pura/harmony-utils"
import { getDjPrograms } from "../../api/djApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { DjRadioProgram } from "../../common/entities/dj/DjProgramResult"
import { djRadioItem } from "../../common/entities/dj/DjResult"
import { DjRadioParam } from "../../common/entities/local/PageParams"
import { djRadioToQueue } from "../../common/functions/play/djRadioOp"
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from "../../components/buttons/LoadMoreButtons"
import { SongCard } from "../../components/cards/SongCard"
import { BottomBarComponent } from "../../components/play/BottomBarComponent"

@Component
export struct DjRadioPage {
  param: DjRadioParam = { djRadio: djRadioItem }
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @State programs: DjRadioProgram[] = []
  @State dataSource: LazyData<DjRadioProgram> = new LazyData()
  @State songsOffset: number = 0
  @State translateY: number = 40
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State hasMore: boolean = false
  @Provide('playmode') playmode: number = 3

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    await this.loadSongs(0)
    this.isLoading = false
  }

  async loadSongs(offset: number) {
    let result = await getDjPrograms(this.param.djRadio.id, 50, offset)
    this.songsOffset += 50
    this.hasMore = result.more
    this.programs = [...this.programs, ...result.programs]
    this.dataSource.setData(this.programs)
    this.dataSource.notifyDataReload()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if(this.isLoading) {
          Column() {
            LoadingProgress()
              .width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        else {
          List() {
            ListItem()
              .height(px2vp(this.topRectHeight) + Constants.PADDING_EDGE_TEXT)
            ListItem() {
              Button() {
                Row({ space: 5 }) {
                  if (this.isPlayerLoading) {
                    LoadingProgress().height(35).padding({ left: 30 })
                  } else {
                    Image($r('app.media.ic_play_fill')).width(Constants.FONT_SIZE_COMMON).fillColor(Color.Gray)
                    Text(this.param.djRadio.programCount > 500 ? `播放前 500 首` : `播放全部 (${this.param.djRadio.programCount})`).fontSize(Constants.FONT_SIZE_COMMON)
                  }
                }
                .height(Constants.HEIGHT_TEXT_BUTTON)
              }
              .type(ButtonType.Normal)
              .backgroundColor(Color.Transparent)
              .borderRadius(15)
              .onClick(() => {
                if (this.isPlayerLoading) {
                  ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
                } else {
                  djRadioToQueue(this.param.djRadio.id, this.param.djRadio.programCount > 500 ? 500 : this.param.djRadio.programCount)
                }
              })
            }
            .padding({ left: 20 })
            LazyForEach(this.dataSource, (item: DjRadioProgram, index) => {
              SongCard({
                song: item.mainSong,
                picUrl: item.coverUrl,
                playmode: 3,
                sid: index,
                index: index,
                djRadio: item.radio
              })
                .translate({ y: this.translateY })
                .animation({
                  duration: 600,
                  curve: Curve.LinearOutSlowIn
                })
                .onAppear(() => { this.translateY = 0 })
            })

            if(this.hasMore) {
              if(this.isLoadingMore) {
                LoadingMoreButton()
              } else {
                ClickToLoadButton()
                  .onClick(async() => {
                    this.isLoadingMore = true
                    await this.loadSongs(this.songsOffset)
                    this.isLoadingMore = false
                  })
              }
            } else {
              NoMoreButton()
            }

            ListItem()
              .height(Constants.HEIGHT_MINI + px2vp(this.bottomRectHeight))
          }
          .width('100%')
          .height('100%')
          .backToTop(true)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }

        if(this.breakpoint !== 'lg') {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
    }
    .title(this.param.djRadio.name, { barStyle: BarStyle.STACK, backgroundColor: Color.Transparent, backgroundBlurStyle: BlurStyle.Regular })
    .backgroundColor($r('app.color.background'))
  }
}